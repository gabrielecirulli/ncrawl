// Generated by CoffeeScript 1.3.3
(function() {
  var Reporter, _s;

  _s = require('underscore.string');

  Reporter = (function() {

    function Reporter() {}

    Reporter.prototype.info = function(info) {
      var alias;
      this.info = info;
      alias = [];
      if (this.info.hostname) {
        alias.push(this.info.hostname);
      }
      if (this.info.ip) {
        alias.push(this.info.ip);
      }
      return this.alias = alias.length === 0 ? '' : alias.join(':');
    };

    Reporter.prototype.identify = function(data) {
      console.log(("" + this.alias + " has been identified as " + data.type).bold);
      return console.log();
    };

    Reporter.prototype.result = function(name, result) {
      var alias, color, value, _ref;
      color = result.error ? 'red' : 'green';
      alias = this.alias;
      if (alias) {
        alias += ' - ';
      }
      console.log(("   " + alias + name + " - " + result.took + "ms")[color]);
      _ref = result.data;
      for (name in _ref) {
        value = _ref[name];
        console.log(" > " + (_s.capitalize(name)) + ": " + value);
      }
      return console.log();
    };

    return Reporter;

  })();

  exports.Reporter = Reporter;

}).call(this);