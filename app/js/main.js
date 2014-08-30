$(function() {
  $('#search').on('keypress', function(e) {
    if (e.which == 13) {
      $.get({
        url: '/search',
        data: { search: $(this).val() }
      })
    }
  });
});
