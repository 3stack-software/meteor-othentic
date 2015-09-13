class Othentic.CallbackUrlHandler
  constructor: (@params, @response)->

  obtainAccessTokenAndRespond: ->
    try
      @tryObtainAccessTokenAndRespond()
    catch err
      @respondToError(err)
    return

  tryObtainAccessTokenAndRespond: ->
    @checkRequiredParametersAndObtainAccessToken()
    @respondToAuthoriseCallback()
    return

  checkRequiredParametersAndObtainAccessToken: ->
    unless @params.query.oauth_token? and @params.query.oauth_verifier?
      throw new Othentic.BadRequestError()
    handshake = new Othentic.Handshake(@params.providerId, @params.userId)
    handshake.obtainAndStoreAccessToken(@params.query.oauth_token, @params.query.oauth_verifier)
    return

  respondToAuthoriseCallback: ->
    if 'close' of @params.query
      @response.writeHead(200, {'Content-Type': 'text/html'})
      @response.end('<html><head><script>window.close()</script></head></html>', 'utf-8')
    else if @params.query.redirect?
      @response.writeHead(302, {'Location': @params.query.redirect})
      @response.end()
    else
      @response.writeHead(200, {'Content-Type': 'text/html'});
      @response.end(@authorisationCompleteTemplate(), 'utf-8');
    return

  authorisationCompleteTemplate: ()->
    return """
<!DOCTYPE html>
<html><body><div style="margin: 10px; padding: 10px; font-family: verdana, sans-serif; border: 1px solid #333333; background: #f1f1f1;">Authorisation complete.
</div></body></html>
"""


  respondToError: (err)->
    Log.error(err)
    @response.writeHead(500)
    @response.end('There was an error communicating with the server. Check your integration configuration, or try again later.')
    return
