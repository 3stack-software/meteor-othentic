oauth = Npm.require('oauth-client')

###
  This class is responsible for building an 'oauth.Signature'
  based on a consumer, signature method & token (optional)
###
class Othentic.SignatureBuilder
  constructor: (@consumerKey, @consumerSecret, @signatureMethod)->
    @token = null

  setToken: (@token)->

  build: ->
    consumer = @getConsumer()
    token = null
    if @token?
      token = oauth.createToken(@token.key, @token.secret)
    return @createSigner(consumer, token)

  getConsumer: ->
    return oauth.createConsumer(@consumerKey, @consumerSecret)

  createSigner: (consumer, token=null)->
    switch @signatureMethod
      when 'PLAINTEXT' then oauth.createSignature(consumer, token)
      when 'HMAC-SHA1' then oauth.createHmac(consumer, token)
      else throw new Othentic.InternalError("Unknown signature method #{@signatureMethod}")
