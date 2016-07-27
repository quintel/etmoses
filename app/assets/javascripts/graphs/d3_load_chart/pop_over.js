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
        var key, span, square, spanValue, type;

        for (type in this.results) {
            if (isShown.call(this, type)) {
                square = $("<span>").addClass("square").css({
                    "background-color": this.results[type].color,
                    "opacity": this.seriesOpacity
                });

                key = $("<span class='key'>").text(this.results[type].key);

                spanValue = $("<span>").html(setSpanText.bind(this, type));
                span = $("<span>").addClass("wrap").append(key, square, spanValue);

                this.scope.append(span);
            }
        }

        // Adjust the position of the series keys.
        this.scope.find('span.key').css({ right: this.scope.width() + 4 });
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
