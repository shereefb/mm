var $modalTopic = "";
var $converter = new showdown.Converter();

$('#mainModal').on('show.bs.modal', function (e) {
    var modal = $(this);
    var result = null;
    console.log($modalTopic)
    modal.find('.modal-title').text($modalTopic.title);
    var imageHtml = "";
    var fileName = '/images/back/' + $modalTopic.title.replace(" ", "_").toLowerCase() + '.jpg';
    
    $.get(fileName)
        .done(function () {
            imageHtml = "<img src='" + fileName + "'/><br><br>";
            modal.find('.modal-body').html(imageHtml + $converter.makeHtml($modalTopic.description));
        }).fail(function () {
            modal.find('.modal-body').html($converter.makeHtml($modalTopic.description));
        })

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



var myLayer = L.geoJSON("", {
    pointToLayer: function (feature, latlng) {

        var geojsonMarkerOptions = {
            radius: 8,
            fillColor: "#111",
            color: "#444444",
            weight: 1,
            opacity: 1,
            fillOpacity: 0.8,
            className: 'mymarker'
        };

        geojsonMarkerOptions.radius = radiusCals(feature.properties.depth);
        switch (feature.properties.type) {
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
        if (feature.properties.draft == true) {
            geojsonMarkerOptions.fillColor = "white";
            geojsonMarkerOptions.fillOpacity = 0.3;
            geojsonMarkerOptions.opacity = 0.4;
        }

        if (feature.properties.type != "Quality")
            return L.circleMarker(latlng, geojsonMarkerOptions).bindTooltip(feature.properties.title).on('click', markerOnClick);
        else
            return null;
    }
}).addTo(map);

var myLayer2 = L.geoJSON("", {
    pointToLayer: function (feature, latlng) {

        var geojsonMarkerOptions = {
            radius: 8,
            fillColor: "#111",
            color: "#444444",
            weight: 1,
            opacity: 1,
            fillOpacity: 0.8,
            className: 'mymarker'
        };

        geojsonMarkerOptions.radius = radiusCals(feature.properties.depth);
        switch (feature.properties.type) {
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
        if (feature.properties.draft == true) {
            geojsonMarkerOptions.fillColor = "white";
            geojsonMarkerOptions.fillOpacity = 0.3;
            geojsonMarkerOptions.opacity = 0.4;
        }

        if (feature.properties.type == "Quality")
            return L.circleMarker(latlng, geojsonMarkerOptions).bindTooltip(feature.properties.title).on('click', markerOnClick);
        else
            return null;
    }
}).addTo(map);


var controlLayers = L.control.layers().addTo(map);
controlLayers.addOverlay(myLayer, 'Archetypes');
controlLayers.addOverlay(myLayer2, 'Qualities');



$("button");
$.getJSON("/images/final.json", function (json) {
    myLayer.addData(json);
    myLayer2.addData(json);
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

    myLayer2.eachLayer(function (layer) {
        layer.setRadius(radiusCals(layer.feature.properties.depth));
    });
}



/* Open modal & center map on marker click 	*/
function markerOnClick(e) {
    console.log(e.target.feature.properties.title);
    $modalTopic = e.target.feature.properties;
    $('#mainModal').modal({
    })
}
