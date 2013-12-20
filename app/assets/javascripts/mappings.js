(function() {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if (typeof root.GOVUK === 'undefined') {
    root.GOVUK = {};
  }

  var Mappings = {

    edit: function() {

      var form = $('.js-edit-mapping-form'),
          httpStatus = form.find('.js-http-status'),
          archiveFields = form.find('.js-for-archive'),
          redirectFields = form.find('.js-for-redirect');

      httpStatus.on('change', toggleFormFieldsets);
      toggleFormFieldsets();

      form.find('[data-module="toggle"]').each(function() {
        GOVUK.Mappings.toggle($(this));
      });

      function toggleFormFieldsets() {

        var selectedHTTPStatus = httpStatus.val();

        switch (selectedHTTPStatus) {

          case '301':
            redirectFields.show();
            archiveFields.hide();
            break;

          case '410':
            redirectFields.hide();
            archiveFields.show();
            break;

          default:
            redirectFields.show();
            archiveFields.show();
            break;
        }
      }
    },

    toggle: function(element) {
      element.on('click', '.js-toggle', toggle);
      element.on('click', '.js-cancel', cancel);

      function toggle(event) {
        element.find('.js-toggle-target').toggleClass('if-js-hide');
        element.find('input').first().focus();
        event.preventDefault();
      }

      function cancel(event) {
        toggle(event);
        element.find('input').first().val('');
      }
    }
  };

  root.GOVUK.Mappings = Mappings;
}).call(this);
