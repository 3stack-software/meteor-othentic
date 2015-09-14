querystring = Npm.require('querystring')


class Othentic.TemporaryCredentialRequest
  constructor: (@serviceConfiguration)->
    @callbackUrl = 'oob'

  setCallbackUrl: (@callbackUrl)->

  execute: ->
    session = @getSession()
    data = session.execute()
    return @parseResponse(data)

  getSession: ->
    session = Othentic.Session(@serviceConfiguration)
    session.setPath(@serviceConfiguration.endpoints.requestToken)
    session.setParam('oauth_callback', @callbackUrl)
    return session

  parseResponse: (data)->
    parsedData = querystring.parse(data)

    unless parsedData.oauth_token? and parsedData.oauth_token_secret?
      throw new Othentic.InternalError("Response did not provide 'oauth_token' and 'oauth_token_secret' - #{data}")

    return {
      key: parsedData.oauth_token
      secret: parsedData.oauth_token_secret
    }
