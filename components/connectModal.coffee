Template.othentic_connectModal.created = ->
  providerId = @data.providerId
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


Template.othentic_connectModal.helpers
  connected: -> Template.instance().connected.get()
  providerName: -> Othentic.providers.findOne(@providerId, {fields: {name: true}}).name

