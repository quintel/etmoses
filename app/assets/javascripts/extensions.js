$.fn.extend({
    formatCurrency: function() {
        'use strict';

        $(this).each(function(index, element) {
            element = $(element);

            var formatted = (parseFloat(element.text()) || 0.0).toFixed(2).
                replace(/(\d)(?=(\d{3})+\.)/g, "$1,");


            if (formatted[0] === '-') {
                formatted = '-€' + formatted.slice(1, formatted.length);
            } else {
                formatted = '€' + formatted;
            }

            element.text(formatted);
        });
    },

    outerHTML: function (s) {
        'use strict';

        return s
            ? this.before(s).remove()
            : $("<p>").append(this.eq(0).clone()).html();
    },

    underscorizedData: function () {
        'use strict';

        var u = $(this).data(),
            newObject = {},
            keys = Object.keys(u);

        $.each(keys, function () {
            newObject[this.underscorize()] = u[this];
        });

        return newObject;
    },

    selectedOption: function (value) {
        'use strict';

        return $(this).find("option[value='" + (value || $(this).val()) + "']");
    },

    /* $(..).set(option, value);
     *
     * Sets the data-attriute aswell as the attribute in the dom.
     */
    set: function (option, value) {
        'use strict';

        $(this).data(option, value)
               .attr("data-" + option.underscorize().replace(/\_/g, '-'), value);
    }
});

String.prototype.underscorize = function () {
    'use strict';

    return this.replace(/([A-Z])/g, function (a) {
        return "_" + a.toLowerCase();
    });
};
