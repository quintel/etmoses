var StatusUpdater = (function () {
    'use strict';

    StatusUpdater.prototype = {
        append: function () {
            var box = $(".status"),
                status = $("<span/>").addClass("g" + this.gravity).text(this.message);

            if ($('.status').length > 0) {
                box.append(status).scrollTop($('.status')[0].scrollHeight);
            }
        }
    };

    function StatusUpdater(message, gravity) {
        this.message = message;
        this.gravity = gravity || 0;
    }

    return StatusUpdater;
}());
