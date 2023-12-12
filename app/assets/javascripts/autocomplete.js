//= require accessible-autocomplete.min.js

initialiseSelectElement();

function initialiseSelectElement() {
  const selectElement = document.querySelector('.autocomplete-enabled');

  accessibleAutocomplete.enhanceSelectElement({
    selectElement: selectElement,
    showAllValues: selectElement.multiple,
  })
}
