var EDSN_THRESHOLD = 30;

var EdsnSwitch = (function() {
    var editing;
    var validBaseLoads = /^(base_load|base_load_edsn)$/;

    EdsnSwitch.prototype = {
        enable: function() {
            if (editing) {
                swapEdsnBaseLoadSelectBoxes();
            }
        },

        isEdsn: function() {
            return validBaseLoads.test($(this).val());
        },

        cloneAndAppendProfileSelect: function() {
            swapSelectBox.call(this);
        }
    };

    function swapEdsnBaseLoadSelectBoxes() {
        $("tr.base_load_edsn select.name").each(swapSelectBox);
    };

    function swapSelectBox() {
        var technology = $(this).val();
        var self = this;
        var unitSelector = $(this).parents("tr").find(".units input");
        var units = parseInt(unitSelector.val());
        var actual = (units > EDSN_THRESHOLD ? "base_load_edsn" : "base_load");
        var select = $(".hidden select." + actual).clone(true, true);

        if ($("form.edit_testing_ground").length > 0 && $(this).data('profile')) {
            select.val($(this).data('profile'));
        };

        $(this).parent().next().html(select);
        $(this).find("option[value='" + technology + "']").attr('value', actual);

        unitSelector.off('change').on('change', swapSelectBox.bind(self));

        return select;
    };

    function EdsnSwitch(_editing) {
        editing = _editing;
    };

    return EdsnSwitch;
})();
