var Ajax = (function () {
    'use strict';

    return {
        json: function (url, data, success, error) {
            $.ajax({
                type:        "POST",
                contentType: "application/json",
                dataType:    "json",
                url:         url,
                data:       JSON.stringify(data),
                success:    (success || function () { return; }),
                error:      (error || function () { return; })
            });
        }
    };
}());
