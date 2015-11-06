var React = require('react');
var Header = require('./Header');
var Navbar = require('./Navbar');
var Content = require('./Content');
var Slider = require('./Slider');

var PrimaryPane = React.createClass({
  render: function() {
    return (
      <div className={"primary-pane " + this.props.className}>
        <div className="arbitrary">
          <Header/>
          <Navbar/>
          <Content/>
          <Slider/>
        </div>
      </div>
    )
  }
});

module.exports = PrimaryPane;