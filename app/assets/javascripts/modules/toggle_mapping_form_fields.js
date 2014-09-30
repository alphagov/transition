(function(Modules) {
  "use strict"

  Modules.ToggleMappingFormFields = function() {

    var that = this;

    that.start = function(element) {

      var form = element,
          mappingType = form.find('.js-type'),
          archiveFields = form.find('.js-for-archive'),
          redirectFields = form.find('.js-for-redirect'),
          unresolvedFields = form.find('.js-for-unresolved');

      mappingType.on('change', toggleFormFieldsets);
      toggleFormFieldsets();

      function toggleFormFieldsets() {

        var selectedMappingType = mappingType.filter(':checked').val();

        switch (selectedMappingType) {

          case 'redirect':
            redirectFields.show();
            archiveFields.hide();
            unresolvedFields.hide();
            break;

          case 'archive':
            redirectFields.hide();
            archiveFields.show();
            unresolvedFields.hide();
            break;

          case 'unresolved':
            redirectFields.hide();
            archiveFields.hide();
            unresolvedFields.show();
            break;

          default:
            redirectFields.show();
            archiveFields.show();
            unresolvedFields.show();
            break;
        }
      }
    };
  };

})(GOVUKAdmin.Modules);
