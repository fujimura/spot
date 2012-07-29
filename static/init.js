(function() {
  var init;

  init = function() {
    var _this = this;
    new App.Map({
      div: "#map",
      lat: util.getParams("lat") || 35.65980,
      lng: util.getParams("lng") || 139.69518,
      disableDoubleClickZoom: true,
      dblclick: function(e) {
        var spot;
        spot = new App.Spot({
          lat: e.latLng.lat(),
          lng: e.latLng.lng()
        });
        return this.addMarker({
          lat: spot.lat,
          lng: spot.lng,
          title: "New marker",
          infoWindow: {
            content: (new App.SpotForm(spot)).render().el
          }
        });
      }
    });
    this.spots = [];
    return $.getJSON('/spots', function(data) {
      _.map(data, function(d) {
        return _this.spots.push(new App.Spot(d));
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
  };

  $(init);

}).call(this);
