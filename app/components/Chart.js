// var LineChart = require("react-chartjs").Line;
var React = require('react');
var RChartJS = require("react-chartjs");

var Chart = React.createClass({

  componentDidMount: function(){
    var legend = this.refs.lineChart.state.chart.generateLegend();
    this.setState({
      legend: legend
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


  // this.props.data is an object with
  //    labels
  //    an array of data arrays...
  regen: function() {
    var curData = this.state.data;
    curData.labels = this.props.labels;
    this.props.data.forEach(function(element, index) {
      curData.datasets[index].data = element;
    })
    this.setState({data: curData});
  },

  render: function(){
    var legend = this.state && this.state.legend || '';
    return (
      <div>
        <RChartJS.Line data={this.state.data} options={this.props.options} width="600" height="250" ref="lineChart"/>
        <div dangerouslySetInnerHTML={{ __html: legend }} />
      </div>
    );
  },

});

module.exports = Chart;