(function($, root) {
  "use strict"

  var GOVUK = root.GOVUK = {
    Modules: {}
  };

  GOVUK.find = function(container) {

    var modules,
        pattern = '[data-module]',
        container = container || $('body');

    modules = container.find(pattern);

    // Include container if it matches pattern, as that could
    // be a module too
    if (container.is(pattern)) {
      modules.push(container);
    }

    return modules;
  }

  GOVUK.start = function(container) {

    var modules = this.find(container);

    for (var i = 0, l = modules.length; i < l; i++) {

      var module,
          element = $(modules[i]),
          type = camelCaseAndCapitalise(element.data('module'));

      if (typeof GOVUK.Modules[type] === "function") {
        module = new GOVUK.Modules[type]();
        module.start(element);
      }
    }

    // eg selectable-table to SelectableTable
    function camelCaseAndCapitalise(string) {
      return capitaliseFirstLetter(camelCase(string));
    }

    // http://stackoverflow.com/questions/6660977/convert-hyphens-to-camel-case-camelcase
    function camelCase(string) {
      return string.replace(/-([a-z])/g, function (g) {
        return g[1].toUpperCase();
      });
    }

    // http://stackoverflow.com/questions/1026069/capitalize-the-first-letter-of-string-in-javascript
    function capitaliseFirstLetter(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    }

  }

  GOVUK.startAll = function() {
    GOVUK.start();
  }

})(jQuery, window);
