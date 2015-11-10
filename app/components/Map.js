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
      <div className={"map-holder " + this.props.className}>
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
    var sentimentValue = this.getRandomArbitrary(1,5)

    // Adding a marker to each location
    this.addMarker(lat, lng, sentimentValue);
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
  createMap: function(initialLat, initialLng, initialZoom) {
    var mapOptions = {
      zoom: initialZoom,
      center: {lat: initialLat, lng: initialLng},
      mapTypeId: google.maps.MapTypeId.TERRAIN
    };

    var map = new google.maps.Map(document.getElementById('map'), mapOptions);
    var that = this;
    map.data.setStyle(function(sentimentValue) {
      return {
        icon: that.getCircle(sentimentValue)
      }
    });

    return map;

  },

  getCircle: function(sentimentValue) {
    var circle = {
      path: google.maps.SymbolPath.CIRCLE,
      fillColor: 'red',
      fillOpacity: .4,
      scale: Math.pow(2, sentimentValue) / 2,
      strokeColor: 'white',
      strokeWeight: .5
    }
    return circle;
  },
  
  /**
  * Create and add a new marker at lat, lng
  */
  addMarker: function(lat, lng, sentimentValue) {
    // add to the markers array
    this.markers.push({lat: lat, lng: lng});

    console.log(lat, lng);

    // actually add the marker to the map
    var marker = new google.maps.Marker({
      icon: {
        path: google.maps.SymbolPath.CIRCLE,
        fillColor: 'red',
        fillOpacity: .2,
        strokeColor: 'white',
        strokeWeight: .5,
        scale: Math.pow(2, sentimentValue) / 2
      },
      position: {lat: lat, lng: lng},
      map: this.map
    });
  }
});

module.exports = Map;