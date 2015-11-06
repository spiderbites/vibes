var React = require('react');

var Navbar = React.createClass({
  render: function() {
    return (
      <div className={"navbar"}>
        <h1>I am a Navbar.</h1>
      </div>
    )
  }
});

module.exports = Navbar;