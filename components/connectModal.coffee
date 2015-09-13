Template.othentic_connectModal.created = ->
  providerId = @data.providerId
  @loading = new ReactiveVar(true)
  connected = @connected = new ReactiveVar(false)
  minimumExpiry = null
  @autorun (c)->
    {status, expiry} = Othentic.providerStatus.findOne(providerId)
    if c.firstRun
      minimumExpiry = expiry
    else if status == Othentic.STATUS_CONNECTED and expiry > minimumExpiry
      connected.set(true)
      setTimeout((()-> Remodal.close()), 2000)
    return
  return


Template.othentic_connectModal.rendered = ->
  loading = @loading
  timeout = Meteor.setTimeout ()->
    timeout = null
    loading.set(false)
    return
  , 5000

  @$('iframe').load ()->
    loading.set(false)
    Meteor.clearTimeout(timeout)
    return
  return


Template.othentic_connectModal.helpers
  loading: -> Template.instance().loading.get()
  connected: -> Template.instance().connected.get()
  providerName: -> Othentic.providers.findOne(@providerId, {fields: {name: true}}).name

