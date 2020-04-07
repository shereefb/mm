var $modalTopic = "";
var $converter = new showdown.Converter();

$('#mainModal').on('show.bs.modal', function (e) {

    var modal = $(this);

    var result = null;

    for (var i = 0; i < $archetypes.length; i++) {
        if ($archetypes[i].title == $modalTopic) {
            result = $archetypes[i];
            break;
        }
    }

    modal.find('.modal-title').text(result.title);
    modal.find('.modal-body').html($converter.makeHtml(result.description));
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

var request = new XMLHttpRequest();
request.open("GET", '/assets/exported.geojson', false);
request.send(null);
var jsonData = JSON.parse(request.responseText);
myLayer.addData(jsonData);

/* Open modal & center map on marker click 	*/
function markerOnClick(e) {
    console.log(e.target.feature.properties.name);
    $modalTopic = e.target.feature.properties.name;
    $('#mainModal').modal({
        keyboard: false
    })
}
