var React = require('react');

var Header = React.createClass({
  render: function() {
    return (
      <div className={"header"}>
        <input type="search" placeholder="Twitter username"/>
      </div>
    )
  }
});

module.exports = Header;