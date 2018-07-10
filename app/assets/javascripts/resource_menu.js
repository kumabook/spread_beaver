$(document).on('turbolinks:load', function() {
  var $dropdown = $('<span class="dropdown" />');
  $dropdown.append(
    '<button class="btn btn-default dropdown-toggle resource-menu"' +
     'type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">' +
      '<i class="fas fa-bars"></i>' +
    '</button>'
  );
  var $dropdownContent = $('<div class="dropdown-menu resource-dropdown-menu" />');
  if ($('.resource-menu').is('[data-id]')) {
    $dropdownContent.append(
      '<label>ID</label>' +
      '<div class="input-group">' +
        '<input class="form-control id-input" type="text">' +
          '<span class="input-group-btn">' +
            '<button class="btn btn-default fas fa-copy copy-resource-id" type="submit" />' +
          '</span>' +
        '</input>' +
      '</div>'
    );
  }
  if ($('.resource-menu').is('[data-resource-id]')) {
    $dropdownContent.append(
      '<label>Resource ID</label>' +
        '<div class="input-group">' +
          '<input class="form-control resource-id-input" type="text">' +
            '<span class="input-group-btn">' +
              '<button class="btn btn-default fas fa-copy copy-resource-id" type="submit" />' +
            '</span>' +
          '</input>' +
        '</div>' +
      '</div>'
    );
  }
  $dropdown.append($dropdownContent);
  $(".resource-menu")
    .off('click')
    .empty()
    .prepend($dropdown)
    .on('click', ".resource-menu", function(e) {
      var $container = $(this).parent().parent();
      var id = $container.attr('data-id');
      $container.find('.id-input').val(id);
      var resourceId = $container.attr('data-resource-id');
      $container.find('.resource-id-input').val(resourceId);
    })
    .on('click', ".copy-id", function() {
      $(this).parent().parent().find('.id-input').select();
      document.execCommand('copy');
    })
    .on('click', ".copy-resource-id", function() {
      $(this).parent().parent().find('.resource-id-input').select();
      document.execCommand('copy');
    });
});
