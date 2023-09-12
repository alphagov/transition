(function(Modules) {
  "use strict";

  Modules.GoTo = function() {
    var that = this;

    that.start = function(element) {

      var mappingOrSiteModal = element.find('.js-go-to-site-or-mapping');
      Mousetrap.bind('g m', openGotoSiteOrMappingModal);

      function openGotoSiteOrMappingModal() {
        mappingOrSiteModal.on('shown.bs.modal', function() {
          setTimeout(function() {
            mappingOrSiteModal.find('input[type="text"]').focus();
          }, 50);
        });
        mappingOrSiteModal.modal('show');
      }
    }
  };

})(window.GOVUKAdmin.Modules);
