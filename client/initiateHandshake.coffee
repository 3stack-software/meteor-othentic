handshakeOptions = {}
Othentic.setHandshakeOptions = (providerId, queryParameters, cookieCheckUrl)->
  handshakeOptions[providerId] = {
    params: queryParameters,
    cookieCheckUrl: cookieCheckUrl
  }
  return

Othentic.initiateHandshakePopup = (providerId, userId, callback)->
  beforeShown = ($modal)->
    $modal.one 'hidden.bs.modal', ->
      callback?()
      return
    return

  options = handshakeOptions[providerId] or {}
  query = _.extend({iframe: true}, options.params)
  successUrl = Router.url('othentic.initiateHandshake', {providerId: providerId, userId: userId}, {query: query})
  if options.cookieCheckUrl
    failureUrl = Router.url('othentic.initiateHandshake', {providerId: providerId, userId: userId}, {query: {requireNewWindow: true}})
    url = URI(options.cookieCheckUrl).query({success: successUrl, failure: failureUrl}).toString()
  else
    url = successUrl

  Remodal.open('othentic_connectModal', {
    providerId: providerId,
    oauthUrl: url
  }, beforeShown)
  return
