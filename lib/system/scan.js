// Generated by CoffeeScript 1.3.3
(function() {
  var EventEmitter2, Scan, async, dns, net, services, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  EventEmitter2 = require('eventemitter2').EventEmitter2;

  services = require('./services');

  async = require('async');

  dns = require('dns');

  net = require('net');

  _ = require('underscore');

  Scan = (function(_super) {

    __extends(Scan, _super);

    function Scan(o) {
      var key, module, name, value, _ref,
        _this = this;
      for (key in o) {
        value = o[key];
        this[key] = value;
      }
      this.completedModules = 0;
      this.remainingModules = this.totalModules;
      this.currentProgress = 0;
      this.lastUpdatedProgress = 0;
      this.progressIncrement = this.totalModules * 100 / this.totalModules;
      this.emit('scan start', {
        sessionID: this.sessionID,
        scanID: this.scanID,
        target: this.target
      });
      this.startTime = Date.now();
      this.results = {};
      _ref = this.modules;
      for (name in _ref) {
        module = _ref[name];
        this.results[name] = {
          error: true
        };
      }
      this.progressInterval = setInterval(function() {
        var elapsed;
        if (_this.lastUpdatedProgress === _this.currentProgress) {
          return;
        }
        _this.lastUpdatedProgress = _this.currentProgress;
        elapsed = Date.now() - _this.startTime;
        return _this.emit('scan progress', {
          sessionID: _this.sessionID,
          scanID: _this.scanID,
          progress: _this.currentProgress,
          elapsed: elapsed,
          eta: elapsed * (_this.totalModules / _this.completedModules - 1),
          remainingModules: _this.remainingModules,
          completedModules: _this.completedModules
        });
      }, 2000);
      this.info = {
        target: this.target,
        scanID: this.scanID,
        sessionID: this.sessionID,
        type: [],
        mx: [],
        txt: [],
        srv: [],
        ns: [],
        cname: [],
        resolve: {},
        isIP: false,
        ip: null,
        hostname: null
      };
      if (net.isIP(this.target)) {
        this.info.isIP = true;
        this.info.ip = this.target;
      } else {
        this.info.hostname = this.target;
      }
      this.dns(function() {
        var port, _i, _len, _ref1, _ref2, _results;
        _this.emit('target info', _this.info);
        _ref1 = _this.modules;
        for (name in _ref1) {
          module = _ref1[name];
          _this.addModule(name, module);
        }
        _ref2 = _this.ports;
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          port = _ref2[_i];
          _results.push(_this.addPort(port));
        }
        return _results;
      });
    }

    Scan.prototype.dns = function(finish) {
      var next,
        _this = this;
      next = function() {
        _this.queueDone();
        return finish();
      };
      return async.series({
        reverse: function(callback) {
          return dns.resolve(_this.target, function(err, results) {
            if (err) {
              return callback();
            }
            if (results && !_this.info.ip) {
              _this.info.ip = results[0];
            }
            _this.info.resolve = {};
            return async.forEach(results, function(item, done) {
              return dns.reverse(item, function(err, results) {
                if (results && !_this.info.hostname) {
                  _this.info.hostname = results[0];
                }
                _this.info.resolve[item] = results;
                return done();
              });
            }, callback);
          });
        },
        mx: function(callback) {
          if (!_this.info.ip) {
            return next(_this.results = {});
          }
          if (!_this.info.hostname) {
            return next();
          }
          return dns.resolveMx(_this.info.hostname, function(err, records) {
            if (records) {
              _this.info.mx = records;
            }
            return callback();
          });
        },
        txt: function(callback) {
          return dns.resolveTxt(_this.info.hostname, function(err, records) {
            if (records) {
              _this.info.txt = records;
            }
            return callback();
          });
        },
        srv: function(callback) {
          return dns.resolveSrv(_this.info.hostname, function(err, records) {
            if (records) {
              _this.info.srv = records;
            }
            return callback();
          });
        },
        ns: function(callback) {
          return dns.resolveNs(_this.info.hostname, function(err, records) {
            if (records) {
              _this.info.ns = records;
            }
            return callback();
          });
        },
        cname: function(callback) {
          return dns.resolveCname(_this.info.hostname, function(err, records) {
            if (records) {
              _this.info.cname = records;
            }
            return callback();
          });
        },
        next: next
      });
    };

    Scan.prototype.identify = function(device) {
      this.info.type.push(device);
      return this.emit('target identify', {
        device: device,
        scanID: this.scanID,
        sessionID: this.sessionID
      });
    };

    Scan.prototype.addModule = function(name, obj) {
      var _this = this;
      return this.queue.add(function(finished) {
        var start;
        start = Date.now();
        return _this.checkPort(obj.port, function(error) {
          if (_this.stopped) {
            return finished();
          }
          if (error) {
            _this.moduleDone(name, {
              module: name,
              port: obj.port,
              error: true,
              start: start,
              finish: Date.now(),
              took: Date.now() - start
            });
            return finished();
          } else {
            return _this.startModule(name, obj, finished);
          }
        });
      });
    };

    Scan.prototype.addPort = function(port) {
      var _this = this;
      return this.queue.add(function(finished) {
        var start;
        start = Date.now();
        return _this.checkPort(port, function(error) {
          var info;
          if (_this.stopped) {
            return finished();
          }
          info = services.getByPort(port);
          _this.moduleDone(info.name || 'port', {
            port: port,
            data: {
              port: port
            },
            error: error,
            start: start,
            finish: Date.now(),
            took: Date.now() - start
          });
          return finished();
        });
      });
    };

    Scan.prototype.checkPort = function(port, callback) {
      var error, next, socket, timeout,
        _this = this;
      if (this.stopped) {
        return callback();
      }
      socket = new net.Socket;
      error = true;
      next = function() {
        socket.destroy();
        clearTimeout(timeout);
        return callback(error);
      };
      socket.on('connect', function() {
        error = false;
        return socket.destroy();
      });
      timeout = setTimeout(next, this.options.timeout);
      socket.on('error', function() {});
      socket.on('close', next);
      return socket.connect(port, this.target);
    };

    Scan.prototype.stop = function() {
      return this.stopped = true;
    };

    Scan.prototype.cleanUp = function(callback) {
      clearInterval(this.progressInterval);
      if (callback) {
        return callback();
      }
    };

    Scan.prototype.startModule = function(name, obj, finished) {
      var module, start,
        _this = this;
      if (this.stopped) {
        return this.cleanup(finished);
      }
      start = Date.now();
      module = new obj.Module(this.target, this.options, this.identify.bind(this));
      return module.start(function(result) {
        var check, data, device, reg, types, values, _ref;
        if (result == null) {
          result = {};
        }
        result.port = obj.port;
        result.finish = Date.now();
        result.start = start;
        result.took = result.finish - result.start;
        _ref = obj.identities;
        for (device in _ref) {
          types = _ref[device];
          for (check in types) {
            values = types[check];
            if (!(result.data && (data = result.data[check]))) {
              continue;
            }
            reg = new RegExp("(" + (values.join('|')) + "})", 'i');
            if (reg.test(data)) {
              _this.identify(device);
            }
          }
        }
        finished();
        return _this.moduleDone(name, result);
      });
    };

    Scan.prototype.moduleDone = function(name, result) {
      if (result == null) {
        result = {};
      }
      this.currentProgress += this.progressIncrement;
      this.remainingModules--;
      this.completedModules++;
      result.module = name;
      result.scanID = this.scanID;
      result.sessionID = this.sessionID;
      result.data = result.data || {};
      if (!result.error || result.error && this.options.errors) {
        this.results[name] = result;
        this.emit('module result', result);
      } else {
        delete this.results[name];
      }
      if (--this.totalModules !== 0) {
        return;
      }
      this.cleanUp();
      this.finishTime = Date.now();
      return this.emit('scan finish', {
        info: this.info,
        results: this.results,
        start: this.startTime,
        finish: this.finishTime,
        took: this.finishTime - this.startTime
      });
    };

    return Scan;

  })(EventEmitter2);

  module.exports = Scan;

}).call(this);
