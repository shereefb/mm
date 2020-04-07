console.log("we are live");

var $modalTopic = ""
$('#mainModal').on('show.bs.modal', function (e) {

    var modal = $(this)
    modal.find('.modal-title').text($modalTopic);
    modal.find('.modal-body').text('lets talk about ' + $modalTopic);
})

var request = new XMLHttpRequest();
request.open("GET", '/assets/exported.geojson', false);
request.send(null);
var jsonData = JSON.parse(request.responseText);

var map = L.map('mapid', {
    crs: L.CRS.Simple,
    minZoom: -0.25,
    maxZoom: 3,
    zoomSnap: 0,
    zoomDelta: 0.5
}).setView([500, 500], -0.25);

map.attributionControl.setPrefix(false);
map.attributionControl.addAttribution('&copy; <a href="maturemasculine.org">Mature Masculine</a>');

var bounds = [
    [0, 0],
    [1000, 1000]
]

var image = L.imageOverlay('/images/kwml.jpg', bounds).addTo(map);

var options = {
    icon: 'leaf',
    iconShape: 'marker'
};

// var myStyle = {
//     "color": "#333333",
//     "weight": 5,
//     "opacity": 0.65
// };


// var myLayer = L.geoJSON().addTo(map);

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



// myLayer.setStyle = myStyle;
myLayer.addData(jsonData);
// myLayer.setStyle = myStyle;


L.marker([48.13710, 11.57539], {
    icon: L.BeautifyIcon.icon(options),
    draggable: true
}).addTo(map).bindPopup("popup").bindPopup("This is a BeautifyMarker");

/* Open modal & center map on marker click 	*/
function markerOnClick(e) {
    console.log(e.target.feature.properties.name);
    $modalTopic = e.target.feature.properties.name;
    $('#mainModal').modal({
        keyboard: false
    })
    // var id = this.options.id;
    // $(".modal-content").html('This is marker ' + id);
    // $('#emptymodal').modal('show');
    // map.setView(e.target.getLatLng());
    // init();
}

// var geojsonLayer = new L.GeoJSON.AJAX("assets/exported.geojson");       
// geojsonLayer.addTo(map);

