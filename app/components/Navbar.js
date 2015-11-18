var React = require('react');

var Navbar = React.createClass({
  selectContent: function(type) {
    this.props.selectContent(type);
  },

  render: function() {
    return (
      <div className={"navbar"}>
        <div className="navbar-inner">
          <ul>
            <li name="chart" onClick={this.selectContent.bind(null, "Chart")}><span><i name="chart" className="fa fa-line-chart" /></span></li>
            <li name="map" onClick={this.selectContent.bind(null, "Map")}><span><i name="map" className="fa fa-globe" /></span></li>
          </ul>
        </div>
      </div>
    )
  }
});

module.exports = Navbar;