describe('A batch progress module', function() {
  "use strict";

  var root = window,
      batchProgress,
      element;

  beforeEach(function() {
    element = $('\
      <div data-url="some-JSON-endpoint">\
        <span class="js-progress-message"></span>\
        <span class="js-progress-percent"></span>\
        <span class="js-progress-bar"></span>\
      </div>\
    ');
    batchProgress = new GOVUK.Modules.BatchProgress();
  });

  describe('when started', function() {
    it('requests the current values from the URL provided when started', function() {
      spyOn($, 'ajax');
      batchProgress.start(element);
      expect($.ajax).toHaveBeenCalledWith({
        url: 'some-JSON-endpoint',
        success: jasmine.any(Function)
      });
    });
  });

  describe('when progress is returned', function() {

    beforeEach(function() {
      var response = {done: 1, total: 10};
      spyOn($, 'ajax').and.callFake(function(options) {
        options.success(response);
        response.done = 2;
      });
      batchProgress.start(element);
    });

    afterEach(function() {
      batchProgress.stop();
    });

    it('updates the width of the progress bar', function() {
      expect(element.find('.js-progress-bar').attr('style')).toMatch('width: 10%;');
    });

    it('updates the count of done mappings', function() {
      expect(element.find('.js-progress-message').text()).toBe('1 of 10 mappings added');
    });

    it('updates the percentage of done mappings', function() {
      expect(element.find('.js-progress-percent').text()).toBe('10');
    });

    describe('and a second has passed', function() {

      beforeEach(function(done) {
        setTimeout(function() {
          done();
        }, 1000);
      });

      it('keeps updating the display as the response changes', function() {
        expect(element.find('.js-progress-bar').attr('style')).toMatch('width: 20%;');
        expect(element.find('.js-progress-message').text()).toBe('2 of 10 mappings added');
        expect(element.find('.js-progress-percent').text()).toBe('20');
      });
    })

  });

});
