

_.extend(Othentic,{
  providers: new Mongo.Collection("othentic.providers")

  providerStatus: new Mongo.Collection("othentic.status")

  providerHandle: Meteor.subscribe("othentic.providers")

  statusByProvider: new ReactiveDict()

  status: (providerId)-> Othentic.statusByProvider.get(providerId)

  isStatus: (providerId, status)-> Othentic.statusByProvider.equals(providerId, status)

  notStatus: (providerId, status)-> !Othentic.statusByProvider.equals(providerId, status)

  getServiceConfigurationId: (providerId)-> null
})


###
  Monitors the Othentic.providers collection, and sets-up a subscription to monitor the status of each.

  Then, it monitors the providerStatus collection for changes, and sets the results in `statusByProvider`

###
class StatusMapper

  setStatus: (record)->
    Othentic.statusByProvider.set(record._id, record.status)
    return

  clearStatus: (record)->
    Othentic.statusByProvider.set(record._id, Othentic.STATUS_UNKNOWN)
    return

  subscribeToProviderStatus: (providerId)->
    return ->
      serviceConfigurationId = Othentic.getServiceConfigurationId(providerId)
      Meteor.subscribe('othentic.status', providerId, serviceConfigurationId)
      return

  run: ->
    # get a list of each provider, and ensure that we're subscribed
    providerIds = []
    Othentic.providers.find({autoStatus: true}).forEach (provider)=>
      Othentic.statusByProvider.set(provider._id, Othentic.STATUS_UNKNOWN)
      providerIds.push(provider._id)
      # this autorun will get torn down automatically if this computation re-runs
      Tracker.autorun(@subscribeToProviderStatus(provider._id))
      return

    Othentic.providerStatus.find({_id: {$in: providerIds}}).observe({
      added: @setStatus,
      changed: @setStatus,
      removed: @clearStatus
    })
    return

  bind: -> Tracker.autorun(_.bind(@run, this))


Meteor.startup ()->
  mapper = new StatusMapper()
  mapper.bind()
  return

