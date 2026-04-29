function selectAllOptions(select_id){
  let $select = $('#' + select_id);
  // Get all option values
  let allValues = $select.find('option').map(function() {
    return $(this).val();
  }).get();
  // Set all values and trigger change for Select2 compatibility
  $select.val(allValues).trigger('change');
}

// Legacy functions kept for backwards compatibility
function selectAll(elem, select_id){
  let options = '#'+ select_id + " > option";
  let id = '#'+ select_id;
  if($(elem).is(':checked')){
    $(options).prop("selected", "selected");
    $(id).trigger("change");
  } else {
    $(options).removeAttr("selected");
    $(id).trigger("change");
  }
}

function update_checkbox(elem, checkbox, count) {
  let checkbox_id = '#'+ checkbox;
  if ($('#' + elem.id + ' option:selected').length == count) {
    $(checkbox_id).prop("checked", "checked")
  } else {
    $(checkbox_id).removeAttr("checked")
  }
}