/*global Poller,Ajax,ErrorDisplayer*/
var TreeFetcher = (function () {
    'use strict';

    function failCallback(treeData) {
        new ErrorDisplayer(
            treeData.responseJSON,
            $('.testing-ground-view')
        ).displayError();
    }

    function finalCall() {
        Ajax.json(this.url, this.data, this.cachedCallback.bind(this), failCallback.bind(this));
    }

    /* Private: pendingCalculate
     *
     * Polls pendingData request
     */
    function pendingCalculate() {
        new Poller({
            url: this.url,
            data: this.data
        }).poll()
            .done(finalCall.bind(this))
            .fail(failCallback.bind(this));
    }

    /* Private: cachedDataCallback
     *
     * callback after requesting caching
     */
    function initialCachingCallback(cachedData) {
        if (cachedData.graph) {
            this.cachedCallback(cachedData);
        } else {
            pendingCalculate.call(this);
        }
    }

    TreeFetcher.prototype = {
        fetch: function (data, cachedCallback) {
            this.data = data;
            this.cachedCallback = cachedCallback;

            Ajax.json(
                this.url,
                data,
                initialCachingCallback.bind(this),
                failCallback.bind(this)
            );
        }
    };

    function TreeFetcher(url) {
        this.url = url;
    }

    return TreeFetcher;
}());
