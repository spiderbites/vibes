var React = require('react');

var Header = React.createClass({

  placeholder: {search: "@handle, #hash, etc...", number: "Hours"},

  handleSubmit: function(e) {
    e.preventDefault();
    var query = this.refs.query.value.trim();
    var hours = this.refs.hours.value;
    if (!query)
      return;
    this.props.onQuerySubmit({q: query, hours: hours});
    this.refs.query.value = "";
    this.refs.hours.value = this.placeholder.number;
  },

  render: function() {
    return (
      <div className={"header"}>
        <form onSubmit={this.handleSubmit}>
          <input type="search" placeholder={this.placeholder.search} ref="query" />
          <input type="number" min="1" max="24" ref="hours" placeholder={this.placeholder.number}/>
          <input type="submit" />
        </form>
      </div>
    )
  }
});

module.exports = Header;