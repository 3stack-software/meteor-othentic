class Othentic.TokenStoreBuilder

  constructor: (@providerId, @userId)->
    @serviceConfiguration = null

  setServiceConfiguration: (@serviceConfiguration)->

  build: ->
    unless @serviceConfiguration?
      @serviceConfiguration = Othentic.getProviderServiceConfigurationForUser(@providerId, @userId)

    tokenStore = new Othentic.TokenStore(@providerId, @serviceConfiguration._id, @userId)

    if @serviceConfiguration.tokenExpiry?
      if Othentic.TokenStore.TYPE_ACCESS of @serviceConfiguration.tokenExpiry
        tokenStore.setTokenExpiry(Othentic.TokenStore.TYPE_ACCESS, @serviceConfiguration.tokenExpiry[Othentic.TokenStore.TYPE_ACCESS])
      if Othentic.TokenStore.TYPE_REQUEST of @serviceConfiguration.tokenExpiry
        tokenStore.setTokenExpiry(Othentic.TokenStore.TYPE_REQUEST, @serviceConfiguration.tokenExpiry[Othentic.TokenStore.TYPE_REQUEST])
    tokenStore.clean()
    return tokenStore
