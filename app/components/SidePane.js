var React = require('react');
var Tweet = require('./Tweet');

var SidePane = React.createClass({
  render: function() {
    return (
      <div className={"side-pane " + this.props.className}>
        <div className="clicktab" onClick={this.props.clicktabClick}><i className="fa fa-twitter"></i></div>
        <TweetList tweetData={this.props.tweetData} />
      </div>
    )
  }
});

var TweetList = React.createClass({

  // Comparison function used to order tweets by time posted
  timeCompare: function(tweeta, tweetb) {
    return Date.parse(tweeta.time) - Date.parse(tweetb.time)
  },

  render: function() {
    if (Object.keys(this.props.tweetData).length !== 0) {
      var tweetCopy = this.props.tweetData.slice();
      tweetCopy.sort(this.timeCompare).reverse();
      var tweetNodes = tweetCopy.map(function (tweet) {
        return (
          <Tweet tweet={tweet} />
          );
      });
    }

    return (
      <div className="tweets">
        {tweetNodes}
      </div>
    );
  }
});

module.exports = SidePane;