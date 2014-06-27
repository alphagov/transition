(function(Modules) {
  "use strict"

  Modules.ToggleOverwriteExistingMappingsCount = function() {

    var that = this;

    that.start = function(element) {

      var form = element,
          overwriteExisting = form.find('input:radio'),
          overwriteCount = form.find('.js-overwrite-count');

      overwriteExisting.on('change', toggleOverwriteCount);
      toggleOverwriteCount();

      function toggleOverwriteCount() {

        var selectedOverwriteOption = $('#import_batch_update_existing_true').prop('checked');

        switch (selectedOverwriteOption) {

          case true:
            overwriteCount.show();
            break;

          case false:
            overwriteCount.hide();
            break;

          default:
            overwriteCount.hide();
            break;
        }
      }
    };
  };

})(GOVUKAdmin.Modules);
