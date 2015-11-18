var React = require('react');
var Tweet = require('./Tweet');

var SidePane = React.createClass({

  getInitialState: function () {
    return {filter: null};
  },

  render: function() {
    return (
      <div className={"side-pane " + this.props.className}>
        <div className="tabs">
          <div className="clicktab" onClick={this.props.clicktabClick}><i className="fa fa-twitter"></i></div>
          <div className="sentiment-filter-pos" onClick={function() {this.filterTweetsClick("positive")}.bind(this)}><i className={"fa fa-plus-circle " + this.props.posActive}></i></div>
          <div className="sentiment-filter-neg" onClick={function() {this.filterTweetsClick("negative")}.bind(this)}><i className={"fa fa-minus-circle " + this.props.negActive}></i></div>
        </div>
        <TweetList tweetData={this.props.tweetData} />
      </div>
    )
  },

  filterTweetsClick: function(sentiment) {

    // in this case the user is toggling the positive/negative filter, so we want to show all tweets
    if (this.state.filter === sentiment) {
      this.props.filterTweets(null);
      this.setState({filter: null});
      //if (sentiment === "positive")
    }

    // otherwise filter by the sentiment given
    else {
      this.props.filterTweets(sentiment);
      this.setState({filter: sentiment});
      // add active class to this and remove from other
    }    
  },

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
    } else {
      var tweetNodes = <div className="no-tweet"><p>Move along, nothing to see here...</p></div>
    }

    return (
      <div className="tweets">
        {tweetNodes}
      </div>
    );
  }
});

module.exports = SidePane;