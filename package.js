Package.describe({
  name: '3stack:othentic',
  version: '1.0.2',
  summary: 'A package for authenticating & communicating with 3-legged & 2-legged OAuth 1.0 sources',
  git: 'https://github.com/3stack-software/meteor-othentic',
  documentation: 'README.md'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@0.9.2');
  //api.use('standard-app-packages');
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
    '3stack:match-library@1.0.1'
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

  api.addFiles(
    [
      'othentic.coffee',
      'common/statuses.coffee'
    ]
  );

  api.addFiles(
    [
      'server/events.coffee',
      'server/error/BadRequestError.coffee',
      'server/error/InternalError.coffee',
      'server/error/NoTokenError.coffee',
      'server/lib/AuthoriseUrlBuilder.coffee',
      'server/lib/Handshake.coffee',
      'server/lib/Request.coffee',
      'server/lib/RequestBuilder.coffee',
      'server/lib/SignatureBuilder.coffee',
      'server/lib/TemporaryCredentialRequest.coffee',
      'server/lib/TokenRequest.coffee',
      'server/lib/TokenStore.coffee',
      'server/lib/TokenStoreBuilder.coffee',
      'server/handlers/CallbackUrlHandler.coffee',
      'server/handlers/InitiateHandshakeHandler.coffee',
      'server/serviceConfigurations.coffee',
      'server/routing.coffee',
      'server/methods.coffee',
      'server/publications.coffee'
    ]
   ,'server');

  api.addFiles(
    [
      'client/connectModal.html',
      'client/connectModal.coffee',
      'client/status.coffee',
      'client/handlebars.coffee',
      'client/routing.coffee',
      'client/initiateHandshake.coffee'
    ],
    'client'
  );
});
