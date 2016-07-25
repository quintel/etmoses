/*globals LoadChartsSettings*/
var PopOver = (function () {
    'use strict';

    function isShown(type) {
        return (this.results[type] &&
                this.results[type].values &&
                LoadChartsSettings[type].visible);
    }

    function setSpanText(type) {
        return Math.round(this.results[type].values.y * 100) / 100;
    }

    function setResults() {
        var span, square, spanValue, type;

        for (type in this.results) {
            if (isShown.call(this, type)) {
                square = $("<span>").addClass("square").css({
                    "background-color": this.results[type].color,
                    "opacity": this.seriesOpacity
                });

                spanValue = $("<span>").text(setSpanText.bind(this, type));

                span = $("<span>").addClass("wrap").append(square, spanValue);

                this.scope.append(span);
            }
        }
    }

    PopOver.prototype = {
        show: function (mousePosX, results) {
            this.scope.show();
            this.scope.html('');
            this.scope.css("left", mousePosX + "px");

            this.results = results;

            setResults.call(this);
        }
    };

    function PopOver(scope, opacity) {
        this.scope         = scope;
        this.seriesOpacity = opacity || 0.5;
    }

    return PopOver;
}());
