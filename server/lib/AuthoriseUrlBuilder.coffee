class Othentic.AuthoriseUrlBuilder

  constructor: (@serviceConfiguration, @tokenKey)->

  build: ->
    scheme = if @serviceConfiguration.https then 'https' else 'http'
    host = @serviceConfiguration.host
    path = @serviceConfiguration.endpoints.authorise

    if @canOmitPort(@serviceConfiguration.port, scheme)
      port = ''
    else
      port = ":" + @serviceConfiguration.port
    return "#{scheme}://#{host}#{port}#{path}?oauth_token=#{@tokenKey}"

  canOmitPort: (port, scheme)->
    return (port == 443 and scheme == 'https') or (port == 80 and scheme == 'http')
