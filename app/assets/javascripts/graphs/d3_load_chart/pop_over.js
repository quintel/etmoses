/*globals ChartSettings*/

var PopOver = (function () {
    'use strict';

    function isShown(type) {
        return (this.results[type] &&
                this.results[type].values &&
                ChartSettings.forChart(type).visible);
    }

    function setSpanText(type) {
        return Math.round(this.results[type].values.y * 100) / 100;
    }

    function setResults() {
        var key, span, square, spanValue, type;

        for (type in this.results) {
            if (isShown.call(this, type)) {
                square = $("<span>").addClass("square").css({
                    "background-color": this.results[type].color
                });

                key = $("<span class='key'>").text(this.results[type].key);

                spanValue = $("<span>").html(setSpanText.bind(this, type));
                span = $("<span>").addClass("wrap").append(key, square, spanValue);

                this.popOverEl.append(span);
            }
        }

        // Adjust the position of the series keys.
        this.popOverEl.find('span.key').css({ right: this.popOverEl.width() + 4 });
    }

    function mouseout() {
        this.popOverEl.hide();

        d3.select("#hover-line")
            .style("opacity", 1e-6);
    }

    PopOver.prototype = {
        initialize: function (mousemove) {
            $(this.scope).append(this.popOverEl);

            d3.select("#mouse-tracker")
                .on("mousemove", mousemove)
                .on("mouseout", mouseout.bind(this));
        },

        show: function (mousePosX, results) {
            this.popOverEl.show();
            this.popOverEl.html('');
            this.popOverEl.css("left", mousePosX + "px");

            this.results = results;

            setResults.call(this);
        }
    };

    function PopOver(scope) {
        this.scope     = scope;
        this.popOverEl = $("<div/>").addClass("pop-over-load-graph");

    }

    return PopOver;
}());
