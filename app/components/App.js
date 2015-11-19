var React = require('react');
var PrimaryPane = require('./PrimaryPane');
var SidePane = require('./SidePane');
var $ = require('jquery');

var App = React.createClass({

  API_IMMEDIATE: "https://vibesapi.herokuapp.com/immediate/search",
  API_CACHED: "https://vibesapi.herokuapp.com/cached/search",
  API_GRADUAL: "https://vibesapi.herokuapp.com/gradual/search",
  DEFAULT_CHART_LABELS: ["12am", "2am", "4am", "6am", "8am", "10am", "12pm", "2pm", "4pm", "6pm", "8pm", "10pm"],

  // for live polling -- grab every 60 seconds 
  LIVE: {INTERVAL: 60000, STATS: "by_minutes:1", TIMEUNIT: "minutes", TIMELENGTH: "1"},

  getInitialState: function() {
    return { sideshow: '', mapData: {new: [], old: []}, tweetData: [], tweetsToShow: [], q: "", done: true, posActive: "", negActive: "", liveInterval: null, numTweets: 0};
  },

  handleQuerySubmit: function(params) {

    // when a user submits a new query, remove all the data in the browser
    this.setState(
      {
        mapData: {new: [], old: []}, 
        tweetData: [], 
        tweetsToShow: [], 
        chartData: {time_labels: this.DEFAULT_CHART_LABELS, stats: {positive:[], negative:[], neutral:[] }},
        numTweets: 0,
        negActive: "",
        posActive: ""
      }
    );

    if (params.search_type === "live") {
      params = {q: params.q, minutes: this.LIVE.TIMELENGTH, stats: this.LIVE.STATS};
      var intvl = setInterval(this.loadDataLive.bind(this, params), this.LIVE.INTERVAL);
      this.setState({liveInterval: intvl});

      // bootstrap the live polling with the the last 30 mins of data
      this.loadDataFromServer({q: params.q, minutes:"30", stats:"by_minutes:1"}, 0);
      return;
    }

    this.setState({done: false});

    // SEARCH BY DAY: currently allow search for 1 to 30 days
    // -------------------------------------------------------
    // if searching by days, we chunk results by day...


    // SEARCH BY HOUR: currently allow search for 1 to 48 hours
    // -------------------------------------------------------
    // if 1 hr, want results chunked by 2 mins    -> stats=by_minutes:2  (30 chunks)
    // if 2 hrs, want results chunked by 4 mins   -> stats=by_minutes:4  (30 chunks)
    // ...
    // if 48 hrs, want results chunked by 96 mins -> stats=by_minutes:96 (30 chunks)
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
      params["stats"] = "by_days:1";
    }
    // this.loadDataFromServer(params, 0); //<-- old data load entry point
    this.loadDataGradual(params);
  },

  loadDataLive: function(params) {
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

  handleStopLive: function() {
    clearInterval(this.state.liveInterval);
    this.setState({liveInterval:null});
  },

  loadDataGradual: function(params) {
    $.ajax({
      url: this.API_GRADUAL,
      data: params,
      dataType: 'json',
      success: function(data) {
        this.loadDataCached(params, data.meta_data.total, 0, 0);
      }.bind(this),
      error: function(xhr, status, err) {
        this.setState({done: true});
        console.error(params, status, err.toString());
      }.bind(this)
    });
  },

  loadDataCached: function(params, api_total, prev_cached_total, no_progress) {
    $.ajax({
      url: this.API_CACHED,
      data: params,
      dataType: 'json',
      success: function(data) {

        // update the no_progress counter
        if (prev_cached_total === data.meta_data.total)
          no_progress += 1
        else
          no_progress = 0

        // if we haven't received at least api_total results, we need to make the recursive call
        if (data.meta_data.total < api_total && no_progress < 5) {
          console.log("CACHE TOTAL / API_TOTAL: " + data.meta_data.total, api_total)
          // only update data if we received more on this call
          if (prev_cached_total < data.meta_data.total) {
            this.setState({numTweets: data.meta_data.total});
            this.newUpdateData(data.data, params.q);
          }
          this.loadDataCached(params, api_total, data.meta_data.total, no_progress);
        }
        else {
          this.setState({done: true, numTweets: data.meta_data.total});
          this.newUpdateData(data.data, params.q);
        }
      }.bind(this),
      error: function(xhr, status, err) {
        this.setState({done: true});
        console.error(params, status, err.toString());
      }.bind(this)
    })
  },

  loadDataFromServer: function(params, num_loads) {
    $.ajax({
      url: this.API_IMMEDIATE,
      data: params,
      dataType: 'json',
      success: function(data) {

        var MAX_LOADS = 10;

        if (params.from == undefined) { var isNextPage = false; }
        else { var isNextPage = true; }

        // update data with received
        this.updateData(data.data, params.q, isNextPage);

        // Watson restricts us to 500 results at a time
        // check if there is more and run again until we've got it all for the time period requested
        if (data.meta_data.total !== data.meta_data.next_from && num_loads < MAX_LOADS) {
          params.from = data.meta_data.next_from;
          this.loadDataFromServer(params, num_loads + 1);
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
      numTweets: data.tweets.length,
      mapData: {new: data.map, old: (this.state.mapData.new).concat(this.state.mapData.old)},
      tweetData: (this.state.tweetData).concat(data.tweets),
      tweetsToShow: (this.state.tweetData).concat(data.tweets),
      chartData: {stats: {negative: new_negative, neutral:new_neutral, positive:new_positive}, time_labels: new_time_labels}
    });

  },

  newUpdateData: function(data, q) {
    this.setState({
      mapData: {new: data.map, old: []},
      tweetData: data.tweets,
      tweetsToShow: data.tweets,
      chartData: {stats: {negative: data.negative, neutral:data.neutral, positive:data.positive}, time_labels: data.timings},
      q: q
    });
  },

  updateData: function(data, q, isNextPage) {
    // This is a repeat query
    
    if (this.state.q === q) {


      /* Begin chart updating stuff...
       * This gets tricky because on recurring calls we get variable sized arrays, with some endpoints being left off.
       * Accommodating for the cases below
       */
      if (isNextPage) {
        
        var mx = Math.max(data.timings.length, this.state.chartData.time_labels.length);

        var new_positive = Array.apply(null, Array(mx)).map(Number.prototype.valueOf,0);
        var new_negative = Array.apply(null, Array(mx)).map(Number.prototype.valueOf,0);
        var new_neutral = Array.apply(null, Array(mx)).map(Number.prototype.valueOf,0);
        
        for (var i = 0; i < mx; i++) {
          if (data.timings[i] !== undefined) {
            new_positive[i] += data.positive[i]
            new_negative[i] += data.negative[i]
            new_neutral[i] += data.neutral[i]
          }
          if (this.state.chartData.stats.positive[i] !== undefined) {
            new_positive[i] += this.state.chartData.stats.positive[i];
            new_negative[i] += this.state.chartData.stats.negative[i];
            new_neutral[i] += this.state.chartData.stats.neutral[i];            
          }
        }
        var times_to_use = data.timings.length >= this.state.chartData.time_labels.length ? data.timings : this.state.chartData.time_labels
        this.setState({
          chartData: {stats: {negative: new_negative, positive: new_positive, neutral: new_neutral}, time_labels: times_to_use}
        })
      }
      else {
        this.setState({
          chartData: {stats: {negative: data.negative, neutral:data.neutral, positive:data.positive}, time_labels: data.timings}
        });
      }
      /* End charting updating stuff */

      /* Updating everything else is simple, just concat */
      this.setState({
        numTweets: this.state.tweetData.length + data.tweets.length,
        mapData: {new: data.map, old: (this.state.mapData.new).concat(this.state.mapData.old)},
        tweetData: (this.state.tweetData).concat(data.tweets),
        tweetsToShow: (this.state.tweetData).concat(data.tweets)
      });
    }

    // This is a new query
    else {
      this.setState({
        mapData: {new: data.map, old: []},
        numTweets: data.tweets.length,
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
                     done={this.state.done}
                     numTweets={this.state.numTweets}
                     onStopLive={this.handleStopLive} />

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