var DownloadTopologyAs = (function () {
    'use strict';

    /* This function exists purely for the sake of IE.
     * In the <svg> tag there are <g> tags. Those determine the position of the
     * elements with the 'transform=translate(x, y)' attribute.
     *
     * In modern browsers this is:
     *
     *    translate(x, y)
     *
     * In internet explorer this is (with y being optional if it's 0):
     *
     *    translate(x y)
     *
     * Rmagick doesn't agree with this and therefor renders the png wrongly.
     *
     * Also jQuery's attr() doesn't function properly when it comes to cloned
     * DOM-objects in IE. That's why a string replace had to be used.
     */
    function cloneTextArea() {
        var clone = $("svg").clone();

        return clone.outerHTML().replace(/translate\((\d+)\)/g, function (v) {
            return v.replace(/\)/, ' 0)');
        });
    }

    DownloadTopologyAs.prototype = {
        convert: function (e) {
            e.preventDefault();

            var textarea = $("<textarea>").attr("name", "svg").text(cloneTextArea),
                form = $("<form>").attr({
                    "action": $(e.target).data('png'),
                    "method": "post",
                    "style" : "display:none;"
                });

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
