var React = require('react');
var PrimaryPane = require('./PrimaryPane');
var SidePane = require('./SidePane');
var $ = require('jquery');

var App = React.createClass({

  // API_URL: "http://localhost:3000/search",
  API_URL: "http://localhost:3030/api/tweets",

  getInitialState: function() {
    return { sideshow: '', data: {} }
  },

  handleUsernameSubmit: function(params) {
    //console.log("onUsernameSubmit in App.js: " + params.q);
    this.loadDataFromServer(params)
  },

  loadDataFromServer: function(params) {
    $.ajax({ 
      url: this.API_URL,
      // data: params,
      dataType: 'json',
      success: function(data) {
        this.setState({data: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(params, status, err.toString());
      }.bind(this)
    });
  },

  render: function() {
    return (
      <div>
        <PrimaryPane data={this.state.data} onUsernameSubmit={this.handleUsernameSubmit} className={this.state.sideshow} />
        <SidePane className={this.state.sideshow} clicktabClick={this.handleSideshow} tweetData={this.state.data}/>
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