var CustomPrompt = (function () {
    'use strict';

    return {
        prompt: function (title, input, callback) {
            this.callback  = callback || function () { return; };

            this.template = $(".prompt");
            this.template.find(".message").text(title);
            this.template.find(".prompt-message").val(input);
            this.template.find(".save")
                .off("click.performCallback")
                .on("click.performCallback", this.callback);

            this.popup     = $.featherlight(this.template);

            this.popup.$content.removeClass("hidden");

            return this.popup;
        }
    };
}());
