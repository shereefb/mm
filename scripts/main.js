var $modalTopic = "";
var $converter = new showdown.Converter();

$('#mainModal').on('show.bs.modal', function (e) {
    var modal = $(this);
    var result = null;
    console.log($modalTopic)
    modal.find('.modal-title').text($modalTopic.title);
    modal.find('.modal-body').html($converter.makeHtml($modalTopic.description));

})

var map = L.map('mapid', {
    crs: L.CRS.Simple,
    minZoom: -5,
    maxZoom: 3,
    zoomSnap: 0.1,
    zoomDelta: 0.5
}).setView([500, 500], -0.1);

map.attributionControl.setPrefix(false);
map.attributionControl.addAttribution('&copy; <a href="maturemasculine.org">Mature Masculine</a>');

var bounds = [
    [0, 0],
    [1000, 1000]
]

var image = L.imageOverlay('/images/kwml.jpg', bounds).addTo(map);


var geojsonMarkerOptions = {
    radius: 8,
    fillColor: "#ff7800",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
};

var myLayer = L.geoJSON("", {
    pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, geojsonMarkerOptions).on('click', markerOnClick);
    }
}).addTo(map);

$("button");
$.getJSON("/_script/final.json", function(json) {
    myLayer.addData(json);
});


// var request = new XMLHttpRequest();
// request.open("GET", '/_script/final.json', false);
// request.send(null);
// var jsonData = JSON.parse(request.responseText);
// myLayer.addData(jsonData);

/* Open modal & center map on marker click 	*/
function markerOnClick(e) {
    console.log(e.target.feature.properties.title);
    $modalTopic = e.target.feature.properties;
    $('#mainModal').modal({
    })
}
