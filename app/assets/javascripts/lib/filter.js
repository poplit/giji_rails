// Generated by CoffeeScript 1.6.2
var FILTER;

FILTER = function($scope, $filter) {
  var deploy_mode_common, do_scrollTo, filter_filter, form_show, game_rule, mode_params, modes_change, page, scrollTo, _ref;

  PageNavi.push($scope, 'page', OPTION.page.page);
  page = $scope.page;
  filter_filter = $filter('filter');
  if ($scope.stories != null) {
    page.filter_by('stories');
    page.filter_to('stories_find');
    game_rule = {
      options: OPTION.page.game_rule.options,
      button: {
        ALL: "- すべて -"
      }
    };
    SOW.game_rule.keys(function(key, o) {
      return game_rule.button[key] = o.CAPTION;
    });
    Navi.push($scope, 'folder', OPTION.page.folder);
    Navi.push($scope, 'game_rule', game_rule);
    page.filter('folder.value', function(key, list) {
      if ('ALL' === $scope.folder.value) {
        return list;
      } else {
        return list.filter(function(o) {
          return o.folder === $scope.folder.value;
        });
      }
    });
    page.filter('game_rule.value', function(key, list) {
      if ('ALL' === $scope.game_rule.value) {
        return list;
      } else {
        return list.filter(function(o) {
          return o.type.game === $scope.game_rule.value;
        });
      }
    });
  }
  if ($scope.messages_raw != null) {
    page.filter_by('messages_raw');
    page.filter_to('messages');
    page.filter('messages_raw.length');
  }
  if (((_ref = $scope.event) != null ? _ref.messages : void 0) != null) {
    page.filter_by('event.messages');
    page.filter_to('messages');
    page.filter('event.turn');
    page.filter('event.is_news');
    page.filter('event.messages.length');
    deploy_mode_common = function() {
      $scope.mode_current_set();
      return $scope.mode_common = [
        {
          name: '情報',
          value: 'info_open_player'
        }, {
          name: 'メモ',
          value: 'memo_all_open_last_player'
        }, {
          name: '議事',
          value: $scope.mode_current
        }
      ];
    };
    deploy_mode_common();
    mode_params = GIJI.modes.groupBy('val');
    Navi.push($scope, 'search', {
      options: {
        current: "",
        location: 'hash',
        is_cookie: false
      }
    });
    Navi.push($scope, 'mode', {
      options: {
        current: $scope.mode_current,
        location: 'hash',
        is_cookie: false
      },
      select: GIJI.modes
    });
    $scope.modes = $scope.mode.choice();
    modes_change = function(oldVal, newVal) {
      if ("info" === $scope.modes.face) {
        $scope.modes.last = false;
        $scope.modes.view = "open";
      }
      if ("memo" === $scope.modes.face) {
        $scope.modes.open = true;
      }
      if ("open" === $scope.modes.view) {
        $scope.modes.open = true;
      }
      if ("all" !== $scope.modes.view) {
        if ("memo" === $scope.modes.face) {
          $scope.modes.view = "open";
        }
      }
      return $scope.mode.value = [$scope.modes.face, $scope.modes.view, $scope.modes.open ? 'open' : void 0, $scope.modes.last ? 'last' : void 0, $scope.modes.player ? 'player' : void 0].unique().compact(true).join("_");
    };
    $scope.$watch('modes.face', modes_change);
    $scope.$watch('modes.view', modes_change);
    $scope.$watch('modes.open', modes_change);
    $scope.$watch('modes.last', modes_change);
    $scope.$watch('modes.player', modes_change);
    page.filter('mode.value', function(key, list) {
      var add_filter, add_filters, is_mob_open, mode_filter, mode_filters, open_filters, order, result;

      $scope.modes = $scope.mode.choice().clone();
      is_mob_open = false;
      if ($scope.story != null) {
        if ('alive' === $scope.story.type.mob) {
          is_mob_open = true;
        }
        if ($scope.story.turn === 0) {
          is_mob_open = true;
        }
        if ($scope.story.is_epilogue) {
          is_mob_open = true;
        }
      }
      mode_filters = {
        info: /^[aAm]|(vilinfo)/,
        memo_all: /^(.M)/,
        memo_open: /^([qcaAmIMS][MX])/,
        talk_all: /^[^S][^M]\d+/,
        talk_think: /^[qcaAmIi][^M]\d+/,
        talk_clan: /^[qcaAmIi\-WPX][^M]\d+/,
        talk_all_open: /^.[^M]\d+/,
        talk_think_open: /^[qcaAmIiS][^M]\d+/,
        talk_clan_open: /^[qcaAmIi\-WPXS][^M]\d+/,
        talk_all_last: /^[^S][SX]/,
        talk_think_last: /^[qcaAmIi][SX]/,
        talk_clan_last: /^[qcaAmIi\-WPX][SX]/,
        talk_all_open_last: /^.[SX]/,
        talk_think_open_last: /^[qcaAmIiS][SX]/,
        talk_clan_open_last: /^[qcaAmIi\-WPXS][SX]/,
        talk_open: /^[qcaAmIS][^M]/,
        talk_open_last: /^[qcaAmIS][SX]/
      };
      if (is_mob_open) {
        open_filters = {
          talk_think_open_last: /^[qcaAmIiVS][SX]/,
          talk_think_open: /^[qcaAmIiVS][^M]\d+/,
          memo_open: /^([qcaAmIMVS][MX])/,
          talk_open: /^[qcaAmIVS][^M]/,
          talk_open_last: /^[qcaAmIVS][SX]/
        };
      } else {
        open_filters = {};
      }
      add_filters = {
        clan: function(o) {
          return "" !== o.to && (o.to != null);
        },
        think: function(o) {
          return "" === o.to && o.logid.match(/^T[^M]/);
        }
      };
      mode_filter = open_filters[$scope.modes.regexp];
      mode_filter || (mode_filter = mode_filters[$scope.modes.regexp]);
      add_filter = add_filters[$scope.modes.view];
      add_filter || (add_filter = function() {
        return false;
      });
      list = list.filter(function(o) {
        return o.logid.match(mode_filter) || add_filter(o);
      });
      if ($scope.modes.last) {
        result = [];
        order = function(o) {
          return [GIJI.message.order[o.mestype] || 8, o.date || (new Date)];
        };
        list.groupBy($scope.potof_key).keys(function(key, list) {
          return result.push(list.last());
        });
        return result.sortBy(order);
      } else {
        return list;
      }
    });
    page.filter('hide_potofs.value', function(hide_ids, list) {
      var faces, hide_faces;

      hide_faces = hide_ids.clone();
      if (hide_faces.any('others')) {
        hide_faces.add($scope.face.others);
      }
      faces = $scope.face.all.subtract(hide_faces);
      return list.filter(function(o) {
        return faces.some($scope.potof_key(o));
      });
    });
  }
  page.filter('search.value', function(search, list) {
    $scope.search_input = search;
    return filter_filter(list, search);
  });
  page.paginate('row.value', function(page_per, list) {
    var from, page_no, to, _ref1;

    if ((_ref1 = $scope.event) != null ? _ref1.is_news : void 0) {
      $scope.page.visible = false;
      to = list.length;
      from = to - page_per;
      if (from < 0) {
        from = 0;
      }
      $scope.event.is_rowover = 0 < from;
    } else {
      $scope.page.visible = true;
      if ($scope.page.value > $scope.page.length) {
        $scope.page.value = $scope.page.length;
      }
      if ($scope.page.value < 1) {
        $scope.page.value = 1;
      }
      page_no = $scope.page.value;
      to = page_no * page_per + OPTION.page.pile;
      from = (page_no - 1) * page_per;
    }
    return list.to(to).from(from);
  });
  page.filter('order.value', function(key, list) {
    var log, _i, _len;

    for (_i = 0, _len = list.length; _i < _len; _i++) {
      log = list[_i];
      log.text = $scope.text_decolate(log.log);
    }
    $scope.anchors = [];
    if ("desc" === key) {
      return list.reverse();
    } else {
      return list;
    }
  });
  do_scrollTo = function() {
    var target, _ref1;

    $('div.popover').remove();
    target = $(".message_filter." + $scope.top.id);
    if (((_ref1 = $scope.event) != null ? _ref1.is_news : void 0) && ((target != null ? target.offset() : void 0) != null)) {

    } else {
      target = $(".inframe");
    }
    return $(window).scrollTop(target.offset().top - 20);
  };
  scrollTo = do_scrollTo.debounce(500);
  form_show = function() {
    if ($scope.modes != null) {
      return $scope.form_show = $scope.modes.form;
    }
  };
  $scope.$watch('mode.value', form_show);
  $scope.$watch('event.is_news', form_show);
  $scope.$watch('event.is_news', deploy_mode_common);
  $scope.$watch('modes.face', scrollTo);
  $scope.$watch('order.value', scrollTo);
  $scope.$watch('event.turn', scrollTo);
  $scope.$watch('page.value', scrollTo);
  return $scope.$watch('page.value', $scope.boot);
};
