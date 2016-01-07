var CompositeTemplateUpdater = (function () {
    'use strict';

    var toggles = ".editable.buffer, .editable.position_relative_to_buffer, .indent.arrow",
        bufferToggles = ".editable.profile";

    function showBuffer() {
        var includes = $(this.data.append).data('includes');

        return !!includes && includes.indexOf(this.data.type) > -1;
    }

    CompositeTemplateUpdater.prototype = {
        update: function () {
            var isBuffer = showBuffer.call(this.context);

            this.context.template.find(toggles).toggleClass("hidden", !isBuffer);
            this.context.template.find(bufferToggles).toggleClass("hidden", isBuffer);
            this.context.template.toggleClass("buffer-child", isBuffer);

            return this.context.template;
        }
    };

    function CompositeTemplateUpdater(context) {
        this.context = context;
    }

    return CompositeTemplateUpdater;
}());
