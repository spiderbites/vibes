var React = require('react');

var Footer = React.createClass({
  render: function() {
    return (
      <div className={"footer"}>
        <div className="legend">
          <ul>
            <li className="neutral"><div></div> Neutral Sentiments</li>
            <li className="negative"><div></div> Negative Sentiments</li>
            <li className="positive"><div></div> Positive Sentiments</li>
          </ul>
        </div>
        <div className="blurb">
          <p>* Twitter sentiment as analyzed by Watson.</p>
        </div>
      </div>
    )
  }
});

module.exports = Footer;