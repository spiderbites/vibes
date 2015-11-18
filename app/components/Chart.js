// var LineChart = require("react-chartjs").Line;
var React = require('react');
var RChartJS = require("react-chartjs");
var $ = require("jquery");

var Chart = React.createClass({

  componentDidMount: function(){
  },

  formatLabelHour: function(label) {
    return new Date(Date.parse(label + " UTC")).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
  },

  formatLabelDay: function(label) {
    return new Date(Date.parse(label + " UTC")).toLocaleDateString();
  },

  componentWillReceiveProps: function(nextProps) {
    // Format the label strings to look nice.
    // We use some super magic numbers to figure out if we're displaying results of an
    // hourly search or a daily search.
    if (nextProps.labels !== undefined) {
      var diff = new Date(nextProps.labels[1]) - new Date(nextProps.labels[0]);
      if (isNaN(diff)) // don't convert the initial dummy labels...
        this.state.data.labels = nextProps.labels;
      else if (diff >= 86400000) //  There are this many milliseconds in a day -> show data with day labels
        this.state.data.labels = nextProps.labels.map(this.formatLabelDay);
      else // Show data with hour labels
        this.state.data.labels = nextProps.labels.map(this.formatLabelHour);

      // Converting the data into the format required for ChartJS
      var that = this;
      nextProps.data.forEach(function(element, index) {
        that.state.data.datasets[index].data = element;
      });
    }
  },

  getInitialState: function() {
    var data = {
      labels: ["12am", "2am", "4am", "6am", "8am", "10am", "12pm", "2pm", "4pm", "6pm", "8pm", "10pm"],
      datasets: [
        {
          label: "Neutral and Ambivalent Sentiments",
          fillColor: "rgba(220,220,220,0.2)",
          strokeColor: "rgba(220,220,220,1)",
          pointColor: "rgba(220,220,220,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(220,220,220,1)",
          data: []
        },
        {
          label: "Negative Sentiments",
          fillColor: "rgba(255,51,51,0.2)",
          strokeColor: "rgba(255,51,51,1)",
          pointColor: "rgba(255,51,51,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(255,51,51,1)",
          data: []
        },
        {
          label: "Positive Sentiments",
          fillColor: "rgba(0,204,102,0.2)",
          strokeColor: "rgba(0,204,102,1)",
          pointColor: "rgba(0,204,102,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(0,204,102,1)",
          data: []
        }
      ]
    };
    return {
      data: data
    };
  },

  render: function(){
    return (
      <div className={"chart " + this.props.className}>
        <div className="canvas-holder">
          <RChartJS.Line data={this.state.data} options={this.props.options} ref="lineChart" redraw />
        </div>
      </div>
    );
  },

});

module.exports = Chart;