(function() {
  var init;

  init = function() {
    var map,
      _this = this;
    map = new Sache.Map({
      div: "#map",
      lat: util.getParams("lat") || 35.65980,
      lng: util.getParams("lng") || 139.69518,
      disableDoubleClickZoom: true,
      dblclick: function(e) {
        var spot;
        spot = new Sache.Spot({
          lat: e.latLng.lat(),
          lng: e.latLng.lng()
        });
        return map.addMarker({
          lat: spot.lat,
          lng: spot.lng,
          title: "New marker",
          infoWindow: {
            content: (new Sache.SpotForm(spot)).render().el
          }
        });
      }
    });
    this.spots = [];
    $.getJSON('/spots', function(data) {
      _.map(data, function(d) {
        return _this.spots.push(new Sache.Spot(d));
      });
      return _.each(_this.spots, function(s) {
        $('#spotlist').append(s.listItem.render().el);
        return map.addMarker({
          lat: s.lat,
          lng: s.lng,
          infoWindow: {
            content: s.body
          }
        });
      });
    });
    return map.setContextMenu({
      control: "map",
      options: [
        {
          title: "Add marker",
          name: "add_marker",
          action: function(e) {
            var spot;
            spot = new Sache.Spot({
              lat: e.latLng.lat(),
              lng: e.latLng.lng()
            });
            return this.addMarker({
              lat: spot.lat,
              lng: spot.lng,
              title: "New marker",
              infoWindow: {
                content: (new Sache.SpotForm(spot)).render().el
              }
            });
          }
        }
      ]
    });
  };

  $(init);

}).call(this);
