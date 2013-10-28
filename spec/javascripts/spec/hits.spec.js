describe('A hits module', function() {
  "use strict"

  var root = window,
      container;

  describe('when plotting a hits graph', function() {

    beforeEach(function() {

      container = $('<div class="js-hits-graph"></div>');
      $('body').append(container);

      window.google = {
        load: function() {},
        setOnLoadCallback: function() {},
        visualization: {
          arrayToDataTable: function() {},
          LineChart: function() {}
        }
      }
    });

    afterEach(function() {
      container.remove();
      delete window.google;
    });

    it('waits for google charts API to load' , function() {
      spyOn(window.google, "setOnLoadCallback");

      root.GOVUK.Hits.plot();
      expect(window.google.setOnLoadCallback).toHaveBeenCalledWith(jasmine.any(Function));
    });

    describe('when the chart API has loaded', function() {

      var callbackFn,
          chartFn;

      beforeEach(function() {
        window.rawData = [["Date", "Errors"], ["2012-10-17", 200], ["2012-10-18", 810]];

        chartFn = {draw: function() {}};

        spyOn(window.google, "setOnLoadCallback").and.callFake(function(callback) {
          callbackFn = callback;
        });

        spyOn(window.google.visualization, "LineChart").and.returnValue(chartFn);
      });

      it('parses the raw data provided by the page', function() {
        spyOn(window.google.visualization, "arrayToDataTable");

        root.GOVUK.Hits.plot();
        callbackFn();
        expect(window.google.visualization.arrayToDataTable).toHaveBeenCalledWith(window.rawData);
      });

      it('draws into the hits graph container', function() {
        root.GOVUK.Hits.plot();
        callbackFn();

        var call = window.google.visualization.LineChart.calls.mostRecent();
        expect($(call.args[0]).is('.js-hits-graph')).toBe(true);
      });

      it('generates an X axis title based on the date range', function() {
        spyOn(chartFn, 'draw');
        root.GOVUK.Hits.plot();
        callbackFn();

        expect(chartFn.draw.calls.mostRecent().args[1].hAxis.title).toBe("17 October 2012 to 18 October 2012");
      });
    });
  });
});
