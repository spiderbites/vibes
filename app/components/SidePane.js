var React = require('react');

var SidePane = React.createClass({
  render: function() {
    return (
      <div className={"side-pane " + this.props.className}>
        <h1>I am a SidePane.</h1>
      </div>
    )
  }
});

module.exports = SidePane;