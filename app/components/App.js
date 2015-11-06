var React = require('react');
var Map = require('./Map');

var App = React.createClass({
  render: function() {
    return (
      <Map url="" pollInterval={2000} />
    )
  }
});

module.exports = App;