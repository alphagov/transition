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
        <span class="js-remove-on-success js-progress-bar"></span>\
        <span class="js-progress-container"></span>\
        <span class="js-remove-on-success"></span>\
      </div>\
    ');
    batchProgress = new GOVUKAdmin.Modules.BatchProgress();
    jasmine.clock().install();
  });

  afterEach(function() {
    batchProgress.stop();
    jasmine.clock().uninstall();
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
      var response = {done: 1, total: 10, past_participle: 'added'};
      spyOn($, 'ajax').and.callFake(function(options) {
        options.success(response);
        response.done = 2;
      });
      batchProgress.start(element);
    });

    it('updates the width of the progress bar', function() {
      expect(element.find('.js-progress-bar').attr('style')).toMatch('width: 10%;');
    });

    it('updates the aria value now attribute', function() {
      expect(element.find('.js-progress-bar').attr('aria-valuenow')).toMatch('10');
    });

    it('updates the count of done mappings', function() {
      expect(element.find('.js-progress-message').text()).toBe('1 of 10 mappings added');
    });

    it('updates the percentage of done mappings', function() {
      expect(element.find('.js-progress-percent').text()).toBe('10');
    });

    describe('and a second has passed', function() {

      beforeEach(function(done) {
        elapseOneSecondAndTest(done);
      });

      it('keeps updating the display as the response changes', function() {
        expect(element.find('.js-progress-bar').attr('style')).toMatch('width: 20%;');
        expect(element.find('.js-progress-message').text()).toBe('2 of 10 mappings added');
        expect(element.find('.js-progress-percent').text()).toBe('20');
      });
    });
  });

  describe('when processing is done', function() {

    beforeEach(function(done) {
      var response = {done: 10, total: 10, past_participle: 'added'};
      spyOn($, 'ajax').and.callFake(function(options) {
        options.success(response);
      });
      batchProgress.start(element);
      elapseOneSecondAndTest(done);
    });

    it('shows a success state', function() {
      expect(element.find('.alert-success').length).toBe(1);
      expect(element.find('.js-progress-message').text()).toBe('10 of 10 mappings added');
    });

    it('removes elements no longer needed', function() {
      expect(element.find('.js-remove-on-success').length).toBe(0);
    });

    it('stops making requests', function() {
      jasmine.clock().tick(1001);
      expect($.ajax.calls.count()).toBe(1);

      jasmine.clock().tick(10001);
      expect($.ajax.calls.count()).toBe(1);
    });
  });

  function elapseOneSecondAndTest(done) {
    setTimeout(function() {
      done();
    }, 1000);
    jasmine.clock().tick(1001);
  }

});
