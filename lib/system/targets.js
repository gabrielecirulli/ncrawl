// Generated by CoffeeScript 1.3.3
(function() {
  var net, util, _;

  util = require('./util');

  net = require('net');

  _ = require('underscore');

  module.exports = function(raw) {
    var finish, push, split, start, target, targets, _i, _len;
    if (raw == null) {
      raw = '';
    }
    if (!_.isArray(targets)) {
      raw = raw.split(',');
    }
    targets = [];
    push = function(target) {
      target = target.trim();
      if (!target) {
        return;
      }
      return targets.push(target);
    };
    for (_i = 0, _len = raw.length; _i < _len; _i++) {
      target = raw[_i];
      split = target.split('-');
      if (split.length === 2 && net.isIPv4(split[0]) && net.isIPv4(split[1])) {
        start = util.IPv4ToLong(split[0]);
        finish = util.IPv4ToLong(split[1]);
        while (!(start > finish)) {
          push(util.longToIPv4(start++));
        }
      } else {
        push(target);
      }
    }
    return _.uniq(targets);
  };

}).call(this);
