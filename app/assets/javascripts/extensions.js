$.fn.extend({
    outerHTML: function (s) {
        'use strict';

        return s
            ? this.before(s).remove()
            : jQuery("<p>").append(this.eq(0).clone()).html();
    },

    underscorizedData: function(){
        var u = $(this).data(),
            newObject = {},
            keys = Object.keys(u);

        $.each(keys, function(){
            newObject[this.underscorize()] = u[this];
        });

        return newObject;
    },

    selectedOption: function(value){
        return $(this).find("option[value='" + (value || $(this).val()) + "']");
    },

    set: function(option, value){
        $(this).data(option, value)
               .attr("data-" + option.underscorize().replace(/\_/g, '-'), value);
    }
});

String.prototype.underscorize = function(){
    return this.replace(/([A-Z])/g, function(a){
        return "_"+a.toLowerCase();
    });
}
