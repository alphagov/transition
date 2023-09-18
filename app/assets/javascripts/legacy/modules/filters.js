(function(Modules) {
  "use strict"

  Modules.Filters = function() {
    var that = this;
    that.start = function(element) {
      // Prevent dropdowns with text inputs from closing when interacting
      // with them
      element.on('click', '.dropdown-text-input', function (event) {
        event.stopPropagation();
      });

      element.on('shown.bs.dropdown', focusInput);

      function focusInput(event) {
        var container = $(event.target);
        setTimeout(function() {
          container.find('input[type="text"]').focus();
        }, 50);
      }

    }
  };

})(window.GOVUKAdmin.Modules);
