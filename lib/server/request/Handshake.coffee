class Othentic.Handshake
  constructor: (@providerId, @userId)->

  obtainRequestTokenAndAuthoriseUrl: (callbackUrl)->
    @getAndSaveServiceConfiguration()
    tokenKey = @obtainAndStoreRequestToken(callbackUrl)
    return @getAuthoriseUrl(tokenKey)


  obtainAndStoreAccessToken: (requestTokenKey, requestVerifier)->
    @getAndSaveServiceConfiguration()
    tokenStore = @getTokenStore()
    requestToken = tokenStore.getRequestToken(requestTokenKey)
    accessToken = @obtainAccessToken(requestToken, requestVerifier)
    tokenStore.putAccessToken(accessToken.key, accessToken.secret)

    Othentic.events.emit "newAccessToken", null,
      providerId: @providerId
      userId: @userId
      serviceConfiguration: @serviceConfiguration
      accessToken: accessToken
    return

  getAndSaveServiceConfiguration: ->
    @serviceConfiguration = @getServiceConfiguration()
    return

  getTokenStore: ->
    builder = new Othentic.TokenStoreBuilder(@providerId, @userId)
    builder.setServiceConfiguration(@serviceConfiguration)
    return builder.build()

  getServiceConfiguration: ->
    serviceConfiguration = Othentic.getProviderServiceConfigurationForUser(@providerId, @userId)

    unless serviceConfiguration?
      throw new Othentic.BadRequestError()
    return serviceConfiguration

  obtainAndStoreRequestToken: (callbackUrl)->
    token = @obtainRequestToken(callbackUrl)
    tokenStore = @getTokenStore()
    tokenStore.putRequestToken(token.key, token.secret)
    return token.key

  obtainRequestToken: (callbackUrl)->
    request = new Othentic.TemporaryCredentialRequest(@serviceConfiguration)
    request.setCallbackUrl(callbackUrl)
    return request.execute()

  getAuthoriseUrl: (tokenKey)->
    builder = new Othentic.AuthoriseUrlBuilder(@serviceConfiguration, tokenKey)
    return builder.build()

  obtainAccessToken: (requestToken, verifier)->
    request = new Othentic.TokenRequest(@serviceConfiguration, requestToken, verifier)
    return request.execute()
