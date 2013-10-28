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

      var callbackFn;

      beforeEach(function() {
        window.rawData = [["Date", "Errors"], ["2012-10-17", 200], ["2012-10-18", 810]];

        spyOn(window.google, "setOnLoadCallback").and.callFake(function(callback) {
          callbackFn = callback;
        });

        spyOn(window.google.visualization, "LineChart").and.returnValue({draw: function() {}});
        root.GOVUK.Hits.plot();
      });

      it('parses the raw data provided by the page', function() {
        spyOn(window.google.visualization, "arrayToDataTable");
        callbackFn();
        
        expect(window.google.visualization.arrayToDataTable).toHaveBeenCalledWith(window.rawData);
      });

      it('draws into the hits graph container', function() {
        callbackFn();

        var call = window.google.visualization.LineChart.calls.mostRecent();
        expect($(call.args[0]).is('.js-hits-graph')).toBe(true);
      });
    });
  });
});
