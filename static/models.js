(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  App.Map = (function(_super) {

    __extends(Map, _super);

    function Map() {
      Map.__super__.constructor.apply(this, arguments);
    }

    return Map;

  })(GMaps);

  App.Spot = (function() {

    function Spot(attr) {
      this.lat = Number(attr.lat);
      this.lng = Number(attr.lng);
      this.body = attr.body || '';
      this.listItem = new App.SpotListItem(this);
      _.bindAll(this, 'post');
    }

    Spot.prototype.post = function() {
      var data, log;
      data = JSON.stringify({
        lat: this.lat,
        lng: this.lng,
        body: this.body
      });
      log = function(d) {
        return console.log(d);
      };
      $.ajax({
        type: 'POST',
        url: 'spots',
        data: data,
        success: log,
        error: log,
        dataType: 'json'
      });
      return this;
    };

    return Spot;

  })();

}).call(this);
