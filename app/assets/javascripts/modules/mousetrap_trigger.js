(function(Modules) {
  "use strict";

  Modules.MousetrapTrigger = function() {
    var that = this;

    that.start = function(element) {
      element.on('click', triggerMousetrapEvent);
      var keys = element.data('keys');

      function triggerMousetrapEvent(event) {
        event.preventDefault();
        Mousetrap.trigger(keys);
      }
    }
  };

})(window.GOVUKAdmin.Modules);
