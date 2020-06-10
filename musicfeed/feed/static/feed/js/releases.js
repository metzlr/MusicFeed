var artists_obj = { artists: [] }

function addArtistToSearch(artist) {
    if (!artists_obj.artists.some(item => item.spotify_id === artist.spotify_id)) {
        $('#addedArtists').append(
                '<div class="d-flex align-items-center" id="'+artist.spotify_id+'">' +
                    '<img class="rounded-circle img-added-artist mr-2" src="'+artist.img_url+'">' +
                    '<div class="mr-auto">'+artist.name+'</div>' +
                    
                    '<button type="button" class="btn bg-transparent remove-added-artist" data-artist-id="'+artist.spotify_id+'">' +
                        '<i class="fas fa-times"></i>'+
                    '</button>' +
                    
                '</div>')

        artists_obj.artists.push(artist)
        $('#artistListHeader').text('Artists Included in Search ('+artists_obj.artists.length+')')
    }
}
$(document).ready(function() {
    $('.add-followed-artist-button').click(function() {
        var artist = { 
            spotify_id: $(this).data('artist-id'),
            name: $(this).data('artist-name'),
            img_url: $(this).data('artist-img'),
            spotify_profile_url: $(this).data('artist-profile-url')
        }
        addArtistToSearch(artist)
    });
});

$(document).ready(function() {
    $('.add-all-followed-button').click(function() {
        $('.add-followed-artist-button').each(function(i, obj) {
            var artist = { 
                spotify_id: $(this).data('artist-id'),
                name: $(this).data('artist-name'),
                img_url: $(this).data('artist-img'),
                spotify_profile_url: $(this).data('artist-profile-url')
            }
            addArtistToSearch(artist)
        });
    });
});

$(document).ready(function() {
    $(document).on("click", ".add-artist-to-search-button", function() {
        var artist = { 
            spotify_id: $(this).data('artist-id'),
            name: $(this).data('artist-name'),
            img_url: $(this).data('artist-img'),
            spotify_profile_url: $(this).data('artist-profile-url')
        }
        addArtistToSearch(artist)
    });
});

$(document).ready(function() {
    $(document).on('click', '.add-group-button', function() {
        var group_id = $(this).data('group-id')
        $.ajax( {
            type:"GET",
            url: $("#artistGroupsList").data('ajax-url'),
            data:{
                type: 'artist_group',
                id: group_id
            },
            success: function( response ) {
                var artists_response = JSON.parse(response['artists'])
                artists_response.forEach(function (arrayItem) {
                    addArtistToSearch(arrayItem.fields)
                });
            }
        });
    });
});

$(document).ready(function() {
    $(document).on('click', '.remove-added-artist', function() {
        var id = $(this).data('artist-id')
        var index = artists_obj.artists.findIndex(function(item, i){
            return item.spotify_id === id
        });
        if (index != -1) {
            $('#'+id).remove()
            artists_obj.artists.splice(index, 1)
            $('#artistListHeader').text('Artists Included in Search ('+artists_obj.artists.length+')')
        } else {
            alert("Error: Artist not found")
        }
    });
});

$(document).ready(function() {
    $('#saveAddedArtistsButton').click(function() {
        $('#modalNewGroup').modal('toggle');
        $modal.find('form')[0].reset();
    });
});
$(document).ready(function() {
    $('#newGroupNameForm').submit(function() {
        $.ajax({ // create an AJAX call...
            data: {
                'artists_json': JSON.stringify(artists_obj.artists),
                'name': $('#id_name').val()
            }, // get the form data
            
            dataType: 'json',
            type: 'POST', // GET or POST
            url: $('#newGroupNameForm').data('ajax-url'), // the file to call
            success: function(response) { // on success..
                if (response.success) {
                    if (response.error) alert(response.error)
                    $("#artistGroupsList").append(
                        '<li class="list-group-item">'+
                            '<div class="container">'+
                                '<div class="row">'+
                                    '<div class="col">'+
                                        '<a href="#">'+response.group.name+'</a>'+
                                    '</div>'+
                                    '<div class="d-flex col align-items-center">'+
                                        '<button type="button" class="btn btn-link add-group-button" data-group-id="'+response.group.id+'" id="addGroupToForm">Add to Search</button>'+
                                    '</div>'+
                                '</div>'+
                            '</div>'+
                        '</li>'
                    );
                    $("#message_div").append(
                        "<div class='alert alert-success alert-dismissable fade show'>"
                            +response.success
                            +"<button type='button' class='close' data-dismiss='alert' aria-label='Close'>"
                                +"<span aria-hidden='true'>&times;</span>"
                            +"</button>"
                        +"</div>"
                    );
                } else {
                    alert("Error saving artists")
                }
                
            },
            error: function(resp) {
                alert(resp)
            }
        });
        $('#modalNewGroup').modal('toggle');
        return false;
    });
});

$(document).ready(function() {
    $('#clearAddedArtists').click(function() {
        artists_obj = { artists: [] }
        $("#addedArtists").empty()
        $('#artistListHeader').text('Artists Included in Search (0)')
    });
});

$(document).ready(function() {
    $('#spotifyArtistSearchForm').submit(function(event) { // catch the form's submit event
        $("#spotifyArtistSearchResultsList").empty()
        $.ajax({ // create an AJAX call...
            data: $(this).serialize(),
            type: $(this).attr('method'), // GET or POST
            url: $(this).attr('action'), // the file to call
            success: function(response) { // on success..
                if (response.error) {
                    alert(response.error)
                }
                if (response.artists) {
                    response.artists.forEach(function(artist) {
                        var imgSrc;
                        if (artist.images.length > 0) {
                            imgSrc = artist.images[artist.images.length - 1].url
                        }
                        $("#spotifyArtistSearchResultsList").append(
                            '<li class="list-group-item">' +
                                '<div class="container p-0">' + 
                                    '<div class="row">' +
                                        '<div class="col-10">' +
                                            '<img class="rounded-circle img-artist mr-3" id="artistSearchImage" src="'+ imgSrc +'">' + 
                                            '<label for="artistSearchImage"><a href="'+ artist.external_urls.spotify +'">'+artist.name+'</a></label>' +
                                        '</div>' +
                                        '<div class="d-flex col-2 flex-column align-items-center justify-content-center">' +
                                            '<button type="button" class="btn btn-link add-artist-to-search-button" data-artist-profile-url="'+ artist.external_urls.spotify +'" data-artist-name="'+ artist.name +'" data-artist-img="'+ imgSrc +'" data-artist-id="'+ artist.id +'">Add</button>' +
                                        '</div>' +
                                    '</div>' +
                                '</div>' +
                            '</li>'
                        );
                    });
                }
            },
            error: function(resp) {
                alert(resp)
            }
        });
        event.preventDefault();
        return false;
    });
})

$(document).ready(function() {
    $('#getReleasesForm').submit(function() { // catch the form's submit event
        $("#releasesTableBody").empty()
        $('#releasesLoadingSpinner').show()
        $.ajax({ // create an AJAX call...
            data: {'artists': JSON.stringify(artists_obj.artists)}, // get the form data
            dataType: 'json',
            type: 'POST', // GET or POST
            url: $('#getReleasesForm').data('ajax-url'), // the file to call
            success: function(response) { // on success..
                $('#releasesLoadingSpinner').hide()
                if (response.success) {
                    if (response.error) alert(response.error)
                    response.releases.forEach(function(release) { 
                        var artist_str = ""
                        var index = 0
                        
                        release.artists.forEach(function(artist) { 
                            if (index == 0) {
                                artist_str += artist.name
                            } else {
                                artist_str += ', '+artist.name
                            }
                            index += 1;
                        });
                        $("#releasesTableBody").append(
                            '<tr>' + 
                                '<td class="align-middle">' +
                                    '<img class="rounded img-release-list" src="'+ release.images[0].url +'">' +
                                '</td>' +
                                '<td class="align-middle">' +
                                    '<p class="mb-0">' + release.name +'</p>' +
                                '</td>' +
                                '<td class="align-middle">' +
                                    '<p class="mb-0">'+ artist_str +'</p>' +
                                '</td>' +
                                '<td class="align-middle">' +
                                    '<p class="mb-0">'+ release.release_date +'</p>' +
                                '</td>' +
                            '</tr>'
                        );
                    });
                    
                } else {
                    alert("Error getting releases")
                }
                
            },
            error: function(resp) {
                $('#releasesLoadingSpinner').hide()
                alert(resp)
            }
        });
        return false;
    });
})

