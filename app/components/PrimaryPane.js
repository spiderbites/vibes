var React = require('react');
var Header = require('./Header');
var Navbar = require('./Navbar');
var Content = require('./Content');
var Slider = require('./Slider');

var PrimaryPane = React.createClass({

  handleUsernameSubmit: function(params) {
    this.props.onUsernameSubmit(params);
  },

  switchContent: function(content) {
    this.setState({showContent: content});
  },

  getInitialState: function() {
    return { showContent: 'Chart' };
  },

  render: function() {
    return (
      <div className={"primary-pane " + this.props.className}>
        <div className="arbitrary">
          <Header onUsernameSubmit={this.handleUsernameSubmit}/>
          <Navbar selectContent={this.switchContent}/>
          <Content showContent={this.state.showContent} data={this.props.data}/>
          <Slider/>
        </div>
      </div>
    )
  }
});

module.exports = PrimaryPane;