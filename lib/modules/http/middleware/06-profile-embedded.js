// Generated by CoffeeScript 1.3.3
(function() {

  module.exports = function(identify, data, res, body) {
    if (/(Allegro-Software-RomPager|GoAhead-Webs)/i.test(data.server)) {
      return identify('embedded');
    }
  };

}).call(this);