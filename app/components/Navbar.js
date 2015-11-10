var React = require('react');

var Navbar = React.createClass({
  selectContent: function (event) {
    this.props.selectContent(event.target.textContent);
  },

  render: function() {
    return (
      <div className={"navbar"}>
        <ul>
          <li onClick={this.selectContent}><span>Chart</span></li>
          <li onClick={this.selectContent}><span>Map</span></li>
        </ul>
      </div>
    )
  }
});

module.exports = Navbar;