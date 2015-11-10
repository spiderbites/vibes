var React = require('react');
var Tweet = require('./Tweet');

var SidePane = React.createClass({
  render: function() {
    return (
      <div className={"side-pane " + this.props.className}>
        <div className="clicktab" onClick={this.props.clicktabClick}></div>
        <div className="tweets">
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
          <Tweet/>
        </div>
      </div>
    )
  }
});

module.exports = SidePane;