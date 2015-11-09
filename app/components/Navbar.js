var React = require('react');

var Navbar = React.createClass({
  render: function() {
    return (
      <div className={"navbar"}>
        <ul>
          <li>Chart</li>
          <li>Map</li>
        </ul>
      </div>
    )
  }
});

module.exports = Navbar;