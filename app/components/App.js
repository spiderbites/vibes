var React = require('react');
var Map = require('./Map');
var Chart = require('./Chart');

// DUMMY DATA SET NOT BASED ON ANYTHING!!

function rand(min, max, num) {
  var rtn = [];
  while (rtn.length < num) {
    rtn.push(Math.floor((Math.random() * (max - min)) + min));
  }
  return rtn;
}


var App = React.createClass({

  componentDidMount: function() {
    // change data to test redrawing
    setInterval(this.newData, 2500);
  },

  getInitialState: function() {
    return {
      chartData: [rand(250, 500, 12), rand(0, 150, 12), rand(0, 500, 12)],
      chartLabels: ["12am", "2am", "4am", "6am", "8am", "10am", "12pm", "2pm", "4pm", "6pm", "8pm", "10pm"],
      
    }
  },

  // Figure out smoother animation...
  getDefaultProps: function() {
    return {
      chartOptions: {
          multiTooltipTemplate: "<%= datasetLabel %> - <%= value %>",
          legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].fillColor%>\"><%if(datasets[i].label){%><%=datasets[i].label%><%}%></span></li><%}%></ul>",
          animationSteps: 15
        }
    };
  },

  newData: function() {
    console.log('newdata');
    var labels = this.state.chartLabels;
    labels.push(labels.shift());
    this.setState({
      chartData: [this.state.chartData[0].slice(1).concat(rand(250, 500, 1)), 
                  this.state.chartData[1].slice(1).concat(rand(0, 150, 1)),
                  this.state.chartData[2].slice(1).concat(rand(0, 500, 1))],
      chartLabels: labels
    });

  },

  render: function() {
    console.log('in app render');
    return (
      <Chart data={this.state.chartData} labels={this.state.chartLabels} width="600" height="250" options={this.props.chartOptions}/>
    )
  }
});

module.exports = App;