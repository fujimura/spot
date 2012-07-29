class App.SpotListItem extends Backbone.View
  initialize: (spot) ->
    @spot = spot
    _.bindAll @, 'render'
  template: \
    """
    <span>{{body}}</span>
    """
  render: ->
    $(@el).html Mustache.render(@template, @spot)
    @

class App.SpotForm extends Backbone.View
  initialize: (spot) ->
    @spot = spot
    _.bindAll @, 'render'
  render: ->
    $(@el).html Mustache.render(@template, @spot)
    @
  update: (event) ->
    spot = @getSpot()
    event.preventDefault()
    spot.post()
  events:
    'submit form': "update"
  template:
    # TODO move to partial
    """
    <form>
      <textarea data-lat={{lat}} data-lng={{lng}}>{{body}}</textarea>
      <input type='submit'>
    </form>
    """
  getSpot: ->
    new App.Spot
      lat:  $(@el).find('textarea').attr 'data-lat'
      lng:  $(@el).find('textarea').attr 'data-lng'
      body: $(@el).find('textarea').val()
