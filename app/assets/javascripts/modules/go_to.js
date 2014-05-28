(function(Modules) {
  "use strict";

  Modules.GoTo = function() {
    var that = this;

    that.start = function(element) {

      var mappingModal = element.find('.js-go-to-mapping');
      Mousetrap.bind('g m', openGotoMappingModal);

      function openGotoMappingModal() {
        mappingModal.on('shown.bs.modal', function() {
          setTimeout(function() {
            mappingModal.find('input[type="text"]').focus();
          }, 50);
        });
        mappingModal.modal('show');
      }
    }
  };

})(window.GOVUKAdmin.Modules);
