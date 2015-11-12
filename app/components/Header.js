var React = require('react');

var Header = React.createClass({

  placeholder: {search: "@handle, #hash, etc...", hours: "Hours", days: "Days"},

  handleSubmit: function(e) {
    e.preventDefault();
    var query = this.refs.query.value.trim();
    var hours = this.refs.hours.value.trim();
    var days = this.refs.days.value.trim();
    if (!query)
      return;
    this.props.onQuerySubmit({q: query, hours: hours, days: days});
    this.refs.query.value = "";
    this.refs.hours.value = this.placeholder.hours;
    this.refs.days.value = this.placeholder.days;
  },

  render: function() {
    return (
      <div className={"header"}>
        <form onSubmit={this.handleSubmit}>
          <input type="search" placeholder={this.placeholder.search} ref="query" />
          <input type="number" min="0" max="24" ref="hours" placeholder={this.placeholder.hours}/>
          <input type="number" min="0" max="30" ref="days" placeholder={this.placeholder.days}/>
          <input type="submit" />
        </form>
      </div>
    )
  }
});

module.exports = Header;