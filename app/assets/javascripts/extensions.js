$.fn.extend({
    formatCurrency: function () {
        'use strict';

        if ($(this).length > 1) {
            $(this).each(function () {
                $(this).formatCurrency();
            });
        } else {
            var result,
                neg = false,
                total = parseFloat($(this).text()) || 0.0;

            if (total < 0) {
                neg = true;
                total = Math.abs(total);
            }

            result = (neg ? "-€" : '€') + parseFloat(total, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString();

            $(this).text(result);
        }
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
