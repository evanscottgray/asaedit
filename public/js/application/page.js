$('document').ready(function () {
    $('.close').click(function () {
        $(this).closest('.alert').fadeOut("slow");
    });
    $('.list-users').click(function () {
        $.ajax(
            {
                url: "/users",
                type: "GET",
                success: function (data, textStatus, jqXHR) {
                    $('#users').text(jqXHR.responseText);
                    $('.users').fadeIn("slow");
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    $('#error').text('Something went wrong... ' + jqXHR.responseText);
                    $('.alert-info').fadeOut("slow");
                    $('.alert-danger').delay(1000).fadeIn("slow");
                }
            });
    });
});

$('#form').submit(function (event) {
    var postData = $(this).serializeArray();
    $('.user').val('');
    $('.alert-info').delay(1000).fadeIn("slow");
    $.ajax(
        {
            url: "/make_user",
            type: "POST",
            data: postData,
            success: function (data, textStatus, jqXHR) {
                $('.response').text('Yay! User Created: ' + jqXHR.responseText);
                $('.alert-info').fadeOut("slow");
                $('.password').delay(1000).fadeIn("slow");
            },
            error: function (jqXHR, textStatus, errorThrown) {
                $('#error').text('Something went wrong... ' + jqXHR.responseText);
                $('.alert-info').fadeOut("slow");
                $('.alert-danger').delay(1000).fadeIn("slow");
            }
        });
    event.preventDefault();
});