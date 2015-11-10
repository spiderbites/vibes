var React = require('react');
var PrimaryPane = require('./PrimaryPane');
var SidePane = require('./SidePane');
var $ = require('jquery');

var App = React.createClass({

  API_URL: "http://localhost:3000/search",

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
      data: params,
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
      <div onClick={this.handleSideshow}>
        <PrimaryPane data={this.state.data} className={this.state.sideshow} onUsernameSubmit={this.handleUsernameSubmit} />
        <SidePane className={this.state.sideshow}/>
      </div>
    )
  },
  
  handleSideshow: function() {
    this.setState({sideshow: this.state.sideshow === '' ? 'sideshow' : ''});
  }
});

module.exports = App;