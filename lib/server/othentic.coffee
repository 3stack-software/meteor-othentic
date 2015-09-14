EventEmitter2 = Npm.require('eventemitter2').EventEmitter2


_.extend(Othentic, {
  events: new EventEmitter2(),
  serviceConfigurations: new Mongo.Collection("othentic.serviceConfigurations", {_preventAutoPublish: true})
  providers: new Mongo.Collection("othentic.providers")
  userTokens: new Mongo.Collection("othentic.userTokens", {_preventAutoPublish: true})

  getProviderServiceConfigurationForUser: (providerId, userId)->
    throw new Othentic.InternalError("Please provide you own implementation of 'Othentic.getProviderServiceConfigurationForUser(userId)'")

  getServiceConfigurationById: (serviceConfigurationId)->
    serviceConfiguration = Othentic.serviceConfigurations.findOne(serviceConfigurationId)
    unless serviceConfiguration?
      throw new Othentic.BadRequestError("Could not find service configuration #{serviceConfigurationId}")
    return serviceConfiguration

  getStatus: (userId, providerId)->
    try
      builder = new Othentic.TokenStoreBuilder(providerId, userId)
      tokenStore = builder.build()
    catch err
      return Othentic.STATUS_UNAVAILABLE

    try
      token = tokenStore.findAccessToken()
    catch err
      return Othentic.STATUS_AVAILABLE

    return Othentic.STATUS_CONNECTED

  addServiceConfiguration: (providerId, settings)->
    check(providerId, MatchLib.NonEmptyString)

    provider = Othentic.providers.findOne(providerId)

    baseValues =
      providerId: providerId
    serviceConfiugration = _.extend(provider.defaults or {}, settings, baseValues)

    if '_id' of serviceConfiugration
      delete serviceConfiugration._id

    return Othentic.serviceConfigurations.insert(serviceConfiugration)

  removeServiceConfiguration: (providerId, serviceConfigurationId)->
    check(providerId, MatchLib.NonEmptyString)
    check(serviceConfigurationId, MatchLib.RandomId)
    Othentic.serviceConfigurations.remove
      _id: serviceConfigurationId
      providerId: providerId
    Othentic.userTokens.remove
      serviceConfigurationId: serviceConfigurationId
      providerId: providerId
    return

  HTTP: {
    session: (userId, providerId)->
      serviceConfiguration = Othentic.getProviderServiceConfigurationForUser(providerId, userId)

      if serviceConfiguration.twoLegged
        return Othentic.Session(serviceConfiguration)

      tokenStoreBuilder = new Othentic.TokenStoreBuilder(providerId, userId)
      tokenStoreBuilder.setServiceConfiguration(serviceConfiguration)
      tokenStore = tokenStoreBuilder.build()
      token = tokenStore.findAccessToken()
      return Othentic.Session(serviceConfiguration, token)

    request: (userId, providerId, method, path, params, body, headers)->
      session = Othentic.HTTP.builder(userId, providerId)
      session.setPath(path)
      session.setMethod(method)
      session.setParams(params)
      if body? or method == 'POST'
        session.setBody(body)
      session.setHeaders(headers)

      data = session.execute()
      return data

    get: (userId, providerId, path, params, headers)->
      return Othentic.HTTP.request(userId, providerId, 'GET', path, params, null, headers)

    post: (userId, providerId, path, params, body, headers)->
      return Othentic.HTTP.request(userId, providerId, 'POST', path, params, body, headers)

    jsonRpc: (userId, providerId, endpoint, method, params)->
      id = Random.id()
      requestText = JSON.stringify
        id: id
        method: method
        params: params

      headers =
        "content-type": "application/json"
        "accept": "application/json"

      responseText = Othentic.HTTP.request(userId, providerId, 'POST', endpoint, {}, requestText, headers)
      response = JSON.parse(responseText)

      if response.id != id or 'result' not of response
        Log.error("Invalid response for #{requestText}\n response:#{responseText}")
        throw new Meteor.Error(500, 'Malformed response')

      if ('error' of response and response.error?)
        Log.error("Received error for Request[#{method},#{JSON.stringify(params)}]\n Response[#{responseText}]")
        throw new Meteor.Error(500, response.error)

      return response.result

  }
})
