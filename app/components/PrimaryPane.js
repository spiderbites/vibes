var React = require('react');
var Header = require('./Header');
var Navbar = require('./Navbar');
var Content = require('./Content');
var Slider = require('./Slider');

var PrimaryPane = React.createClass({

  handleUsernameSubmit: function(params) {
    this.props.onUsernameSubmit(params);
  },

  render: function() {
    return (
      <div className={"primary-pane " + this.props.className}>
        <div className="arbitrary">
          <Header onUsernameSubmit={this.handleUsernameSubmit}/>
          <Navbar/>
          <Content data={this.props.data}/>
          <Slider/>
        </div>
      </div>
    )
  }
});

module.exports = PrimaryPane;