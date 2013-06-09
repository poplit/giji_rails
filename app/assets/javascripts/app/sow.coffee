if SOW_RECORD.CABALA.events?
  SOW.events.keys (k,v)->
    v.id  = SOW_RECORD.CABALA.events.indexOf k
    v.key = k

CGI = ($scope, $filter)->
  $scope.mode_cache = 
    info: 'info_open_player'
    memo: 'memo_all_open_last_player'
    talk: 'talk_all_open_player'
  $scope.deploy_mode_common = ->
    $scope.mode_common = [
      {name: '情報', value: $scope.mode_cache.info }
      {name: 'メモ', value: $scope.mode_cache.memo }
      {name: '議事', value: $scope.mode_cache.talk }
    ]

  get = (href, cb)->
    $scope.get href + "&ua=javascript", cb

  $scope.event_url = (event)->
    return null unless event
    (event.is_news && event.news) || event.link

  $scope.get_news = (event,cb)->
    href = $scope.event_url(event)
    get href, cb if href

  $scope.get_all = (event,cb)->
    return null unless event
    href = event.link
    get href, cb if href


  submit = (param, cb)->
    switch param.cmd
      when 'login'
        if param.vid?
          protocol = $scope.post_iframe
        else
          protocol = $scope.post_submit
      when 'editvilform', 'logout'
        protocol = $scope.post_submit
      when 'wrmemo', 'write', 'action', 'entry'
        protocol = $scope.post_iframe
      else
        protocol = $scope.post
    param.ua = "javascript" unless $scope.post_submit == protocol
    protocol $scope.form.uri, param, ->
      $scope.init()
      cb() if cb
  $scope.submit = submit.throttle 5000

  regexp =
    uid: ///(^|\s)uid=([^;]+)///
    pwd: ///(^|\s)pwd=([^;]+)///
  $scope.logined = ->
    uid = document.cookie.match(regexp.uid)?[2]
    pwd = document.cookie.match(regexp.pwd)?[2]
    uid? && pwd?

  $scope.login = (f)->
    f.uid = $("""[name="uid"]""").val()
    f.pwd = $("""[name="pwd"]""").val()
    param =
      cmd: 'login'
      uid: f.uid
      pwd: f.pwd
      cmdfrom: f.cmdfrom
    param.vid = $scope.story.vid if $scope.story?.vid?
    $scope.submit param, ->

  $scope.logout = (f)->
    param =
      cmd: 'logout'
      cmdfrom: f.cmdfrom
    $scope.submit param, ->

  MODULE $scope, $filter
  FORM    $scope

