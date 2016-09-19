/* Future file for cleaning up Topology graphs.
 *
 */

Topology.Base = (function () {
    'use strict';

    Base.prototype = {
        buildBaseSVG: function () {
            return d3.select(this.scope).append('svg')
                .attr('id', this.id)
                .attr('class', 'overlay')
                .attr('width', this.width)
                .attr('height', this.height)
                .attr('viewBox', '0 0 ' + this.width + ' ' + this.height)
                .call(this.zoomListener)
                .on('wheel.zoom', null)
                .on('dblclick.zoom', null);

        },

        zoomListener: function () {
            return;
        },

        draw: function () {
            throw "Not implemented error";
        },

        update: function () {
            throw "Not implemented error";
        }
    }

    function Base(scope) {
        this.scope    = scope;
        this.diagonal = d3.svg.diagonal().projection(function (d) {
            return [d.x, d.y];
        });
    }

    return Base;
}());
