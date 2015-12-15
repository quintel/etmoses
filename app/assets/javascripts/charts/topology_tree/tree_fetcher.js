/*global Poller,Ajax,ErrorDisplayer*/
var TreeFetcher = (function () {
    'use strict';

    function showProgress() {
        new StatusUpdater("...", 1).append();
    }

    function failCallback(treeData) {
        new ErrorDisplayer(
            treeData.responseJSON,
            $('.testing-ground-view')
        ).displayError();
    }

    function finalCall(data) {
        if (data.networks) {
            this.cachedCallback.call(this, data);
        } else {
            this.failCallback.call(this, data);
        };
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
            .progress(showProgress.bind(this))
            .done(finalCall.bind(this))
            .fail(failCallback.bind(this));
    }

    /* Private: cachedDataCallback
     *
     * callback after requesting caching
     */
    function initialCachingCallback(cachedData) {
        if (cachedData.networks) {
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
