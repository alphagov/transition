(function(Modules) {
  "use strict"

  Modules.ToggleMappingFormFields = function() {

    var that = this;

    that.start = function(element) {

      var form = element,
          mappingType = form.find('.js-type'),
          archiveFields = form.find('.js-for-archive'),
          redirectFields = form.find('.js-for-redirect');

      mappingType.on('change', toggleFormFieldsets);
      toggleFormFieldsets();

      function toggleFormFieldsets() {

        var selectedMappingType = mappingType.val();

        switch (selectedMappingType) {

          case 'redirect':
            redirectFields.show();
            archiveFields.hide();
            break;

          case 'archive':
            redirectFields.hide();
            archiveFields.show();
            break;

          default:
            redirectFields.show();
            archiveFields.show();
            break;
        }
      }
    };
  };

})(GOVUKAdmin.Modules);
