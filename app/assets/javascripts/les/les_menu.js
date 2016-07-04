var LesMenu = (function () {
    'use strict';

    var paths = {
        '/testing_grounds/:id': 'load',
        '/testing_grounds/:id/gas_load': 'gas_load',
        '/testing_grounds/:id/heat_load': 'heat_load',
        '/testing_grounds/:id/business_cases/:id': 'business_case'
    };

    return {
        activateWith: function (path) {
            var strippedPath = path.replace(/\d+/g, ':id').replace(/\/$/, '');

            $("#les-menu ul.nav li." + paths[strippedPath]).addClass("active");
        }
    };
}());

$(document).on("page:change", function () {
    LesMenu.activateWith(window.location.pathname);
});
