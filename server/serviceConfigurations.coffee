_.extend(Othentic, {
  serviceConfigurations: new Mongo.Collection("othentic.serviceConfigurations", {_preventAutoPublish: true})
  providers: new Mongo.Collection("othentic.providers")
  userTokens: new Mongo.Collection("othentic.userTokens", {_preventAutoPublish: true})

  getProviderServiceConfigurationForUser: (providerId, userId)->
    throw new Othentic.InternalError("Please provide you own implementation of 'Othentic.getProviderServiceConfigurationForUser(userId)'")

  getServiceConfigurationById: (serviceConfigurationId)->
    serviceConfiguration = Othentic.serviceConfigurations.findOne(serviceConfigurationId)
    unless serviceConfiguration?
      throw new Othentic.BadRequestError("Could not find service configuration #{serviceConfigurationId}")
    return serviceConfiguration
})
