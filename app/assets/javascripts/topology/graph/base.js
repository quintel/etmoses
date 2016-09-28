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

        center: function (node) {
            var scale;

            if (this.zoomListener) {
                var scale = this.zoomListener.scale(),
                        x = node.x + (this.width / 2) + (this.radius / 2),
                        y = 50;

                this.group.attr('transform',
                    'translate(' + x + ', ' + y + ') scale(' + scale + ')');
            }
        },

        maxId: function () {
            var ids = [0];

            ETHelper.eachNode([this.data], function (node) {
                ids.push(node.id);
            });

            return d3.max(ids);
        },

        zoomListener: function () {
            return function () {
                return;
            };
        },

        draw: function () {
            throw "Not implemented error";
        },

        update: function () {
            throw "Not implemented error";
        }
    }

    function Base(scope) {
        this.scope        = scope;
        this.zoomListener = this.zoomListener();
        this.diagonal     = d3.svg.diagonal().projection(function (d) {
            return [d.x, d.y];
        });
    }

    return Base;
}());
