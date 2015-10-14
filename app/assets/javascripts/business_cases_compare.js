function enableCompareSelectbox() {
    'use strict';

    var compareSelectBox = $(".compare select");

    function clearRow() {
        var destroyRow = true;
        $(this).find("td.editable").each(function () {
            if ($.trim($(this).text()) !== '-') {
                destroyRow = false;
                return false;
            }
        });

        if (destroyRow) {
            $(this).remove();
        }
    }

    function compareBusinessCase() {
        $(this).prop('disabled', true);

        if ($(this).val() !== "") {
            $.ajax({
                url: $(this).data('compareUrl'),
                type: "POST",
                data: {
                    comparing_testing_ground_id: $(this).val()
                }
            });
        } else {
            $("span.difference").empty();
            $("table.compare tbody tr").each(clearRow);
            $(this).prop('disabled', false);
        }
    }

    if (compareSelectBox.length > 0) {
        compareSelectBox.off("change").on("change", compareBusinessCase);
        compareSelectBox.prop('disabled', false);
    }
}
