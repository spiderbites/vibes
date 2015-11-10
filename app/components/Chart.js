// var LineChart = require("react-chartjs").Line;
var React = require('react');
var RChartJS = require("react-chartjs");

var Chart = React.createClass({

  componentDidMount: function(){
    console.log('in componentDidMount');
    var legend = this.refs.lineChart.state.chart.generateLegend();
    this.setState({
      legend: legend
    });
  },

  componentWillReceiveProps: function(nextProps) {
    var that = this;
    nextProps.data.forEach(function(element, index) {
      that.state.data.datasets[index].data = element;
    });
  },

  getInitialState: function() {
    var data = {
      labels: this.props.labels,
      datasets: [
        {
          label: "Neutral and Ambivalent Sentiments",
          fillColor: "rgba(220,220,220,0.2)",
          strokeColor: "rgba(220,220,220,1)",
          pointColor: "rgba(220,220,220,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(220,220,220,1)",
          data: this.props.data[0]
        },
        {
          label: "Negative Sentiments",
          fillColor: "rgba(255,51,51,0.2)",
          strokeColor: "rgba(255,51,51,1)",
          pointColor: "rgba(255,51,51,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(255,51,51,1)",
          data: this.props.data[1]
        },
        {
          label: "Positive Sentiments",
          fillColor: "rgba(0,204,102,0.2)",
          strokeColor: "rgba(0,204,102,1)",
          pointColor: "rgba(0,204,102,1)",
          pointStrokeColor: "#fff",
          pointHighlightFill: "#fff",
          pointHighlightStroke: "rgba(0,204,102,1)",
          data: this.props.data[2]
        }
      ]
    };
    return {data: data};
  },

  render: function(){
    var legend = this.state && this.state.legend || '';
    console.log('in render');
    // console.log(this.props.data[0]);
    // console.log(this.state.data.datasets[0].data);

    return (
      <div>
        <RChartJS.Line data={this.state.data} options={this.props.options} width="600" height="250" ref="lineChart" />
        <div dangerouslySetInnerHTML={{ __html: legend }} />
      </div>
    );
  },

});

module.exports = Chart;