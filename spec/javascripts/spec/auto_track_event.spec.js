describe('An auto event tracker', function() {
  "use strict"

  var root = window,
      tracker,
      element;

  beforeEach(function() {
    element = $('\
      <div data-track-action="action" data-track-label="label" data-track-value="10">\
      </div>\
    ');

    tracker = new GOVUK.Modules.AutoTrackEvent();
  });

  it('tracks events on start', function() {
    spyOn(root.GOVUK, 'track');
    tracker.start(element);
    expect(GOVUK.track).toHaveBeenCalledWith('action', 'label', 10)
  });
});
