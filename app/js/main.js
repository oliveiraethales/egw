$(function() {
  $('#load-more').click(function() {
    $.get('/subjects.json?page=1', function(data) {
      $(this).parent().empty();

      $.each(data, function(index, value)) {
        var newColumn = (index == 0 || index % 10);

        if (newColumn) {
          $(this).nearest('col-lg-3');
        }
      }

      $(this).parent().append();
    });

    return false;
  });
});
