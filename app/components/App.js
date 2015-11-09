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

// data needs to be in this format for chart.js
var labels = ["12am", "2am", "4am", "6am", "8am", "10am", "12pm", "2pm", "4pm", "6pm", "8pm", "10pm", "12am"];

// here we create some random data to pass in to chart
var data = [rand(250, 500, 13), rand(0, 150, 13), rand(0, 500, 13)]

var options = {
  multiTooltipTemplate: "<%= datasetLabel %> - <%= value %>",
  legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].fillColor%>\"><%if(datasets[i].label){%><%=datasets[i].label%><%}%></span></li><%}%></ul>"
};

var App = React.createClass({
  render: function() {
    return (
      <Chart data={data} labels={labels} width="600" height="250" options={options}/>
    )
  }
});

module.exports = App;