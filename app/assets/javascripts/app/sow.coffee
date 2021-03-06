CGI = ($scope, $filter, $sce, $cookies, $http, $timeout)->
  win.cookies = $cookies
  $scope.mode_cache =
    info: 'info_open_last'
    memo: 'memo_all_open_last'
    talk: 'talk_all_open'
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
  $scope.submit = _.throttle submit, DELAY.lento

  $scope.logined = ->
    win.cookies.uid && win.cookies.pwd

  $scope.login = (f)->
    param =
      cmd: "login"
      uid: f.uid = $("""[name="uid"]""").val()
      pwd: f.pwd = $("""[name="pwd"]""").val()
      cmdfrom: f.cmdfrom
    param.vid = $scope.story.vid if $scope.story?.vid?
    $scope.submit param, ->
      $scope.wary_messages()

  $scope.logout = (f)->
    param =
      cmd: 'logout'
      cmdfrom: f.cmdfrom
    $scope.submit param, ->

  MODULE $scope, $filter, $sce, $http, $timeout
  FORM   $scope, $sce

  $scope.story_has_option = (option)->
    _.include $scope.story.options, option
