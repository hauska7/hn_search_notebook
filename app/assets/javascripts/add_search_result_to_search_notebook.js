$(document).ready(function() {
  setup_add_search_result_to_search_notebook();
});

function setup_add_search_result_to_search_notebook () {
  if ($('.add-search-result-to-search-notebook').length == 0) { return; }

  $('.add-search-result-to-search-notebook').each(function(_index, item) {
    $(item).click(function (e) {
      e.preventDefault();

      element = $(e.target);

      var data = { search_notebook_id: element.attr("data-search-notebook-id"),
                   search_result_id: element.attr("data-search-result-id") }

      var on_success = function() {
        main_notify_success("Result added succesfully.");
      }

      var on_failure = function() {
        main_notify_failure("An error has occured.");
      }

      main_ajax_add_search_result_to_search_notebook(data, on_success, on_failure);
    });

  })

}