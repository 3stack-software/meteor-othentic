###
  This class is responsible for setting required
  parameters on a request based on a service configuration

###
class Othentic.RequestBuilder

  constructor: (@serviceConfiguration)->
    @path = null

  build: ->
    unless @path?
      throw new Othentic.InternalError("Request builder requires a path")

    signer = @getSigner()
    request = new Othentic.Request(
      @serviceConfiguration.https,
      @serviceConfiguration.host,
      @serviceConfiguration.port,
      @path,
      signer,
      @serviceConfgiuration.verifyCertificate == null || @serviceConfgiuration.verifyCertificate
    )
    return request

  getSigner: ->
    signer = new Othentic.SignatureBuilder(
      @serviceConfiguration.consumerKey,
      @serviceConfiguration.consumerSecret,
      @serviceConfiguration.signatureMethod,
    )
    signer.setToken(@token)
    return signer.build()

  setPath: (@path)->

  setPathToAccessTokenEndpoint: ->
    @path = @serviceConfiguration.endpoints.accessToken
    return

  setPathToRequestTokenEndpoint: ->
    @path = @serviceConfiguration.endpoints.requestToken
    return

  setToken: (@token)->
