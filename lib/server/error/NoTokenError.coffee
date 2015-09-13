class Othentic.NoTokenError extends Error
  constructor: (@message)->
    super
    @sanitizedError = new Meteor.Error(401, "No Token", @message)