Meteor.methods
  'othentic.request': (providerId, method, path, params, body, headers)->
    @unblock()

    serviceConfiguration = Othentic.getProviderServiceConfigurationForUser(providerId, @userId)

    tokenStoreBuilder = new Othentic.TokenStoreBuilder(providerId, @userId)
    tokenStoreBuilder.setServiceConfiguration(serviceConfiguration)
    tokenStore = tokenStoreBuilder.build()

    token = tokenStore.findAccessToken()

    requestBuilder = new Othentic.RequestBuilder(serviceConfiguration)
    requestBuilder.setToken(token)
    requestBuilder.setPath(path)
    request = requestBuilder.build()

    request.setMethod(method)
    request.setParams(params)
    if body? or method == 'POST'
      request.setBody(body)
    request.setHeaders(headers)

    data = request.execute()
    return data

  'othentic.get': (providerId, path, params, headers)->
    @unblock()
    return Meteor.call('othentic.request', providerId, 'GET', path, params, null, headers)

  'othentic.post': (providerId, path, params, body, headers)->
    @unblock()
    return Meteor.call('othentic.request', providerId, 'POST', path, params, body, headers)

  'othentic.jsonrpc': (providerId, endpoint, method, params)->
    @unblock()
    id = Random.id()
    requestText = JSON.stringify
      id: id
      method: method
      params: params

    headers =
      "content-type": "application/json"
      "accept": "application/json"

    responseText = Meteor.call('othentic.post', providerId, endpoint, {}, requestText, headers)
    response = JSON.parse(responseText)
    if ('error' of response and response.error?) or response.id != id or 'result' not of response
      throw new Meteor.Error(500, "request: #{requestText}\n response:#{responseText}")

    return response.result

  'othentic.status': (providerId)->
    try
      builder = new Othentic.TokenStoreBuilder(providerId, @userId)
      tokenStore = builder.build()
    catch err
      return Othentic.STATUS_UNAVAILABLE

    try
      token = tokenStore.findAccessToken()
    catch err
      return Othentic.STATUS_AVAILABLE

    return Othentic.STATUS_CONNECTED

  'othentic.serviceConfigurations.insert': (providerId, settings)->
    check(providerId, MatchLib.NonEmptyString)

    provider = Othentic.providers.findOne(providerId)

    baseValues =
      providerId: providerId
    serviceConfiugration = _.extend(provider.defaults or {}, settings, baseValues)

    if '_id' of serviceConfiugration
      delete serviceConfiugration._id

    return Othentic.serviceConfigurations.insert(serviceConfiugration)

  'othentic.serviceConfigurations.remove': (providerId, serviceConfigurationId)->
    check(providerId, MatchLib.NonEmptyString)
    check(serviceConfigurationId, MatchLib.RandomId)
    Othentic.serviceConfigurations.remove
      _id: serviceConfigurationId
      providerId: providerId
    Othentic.userTokens.remove
      serviceConfigurationId: serviceConfigurationId
      providerId: providerId
    return
