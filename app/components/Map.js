var React = require('react');
var $ = require('jquery');

var Map = React.createClass({

  /* * * * * * * * * * * *
  * LIFECYCLE FUNCTIONS *
  * * * * * * * * * * * */ 
  componentDidMount: function(){
    // hardcoding Toronto to be at the center for now with no marker.
    this.map = this.createMap(43.653226, -79.383184, 3);

    // keep track of markers
    this.markers = [];
  },

  componentDidUpdate: function(){
    // need some logic here to clear markers?
    // also would be good to calculate a busy region of the map to zoom on
    if (!(this.props.data === undefined)) {
      this.props.data.map(function(geo_array) {
        this.addMarker(geo_array[1], geo_array[0], geo_array[2]);
      }.bind(this));
    }
  },

  getInitialState: function() {
    // tbd, what state are we saving, do we even save it in Map or in a parent component?
    //return {coords: []};  
    return null;
  },

  render: function(){
    return (
      <div className={"map-holder " + this.props.className}>
        <div id="map"></div>
      </div>
    );
  },

  /* * * * * * * * *
  * MAP FUNCTIONS *
  * * * * * * * * */ 

  /**
  * Create a map in the div with id #map, using params provided
  */
  createMap: function(initialLat, initialLng, initialZoom) {
    var mapOptions = {
      zoom: initialZoom,
      center: {lat: initialLat, lng: initialLng},
      mapTypeId: google.maps.MapTypeId.TERRAIN
    };
    var map = new google.maps.Map(document.getElementById('map'), mapOptions);
    return map;
  },
  
  /**
  * Create and add a new marker at lat, lng
  * sentimentValue must be one of "neutral", "positive" or "negative"
  */
  addMarker: function(lat, lng, sentimentValue) {
    // add to the markers array
    this.markers.push({lat: lat, lng: lng});

    var fillColor;
    switch(sentimentValue) {
      case "neutral":
        fillColor = "black";
        break;
      case "positive":
        fillColor = "green";
        break;
      case "negative":
        fillColor = "red";
        break;
    }

    // actually add the marker to the map
    var marker = new google.maps.Marker({
      icon: {
        path: google.maps.SymbolPath.CIRCLE,
        fillColor: fillColor,
        fillOpacity: .2,
        strokeColor: 'white',
        strokeWeight: .5,
        scale: 5
      },
      position: {lat: lat, lng: lng},
      map: this.map
    });
  }
});

module.exports = Map;