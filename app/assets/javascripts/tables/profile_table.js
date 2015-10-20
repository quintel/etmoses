/*global document,EditableTable,EdsnSwitch,ETHelper,ProfileSelectBoxes*/
var ProfileTable = (function () {
    'use strict';

    function parseTableToJSON() {
        var tableProfile  = this.editableTable.getData(),
            groupedByNode = ETHelper.groupBy(tableProfile, 'node');

        $("#technology_distribution").text(JSON.stringify(tableProfile));
        $("#testing_ground_technology_profile").text(JSON.stringify(groupedByNode));
    }

    function getNameForType(type) {
        var selectedOption = $("select.name").first().find("option").filter(function () {
            if (type === "base_load_edsn") {
                type = "base_load";
            }
            return $(this).val() === type;
        });
        return selectedOption.text();
    }

    function changeData() {
        if (this.header === "name") {
            this.tableData.name = getNameForType(this.attribute);
            this.tableData.type = this.attribute;
        } else if (!(/demand|electrical_capacity/.test(this.header) && this.attribute === "")) {
            this.tableData[this.header] = this.attribute;
        }
    }

    ProfileTable.prototype = {
        append: function () {
            this.profileSelectBoxes.add();
            this.edsnSwitch.enable();
            this.editableTable.append(parseTableToJSON.bind(this), changeData);

            parseTableToJSON.call(this);
        },

        updateProfiles: function () {
            this.profileSelectBoxes.update();

            parseTableToJSON.call(this);
        }
    };

    function ProfileTable(selector) {
        this.selector           = selector;
        this.editing            = $("form.edit_testing_ground").length > 0;
        this.edsnSwitch         = new EdsnSwitch(this.editing);
        this.profileSelectBoxes = new ProfileSelectBoxes(this.edsnSwitch);
        this.editableTable      = new EditableTable(this.selector);
    }

    return ProfileTable;
}());

$(document).on("page:change", function () {
    'use strict';

    if ($("#profiles-table > table").length > 0) {
        window.currentProfileTable = new ProfileTable("#profiles-table > table");
        window.currentProfileTable.append();
    }
});
