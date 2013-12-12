describe('A selectable table module', function() {
  "use strict"

  var root = window,
      table,
      tableRows,
      tableInputs;

  // Bypass jQuery, setting shiftKey on jQuery event didn't pass through as expected
  function simulateShiftClick(element) {
    var evt = document.createEvent('HTMLEvents');

        // See https://developer.mozilla.org/en-US/docs/Web/API/Event.initEvent
        // Event bubbles but is not cancelable
        evt.initEvent('click', true, false);
        evt.shiftKey = true;

    element.dispatchEvent(evt);
  }

  beforeEach(function() {

    table = $('<table>\
      <thead>\
        <tr>\
          <th><input type="checkbox" class="js-toggle-all" /></th>\
        </tr>\
      </thead>\
      <tbody>\
        <tr>\
          <td><input type="checkbox" class="js-toggle-row" /></td>\
        </tr>\
        <tr>\
          <td><input type="checkbox" class="js-toggle-row" /></td>\
        </tr>\
        <tr>\
          <td><input type="checkbox" class="js-toggle-row" /></td>\
        </tr>\
        <tr>\
          <td><input type="checkbox" class="js-toggle-row" /></td>\
        </tr>\
        <tr>\
          <td><input type="checkbox" class="js-toggle-row" /></td>\
        </tr>\
        <tr>\
          <td><input type="checkbox" class="js-toggle-row" /></td>\
        </tr>\
      </tbody>\
    </table>');

    $('body').append(table);
    root.GOVUK.SelectableTable.start(table);

    tableRows = table.find('tbody tr');
    tableInputs = tableRows.find('input');

  });

  afterEach(function() {
    table.remove();
  });

  describe('when the page loads', function() {

    var tableWithSelection;

    beforeEach(function() {

      tableWithSelection = $('<table>\
        <thead>\
          <tr>\
            <th><input type="checkbox" class="js-toggle-all" /></th>\
          </tr>\
        </thead>\
        <tbody>\
          <tr>\
            <td><input type="checkbox" class="js-toggle-row" checked="checked"/></td>\
          </tr>\
          <tr>\
            <td><input type="checkbox" class="js-toggle-row" /></td>\
          </tr>\
        </tbody>\
      </table>');

      $('body').append(tableWithSelection);
      root.GOVUK.SelectableTable.start(tableWithSelection);

    });

    afterEach(function() {
      tableWithSelection.remove();
    });

    it('marks rows as selected if the checkbox is already checked', function() {
      expect(tableWithSelection.find('tr:first-child').is('.selected-row')).toBe(true);
      expect(tableWithSelection.find('tr.selected-row').length).toBe(1);
    });

    it('marks the header checkbox based on the loaded state of the checkboxes', function() {
      expect(tableWithSelection.find('.js-toggle-all').prop('indeterminate')).toBe(true);
      expect(tableWithSelection.find('.js-toggle-all').prop('checked')).toBe(false);
    });

  });

  describe('when clicking a checkbox on a body row', function() {

    it('toggles the selection', function() {
      var firstRow = table.find('tbody tr:first-child'),
          firstInput = firstRow.find('input');

      firstInput.click();
      expect(firstRow.is('.selected-row')).toBe(true);
      expect(table.find('.selected-row').length).toBe(1);

      firstInput.click();
      expect(firstRow.is('.selected-row')).toBe(false);
    });

    it('updates the header checkbox', function() {
      var firstInput = table.find('tbody tr:first-child input'),
          secondInput = table.find('tbody tr:first-child + tr input'),
          headerInput = table.find('thead input');

      firstInput.click();
      expect(headerInput.prop('indeterminate')).toBe(true);
      expect(headerInput.prop('checked')).toBe(false);

      firstInput.click();
      table.find('tbody input').each(function() {
        $(this).click();
      });

      expect(headerInput.prop('indeterminate')).toBe(false);
      expect(headerInput.prop('checked')).toBe(true);

      table.find('tbody input').each(function() {
        $(this).click();
      });

      expect(headerInput.prop('indeterminate')).toBe(false);
      expect(headerInput.prop('checked')).toBe(false);

    });

  });

  describe('when a row is shift clicked without any other previous rows being changed', function() {

    it('toggles the row as normal', function() {
      simulateShiftClick(tableInputs.get(1));
      expect(tableRows.eq(1).is('.selected-row')).toBe(true);
    });

  });

  describe('when a row has been selected', function() {

    describe('when another row is selected using the shift key', function() {

      it('selects all rows between the (above) previously changed and the newly changed', function() {

        tableInputs.eq(1).click();
        simulateShiftClick(tableInputs.get(5));

        expect(tableRows.eq(0).is('.selected-row')).toBe(false);
        expect(tableRows.eq(1).is('.selected-row')).toBe(true);
        expect(tableRows.eq(2).is('.selected-row')).toBe(true);
        expect(tableRows.eq(3).is('.selected-row')).toBe(true);
        expect(tableRows.eq(4).is('.selected-row')).toBe(true);
        expect(tableRows.eq(5).is('.selected-row')).toBe(true);
      });

      it('selects all rows between the (below) previously changed and the newly changed', function() {

        tableInputs.eq(5).click();
        simulateShiftClick(tableInputs.get(1));

        expect(tableRows.eq(0).is('.selected-row')).toBe(false);
        expect(tableRows.eq(1).is('.selected-row')).toBe(true);
        expect(tableRows.eq(2).is('.selected-row')).toBe(true);
        expect(tableRows.eq(3).is('.selected-row')).toBe(true);
        expect(tableRows.eq(4).is('.selected-row')).toBe(true);
        expect(tableRows.eq(5).is('.selected-row')).toBe(true);
      });

      it('updates the state of the header toggle', function() {

        tableInputs.eq(0).click();
        simulateShiftClick(tableInputs.get(5));
        expect(table.find('.js-toggle-all').prop('checked')).toBe(true);
      });

    });

    describe('when another row is unselected using the shift key', function() {

      it('unselects all rows between the previously changed and newly changed', function() {

        tableInputs.eq(1).click();
        simulateShiftClick(tableInputs.get(5));
        simulateShiftClick(tableInputs.get(2));

        expect(tableRows.eq(0).is('.selected-row')).toBe(false);
        expect(tableRows.eq(1).is('.selected-row')).toBe(true);
        expect(tableRows.eq(2).is('.selected-row')).toBe(false);
        expect(tableRows.eq(3).is('.selected-row')).toBe(false);
        expect(tableRows.eq(4).is('.selected-row')).toBe(false);
        expect(tableRows.eq(5).is('.selected-row')).toBe(false);

      });

    });

  });

  describe('when clicking the checkbox in the header', function() {

    var headerInput,
        rows;

    beforeEach(function() {
      headerInput = table.find('thead input');
      rows = table.find('tbody tr');
    });

    describe('when some inputs are already selected', function() {

      beforeEach(function() {
        table.find('tbody tr').first().addClass('selected-row').find('input').prop('checked', true);
        headerInput.click();
      });

      it('selects all rows', function() {
        expect(table.find('.selected-row').length).toBe(rows.length);
        expect(table.find('.selected-row input:checked').length).toBe(rows.length);
      });

      it('checks the header checkbox', function() {
        expect(headerInput.prop('checked')).toBe(true);
      });

    });

    describe('when no inputs are selected', function() {

      beforeEach(function() {
        headerInput.click();
      });

      it('selects all rows', function() {
        expect(table.find('.selected-row').length).toBe(rows.length);
        expect(table.find('.selected-row input:checked').length).toBe(rows.length);
      });

      it('checks the header checkbox', function() {
        expect(headerInput.prop('checked')).toBe(true);
      });

    });

    describe('when all inputs are selected', function() {

      beforeEach(function() {
        table.find('tbody tr').addClass('selected-row').find('input').prop('checked', true);
        headerInput.click();
      });

      it('unselects all rows', function() {
        expect(table.find('.selected-row').length).toBe(0);
        expect(table.find('tbody input:checked').length).toBe(0);
      });

      it('unchecks the header checkbox', function() {
        expect(headerInput.prop('checked')).toBe(false);
      });

    });

  });

});
