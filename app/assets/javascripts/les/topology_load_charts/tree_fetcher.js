/*global Poller,Ajax,ErrorDisplayer*/
var TreeFetcher = (function () {
    'use strict';

    var deferred,
        polls = [],
        finalData = {};

    function setFinalData(data, lesType) {
        finalData[lesType] = data.networks;

        if (data.error) {
            finalData.error = data.error;
        }
    }

    function progress() {
        deferred.notify();
    }

    function done(data, lesType) {
        if (data.networks) {
            setFinalData(data, lesType);

            deferred.notify(data);
        } else {
            deferred.reject(data);
        }
    }

    function fail(e, f) {
        deferred.reject(e, f);
    }

    function poll(lesData) {
        var pollerData = { url: this.url, data: lesData },
            poller     = new Poller(pollerData).poll();

        poller.progress(progress.bind(this))
            .done(function (data) {
                done.call(this, data, lesData.type);
            })
            .fail(fail);

        polls.push(poller);
    }

    function success(cachedData) {
        var lesData = JSON.parse(this.data);

        if (cachedData.networks) {
            setFinalData(cachedData, lesData.type);

            deferred.notify(cachedData);
        } else {
            poll.call(this, lesData);
        }
    }

    function finish() {
        $.when.apply(null, polls)
            .fail(fail)
            .done(function () {
                deferred.resolve(finalData);
            });
    }

    function fetchInitialLes() {
        var nodeData, i;

        for (i in this.lesses) {
            nodeData = this.lesses[i].nodeData(this.nodes, this.options);

            if (this.lesses[i].anyStrategies()) {
                this.requests.push(Ajax.json(this.url, nodeData, success, fail));
            }
        }

        $.when.apply(null, this.requests).done(finish.bind(this)).fail(fail);
    }

    /* This prototype fetches the load for multiple Les's.
     * One with and one without strategies.
     *
     * The progression for fetching the calculation is the following:
     * - Grab load
     * - Poll if necessary
     * - Merge end-result with the finalData.
     * - Repeat for next Les
     * - When all is done return finalData.
     */
    TreeFetcher.prototype = {
        fetch: function (nodes, options) {
            polls         = [];
            this.requests = [];
            this.nodes    = nodes;
            this.options  = options;

            deferred = $.Deferred();

            fetchInitialLes.call(this);

            return deferred.promise();
        }
    };

    function TreeFetcher(lesses) {
        this.lesses   = lesses;
        this.url      = window.currentTree.url;
    }

    return TreeFetcher;
}());
