var React = require('react');
var PrimaryPane = require('./PrimaryPane');
var SidePane = require('./SidePane');
var $ = require('jquery');

var App = React.createClass({

  API_IMMEDIATE: "https://vibesapi.herokuapp.com/immediate/search",
  API_CACHED: "https://vibesapi.herokuapp.com/cached/search",
  API_GRADUAL: "https://vibesapi.herokuapp.com/gradual/search",

  // for live polling -- grab every 30 seconds 
  LIVE: {INTERVAL: 60000, STATS: "by_minutes:1", TIMEUNIT: "minutes", TIMELENGTH: "1"},

  getInitialState: function() {
    return { sideshow: '', mapData: {new: [], old: []}, tweetData: [], tweetsToShow: [], q: "", done: true, posActive: "", negActive: ""};
  },

  handleQuerySubmit: function(params) {

    if (params.search_type === "live") {
      params = {q: params.q, minutes: this.LIVE.TIMELENGTH, stats: this.LIVE.STATS};
      setInterval(this.loadDataLive.bind(this, params), this.LIVE.INTERVAL);

      // bootstrap the live polling with the the last 30 mins of data
      this.loadDataFromServer({q: params.q, minutes:"30", stats:"by_minutes:1"});
      return;
    }

    this.setState({done: false});

    // SEARCH BY DAY: currently allow search for 1 to 30 days
    // -------------------------------------------------------
    // if 1 day, want results chunked by hour       -> stats=by_hours:1  (24 chunks)
    // if 2 days, want results chunked by 2 hours   -> stats=by_hours:2  (24 chunks)
    // ...
    // if 30 days, want results chunked by 30 hours -> stats=by_hours:30 (24 chunks)
    // =====
    // in other words, "stats=by_hours:?" = day


    // SEARCH BY HOUR: currently allow search for 1 to 48 hours
    // -------------------------------------------------------
    // if 1 hr, want results chunked by 2 mins    -> stats=by_minutes:2  (30 chunks)
    // if 2 hrs, want results chunked by 4 mins   -> stats=by_minutes:4  (30 chunks)
    // ...
    // if 48 hrs, want results chunked by 96 mins -> stats=by_minutes: (30 chunks)
    // =====
    // in other words, "stats=by_minutes:?" = 2*hours


    // default to one hour or one day if no time specified
    if (params["hours"] === "")
      params["hours"] = "1";
    else if (params["days"] === "")
      params["days"] = "1";

    // set stats_by
    if (params["hours"] !== undefined) {
      params["stats"] = "by_minutes:" + (2 * params["hours"]);
    }
    else {
      params["stats"] = "by_hours:" + (params["days"]);
    }
    this.loadDataFromServer(params);
  },

  loadDataLive: function(params) {
    console.log("POLLING");
    $.ajax({
      url: this.API_IMMEDIATE,
      data: params,
      dataType: 'json',
      success: function(data) {

        this.updateLive(data.data);
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(params, status, err.toString());
      }.bind(this)
    });
  },

  loadDataFromServer: function(params) {
    $.ajax({
      url: this.API_IMMEDIATE,
      data: params,
      dataType: 'json',
      success: function(data) {
        if (params.from == undefined) { var isNextPage = false; }
        else { var isNextPage = true; }

        // update data with received
        this.updateData(data.data, params.q, isNextPage);

        // Watson restricts us to 500 results at a time
        // check if there is more and run again until we've got it all for the time period requested
        if (data.meta_data.total !== data.meta_data.next_from) {
          params.from = data.meta_data.next_from;
          this.loadDataFromServer(params);
        }
        else {
          this.setState({done: true});
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(params, status, err.toString());
      }.bind(this)
    });
  },

  updateLive: function(data) {

    // remove the first data point and add the next one
    var new_time_labels = this.state.chartData.time_labels.slice(1).concat(data.timings)
    var new_positive = this.state.chartData.stats.positive.slice(1).concat(data.positive)
    var new_negative = this.state.chartData.stats.negative.slice(1).concat(data.negative)
    var new_neutral = this.state.chartData.stats.neutral.slice(1).concat(data.neutral)

    this.setState({
      mapData: {new: data.map, old: (this.state.mapData.new).concat(this.state.mapData.old)},
      tweetData: (this.state.tweetData).concat(data.tweets),
      tweetsToShow: (this.state.tweetData).concat(data.tweets),
      chartData: {stats: {negative: new_negative, neutral:new_neutral, positive:new_positive}, time_labels: new_time_labels}
    });

  },

  updateData: function(data, q, isNextPage) {
    // This is a repeat query
    
    if (this.state.q === q) {
      if (isNextPage) {
        for (var i = 0; i < data.timings.length; i++) {
          data.positive[i] += this.state.chartData.stats.positive[i];
          data.neutral[i] += this.state.chartData.stats.neutral[i];
          data.negative[i] += this.state.chartData.stats.negative[i];
        }
      }

      this.setState({
        mapData: {new: data.map, old: (this.state.mapData.new).concat(this.state.mapData.old)},
        tweetData: (this.state.tweetData).concat(data.tweets),
        tweetsToShow: (this.state.tweetData).concat(data.tweets),
        chartData: {stats: {negative: data.negative, neutral:data.neutral, positive:data.positive}, time_labels: data.timings}
      });
    }

    // This is a new query
    else {
      this.setState({
        mapData: {new: data.map, old: []},
        tweetData: data.tweets,
        tweetsToShow: data.tweets,
        chartData: {stats: {negative: data.negative, neutral:data.neutral, positive:data.positive}, time_labels: data.timings},
        q: q
      });
    }
  },

  filterTweets: function(sentiment) {
    
    // ughhh this
    if (sentiment === "positive")
      this.setState({posActive: (this.state.posActive === '' ? 'active' : ''), negActive: ''});
    else if (sentiment === "negative")
      this.setState({negActive: (this.state.negActive === '' ? 'active' : ''), posActive: ''});
    else // (sentiment === null)
      this.setState({negActive: '', posActive: ''})

    if (this.state.tweetData.length !== 0) {
      if (sentiment === null) // show all tweets
        this.setState({tweetsToShow: this.state.tweetData});
      else {
        var filteredTweets = this.state.tweetData.filter(function(e) {return e.sentiment === sentiment});
        this.setState({tweetsToShow: filteredTweets})
      }
    }
  },

  handleSideshow: function() {
    this.setState({sideshow: this.state.sideshow === '' ? 'sideshow' : ''}, function() {
      var count = 0;

      var interval = setInterval(function() {
        window.dispatchEvent(new Event('resize'));
        count++;
        if (count == 10) { clearInterval(interval); }
      }, 100);
    });
  },

  render: function() {
    return (
      <div>
        <PrimaryPane mapData={this.state.mapData}
                     chartData={this.state.chartData}
                     onQuerySubmit={this.handleQuerySubmit}
                     className={this.state.sideshow}
                     currentQuery={this.state.q}
                     done={this.state.done} />

        <SidePane className={this.state.sideshow}
                  clicktabClick={this.handleSideshow}
                  tweetData={this.state.tweetsToShow}
                  filterTweets={this.filterTweets}
                  posActive={this.state.posActive}
                  negActive={this.state.negActive}/>
      </div>
    )
  }  
});

module.exports = App;