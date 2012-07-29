(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  App.SpotListItem = (function(_super) {

    __extends(SpotListItem, _super);

    function SpotListItem() {
      SpotListItem.__super__.constructor.apply(this, arguments);
    }

    SpotListItem.prototype.initialize = function(spot) {
      this.spot = spot;
      return _.bindAll(this, 'render');
    };

    SpotListItem.prototype.template = "<span>{{body}}</span>";

    SpotListItem.prototype.render = function() {
      $(this.el).html(Mustache.render(this.template, this.spot));
      return this;
    };

    return SpotListItem;

  })(Backbone.View);

  App.SpotForm = (function(_super) {

    __extends(SpotForm, _super);

    function SpotForm() {
      SpotForm.__super__.constructor.apply(this, arguments);
    }

    SpotForm.prototype.initialize = function(spot) {
      this.spot = spot;
      return _.bindAll(this, 'render');
    };

    SpotForm.prototype.render = function() {
      $(this.el).html(Mustache.render(this.template, this.spot));
      return this;
    };

    SpotForm.prototype.update = function(event) {
      var spot;
      spot = this.getSpot();
      event.preventDefault();
      return spot.post();
    };

    SpotForm.prototype.events = {
      'submit form': "update"
    };

    SpotForm.prototype.template = "<form>\n  <textarea data-lat={{lat}} data-lng={{lng}}>{{body}}</textarea>\n  <input type='submit'>\n</form>";

    SpotForm.prototype.getSpot = function() {
      return new App.Spot({
        lat: $(this.el).find('textarea').attr('data-lat'),
        lng: $(this.el).find('textarea').attr('data-lng'),
        body: $(this.el).find('textarea').val()
      });
    };

    return SpotForm;

  })(Backbone.View);

}).call(this);
