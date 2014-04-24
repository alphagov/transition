(function(Modules) {
  "use strict";

  Modules.BatchProgress = function() {
    var that = this,
        timeout,
        request;

    that.start = function(element) {

      var url = element.data('url'),
          timeout,
          message = element.find('.js-progress-message'),
          percentDone = element.find('.js-progress-percent'),
          bar = element.find('.js-progress-bar');

      requestProgress();

      function requestProgress() {
        request = $.ajax({
          url: url,
          success: updateProgress
        });
      }

      // {done: X, total: X}
      function updateProgress(progress) {
        var percent = (progress.done/progress.total * 100).toFixed(0);
        message.text(progress.done + " of " + progress.total + " mappings added");
        percentDone.text(percent);
        bar.css('width', percent + '%');
        timeout = setTimeout(requestProgress, 1000);
      }
    };

    that.stop = function() {
      if (typeof request === "object") {
        request.abort();
      }
      clearTimeout(timeout);
    };

  };

})(window.GOVUK.Modules);
