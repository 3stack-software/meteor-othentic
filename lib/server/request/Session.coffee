###
  This function is responsible for setting required
  parameters on a request based on a service configuration

###
Othentic.Session = (serviceConfiguration, token = null)->
  signer = Othentic.Signer(
    serviceConfiguration.consumerKey,
    serviceConfiguration.consumerSecret,
    serviceConfiguration.signatureMethod,
    token
  )
  session = new Othentic.Request(
    serviceConfiguration.https,
    serviceConfiguration.host,
    serviceConfiguration.port,
    signer,
    serviceConfiguration.verifyCertificate == null || serviceConfiguration.verifyCertificate
  )
  return session

