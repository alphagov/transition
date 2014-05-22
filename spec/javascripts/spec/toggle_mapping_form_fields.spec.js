describe('A mappings module', function() {
  "use strict"

  var toggle,
      form;

  describe('when editing or adding a mapping', function() {

    beforeEach(function() {

      form = $('<form>\
        <select class="js-type">\
          <option value="0"></option>\
          <option value="redirect">Redirect</option>\
          <option value="archive">Archive</option>\
        </select>\
        <div class="js-for-redirect"></div>\
        <div class="js-for-archive"></div>\
        <div data-module="toggle">\
          <a href="#" class="js-toggle">Toggle</a>\
          <span class="js-toggle-target"></span>\
          <strong class="js-toggle-target if-js-hide"></strong>\
        </div>\
      </form>');

      $('body').append(form);

      toggle = new GOVUK.Modules.ToggleMappingFormFields();
    });

    afterEach(function() {
      form.remove();
    });

    it('shows only the archive fields when the mapping is an archive' , function() {

      form.find('.js-type').val('archive');
      toggle.start(form);

      expect(form.find('.js-for-redirect:visible').length).toBe(0);
      expect(form.find('.js-for-archive:visible').length).toBe(1);
    });

    it('shows only the redirect fields when the mapping is a redirect' , function() {

      form.find('.js-type').val('redirect');
      toggle.start(form);

      expect(form.find('.js-for-redirect:visible').length).toBe(1);
      expect(form.find('.js-for-archive:visible').length).toBe(0);
    });

    describe('when the mapping type changes', function() {

      it('toggles the appropriate form fields' , function() {

        toggle.start(form);
        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(1);

        form.find('.js-type').val('redirect').trigger('change');
        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(0);

        form.find('.js-type').val('archive').trigger('change');
        expect(form.find('.js-for-redirect:visible').length).toBe(0);
        expect(form.find('.js-for-archive:visible').length).toBe(1);
      });

      it('shows all fields if the new mapping type is not redirect or archive' , function() {

        toggle.start(form);
        form.find('.js-type').val(0).trigger('change');

        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(1);
      });

    });

  });

});
