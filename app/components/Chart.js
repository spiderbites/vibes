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
    return {data: this.props.data};
  },

  regen: function() {
    this.setState({data: this.props.data});
  },

  render: function(){
    var legend = this.state && this.state.legend || '';
    return (
      <div>
        <RChartJS.Line data={this.props.data} options={this.props.options} width="600" height="250" ref="lineChart"/>
        <div dangerouslySetInnerHTML={{ __html: legend }} />
      </div>
    );
  },

});

module.exports = Chart;