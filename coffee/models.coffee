class Sache.Map extends GMaps

class Sache.Spot
  constructor: (attr) ->
    @lat = Number attr.lat
    @lng = Number attr.lng
    @body = attr.body || ''
    @listItem = new Sache.SpotListItem @
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
