
class Othentic.InitiateHandshakeHandler
  constructor: (@params, @response)->
    @callbackUrl = 'oob'


  setCallbackUrl: (callbackUrl)->
    if callbackUrl == 'oob'
      @callbackUrl = callbackUrl
    else
      uri = URI(callbackUrl)
      if 'close' of @params.query
        uri.addQuery('close')
      else if @params.query.redirect
        uri.addQuery('redirect', @params.query.redirect)
      @callbackUrl = uri.toString()
    return

  obtainRequestTokenAndRedirect: ->
    try
      @tryObtainRequestTokenAndRedirect()
    catch err
      @respondToError(err)
    return

  tryObtainRequestTokenAndRedirect: ->
    handshake = new Othentic.Handshake(@params.providerId, @params.userId)
    authoriseUrl = handshake.obtainRequestTokenAndAuthoriseUrl(@callbackUrl)

    if @canRedirectToUrl(authoriseUrl)
      @response.writeHead(302, {'Location': authoriseUrl})
      @response.end()
    else
      @response.writeHead(200, {'Content-Type': 'text/html'} )
      @response.end(@newWindowTemplate(authoriseUrl))
    return

  canRedirectToUrl: (url)->
    redirect = true
    if @params.query.requireNewWindow
      return false

    if @params.query.iframe
      uri = URI(url)
      if @params.query.hostname
        expression = new RegExp(@params.query.hostname)
        redirect &&= expression.test(uri.hostname())
      if @params.query.scheme
        expression = new RegExp(@params.query.scheme)
        redirect &&= expression.test(uri.scheme())

    return redirect

  newWindowTemplate: (url)->
    return """
<!DOCTYPE html>
<html><body><div style="margin: 10px; padding: 10px; font-family: verdana, sans-serif; border: 1px solid #333333; background: #f1f1f1;">To complete authorisation, open the following link:
<a href="#{_.escape(url)}" target="_blank" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-top: 10px; display: block;">#{_.escape(url)}</a>
</div></body></html>
"""

  respondToError: (err)->
    Log.error(err)
    @response.writeHead(500)
    @response.end('There was an error connecting to server. Check your integration configuration, or try again later.')
    return

