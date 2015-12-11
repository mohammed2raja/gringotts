(function() {
  define(function(require) {
    var utils;
    utils = require('lib/utils');
    return {
      setupError: function(context) {
        return $(document).ajaxError(function(event, jqXHR, options, error) {
          var session, status;
          status = jqXHR.status;
          if (status === 401) {
            session = utils.parseJSON(jqXHR.responseText);
            if (session.CODE === 'SESSION_EXPIRED') {
              return (context || window).location.reload();
            }
          }
        });
      }
    };
  });

}).call(this);
