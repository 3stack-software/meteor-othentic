Meteor.publish "othentic.providers", ->
  return Othentic.providers.find({},{
      fields:{
        _id: 1,
        name: 1,
        website: 1
        autoStatus: 1
      }
    })

Meteor.publish 'othentic.status', (providerId, serviceConfigurationId)->
  unless @userId? and serviceConfigurationId?
    @added('othentic.status', providerId, {status: Othentic.STATUS_UNAVAILABLE, expiry: null})
    @ready()
    return
  # Ignore `serviceConfigurationId` - Just used to cause the subscription to refresh

  serviceConfiguration = Othentic.getProviderServiceConfigurationForUser(providerId, @userId)

  unless serviceConfiguration?
    @added('othentic.status', providerId, {status: Othentic.STATUS_UNAVAILABLE, expiry: null})
    @ready()
    return

  accessTokenExpiry =  serviceConfiguration.tokenExpiry?[Othentic.TokenStore.TYPE_ACCESS] ? Othentic.TokenStore.DEFAULT_EXPIRY[Othentic.TokenStore.TYPE_ACCESS]

  recheckInterval = 30 * 60 * 1000 # 30 mins?
  tokensExpiries = {}
  currentStatus = Othentic.STATUS_AVAILABLE
  currentExpiry = null
  getStatus = ->
    expiries = _.values(tokensExpiries)
    if expiries.length
      newestToken = Math.max.apply(Math, expiries)
      newestToken += accessTokenExpiry
      newestToken -= recheckInterval
      return [Othentic.STATUS_CONNECTED, newestToken]
    else
      return [Othentic.STATUS_AVAILABLE, null]

  currentHandle = null

  firstRun = true
  initialising = true

  tokenCountChanged = ()=>
    [newStatus, newExpiry] = getStatus()
    if currentStatus != newStatus or currentExpiry != newExpiry
      currentStatus = newStatus
      currentExpiry = newExpiry
      @changed('othentic.status', providerId, {status: currentStatus, expiry: newExpiry})
    return

  onTokenAdded = (r)->
    tokensExpiries[r._id] = r.createdAt
    tokenCountChanged() unless initialising
    return

  onTokenRemoved = (r)->
    delete tokensExpiries[r._id]
    tokenCountChanged()
    return

  userId = @userId
  recheck = ->
    if currentHandle?
      currentHandle.stop()
    tokensExpiries = {}
    initialising = true
    currentHandle = Othentic.userTokens.find({
      providerId: providerId
      serviceConfigurationId: serviceConfiguration._id
      userId: userId
      type: Othentic.TokenStore.TYPE_ACCESS
      createdAt: {
        $gt: +(new Date()) - accessTokenExpiry - recheckInterval
      }
    }).observe({
      added: onTokenAdded,
      removed: onTokenRemoved
    })
    initialising = false
    tokenCountChanged() unless firstRun
    return

  recheck()
  [currentStatus, currentExpiry] = getStatus()
  @added('othentic.status', providerId, {status: currentStatus, expiry: currentExpiry})
  @ready()

  firstRun = false
  recheckHandle = Meteor.setInterval(recheck, recheckInterval)

  @onStop ()->
    currentHandle.stop()
    Meteor.clearTimeout(recheckHandle)
    return
  return
