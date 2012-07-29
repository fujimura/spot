init = ->
  new App.Map
    div: "#map"
    lat: (util.getParams("lat") or 35.65980)
    lng: (util.getParams("lng") or 139.69518)
    disableDoubleClickZoom: true
    dblclick: (e) ->
      spot = new App.Spot
        lat: e.latLng.lat()
        lng: e.latLng.lng()
      @addMarker
        lat: spot.lat
        lng: spot.lng
        title: "New marker"
        infoWindow:
          content: (new App.SpotForm spot).render().el

  @spots = []
  $.getJSON '/spots', (data) =>
    _.map data, (d) => @spots.push(new App.Spot d)
    _.each @spots, (s) ->
      $('#spotlist').append s.listItem.render().el
      map.addMarker
        lat   : s.lat
        lng   : s.lng
        infoWindow:
          content: s.body

$(init)
