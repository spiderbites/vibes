var React = require('react');
var PrimaryPane = require('./PrimaryPane');
var SidePane = require('./SidePane');

var App = React.createClass({
  getInitialState: function() {
    return { sideshow: '' }
  },

  render: function() {
    console.log('in app render');
    return (
      <div onClick={this.handleSideshow}>
        <PrimaryPane className={this.state.sideshow}/>
        <SidePane className={this.state.sideshow}/>
      </div>
    )
  },
  
  handleSideshow: function() {
    this.setState({sideshow: this.state.sideshow === '' ? 'sideshow' : ''});
  }
});

module.exports = App;