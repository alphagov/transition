describe('A mappings module', function() {
  "use strict"

  var toggle,
      form;

  describe('when editing or adding a mapping', function() {

    beforeEach(function() {

      form = $('<form>\
        <select class="js-http-status">\
          <option value="0"></option>\
          <option value="301">301 Moved Permanently</option>\
          <option value="410">410 Gone</option>\
        </select>\
        <div class="js-for-redirect"></div>\
        <div class="js-for-archive"></div>\
        <div data-module="toggle">\
          <a href="#" class="js-toggle">Toggle</a>\
          <span class="js-toggle-target"></span>\
          <strong class="js-toggle-target if-js-hide"></strong>\
        </div>\
      </form>');

      toggle = new GOVUK.Modules.ToggleMappingFormFields();
    });

    it('shows only the archive fields when the mapping is a 410' , function() {

      form.find('.js-http-status').val(410);
      toggle.start(form);

      expect(form.find('.js-for-redirect:visible').length).toBe(0);
      expect(form.find('.js-for-archive:visible').length).toBe(1);
    });

    it('shows only the redirect fields when the mapping is a 301' , function() {

      form.find('.js-http-status').val(301);
      toggle.start(form);

      expect(form.find('.js-for-redirect:visible').length).toBe(1);
      expect(form.find('.js-for-archive:visible').length).toBe(0);
    });

    describe('when the http status changes', function() {

      it('toggles the appropriate form fields' , function() {

        toggle.start(form);
        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(1);

        form.find('.js-http-status').val(301).trigger('change');
        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(0);

        form.find('.js-http-status').val(410).trigger('change');
        expect(form.find('.js-for-redirect:visible').length).toBe(0);
        expect(form.find('.js-for-archive:visible').length).toBe(1);
      });

      it('shows all fields if the new http status is not 301 or 410' , function() {

        toggle.start(form);
        form.find('.js-http-status').val(0).trigger('change');

        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(1);
      });

    });

  });

});
