var Bump = function () {
    'use strict';

    var randId = "T" + new Date().getTime().toString();

    $(this).attr("id", randId);
    $(this).find("[data-type=position_relative_to_buffer]")
        .attr("name", "position_relative_to_buffer_name_" + randId);
};
