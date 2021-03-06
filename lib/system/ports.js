// Generated by CoffeeScript 1.3.3
(function() {
  var _;

  _ = require('underscore');

  module.exports = function(raw) {
    var finish, port, ports, push, split, start, _i, _len;
    if (raw == null) {
      raw = '';
    }
    if (!_.isArray(raw)) {
      raw = raw.split(',');
    }
    ports = [];
    push = function(port) {
      port = port.trim();
      port = +port;
      if (!(port >= 1 && !isNaN(port))) {
        return;
      }
      return ports.push(port);
    };
    for (_i = 0, _len = raw.length; _i < _len; _i++) {
      port = raw[_i];
      split = port.split('-');
      if (split.length === 2) {
        start = split[0];
        finish = split[1];
        while (!(start > finish)) {
          push(start);
        }
      } else {
        push(port);
      }
    }
    return _.uniq(ports);
  };

}).call(this);
