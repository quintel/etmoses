var DownloadTopologyAs = (function () {
    'use strict';

    DownloadTopologyAs.prototype = {
        convert: function (e) {
            e.preventDefault();

            var topology = document.querySelector("svg"),
                form = $("<form>").attr({
                    "action": $(e.target).data('png'),
                    "method": "post",
                    "style" : "display:none;"
                }),
                textarea = $("<textarea>").attr("name", "svg").text(topology.outerHTML);

            form.append(textarea);
            $("body").append(form);
            form.submit();
        }
    };

    function DownloadTopologyAs() {
        return;
    }

    return DownloadTopologyAs;
}());

$(document).on("page:change", function () {
    'use strict';

    var target = $(".btn-download-as-png");

    if (target.length > 0) {
        target.on("click", new DownloadTopologyAs().convert);
    }
});
