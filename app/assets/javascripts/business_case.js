var BusinessCase = (function () {
    'use strict';

    return {
        formatCell: function () {
            if ($(this).text().replace(/\s/g, '') === '') {
                $(this).html("--");
            } else {
                $(this).formatCurrency();
            }
        }
    }
}());
