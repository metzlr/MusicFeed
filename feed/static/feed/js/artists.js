
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

$('#modalArtistAdd').on('show.bs.modal', function (event) {
    $modal = $(this);
    $modal.find('form')[0].reset();
    $("#ajaxAddFailAlert").hide();
    var button = $(event.relatedTarget) // Button that triggered the modal
    var name = button.data('artist-name') // Extract info from data-* attributes
    var img = button.data('artist-img')
    var id = button.data('artist-id')
    // Store artist data in form
    var artists = JSON.parse(document.getElementById('artist-data').textContent)
    var index = artists.findIndex(function(item, i){
        return item.id === id
    });

    var artist = JSON.stringify(artists[index])
    $("#id_artist_metadata").val(artist)


    // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
    // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
    $("#modalArtistAddName").text(name)
    $("#modalArtistAddImage").attr('src', img)
});

$('#modalGroupDelete').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget) // Button that triggered the modal
    var name = button.data('group-name') // Extract info from data-* attributes
    var id = button.data('group-id')

    $("#id_group_id").val(id)
    $("#modalGroupDeleteName").text('Are you sure you want to delete "'+name+'"?')
});




