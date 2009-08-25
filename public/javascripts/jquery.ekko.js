/**
* ekko - jQuery Plugin
*
* Version - 0.1.0
*
* Copyright (c) 2009 Terry M. Schmidt
*
* Dual licensed under the MIT and GPL licenses:
*   http://www.opensource.org/licenses/mit-license.php
*   http://www.gnu.org/licenses/gpl.html
*
* Based on the work done by John McCollum and the jQuery PeriodicalUpdater plugin.
*
**/

(function(jQuery) {
  jQuery.fn.ekko = function (options, callback) {

    return this.each(function () {

      var elem  = this;
      var $elem = jQuery(this);

      // Initial Settings
      elem.settings = jQuery.extend({
              url     : '',
              method    : 'get',
              sendData  : '',
              minTimeout  : 1000, // Default 1 second
              maxTimeout  : ((1000 * 60) * 60), // Default 1 hour
              multiplier  : 2,
              type    : 'text'
          }, options);

      elem.settings.ajaxMethod = jQuery.ajax
      elem.settings.prevContent = '';
      elem.settings.originalMinTimeout = elem.settings.minTimeout;

      start();

      function updateTimeout() {
        if (elem.settings.minTimeout < elem.settings.maxTimeout) {
          elem.settings.minTimeout = elem.settings.minTimeout * elem.settings.multiplier
        }

        if (elem.settings.minTimeout > elem.settings.maxTimeout) {
          elem.settings.minTimeout = elem.settings.maxTimeout
        }

        elem.settings.periodicalUpdater = setTimeout(start, elem.settings.minTimeout);
      }

      function start() {
        elem.settings.ajaxMethod({url:elem.settings.url,data:elem.settings.sendData,dataType:elem.settings.type,
          success: function(data) {
          if (elem.settings.prevContent != data) {
            elem.settings.prevContent = data;
            if (callback) {
              callback(data)
            }
            // reset minTimeout
            elem.settings.minTimeout = elem.settings.originalMinTimeout;
            elem.settings.periodicalUpdater = setTimeout(start, elem.settings.minTimeout);
          } else {
            updateTimeout();
          }
        },
        error:function() { updateTimeout(); }});
      } // start()
    });

  }; // jQuery.fn.ekko()

  jQuery.fn.ekkoStop = function () {
    return this.each(function () {
      var elem = this;
      clearTimeout(elem.settings.periodicalUpdater)
    });
  } // jQuery.fn.ekkoStop()
})(jQuery);
