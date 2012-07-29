class App.Map extends GMaps
  constructor: (args) ->
    super(args)
    @setContextMenu
      control: "map"
      options: [
        title: "Add marker"
        name: "add_marker"
        action: (e) ->
          spot = new App.Spot
            lat: e.latLng.lat()
            lng: e.latLng.lng()
          @addMarker
            lat: spot.lat
            lng: spot.lng
            title: "New marker"
            infoWindow:
              content: (new App.SpotForm spot).render().el
       ]

class App.Spot
  constructor: (attr) ->
    @lat = Number attr.lat
    @lng = Number attr.lng
    @body = attr.body || ''
    @listItem = new App.SpotListItem @
    _.bindAll @, 'post'

  # FIXME naming
  post: ->
    data = JSON.stringify { lat: @lat, lng: @lng, body: @body }
    log = (d) -> console.log d #TODO FIXME
    $.ajax
      type     : 'POST',
      url      : 'spots',
      data     : data,
      success  : log,
      error    : log,
      dataType : 'json'
    @
