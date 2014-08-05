(function(Modules) {
  "use strict";

  Modules.BatchProgress = function() {
    var that = this,
        timeout,
        request;

    that.start = function(element) {

      var url = element.data('url'),
          message = element.find('.js-progress-message'),
          percentDone = element.find('.js-progress-percent'),
          progressContainer = element.find('.js-progress-container'),
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
        var percent;
        message.text(progress.done + " of " + progress.total + " mappings " + progress.past_participle);

        if (progress.done === progress.total) {
          showSuccess(progress);
          return;
        }

        percent = (progress.done/progress.total * 100).toFixed(0);
        percentDone.text(percent);
        bar.css('width', percent + '%');
        bar.attr('aria-valuenow', percent);
        timeout = setTimeout(requestProgress, 1000);
      }

      function showSuccess(progress) {
        element.find('.js-remove-on-success').remove();
        progressContainer.removeClass('alert-info');
        progressContainer.addClass('alert alert-success');
        that.stop();
      }

    };

    that.stop = function() {
      if (typeof request === "object") {
        request.abort();
      }
      clearTimeout(timeout);
    };

  };

})(window.GOVUKAdmin.Modules);
