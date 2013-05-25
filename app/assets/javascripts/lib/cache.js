// Generated by CoffeeScript 1.6.2
var CACHE;

CACHE = function($scope) {
  var cache, concat_merge, find_or_create, find_turn, merge, merge_by,
    _this = this;

  $scope.set_turn = function(turn) {
    var _ref, _ref1;

    if (((_ref = $scope.events) != null ? _ref[turn] : void 0) != null) {
      $scope.event = $scope.events[turn];
    }
    if (((_ref1 = $scope.forms) != null ? _ref1[turn] : void 0) != null) {
      return $scope.form = $scope.forms[turn];
    }
  };
  $scope.merge_turn = function(old_base, new_base) {
    var turn;

    if (!((old_base != null) && (new_base != null))) {
      return;
    }
    turn = find_turn(new_base);
    if (turn) {
      return $scope.set_turn(turn);
    }
  };
  $scope.merge = function(old_base, new_base, target) {
    var func;

    if (!((old_base != null) && (new_base != null))) {
      return;
    }
    func = merge[target] || merge_by.copy;
    return func(old_base, new_base, target);
  };
  merge = {
    events: function(old_base, new_base, target) {
      var filter, guard, new_event, old_event;

      guard = function(key) {
        return ["messages", "has_all_messages"].any(key);
      };
      filter = function(o) {
        return o.turn;
      };
      merge_by.simple(old_base, new_base, "events", guard, filter);
      new_event = new_base.event;
      old_event = find_or_create(new_base, old_base.events);
      if (new_event == null) {
        return;
      }
      new_event.keys(function(key, o) {
        if (!guard(key)) {
          return old_event[key] = o;
        }
      });
      old_event.has_all_messages || (old_event.has_all_messages = new_event.has_all_messages);
      merge._messages(old_event, new_event);
      merge._potofs(old_event, new_base);
      old_base.potofs = old_event.potofs;
      return old_base.event || (old_base.event = old_event);
    },
    event: function() {},
    _messages: function(old_base, new_base) {
      var filter, guard;

      guard = function() {
        return false;
      };
      filter = function(o) {
        return o.logid;
      };
      if ((new_base != null ? new_base.messages : void 0) == null) {
        return;
      }
      if (new_base.turn != null) {
        new_base.messages.each(function(message) {
          return message.turn = new_base.turn;
        });
      }
      return merge_by.news(old_base, new_base, 'messages', guard, filter);
    },
    _potofs: function(old_base, new_base) {
      var filter, guard;

      guard = function() {
        return false;
      };
      filter = function(o) {
        return o.pno;
      };
      if ((new_base != null ? new_base.potofs : void 0) == null) {
        return;
      }
      if (new_base.turn != null) {
        new_base.potofs.each(function(potof) {
          return potof.turn = new_base.turn;
        });
      }
      return merge_by.simple(old_base, new_base, "potofs", guard, filter);
    },
    forms: function() {},
    form: function(old_base, new_base) {
      var filter, guard, new_form, old_form;

      guard = function(key) {
        return ["texts"].any(key);
      };
      filter = function(o) {
        return o.turn;
      };
      cache.load(old_base, new_base, 'forms', 'form');
      new_form = new_base.form;
      old_form = old_base.form;
      if (new_form == null) {
        return;
      }
      new_form.keys(function(key, o) {
        if (!guard(key)) {
          return old_form[key] = o;
        }
      });
      old_base.form || (old_base.form = old_form);
      return merge.form_texts(old_form, new_base.form);
    },
    form_texts: function(old_base, new_base) {
      var filter, guard;

      guard = function(key) {
        return !["count", "targets", "votes"].any(key);
      };
      filter = function(o) {
        return o.jst + o["switch"];
      };
      if (!((old_base != null) && (new_base != null))) {
        return;
      }
      return merge_by.simple(old_base, new_base, "texts", guard, filter);
    }
  };
  merge_by = {
    copy: function(old_base, new_base, target) {
      return old_base[target] = new_base[target];
    },
    simple: function(old_base, new_base, target, guard, filter) {
      var news, olds;

      olds = old_base[target];
      news = new_base[target];
      if (news == null) {
        return;
      }
      if (olds == null) {
        old_base[target] = news;
        return;
      }
      return old_base[target] = concat_merge(olds, news, guard, filter);
    },
    news: function(old_base, new_base, target, guard, filter) {
      var news, olds;

      olds = old_base[target];
      news = new_base[target];
      if (news == null) {
        return;
      }
      if (olds == null) {
        old_base[target] = news;
        return;
      }
      return old_base[target] = concat_merge(olds, news, guard, filter);
    }
  };
  cache = {
    load: function(old_base, new_base, target, child) {
      var filter, guard, _base;

      guard = function() {
        return false;
      };
      filter = function(o) {
        return o.turn;
      };
      old_base[target] || (old_base[target] = []);
      merge_by.simple(old_base, new_base, target, guard, filter);
      if ((new_base != null ? new_base.events : void 0) != null) {
        return old_base[child] = find_or_create(new_base, old_base[target]);
      } else {
        return old_base[child] = (_base = old_base[target])[0] || (_base[0] = {});
      }
    },
    build: function(new_base, field) {
      var event, _i, _len, _name, _ref, _results;

      if ((field != null) && ((new_base != null ? new_base.events : void 0) != null)) {
        _ref = new_base.events;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          event = _ref[_i];
          if (event.turn != null) {
            _results.push(field[_name = event.turn] || (field[_name] = {
              turn: event.turn
            }));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    }
  };
  find_or_create = function(new_base, field) {
    var turn;

    cache.build(new_base, field);
    turn = find_turn(new_base);
    if ((turn != null) && (field != null) && field[turn]) {
      return field[turn];
    } else {
      return {};
    }
  };
  find_turn = function(new_base) {
    var _ref;

    return new_base != null ? (_ref = new_base.event) != null ? _ref.turn : void 0 : void 0;
  };
  return concat_merge = function(olds, news, guard, filter) {
    var key, new_item, old_hash, old_item, olds_head, _i, _len, _ref;

    olds_head = olds.filter(function(o) {
      return !o.is_delete;
    });
    old_hash = olds_head.groupBy(filter);
    for (_i = 0, _len = news.length; _i < _len; _i++) {
      new_item = news[_i];
      key = filter(new_item);
      old_item = (_ref = old_hash[key]) != null ? _ref[0] : void 0;
      if (old_item != null) {
        olds_head.remove(old_item);
        new_item.keys(function(key, o) {
          if (!guard(key)) {
            return old_item[key] = o;
          }
        });
        new_item = old_item;
      }
      olds_head.push(new_item);
    }
    return olds_head;
  };
};
