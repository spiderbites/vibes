var React = require('react');

var Header = React.createClass({
  render: function() {
    return (
      <div className={"header"}>
        <h1>I am a Header.</h1>
      </div>
    )
  }
});

module.exports = Header;