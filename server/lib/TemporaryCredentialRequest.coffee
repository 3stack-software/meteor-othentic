querystring = Npm.require('querystring')


class Othentic.TemporaryCredentialRequest
  constructor: (@serviceConfiguration)->
    @callbackUrl = 'oob'

  setCallbackUrl: (@callbackUrl)->

  execute: ->
    request = @buildRequest()
    data = request.execute()
    return @parseResponse(data)

  buildRequest: ->
    builder = new Othentic.RequestBuilder(@serviceConfiguration)
    builder.setPathToRequestTokenEndpoint()
    request = builder.build()
    request.setParam('oauth_callback', @callbackUrl)
    return request

  parseResponse: (data)->
    parsedData = querystring.parse(data)

    unless parsedData.oauth_token? and parsedData.oauth_token_secret?
      throw new Othentic.InternalError("Response did not provide 'oauth_token' and 'oauth_token_secret' - #{data}")

    return {
      key: parsedData.oauth_token
      secret: parsedData.oauth_token_secret
    }
