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
var data = {
  labels: ["12am", "2am", "4am", "6am", "8am", "10am", "12pm", "2pm", "4pm", "6pm", "8pm", "10pm", "12am"],
  datasets: [
    {
      label: "Neutral and Ambivalent Sentiments",
      fillColor: "rgba(220,220,220,0.2)",
      strokeColor: "rgba(220,220,220,1)",
      pointColor: "rgba(220,220,220,1)",
      pointStrokeColor: "#fff",
      pointHighlightFill: "#fff",
      pointHighlightStroke: "rgba(220,220,220,1)",
      data: rand(250, 500, 13)
    },
    {
      label: "Negative Sentiments",
      fillColor: "rgba(255,51,51,0.2)",
      strokeColor: "rgba(255,51,51,1)",
      pointColor: "rgba(255,51,51,1)",
      pointStrokeColor: "#fff",
      pointHighlightFill: "#fff",
      pointHighlightStroke: "rgba(255,51,51,1)",
      data: rand(0, 150, 13)
    },
    {
      label: "Positive Sentiments",
      fillColor: "rgba(0,204,102,0.2)",
      strokeColor: "rgba(0,204,102,1)",
      pointColor: "rgba(0,204,102,1)",
      pointStrokeColor: "#fff",
      pointHighlightFill: "#fff",
      pointHighlightStroke: "rgba(0,204,102,1)",
      data: rand(0, 500, 13)
    }
  ]
};

var options = {
  multiTooltipTemplate: "<%= datasetLabel %> - <%= value %>",
  legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].fillColor%>\"><%if(datasets[i].label){%><%=datasets[i].label%><%}%></span></li><%}%></ul>"
};

var App = React.createClass({
  render: function() {
    return (
      <Chart data={data} width="600" height="250" options={options}/>
    )
  }
});

module.exports = App;