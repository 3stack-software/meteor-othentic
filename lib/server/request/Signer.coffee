oauth = Npm.require('oauth-client')

###
  This function is responsible for building an 'oauth.Signature'
  based on a consumer, signature method & token (optional)
###
Othentic.Signer = (consumerKey, consumerSecret, signatureMethod, token = null)->
  consumer = oauth.createConsumer(consumerKey, consumerSecret)
  if token?
    oToken = oauth.createToken(token.key, token.secret)

  if signatureMethod == 'PLAINTEXT'
    return oauth.createSignature(consumer, oToken)

  if signatureMethod == 'HMAC-SHA1'
    return oauth.createHmac(consumer, oToken)

  throw new Othentic.InternalError("Unknown signature method #{signatureMethod}")
