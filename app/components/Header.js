var React = require('react');

var Header = React.createClass({

  handleSubmit: function(e) {
    e.preventDefault();
    var username = this.refs.username.value.trim();
    if (!username)
      return;
    this.props.onUsernameSubmit({q: username});
    this.refs.username.value = '';
  },

  render: function() {
    return (
      <div className={"header"}>
        <form onSubmit={this.handleSubmit}>
          <input type="search" placeholder="Twitter username" ref="username" />
        </form>
      </div>
    )
  }
});

module.exports = Header;