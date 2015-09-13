class Othentic.InternalError extends Error
  constructor: (@message)->
    super
    @sanitizedError = new Meteor.Error(500, "Internal Error", @message)