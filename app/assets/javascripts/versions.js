(function() {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var Versions = {
    selectedVersionId: function() {
      return window.location.hash.split('#')[1];
    },
    highlightChangeset: function() {
      var version = Versions.selectedVersionId();
      if(version) {
        $('a[name=' + version + ']').closest('tr').addClass('selected');
      }
    },
    ready: function () {
      $(document).ready(function () {
        Versions.highlightChangeset();
      });
    }
  };

  root.GOVUK.Versions = Versions;
}).call(this);
