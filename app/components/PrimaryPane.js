var React = require('react');
var Header = require('./Header');
var Navbar = require('./Navbar');
var Content = require('./Content');
var Slider = require('./Slider');

var PrimaryPane = React.createClass({
  getInitialState: function() {
    return { showContent: 'Chart' }
  },

  render: function() {
    return (
      <div className={"primary-pane " + this.props.className}>
        <div className="arbitrary">
          <Header/>
          <Navbar selectContent={this.switchContent}/>
          <Content showContent={this.state.showContent}/>
          <Slider/>
        </div>
      </div>
    )
  },

  switchContent: function(content) {
    this.setState({showContent: content});
  }
});

module.exports = PrimaryPane;