
$('#modalArtistAdd').on('show.bs.modal', function (event) {
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

/*
$("#modalAddArtistSubmitButton").click(function(){
    var artists = JSON.parse(document.getElementById('artist-data').textContent)
    var id = $("")
    var index = artists.findIndex(function(item, i){
        return item.name === val
    });
    //$("#id_artist").attr("value",)
    
    $("#selectArtistGroupForm").submit(function(){
      $("<input />").attr("type", "hidden")
      .attr("name", "dates")
      .attr("value", "something")
      .appendTo("#objectForm");
      return true;
     }); // Submit the form
    
});
*/
