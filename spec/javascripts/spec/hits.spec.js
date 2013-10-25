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

      spyOn(window.google, "load");
      spyOn(window.google, "setOnLoadCallback");

      root.GOVUK.Hits.plot();

      expect(window.google.load).toHaveBeenCalledWith("visualization", "1", {packages:["corechart"]});
      expect(window.google.setOnLoadCallback).toHaveBeenCalledWith(jasmine.any(Function));
    });

    describe('when the chart API has loaded', function() {

      beforeEach(function() {
        window.rawData = [["Date", "Errors"], ["2012-10-17", 200], ["2012-10-18", 810]];
      });

      it('parses the raw data and draws it', function() {

        var callbackFn,
            chart = {draw: function() {}};

        spyOn(window.google, "setOnLoadCallback").and.callFake(function(callback) {
          callbackFn = callback;
        });

        spyOn(window.google.visualization, "arrayToDataTable");
        spyOn(window.google.visualization, "LineChart").and.returnValue(chart);
        spyOn(chart, "draw");

        root.GOVUK.Hits.plot();
        callbackFn();

        expect(window.google.visualization.arrayToDataTable).toHaveBeenCalledWith(window.rawData);
        expect(window.google.visualization.LineChart).toHaveBeenCalled();

        var call = window.google.visualization.LineChart.calls.mostRecent();
        expect($(call.args[0]).is('.js-hits-graph')).toBe(true);

        expect(chart.draw).toHaveBeenCalled();

      });

    });

  });

});
