class Browser
  constructor: (@location, @cookies)->
    @list = {}
    @location ||=
      search: ""
      hash: ""
    @cookies ||= {}

  location_val: (target, find_key)->
    for key_value_pair in @location[target].replace(/^[#?]/,"").split('&')
      [key, value] = key_value_pair.split('=')
      return decodeURIComponent value if key == find_key

  set_cookie: ->
    for _, navi of @list
      options = navi.params
      if navi.value && options.is_cookie
        @cookies[navi.key] = navi.value

  to_url: (append)->
    data =
      search: []
      hash: []

    scanner = (location, key, value)->
      if value
        cmd = "#{key}=#{value}"
        data[location]?.push cmd

    for _, navi of @list
      scanner(navi.params.location, navi.key, navi.value)
    for location, navi of append
      for key, value of navi
        scanner(location, key, value)


    if data.search.length
      search = "?" + (data.search || []).join("&")
      unless @location.search == search
        @location.search = search

    if data.hash.length
      hash = "#" +  (data.hash || []).join("&")
      unless @location.hash == hash
        @location.hash = hash
      # win.history null, null, h
