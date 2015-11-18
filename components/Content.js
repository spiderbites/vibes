var React = require('react');
var Map = require('./Map');
var Chart = require('./Chart');

var Content = React.createClass({
  getInitialState: function() {
    return {
      chartData: [],
      chartLabels: ["12am", "2am", "4am", "6am", "8am", "10am", "12pm", "2pm", "4pm", "6pm", "8pm", "10pm"]
    }
  },

  // Figure out smoother animation...
  getDefaultProps: function() {
    return {
      chartOptions: {
          multiTooltipTemplate: "<%= datasetLabel %> - <%= value %>",
          legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].fillColor%>\"><%if(datasets[i].label){%><%=datasets[i].label%><%}%></span></li><%}%></ul>",
          scaleGridLineColor: "rgba(100,100,100,0.8)",
          scaleLineColor: "rgba(140,140,140,0.8)",
          scaleFontColor: "rgba(200,200,200,0.8)",
          animationSteps: 15,
          responsive: true,
          maintainAspectRatio: false
        }
    };
  },

  componentWillReceiveProps: function(nextProps) {
    if (nextProps.chartData != undefined) {
      this.setState({
        chartData: [
          nextProps.chartData.stats.neutral,
          nextProps.chartData.stats.negative,
          nextProps.chartData.stats.positive
        ],
        chartLabels: nextProps.chartData.time_labels
      });
    }
  },

  render: function() {
    return (
      <div className={"content"}>
        <Chart className={this.props.contentClasses['Chart']} data={this.state.chartData} labels={this.state.chartLabels} options={this.props.chartOptions}/>
        <Map className={this.props.contentClasses['Map']} url="" data={this.props.mapData} />
      </div>
    )
  }
});

module.exports = Content;