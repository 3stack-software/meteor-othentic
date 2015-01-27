#
Router.map ->

  @route 'othentic.initiateHandshake',
    path: '/_othentic/:providerId/:userId/initiateHandshake'
    where: 'server'

  return
