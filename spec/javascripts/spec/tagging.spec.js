describe('A tagging selector', function() {
  "use strict"

  var container,
      input;

  describe('an input with comma-separated tags and autocomplete values', function() {

    beforeEach(function() {
      input = '<input class="js-tag-list" value="tag 1, tag 2, tag_3">';
      container = $('<div>' + input + '</div>');

      $('body').append(container);

      GOVUK.Tagging.ready({autocompleteWith: ['red', 'green', 'blue', 'brown']});
    });

    afterEach(function() {
      container.remove();
    });

    it('has one value per tag in a select2 list on ready' , function() {
      expect(container.find('.select2-search-choice').length).toBe(3);
    });

    it('has the first tag as expected', function(){
      expect(container.find('.select2-search-choice div:first-child')[0].textContent).toBe('tag 1');
    });

    it('shows values from the autocompleteWith list as you type', function() {
      // type 'b'
      $('.select2-input').val('b').click();

      // it shows 'b', 'blue' and 'brown'
      var $select2Results = $('.select2-results .select2-result-label');

      expect($select2Results[0].textContent).toBe('b');
      expect($select2Results[1].textContent).toBe('blue');
      expect($select2Results[2].textContent).toBe('brown');
    });

  });

});
