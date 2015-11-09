var React = require('react');
var Map = require('./Map');

var Content = React.createClass({
  render: function() {
    return (
      <div className={"content"}>
        <Map url="" pollInterval={2000} />
      </div>
    )
  }
});

module.exports = Content;