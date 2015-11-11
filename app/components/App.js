var React = require('react');
var PrimaryPane = require('./PrimaryPane');
var SidePane = require('./SidePane');
var $ = require('jquery');

var App = React.createClass({

  API_URL: "http://localhost:3000/search",
  // API_URL: "http://localhost:3030/api/tweets",

  getInitialState: function() {
    return { sideshow: '', mapData: [], tweetData: [], q: ""};
  },

  handleQuerySubmit: function(params) {
    if (!("hours" in params) || params["hours"] === "")
      params["hours"] = "1";
    debugger;
    this.loadDataFromServer(params);
  },

  loadDataFromServer: function(params) {
    $.ajax({ 
      url: this.API_URL,
      data: params,
      dataType: 'json',
      success: function(data) {
        debugger;
        // update data with received
        this.updateData(data[2].data, params.q);

        // Watson restricts us to 500 results at a time
        // check if there is more and run again until we've got it all for the time period requested
        if (data[2].quantity !== data[2].from) {
          params.from = data[2].from;
          this.loadDataFromServer(params);
        }
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(params, status, err.toString());
      }.bind(this)
    });
  },

  updateData: function(data, q) {
    // repeat query
    if (this.state.q === q) {
      this.setState({
        mapData: (this.state.mapData).concat(data.map),
        tweetData: (this.state.tweetData).concat(data.tweets)
      // chartData?
      });
    }
    else {
      this.setState({
        mapData: data.map,
        tweetData: data.tweets,
        // chartData?
        q: q
      });
    }
  },

  render: function() {
    return (
      <div>
        <PrimaryPane mapData={this.state.mapData} data={this.state.data} onQuerySubmit={this.handleQuerySubmit} className={this.state.sideshow} />
        <SidePane className={this.state.sideshow} clicktabClick={this.handleSideshow} tweetData={this.state.tweetData}/>
      </div>
    )
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
  }
});

module.exports = App;