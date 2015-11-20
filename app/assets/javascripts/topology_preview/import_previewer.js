$(document).on("page:change", function(){
  var newImportForm = $("form#new_import");

  if(newImportForm.length > 0){
    var topologySelect = newImportForm.find("select#import_topology_id");

    function getTopology(){
      $.ajax({ type: "GET",
              url: "/topologies/" + $(this).val() + ".json",
              dataType: "json",
              success: displayPreview });
    };

    function displayPreview(data){
      new TopologyPreviewer(".topology-preview .preview-svg", data, "simple").preview();
    };

    getTopology.call(topologySelect);
    topologySelect.on('change', getTopology);
  };
});

