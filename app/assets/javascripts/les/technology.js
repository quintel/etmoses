/*globals BufferSelectBox,ProfileSelectBox*/
var Technology = (function () {
    'use strict';

    Technology.prototype = {
        add: function (button) {
            var subTarget = this.technologyDom.data('append'),
                target = $(button).parents(".panel").find(subTarget);

            new BufferSelectBox(this.technologyDom).add();

            $(target).after(this.technologyDom);
        },

        update: function () {
            new ProfileSelectBox(this.technologyDom).add();
            new BufferSelectBox(this.technologyDom).add();
        }
    };

    function Technology(technologyDom) {
        this.technologyDom = technologyDom;
    }

    return Technology;
}());
