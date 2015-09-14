Othentic.initiateHandshakePopup = (providerId, userId, callback)->
  beforeShown = ($modal)->
    $modal.one 'hidden.bs.modal', ->
      callback?()
      return
    return

  handshakeUrl = Router.url('othentic.initiateHandshake', {providerId: providerId, userId: userId}, {query: { close: ''}})
  Remodal.open('othentic_connectModal', {
    providerId: providerId,
    handshakeUrl: handshakeUrl
  }, beforeShown)

  window.open(handshakeUrl, 'othentic-' + providerId)
  return
