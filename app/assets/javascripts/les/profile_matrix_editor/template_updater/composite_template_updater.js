var CompositeTemplateUpdater = (function () {
    'use strict';

    var toggles = ".editable.buffer, .editable.position_relative_to_buffer, .indent.arrow",
        bufferToggles = ".editable.profile",
        compositeToggles = ".editable.composite-attribute";

    function showBuffer() {
        var includes = $(this.data.append).data('includes');

        return !!includes && includes.indexOf(this.data.type) > -1;
    }

    CompositeTemplateUpdater.prototype = {
        update: function () {
            var isBuffer    = showBuffer.call(this.context),
                isComposite = this.context.data.composite;

            this.context.template.find(toggles).toggleClass("hidden", !isBuffer);
            this.context.template.find(bufferToggles).toggleClass("hidden", isBuffer);
            this.context.template.find(compositeToggles).toggleClass("hidden", !isComposite);
            this.context.template.toggleClass("buffer-child", isBuffer);

            return this.context.template;
        }
    };

    function CompositeTemplateUpdater(context) {
        this.context = context;
    }

    return CompositeTemplateUpdater;
}());
