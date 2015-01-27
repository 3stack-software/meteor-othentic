Router.route '/_othentic/:providerId/:userId/initiateHandshake', ->
  handler = new Othentic.InitiateHandshakeHandler(@params, @response)
  handler.setCallbackUrl(Router.url('othentic.callbackUrl', {
    providerId: @params.providerId,
    userId: @params.userId
  }))
  handler.obtainRequestTokenAndRedirect()
,
  name: 'othentic.initiateHandshake'
  where: 'server'

Router.route '/_othentic/:providerId/:userId/callbackUrl', ->
  handler = new Othentic.CallbackUrlHandler(@params, @response)
  handler.obtainAccessTokenAndRespond()
  return
,
  name: 'othentic.callbackUrl'
  where: 'server'

