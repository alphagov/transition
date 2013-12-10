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
    },

    setupTables: function() {
      $('[data-module="selectable-table"]').each(function() {
        GOVUK.Mappings.selectableTable($(this));
      });
    },

    selectableTable: function(element) {

      var tableRows = element.find('tbody tr'),
          SELECTED_ROW_CLASS = 'selected-row';

      element.on('click', 'tbody input', toggleRow);
      element.on('click', 'thead input', toggleAllRows);

      function toggleRow(event) {

        if (event.shiftKey) {
          shiftToggleRow(event);
          return;
        }

        var target = $(event.target),
            row = target.parents('tr'),
            selectedRowsCount,
            inputHeader = element.find('thead input');

        tableRows.removeClass('js-most-recently-changed');
        row.addClass('js-most-recently-changed');

        row.toggleClass(SELECTED_ROW_CLASS);

        selectedRowsCount = tableRows.filter('.' + SELECTED_ROW_CLASS).length;

        if (selectedRowsCount > 0 && selectedRowsCount < tableRows.length) {
          inputHeader.prop('indeterminate', true);
          inputHeader.prop('checked', false);
        } else if (selectedRowsCount === 0) {
          inputHeader.prop('checked', false);
          inputHeader.prop('indeterminate', false);
        } else {
          inputHeader.prop('checked', true);
          inputHeader.prop('indeterminate', false);
        }

      }

      function shiftToggleRow(event) {

        var targetRow = $(event.target).parents('tr'),
            targetIndex = tableRows.index(targetRow),
            mostRecentlyChanged = tableRows.filter('.js-most-recently-changed'),
            mostRecentlyChangedIndex = tableRows.index(mostRecentlyChanged),
            rows = tableRows.slice(mostRecentlyChangedIndex, targetIndex + 1);

        toggleRows(rows, true);

      }

      function toggleAllRows(event) {

        var rows = element.find('tbody tr');

        // If everything selected
        if (tableRows.length == element.find('.' + SELECTED_ROW_CLASS).length) {
          toggleRows(rows, false);
          $(event.target).prop('checked', false);
        } else {
          toggleRows(rows, true);
          $(event.target).prop('checked', true);
        }

      }

      function toggleRows(rows, select) {
        if (select) {
          rows.addClass(SELECTED_ROW_CLASS)
        } else {
          rows.removeClass(SELECTED_ROW_CLASS)
        }
        rows.find('input').prop('checked', select);
      }

    }

  };

  root.GOVUK.Mappings = Mappings;
}).call(this);
