describe('A selectable table module', function() {
  "use strict"

  var root = window,
      table;

  beforeEach(function() {

    table = $('<table>\
      <thead>\
        <tr>\
          <th><input type="checkbox" /></th>\
        </tr>\
      </thead>\
      <tbody>\
        <tr>\
          <td><input type="checkbox" /></td>\
        </tr>\
        <tr>\
          <td><input type="checkbox" /></td>\
        </tr>\
      </tbody>\
    </table>');

    $('body').append(table);
    root.GOVUK.Mappings.selectableTable(table);
  });

  afterEach(function() {
    table.remove();
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

      secondInput.click();
      expect(headerInput.prop('indeterminate')).toBe(false);
      expect(headerInput.prop('checked')).toBe(true);

      secondInput.click();
      firstInput.click();
      expect(headerInput.prop('indeterminate')).toBe(false);
      expect(headerInput.prop('checked')).toBe(false);

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
