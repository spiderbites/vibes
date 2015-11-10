class WatsonTwitterParser
  include WatsonTwitterApiHelper
  attr_accessor :meta_data

  def initialize(unrefined_data, order_by, slices)
    @unrefined_data = sort(unrefined_data)
    @order_by = order_by
    @data = method(('order_by_' + @order_by.to_s).to_sym).call()
    @slice_tracker = SliceTracker.new(slices, @data.keys)

    set_meta_data
    parse
  end

  def sort(data)
    data['tweets'].sort! {|x,y| a = (x['message']['postedTime'] rescue '999999999999999999999999'); b = (y['message']['postedTime'] rescue '999999999999999999999999'); b <=> a}
    data
  end

  def extract(unit)
    e = unit
    gender = (e['cde']['author']['gender'] rescue "non_existent_key_gender").to_s
    sentiment = (e['cde']['content']['sentiment']['polarity'] rescue "non_existent_key_sentiment").to_s

    {
      gender: (gender == "" ? "non_existent_key_gender" : gender),
      location1: (e['cde']['author']['location'] rescue nil),
      location2: (e['message']['actor']['location'] rescue nil),
      location3: (e['message']['object']['actor']['loaction'] rescue nil),
      geo: (e['message']['gnip']['profileLocations'][0]['geo']['coordinates'] rescue nil),
      parentHood: (e['cde']['author']['isParent'] rescue nil),
      maritalStatus: (e['cde']['author']['isMarried'] rescue nil),
      sentiment: (sentiment == "" ? "non_existent_key_sentiment" : sentiment),
      time: (e['message']['postedTime'] rescue nil),
      link: (e['message']['link'] rescue nil),
      text: (e['message']['body'] rescue nil),
      username: (e['message']['actor']['preferredUsername'] rescue nil),
      retweets: (e['message']['retweetCount'] rescue nil),
      favoritesCount: (e['message']['favoritesCount'] rescue nil),
      hashTags: (e['message']['twitter_entities']['hastags'] rescue nil),
      userMentions: (e['message']['twitter_entities']['userMentions'] rescue nil),
      symbols: (e['message']['twitter_entities']['symbols'] rescue nil),
      twitterLanguage: (e['message']['twitter_entities']['twitter_lang'] rescue nil)
    }
  end

  def set_meta_data
    @meta_data = {
      next: @unrefined_data['related']['next']['href'].split('?q=')[1],
      quantity: @unrefined_data['search']['results'].to_i,
      from: @unrefined_data['related']['next']['href'].split('&')
              .select { |href_portion| href_portion.include?('from=') }[0]
              .split('=')[1]
              .to_i
    }
  end

  def add(ordering, data)
    if @slice_tracker.send(ordering) == 0
      @data[ordering] << [data]
    else
      @data[ordering].last << data
    end
  end

  def parse
    @unrefined_data['tweets'].map do |e|
      data = extract(e)
      ordering = data[@order_by].downcase.to_sym
      add(ordering, data)
    end
  end

  def refined_data
    @data
  end
end