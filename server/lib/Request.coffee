oauth = Npm.require('oauth-client')
Future = Npm.require('fibers/future')
querystring = Npm.require('querystring')

class Othentic.Request

  @METHOD_POST = 'POST'

  @METHOD_GET = 'GET'

  constructor: (@https, @host, @port, @path, @signer, @rejectUnauthorized=true)->
    @params = {}
    @headers = {}
    @body = null
    @setMethodGet()

  execute: ->
    requestSettings = @buildRequestSettings()
    future = new Future()
    request = oauth.request(requestSettings)

    request.on 'response', (response)->
      response.setEncoding('utf8')
      data = ''
      response.on 'data', (chunk)->
        data += chunk
        return
      response.on 'end', ->
        unless future.isResolved()
          future.return([null, response, data])
        return
      response.on 'close', ->
        unless future.isResolved()
          future.return([new Othentic.InternalError("Connection closed", requestSettings), null, null])
        return
      return

    request.on 'error', (err)->
      Log.error("Othentic::Request received error on http connection", requestSettings, err)
      unless future.isResolved()
        future.return([new Othentic.InternalError("Connection closed", requestSettings), null, null])
      return

    if requestSettings.body?
      request.write(requestSettings.body)
    else if @body?
      request.write(@body)

    request.end()

    [err, response, data] = future.wait()
    if err?
      throw err

    if response.statusCode < 200 or 299 < response.statusCode
      throw new Othentic.InternalError("Bad response code: #{response.statusCode} data:#{data}")

    return data

  buildRequestSettings: ->
    settings =
      https: @https
      host: @host
      port: @port
      path: @buildPath()
      method: @method
      oauth_signature: @signer
      headers: @headers
      rejectUnauthorized: @rejectUnauthorized
      requestCert: @rejectUnauthorized

    if @body?
      # work around for oauth package - it serializes the body even if it isn't form-encoded (http://tools.ietf.org/html/rfc5849#section-3.4.1.3)
      # so we'll only send the body if it is
      if 'content-type' not of @headers or @headers['content-type'] == 'application/x-www-form-urlencoded'
        settings.body = @body
      # need to set the content-length even when providing manually
      settings.headers['content-length'] = Buffer.byteLength(@body)

    return settings


  buildPath: ->
    return URI(@path).addQuery(@params).toString()

  setToken: (@token)->

  setMethod: (@method)->

  setMethodPost: ->
    @setMethod(Othentic.Request.METHOD_POST)

  setMethodGet: ->
    @setMethod(Othentic.Request.METHOD_GET)

  setPath: (@path)->

  setParams: (@params)->

  setParam: (key, value)->
    @params[key] = value
    return

  setHeaders: (@headers)->

  setHeader: (key, value)->
    @headers[key] = value
    return

  setBody: (@body)->
