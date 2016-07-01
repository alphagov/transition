describe('A hits module', function() {
  "use strict"

  var root = window,
      container;

  describe('when plotting a hits graph', function() {

    beforeEach(function() {
      container = $('<div class="js-hits-graph"></div>');
      $('body').append(container);

      window.google = {
        charts: {
          load: function() {},
          setOnLoadCallback: function() {},
        },
        visualization: {
          events: {
            addListener: function() {}
          },
          DataTable: function() {},
          LineChart: function() {}
        }
      }
    });

    afterEach(function() {
      container.remove();
      delete window.google;
    });

    it('waits for google charts API to load' , function() {
      spyOn(window.google.charts, "setOnLoadCallback");

      root.GOVUK.Hits.plot();
      expect(window.google.charts.setOnLoadCallback).toHaveBeenCalledWith(jasmine.any(Function));
    });

    describe('when the chart API has loaded', function() {

      var callbackFn,
          chartFn,
          literalDataTable = { fakeDataTable: true };

      beforeEach(function() {
        chartFn = {draw: function() {}};

        spyOn(window.google.charts, "setOnLoadCallback").and.callFake(function(callback) {
          callbackFn = callback;
        });

        spyOn(window.google.visualization, "LineChart").and.returnValue(chartFn);
      });

      it('passes the raw data in the page to a DataTable', function() {
        spyOn(window.google.visualization, "DataTable");

        root.GOVUK.Hits.plot(literalDataTable);
        callbackFn();
        expect(window.google.visualization.DataTable).toHaveBeenCalledWith(literalDataTable);
      });

      it('draws into the hits graph container', function() {
        root.GOVUK.Hits.plot();
        callbackFn();

        var call = window.google.visualization.LineChart.calls.mostRecent();
        expect($(call.args[0]).is('.js-hits-graph')).toBe(true);
      });

      it('sets trend colours to those passed in', function() {
        var colors = ['#999', '#000'];

        root.GOVUK.Hits.plot(literalDataTable, colors);
        spyOn(chartFn, 'draw');
        callbackFn();

        expect(chartFn.draw.calls.mostRecent().args[1].colors).toEqual(colors);
      });
    });
  });
});
