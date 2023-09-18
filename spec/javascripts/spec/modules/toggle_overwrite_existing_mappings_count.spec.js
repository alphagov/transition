describe('Toggling the overwrite mappings count', function() {
  "use strict"

  var toggle,
      form;

  describe('when importing mappings', function() {

    beforeEach(function() {

      form = $('<form>\
        <div>\
          <label class="radio-inline" for="import_batch_update_existing_false">\
            <input checked="checked" id="import_batch_update_existing_false" name="import_batch[update_existing]" type="radio" value="false" /> Keep existing mappings\
          </label>\
          <label class="radio-inline" for="import_batch_update_existing_true">\
            <input id="import_batch_update_existing_true" name="import_batch[update_existing]" type="radio" value="true" /> Overwrite existing mappings\
          </label>\
        </div>\
        <ul class="list-group">\
          <li class="list-group-item list-group-item-warning js-overwrite-count">Overwrite 3 existing mappings</li>\
        </ul>\
      </form>');

      $('body').append(form);

      toggle = new GOVUKAdmin.Modules.ToggleOverwriteExistingMappingsCount();
    });

    afterEach(function() {
      form.remove();
    });

    it('does not show the overwrite count to start with' , function() {

      toggle.start(form);

      expect(form.find('.js-overwrite-count:visible').length).toBe(0);
    });

    it('shows the overwrite count when the overwrite option is selected' , function() {

      form.find('#import_batch_update_existing_true').prop('checked', true).trigger('change');
      toggle.start(form);

      expect(form.find('.js-overwrite-count:visible').length).toBe(1);
    });

    it('hides the overwrite count when the keep option is selected' , function() {

      form.find('#import_batch_update_existing_false').prop('checked', true).trigger('change');
      toggle.start(form);

      expect(form.find('.js-overwrite-count:visible').length).toBe(0);
    });

  });

});
