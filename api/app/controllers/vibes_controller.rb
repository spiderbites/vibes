class VibesController < ApplicationController
  include VibesHelper
  include ParameterSanity

  protect_from_forgery
  after_filter :cors_set_access_control_headers

  def index
    render json: nil
  end

  def search
    parameters = convert_string_hash_to_sym_hash(check_params)
    parameters[:epoch] = Time.now.to_i
    parameters[:order_by] = 'sentiment'
    # changes = determine_changes(get_prev_params, parameters)

    if sanity_check_passed?(parameters)
      render json: process_search(parameters, {})
    else
      render json: handle_jsonp({ errors: sanity_violations(parameters), params: params })
    end
  end

  def results
    puts params
    unit = {
      type: params[:type].to_sym,
      quantity: params[:quantity].to_i
    }
    result = Tweet.statistics(unit)
    render json: result
  end

  private
    def get_prev_params
      cookies[:vibes].nil? ? {} : convert_string_hash_to_sym_hash(JSON.parse(cookies[:vibes]))
    end

    def check_params
      params.permit(:q, :seconds, :minutes, :hours, :days, :weeks, :months,
                    :years, :range, :order_by, :locations, :gender,
                    :sentiment, :by_chunks_of, :in_slices_of, :from)
    end

    def handle_jsonp(data)
      cb = params['callback']
      if cb
        cb + '(' + data.to_json + ');'
      else
        data
      end
    end

    def process_search(parameters, changes)
      batches = []
      meta = nil
      next_url = ''
      # while (!meta || (meta[:from] < meta[:quantity])) do
        Resque.enqueue(Background, parameters, next_url)
        # Resque.enqueue(WatsonTwitterApi, *[parameters, next_url])
        # binding.pry
      # end
      # save_to_db(WatsonTwitterApi.batches)
      # handle_jsonp(WatsonTwitterApi.batches)
      []
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      headers['Access-Control-Allow-Credentials'] = 'true'
    end

    def aggregate(aggregation)
      Tweet.all
    end
end