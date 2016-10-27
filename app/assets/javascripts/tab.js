var Tab = (function () {
    'use strict';

    Tab.prototype = {
        markAsEditing: function () {
            this.scope.addClass("editing")
        }
    };

    function Tab(scope) {
        this.tabPane = $("div" + scope + " form");
        this.tabMenu = $("li a[href='" + scope + "']");
        this.scope   = this.tabPane.add(this.tabMenu);
    }

    return Tab;
}());
