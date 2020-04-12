/* Adds CSRF token to ajax call for methods that need it (POST) */
/*--------------------------------------------------------------*/
function getCookie(name) {
    var cookieValue = null;
    if (document.cookie && document.cookie != '') {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
            var cookie = jQuery.trim(cookies[i]);
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) == (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}
var csrftoken = getCookie('csrftoken');

function csrfSafeMethod(method) {
    // these HTTP methods do not require CSRF protection
    return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}

$.ajaxSetup({
    crossDomain: false, // obviates need for sameOrigin test
    beforeSend: function(xhr, settings) {
        if (!csrfSafeMethod(settings.type)) {
            xhr.setRequestHeader("X-CSRFToken", csrftoken);
        }
    }
});
/*--------------------------------------------------------------*/

// Here is the function being called
$(document).ready(function() {
    $('#addArtistGroupForm').submit(function() { // catch the form's submit event
        
        $.ajax({ // create an AJAX call...
            data: $(this).serialize(), // get the form data
            type: $(this).attr('method'), // GET or POST
            url: $(this).attr('action'), // the file to call
            success: function(response) { // on success..
                //alert(response.success)
                if (response.success) {
                    $("#ajaxAddFailAlert").hide();
                    $('#modalArtistAdd').modal('toggle');
                    $("#message_div").append(
                        "<div class='alert alert-success alert-dismissable fade show'>"
                            +response.message
                            +"<button type='button' class='close' data-dismiss='alert' aria-label='Close'>"
                                +"<span aria-hidden='true'>&times;</span>"
                            +"</button>"
                        +"</div>"
                    );
                } else {
                    $("#ajaxAddFailAlert").show();
                }
                
            },
            error: function(resp) {
                alert(resp)
            }
        });
        return false;
    });
});

/*
function update_messages(messages){
    $("#div_messages").html("");
    $.each(messages, function (i, m) {
            $("#div_messages").append("<div class='alert alert-"+m.level+"''>"+m.message+"</div>");
    });
*/