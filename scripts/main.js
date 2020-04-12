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
    fillColor: "#111",
    color: "#444444",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    className: 'mymarker'
  };

  var myLayer = L.geoJSON("", {
    pointToLayer: function (feature, latlng) {
      geojsonMarkerOptions.radius = radiusCals(feature.properties.depth);
      switch (feature.properties.type){
        case "Quality":
          geojsonMarkerOptions.fillColor = "#f9b282";
          break;
        case "Archetype":
          geojsonMarkerOptions.fillColor = "#8f4426";
          break;
        case "Sub Archetype":
          geojsonMarkerOptions.fillColor = "#de6b35";
          break;
      }
      return L.circleMarker(latlng, geojsonMarkerOptions).on('click', markerOnClick);
    }
  }).addTo(map);


$("button");
$.getJSON("/images/final.json", function (json) {
    myLayer.addData(json);
    resizeMarkers();
});

map.on('zoomend', function () {
    resizeMarkers();

});


function radiusCals(depth) {
    var radius = (5 - depth) * (map.getZoom() + 0.5) / 0.25;
    console.log(map.getZoom());
    console.log('depth:' + depth + '  radius:' + radius + ' zoom:' + map.getZoom());
    if (radius > 8)
        radius = 8;
    if (radius < 2)
        radius = 2;
    return radius;
}

function resizeMarkers() {
    myLayer.eachLayer(function (layer) {
        layer.setRadius(radiusCals(layer.feature.properties.depth));
    });
}



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
