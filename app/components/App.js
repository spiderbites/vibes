var React = require('react');
var PrimaryPane = require('./PrimaryPane');
var SidePane = require('./SidePane');

var App = React.createClass({
  render: function() {
    return (
      <div>
        <PrimaryPane/>
        <SidePane/>
      </div>
    )
  }
});

module.exports = App;