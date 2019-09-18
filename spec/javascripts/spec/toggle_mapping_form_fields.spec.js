describe('A mappings module', function() {
  "use strict"

  var toggle,
      form;

  describe('when editing or adding a mapping', function() {

    beforeEach(function() {

      form = $('<form>\
        <div class="form-group row ">\
          <legend class="legend-reset add-label-margin bold">Type</legend>\
          <label class="radio-inline">\
            <input checked="checked" class="js-type" id="type_redirect" name="type" type="radio" value="redirect" />\
            Redirect\
          </label>\
          <label class="radio-inline">\
            <input class="js-type" id="type_archive" name="type" type="radio" value="archive" />\
            Archive\
          </label>\
          <label class="radio-inline">\
            <input class="js-type" id="type_unresolved" name="type" type="radio" value="unresolved" />\
            Unresolved\
          </label>\
        </div>\
        <div class="js-for-redirect"></div>\
        <div class="js-for-archive"></div>\
        <div class="js-for-unresolved"></div>\
        <div data-module="toggle">\
          <a href="#" class="js-toggle">Toggle</a>\
          <span class="js-toggle-target"></span>\
          <strong class="js-toggle-target if-js-hide"></strong>\
        </div>\
      </form>');

      $('body').append(form);

      toggle = new GOVUKAdmin.Modules.ToggleMappingFormFields();
    });

    afterEach(function() {
      form.remove();
    });

    it('shows only the archive fields when the mapping is an archive' , function() {

      form.find('.js-type').val('archive');
      toggle.start(form);

      expect(form.find('.js-for-redirect:visible').length).toBe(0);
      expect(form.find('.js-for-archive:visible').length).toBe(1);
      expect(form.find('.js-for-unresolved:visible').length).toBe(0);
    });

    it('shows only the redirect fields when the mapping is a redirect' , function() {

      form.find('.js-type').val('redirect');
      toggle.start(form);

      expect(form.find('.js-for-redirect:visible').length).toBe(1);
      expect(form.find('.js-for-archive:visible').length).toBe(0);
      expect(form.find('.js-for-unresolved:visible').length).toBe(0);
    });

    it('shows only the unresolved fields when the mapping is unresolved' , function() {
      form.find('.js-type').val('unresolved');
      toggle.start(form);
      expect(form.find('.js-for-redirect:visible').length).toBe(0);
      expect(form.find('.js-for-archive:visible').length).toBe(0);
      expect(form.find('.js-for-unresolved:visible').length).toBe(1);
    });

    describe('when the mapping type changes', function() {

      it('toggles the appropriate form fields' , function() {

        toggle.start(form);
        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(0);
        expect(form.find('.js-for-unresolved:visible').length).toBe(0);

        form.find('.js-type').val('redirect').trigger('change');
        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(0);
        expect(form.find('.js-for-unresolved:visible').length).toBe(0);

        form.find('.js-type').val('archive').trigger('change');
        expect(form.find('.js-for-redirect:visible').length).toBe(0);
        expect(form.find('.js-for-archive:visible').length).toBe(1);
        expect(form.find('.js-for-unresolved:visible').length).toBe(0);

        form.find('.js-type').val('unresolved').trigger('change');
        expect(form.find('.js-for-redirect:visible').length).toBe(0);
        expect(form.find('.js-for-archive:visible').length).toBe(0);
        expect(form.find('.js-for-unresolved:visible').length).toBe(1);
      });

      it('shows all fields if the new mapping type is not redirect, archive or unresolved' , function() {

        toggle.start(form);
        form.find('.js-type').val(0).trigger('change');

        expect(form.find('.js-for-redirect:visible').length).toBe(1);
        expect(form.find('.js-for-archive:visible').length).toBe(1);
        expect(form.find('.js-for-unresolved:visible').length).toBe(1);
      });

    });

  });

});
