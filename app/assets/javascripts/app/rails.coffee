if SOW_RECORD.CABALA.events?
  SOW.events.keys (k,v)->
    v.id  = SOW_RECORD.CABALA.events.indexOf k
    v.key = k

RAILS = ($scope, $filter)->
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
    $scope.get href, cb

  $scope.event_url = (event)->
    return null unless event
    event.link

  $scope.get_news = (event,cb)->
    href = $scope.event_url(event)
    get href, cb if href

  $scope.get_all = (event,cb)->
    href = $scope.event_url(event)
    get href, cb if href

  submit = (param, cb)->
    $scope.post $scope.form.uri, param, ->
      $scope.init()
      cb() if cb
  $scope.submit = submit.throttle 5000


  MODULE   $scope, $filter
