(function() {
  var init, util,
    __slice = Array.prototype.slice;

  init = function() {
    var map;
    map = new GMaps({
      div: "#map",
      lat: util.getParams("lat") || 35.65980,
      lng: util.getParams("lng") || 139.69518
    });
    return map.setContextMenu({
      control: "map",
      options: [
        {
          title: "Add marker",
          name: "add_marker",
          action: function(e) {
            return this.addMarker({
              lat: e.latLng.lat(),
              lng: e.latLng.lng(),
              title: "New marker",
              infoWindow: {
                content: "<p>HTML Content</p>"
              }
            });
          }
        }
      ]
    });
  };

  util = {};

  util.getParams = function(key) {
    var n, params, paramsInArray, _ref;
    _ref = query.split(/[\?\&]/).map(function(x) {
      return x.split('=');
    }), n = _ref[0], paramsInArray = 2 <= _ref.length ? __slice.call(_ref, 1) : [];
    params = {};
    paramsInArray.forEach(function(p) {
      return params[p[0]] = p[1];
    });
    return params[key];
  };

  $(init);

}).call(this);
