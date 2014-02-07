describe('A tagging selector', function() {
  "use strict"

  var container,
      input;

  describe('when wrapping an input with comma-separated tags', function() {

    beforeEach(function() {
      input = '<input class="js-tag-list" value="tag 1, tag 2, tag_3">';
      container = $('<div>' + input + '</div>');

      $('body').append(container);

      GOVUK.Tagging.ready();
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

  });

});
