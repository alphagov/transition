(function() {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if (typeof root.GOVUK === 'undefined') {
    root.GOVUK = {};
  }

  var Hits = {
    plot: function() {

      var chartContainer = $('.js-hits-graph').get(0);
      window.google.load("visualization", "1", {packages:["corechart"]});
      window.google.setOnLoadCallback(drawChart);

      function drawChart() {

        // Documentation
        // https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
        // https://developers.google.com/chart/interactive/docs/roles

        var data = window.google.visualization.arrayToDataTable(rawData),
            chart = new window.google.visualization.LineChart(chartContainer),
            options = {
              chartArea: {
                left: 60,
                top: 20,
                width: '80%',
                height: '80%'
              },
              focusTarget: 'category' // Highlights all trends in a single tooltip, hovering
                                      // anywhere in the space above or below a point
            };

        chart.draw(data, options);
      }
    }
  };

  root.GOVUK.Hits = Hits;
}).call(this);
