$.fn.extend({
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
    }
});

String.prototype.underscorize = function(){
    return this.replace(/([A-Z])/g, function(a){
        return "_"+a.toLowerCase();
    });
}
