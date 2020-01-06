function main_authenticity_token () {
  return $('[name="csrf-token"]').attr("content");
}

function main_ajax_add_search_result_to_search_notebook (data, on_success, on_failure) {
  data.authenticity_token = main_authenticity_token();
  data.mode = "ajax";

  $.ajax({
    url: "add_search_result_to_search_notebook",
    method: "POST",
    data: data,
    dataType: "json"
  })
  .done(on_success)
  .fail(on_failure)
}

function main_notify_success (message) {
  alert(message);
}

function main_notify_failure (message) {
  alert(message);
}