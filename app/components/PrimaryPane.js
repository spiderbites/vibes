var React = require('react');
var Header = require('./Header');
var Navbar = require('./Navbar');
var Content = require('./Content');
var Slider = require('./Slider');

var PrimaryPane = React.createClass({

  handleUsernameSubmit: function(params) {
    this.props.onUsernameSubmit(params);
  },

  switchContent: function(contentSelected) {
    if (contentSelected === 'Chart') {
      this.setState({
        contentClasses: {
          'Chart': '',
          'Map': 'hidden'
        }
      });
    } else if (contentSelected === 'Map') {
      this.setState({
        contentClasses: {
          'Chart': 'hidden',
          'Map': ''
        }
      });
    }
  },

  getInitialState: function() {
    return {
      contentClasses: {
        'Chart': '',
        'Map': 'hidden'
      }
    };
  },

  render: function() {
    return (
      <div className={"primary-pane " + this.props.className}>
        <div className="arbitrary">
          <Header onUsernameSubmit={this.handleUsernameSubmit}/>
          <Navbar selectContent={this.switchContent}/>
          <Content contentClasses={this.state.contentClasses} mapData={this.props.mapData} data={this.props.data}/>
          <Slider/>
        </div>
      </div>
    )
  }
});

module.exports = PrimaryPane;