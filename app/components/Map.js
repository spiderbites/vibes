var React = require('react');
var $ = require('jquery');

var Map = React.createClass({

  /* * * * * * * * * * * *
  * LIFECYCLE FUNCTIONS *
  * * * * * * * * * * * */ 
  componentDidMount: function(){
    // hardcoding Toronto to be at the center for now with no marker.
    this.map = this.createMap(43.653226, -79.383184, 5);

    // keep track of markers
    this.markers = [];

    // for testing purposes, generate and add random markers in north america
    setInterval(this.generateRandomCoords, this.props.pollInterval);
  },

  componentDidUpdate: function(){
    console.log("componentDidUpdate");
  },

  getInitialState: function() {
    // tbd, what state are we saving, do we even save it in Map or in a parent component?
    //return {coords: []};  
    return null;
  },

  render: function(){
    return (
      <div className="map-holder">
        <div id="map"></div>
      </div>
    );
  },


  /* * * * * * * * * * 
  * NETWORK FUNCTIONS *
  * * * * * * * * * * */ 

  // load all location data from server
  // TODO: what state do we set
  loadCoordsFromServer: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function(coords) {
        // this.setState(???);
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },


  /* * * * * * * * *
  * MAP FUNCTIONS *
  * * * * * * * * */ 

  /**
  * Add a random North America marker to the map
  */
  generateRandomCoords: function() {
    var lat = this.getRandomArbitrary(17.127410, 60.7211)
    var lng = this.getRandomArbitrary(-135.056845, -61.846772)

    // Adding a marker to each location
    this.addMarker(lat, lng);
  },

  /**
  * Returns a random number between min (inclusive) and max (exclusive)
  */
  getRandomArbitrary: function(min, max) {
    return Math.random() * (max - min) + min;
  },

  /**
  * Create a map in the div with id #map, using params provided
  */
  createMap: function(initialLat, initialLong, initialZoom) {
    return new GMaps({
      el: '#map',
      zoom: initialZoom,
      lat: initialLat,
      lng: initialLong
    })
  },
  
  /**
  * Create and add a new marker at lat, lng
  */
  addMarker: function(lat, lng) {
    // add to the markers array
    this.markers.push({lat: lat, lng: lng});

    // actually add the marker to the map
    this.map.addMarker({lat: lat, lng: lng});
  }
});

module.exports = Map;