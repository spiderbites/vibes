var React = require('react');
var Tweet = require('./Tweet');

var SidePane = React.createClass({
  render: function() {
    return (
      <div className={"side-pane " + this.props.className}>
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
    )
  }
});

module.exports = SidePane;