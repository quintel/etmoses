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

    outerHTML: function(s) {
        'use strict';

        return s ? this.before(s).remove() : $("<p>").append(this.eq(0).clone()).html();
    },

    underscorizedData: function() {
        'use strict';

        var key,
            u = this.dataset || $(this).data(),
            newObject = {};

        for (key in u) {
            newObject[key.underscorize()] = u[key];
        }

        return newObject;
    },

    selectedOption: function(value) {
        'use strict';

        return $(this).find("option[value='" + (value || $(this).val()) + "']");
    },

    /* $(..).set(option, value);
     *
     * Sets the data-attriute aswell as the attribute in the dom.
     */
    set: function(option, value) {
        'use strict';

        $(this).data(option.camelize(), value)
            .attr("data-" + option.underscorize().replace(/\_/g, '-'), value);
    },

    /* Returns the value which lives under 'data-raw', if that's not present
     * return the default 'val()'
     */
    rawValue: function() {
        return $(this).data('raw') || $(this).val();
    }
});

String.prototype.underscorize = function() {
    'use strict';

    return this.replace(/([A-Z])/g, function(a) {
        return "_" + a.toLowerCase();
    });
};

String.prototype.camelize = function() {
    'use strict';

    return this.replace(/[-_\s]+(.)?/g, function(_, c) {
        return c ? c.toUpperCase() : '';
    });
}

// Polyfill for find
if (!Array.prototype.find) {
    Array.prototype.find = function(predicate) {
        if (this === null) {
            throw new TypeError('Array.prototype.find called on null or undefined');
        }
        if (typeof predicate !== 'function') {
            throw new TypeError('predicate must be a function');
        }
        var list = Object(this);
        var length = list.length >>> 0;
        var thisArg = arguments[1];
        var value;

        for (var i = 0; i < length; i++) {
            value = list[i];
            if (predicate.call(thisArg, value, i, list)) {
                return value;
            }
        }
        return undefined;
    };
}

// Production steps of ECMA-262, Edition 5, 15.4.4.17
// Reference: http://es5.github.io/#x15.4.4.17
if (!Array.prototype.some) {
  Array.prototype.some = function(fun/*, thisArg*/) {
    'use strict';

    if (this == null) {
      throw new TypeError('Array.prototype.some called on null or undefined');
    }

    if (typeof fun !== 'function') {
      throw new TypeError();
    }

    var t = Object(this);
    var len = t.length >>> 0;

    var thisArg = arguments.length >= 2 ? arguments[1] : void 0;
    for (var i = 0; i < len; i++) {
      if (i in t && fun.call(thisArg, t[i], i, t)) {
        return true;
      }
    }

    return false;
  };
}
