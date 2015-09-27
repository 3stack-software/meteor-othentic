Package.describe({
  name: '3stack:othentic',
  version: '1.2.2',
  summary: 'A package for authenticating & communicating with 3-legged & 2-legged OAuth 1.0 sources',
  git: 'https://github.com/3stack-software/meteor-othentic',
  documentation: 'README.md'
});

Package.onUse(function (api) {
  // Make 1.2 style packages compatible with Meteor 1.1
  if (!api.addAssets){
    api.addAssets = function(files, where){
      this.addFiles(files, where, {isAsset: true});
    };
  }
  api.versionsFrom('METEOR@1.1.0.2');

  api.use([
    'logging',
    'tracker',
    'coffeescript',
    'check',
    'underscore',
    'mongo',
    'ddp',
    'iron:router@1.0.0',
    '3stack:uri@1.11.2',
    '3stack:match-library@1.0.1',
    '3stack:embox-value@0.2.3'
  ]);
  api.use([
    'templating',
    'spacebars',
    'reactive-dict',
    'reactive-var',
    '3stack:remodal@1.0.1'
  ], 'client');

  Npm.depends({
    "eventemitter2": '0.4.13',
    "oauth-client": '0.3.0'
  });

  api.export('Othentic');

  //MPKGUTIL
  api.addFiles([
    // lib/common/.*
    "lib/common/othentic.coffee"
  ], ["client", "server"]);

  api.addFiles([
    // lib/client/.*
    "lib/client/initiateHandshake.coffee",
    "lib/client/status.coffee"
  ], ["client"]);

  api.addFiles([
    // lib/server/.*
    "lib/server/othentic.coffee",
    "lib/server/error/BadRequestError.coffee",
    "lib/server/error/InternalError.coffee",
    "lib/server/error/NoTokenError.coffee",
    "lib/server/handlers/CallbackUrlHandler.coffee",
    "lib/server/handlers/InitiateHandshakeHandler.coffee",
    "lib/server/request/AuthorisationUrl.coffee",
    "lib/server/request/Handshake.coffee",
    "lib/server/request/Request.coffee",
    "lib/server/request/Session.coffee",
    "lib/server/request/Signer.coffee",
    "lib/server/request/TemporaryCredentialRequest.coffee",
    "lib/server/request/TokenRequest.coffee",
    "lib/server/token/TokenStore.coffee",
    "lib/server/token/TokenStoreBuilder.coffee"
  ], ["server"]);

  api.addFiles([
    // publications/.*
    "publications/publications.coffee"
  ], ["server"]);

  api.addFiles([
    // components/.*\.html
    // components/.*\.(js|jsx|coffee)
    "components/connectModal.html",
    "components/connectModal.coffee"
  ], ["client"]);

  api.addFiles([
    // routes-server/.*
    "routes-server/routing.coffee"
  ], ["server"]);

  api.addFiles([
    // routes-client/.*
    "routes-client/routing.coffee"
  ], ["client"]);

  api.addAssets([
    // assets/.*
    "assets/close.js"
  ], ["client", "server"]);
  //MPKGUTIL
});
