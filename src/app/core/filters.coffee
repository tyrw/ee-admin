'use strict'

angular.module('app.core').filter 'centToDollar', ($filter) ->
  (cents) ->
    currencyFilter = $filter('currency')
    currencyFilter Math.floor(cents)/100

angular.module('app.core').filter 'percentage', ($filter) ->
  # Usage: | percentage:2
  (input, decimals) ->
    $filter('number')(input * 100, decimals) + '%'

resizeCloudinaryImageTo = (url, w, h) ->
  if !!url and url.indexOf("image/upload") > -1
    regex = /\/v\d{8,12}\//g
    id = url.match(regex)[0]
    url.split(regex).join('/c_pad,w_' + w + ',h_' + h + id)
  else
    url

angular.module('app.core').filter 'cloudinaryResizeTo', () ->
  # Usage: | cloudinaryResizeTo:400:200
  (input, w, h) -> resizeCloudinaryImageTo input, w, h

angular.module('app.core').filter 'cloudinaryTrim', () ->
  (url) ->
    if !!url and url.indexOf("image/upload") > -1
      regex = /\/v\d{8,12}\//g
      id = url.match(regex)[0]
      url.split(regex).join('/e_trim' + id)
    else
      url

angular.module('app.core').filter 'thumbnail', () ->
  (url) ->
    if !!url and url.indexOf('image/upload') > -1
      url.split('image/upload').join('image/upload/c_pad,w_250,h_250')
    else
      url

angular.module('app.core').filter 'mainImg', () ->
  (url) ->
    if !!url and url.indexOf('image/upload') > -1
      url.split('image/upload').join('image/upload/c_limit,w_500,h_500')
    else
      url

angular.module('app.core').filter 'scaledDownBackground', () ->
  (url) ->
    if url and url.indexOf('h_400,w_1200') > -1
      url.replace('h_400,w_1200', 'h_133,w_400')
    else
      url

angular.module('app.core').filter 'tinyBackground', () ->
  (url) ->
    if !!url and url.indexOf("h_400,w_1200") > -1
      url.replace('h_400,w_1200', 'h_50,w_170')
    else if url and url.indexOf('image/upload')
      url.split('image/upload').join('image/upload/c_limit,h_50,w_170')
    else
      url

angular.module('app.core').filter 'urlText', () ->
  (text) ->
    if !text or typeof(text) isnt 'string' then return ''
    text.toLowerCase().replace(/é/g, 'e').replace(/[^a-z0-9-]/gi, '-').replace(/-+/g,'-')

angular.module('app.core').filter 'unboldHtml', () ->
  (text) -> if typeof text isnt 'string' then return text else return text.replace(/<b>/gi, '').replace(/<\/b>/gi, '')

angular.module('app.core').filter 'truncateQty', () ->
  (text) -> if parseInt(text) > 20 then return '20+' else return text

angular.module('app.core').filter 'rangeToText', () ->
  (range) ->
    if !range?.min and !range?.max then return 'Prices'
    ('$' + Math.floor(range.min)/100 + ' to $' + Math.floor(range.max)/100)
      .replace '$0 to', 'Under'
      .replace 'to $0', 'and above'

angular.module('app.core').filter 'addHttp', () ->
  (text) -> if !!text and text.indexOf('http://') isnt 0 and text.indexOf('https://') isnt 0 then 'http://' + text else text

angular.module('app.core').filter 'pluses', () ->
  (text) ->
    if !text or typeof(text) isnt 'string' then return ''
    text.replace(/ /g, '+')

angular.module('app.core').filter 'humanize', () ->
  (text) ->
    if !text or typeof(text) isnt 'string' then return ''
    frags = text.split /_|-/
    (frags[i] = frags[i].charAt(0).toUpperCase() + frags[i].slice(1)) for i in [0..(frags.length - 1)]
    frags.join(' ')

angular.module('app.core').filter 'timeago', () ->
  ## Adapted from https://gist.github.com/rodyhaddad/5896883
  # time: the time
  # local: compared to what time? default: now
  # raw: wheter you want in a format of "5 minutes ago", or "5 minutes"
  (time, local, raw) ->
    if !time then return 'never'
    if !local then local = Date.now()

    if angular.isDate time
      time = time.getTime()
    else if typeof time is 'string'
      time = new Date(time).getTime()

    if angular.isDate local
      local = local.getTime()
    else if typeof local is 'string'
      local = new Date(local).getTime()

    if typeof time isnt 'number' or typeof local isnt 'number' then return

    offset = Math.abs((local - time) / 1000)
    span = []
    MINUTE = 60
    HOUR = 3600
    DAY = 86400
    WEEK = 604800
    MONTH = 2629744
    YEAR = 31556926
    DECADE = 315569260

    if offset <= MINUTE
      span = [ '', '< 1 min' ]
    else if (offset < (MINUTE * 60))
      span = [ Math.round(Math.abs(offset / MINUTE)), 'min' ]
    else if (offset < (HOUR * 24))
      span = [ Math.round(Math.abs(offset / HOUR)), 'hr' ]
    else if (offset < (DAY * 7))
      span = [ Math.round(Math.abs(offset / DAY)), 'day' ]
    else if (offset < (WEEK * 52))
      span = [ Math.round(Math.abs(offset / WEEK)), 'week' ]
    else if (offset < (YEAR * 10))
      span = [ Math.round(Math.abs(offset / YEAR)), 'year' ]
    else if (offset < (DECADE * 100))
      span = [ Math.round(Math.abs(offset / DECADE)), 'decade' ]
    else
      span = [ '', 'a long time' ];

    if (span[0] is 0 or span[0] > 1) then span[1] += 's'
    span = span.join(' ')

    if raw is true then return span
    if time <= local then (span + ' ago') else ('in ' + span)
