class Othentic.BadRequestError extends Error
  constructor: (@message)->
    super
    @sanitizedError = new Meteor.Error(400, "Bad Request", @message)
