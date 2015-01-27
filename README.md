Othentic
=======================

A package for authenticating & communicating with 3-legged OAuth 1.0 sources

** You should probably come back once better documentation can be written **

Usage
-----------------------


1. On the server, implement your own `Othentic.getProviderServiceConfigurationForUser(providerId, userId)`

eg.

```js
Othentic.getProviderServiceConfigurationForUser = function(providerId, userId){
  // we're going to use the one config for the whole server
  return Othentic.serviceConfigurations.findOne({providerId: providerId});
}
```

2. On the client, implement your own `Othentic.getServiceConfigurationId(providerId)`

eg.

```js
Othentic.getServiceConfigurationId = function(providerId){
  // if we store the configuration used against each users profile
  //return Meteor.user().services[providerId]
  // but in this case, we just want to publish all of them, and share amongst users
  var config = Othentic.serviceConfigurations.findOne({providerId: providerId});
  if (config != null) return config._id;
  else return null;
}

if (Meteor.isServer){
  Meteor.publish(null, function(){
    return Othentic.serviceConfigurations.find({},{ fields: {providerId: true} });
  })
}
```

2 .Create a provider (in mongo):

```js
db.othentic.providers.insert({
  _id: "myOAuthProvdier",
  name: "Provider",
  website: "http://their.website.com",
  autoStatus: true,
  defaults: {
    https: true,
    host: "api.their-host.com",
    port: null,
    signatureMethod: 'HMAC-SHA1',
    consumerKey: '<my key>',
    consumerSecret: '<my secret>',
    endpoints: {
      requestToken: '/request_token',
      authorise: '/authorize',
      accessToken: '/access_token'
    },
    tokenExpiry: {
      access: 604800000,
      request: 1800000
    }
  }
});

```

3. Call `Meteor.call('othentic.serviceConfigurations.insert', 'myOAuthProvider', customSetting)` to create a service configuration


4. On the client, connect the user to the provider: `Othentic.initiateHandshakePopup(providerId, userId, callback)` (Note: you will need a remodal placeholder -> `{{> remodal }}`)

5. Then, check the status with `Othentic.status(providerId)` (Compare against `Othentic.STATUS_*`)

6. Once connected, then you can make requests with `othentic.request`, `othentic.post`, `othentic.get`, and `othentic.jsonrpc`


