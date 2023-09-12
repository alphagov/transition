(function() {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if (typeof root.GOVUK === 'undefined') {
    root.GOVUK = {};
  }

  var Hits = {
    lastDataTable: function(dataTable) {
      if (typeof dataTable === "undefined") {
        return this["_lastDataTable"];
      }
      this["_lastDataTable"] = dataTable;
    },
    plot: function(literalDataTable, colors) {

      var chartContainer = $('.js-hits-graph').get(0);
      window.google.charts.load('current', {packages: ['corechart']});
      window.google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
        function onDateSelected() {
          var rowNumber = chart.getSelection()[0].row;      // selection is always single item
          var date      = dataTable.getValue(rowNumber, 0);
          var formatter = new google.visualization.DateFormat({pattern: 'yyyyMMdd'});

          window.location = URI(window.location).setSearch("period", formatter.formatValue(date));
        }

        // Documentation
        // https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
        // https://developers.google.com/chart/interactive/docs/roles

        Hits.lastDataTable(literalDataTable);
        var dataTable = new window.google.visualization.DataTable(literalDataTable),
            chart     = new window.google.visualization.LineChart(chartContainer),
            options   = {
              chartArea: {
                left: 60,
                top: 20,
                width: '80%',
                height: '80%'
              },
              colors: colors,
              annotations: {style: 'line', stemColor: 'black'},
              focusTarget: 'category' // Highlights all trends in a single tooltip, hovering
                                      // anywhere in the space above or below a point
            };
        google.visualization.events.addListener(chart, 'select', onDateSelected);

        chart.draw(dataTable, options);
      }
    }
  };

  root.GOVUK.Hits = Hits;
}).call(this);
