querystring = Npm.require('querystring')

class Othentic.TokenRequest
  constructor: (@serviceConfiguration, @requestToken, @verifier)->

  execute: ->
    session = @getSession()
    data = session.execute()
    return @parseResponse(data)

  getSession: ->
    session = Othentic.Session(@serviceConfiguration, @requestToken)
    session.setPath(@serviceConfiguration.endpoints.accessToken)
    session.setParam('oauth_verifier', @verifier)
    return session

  parseResponse: (data)->
    parsedData = querystring.parse(data)

    unless parsedData.oauth_token? and parsedData.oauth_token_secret?
      throw new Othentic.InternalError("Response did not provide 'oauth_token' and 'oauth_token_secret' - #{data}")

    return {
      key: parsedData.oauth_token
      secret: parsedData.oauth_token_secret
    }
