
class Othentic.TokenStore

  @TYPE_REQUEST = 'request'
  @TYPE_ACCESS = 'access'

  @DEFAULT_EXPIRY = {
    request: 30*60*1000 # 30 mins
    access: 30*24*60*60*1000 # 30 days
  }

  constructor: (@providerId, @serviceConfigurationId, @userId)->
    @tokenExpiry = {}
    @tokenExpiry[Othentic.TokenStore.TYPE_REQUEST] = Othentic.TokenStore.DEFAULT_EXPIRY[Othentic.TokenStore.TYPE_REQUEST]
    @tokenExpiry[Othentic.TokenStore.TYPE_ACCESS] = Othentic.TokenStore.DEFAULT_EXPIRY[Othentic.TokenStore.TYPE_ACCESS]

  setTokenExpiry: (type, duration)->
    @tokenExpiry[type] = duration
    return


  putRequestToken: (key, secret)->
    @put(Othentic.TokenStore.TYPE_REQUEST, key, secret)
    return

  getRequestToken: (key)->
    return @get(Othentic.TokenStore.TYPE_REQUEST, key)

  putAccessToken: (key, secret)->
    @put(Othentic.TokenStore.TYPE_ACCESS, key, secret)
    return

  getAccessToken: (key)->
    return @get(Othentic.TokenStore.TYPE_ACCESS, key)

  findAccessToken: ->
    return @find(Othentic.TokenStore.TYPE_ACCESS)

  put: (type, key, secret)->
    Othentic.userTokens.insert
      providerId: @providerId
      serviceConfigurationId: @serviceConfigurationId
      userId: @userId
      createdAt: +(new Date())
      type: type
      key: key
      secret: secret
    return

  get: (type, key)->
    query =
      providerId: @providerId
      serviceConfigurationId: @serviceConfigurationId
      userId: @userId
      type: type
      key: key
      createdAt:
        $gt: +(new Date()) - @tokenExpiry[type]

    token = Othentic.userTokens.findOne(query)
    unless token?
      throw new Othentic.NoTokenError("Token not found '#{type}':'#{key}' for user:'#{@userId}' under service configuration #{@providerId}:#{@serviceConfigurationId}")
    return {
      key: token.key,
      secret: token.secret
    }

  find: (type)->
    query =
      providerId: @providerId
      serviceConfigurationId: @serviceConfigurationId
      userId: @userId
      type: type
      createdAt:
        $gt: +(new Date()) - @tokenExpiry[type]

    token = Othentic.userTokens.findOne query,
      sort:
        createdAt: -1

    unless token?
      throw new Othentic.NoTokenError("No token un-expired found '#{type}' for user:'#{@userId}' under service configuration #{@providerId}:#{@serviceConfigurationId}")
    return {
      key: token.key,
      secret: token.secret
    }

  clean: ->
    Othentic.userTokens.remove
      providerId: @providerId
      serviceConfigurationId: @serviceConfigurationId
      userId: @userId
      $or:
        [
          {
            type: Othentic.TokenStore.TYPE_ACCESS
            createdAt:
              $lt:  +(new Date()) - @tokenExpiry[Othentic.TokenStore.TYPE_ACCESS]
          },
          {
            type: Othentic.TokenStore.TYPE_REQUEST
            createdAt:
              $lt:  +(new Date()) - @tokenExpiry[Othentic.TokenStore.TYPE_REQUEST]
          }
        ]
    return
