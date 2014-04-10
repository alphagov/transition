(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;

  if (typeof root.GOVUK === 'undefined') {
    root.GOVUK = {};
  }

  root.GOVUK.Tagging = {
    ready: function(options) {
      $('.js-tag-list').select2({
        tags: options['autocompleteWith'],
        selectOnBlur: true,
        tokenSeparators: [','],
        initSelection: function (input, setTags) {
          setTags(
            $(input.val().split(",")).map(function () {
              return {
                id: $.trim(this),
                text: $.trim(this)
              };
            })
          )
        }
      })
    }
  };
}).call(this);
