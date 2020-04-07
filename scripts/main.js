console.log("we are live");

var request = new XMLHttpRequest();
request.open("GET",'/assets/exported.geojson', false);
request.send(null);
var jsonData = JSON.parse(request.responseText);

var map = L.map('mapid', {
    crs: L.CRS.Simple,
    minZoom: -0.25,
    maxZoom: 3,
    zoomSnap: 0,
    zoomDelta: 0.5
}).setView([500,500], -0.25);

map.attributionControl.setPrefix(false);
map.attributionControl.addAttribution('&copy; <a href="maturemasculine.org">Mature Masculine</a>');

var bounds = [
    [0,0],
    [1000,1000]
]

var image = L.imageOverlay('/images/kwml.jpg',bounds).addTo(map);

L.geoJSON(jsonData).addTo(map);

// var geojsonLayer = new L.GeoJSON.AJAX("assets/exported.geojson");       
// geojsonLayer.addTo(map);

