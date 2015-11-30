var Poller = (function () {
    'use strict';

    var pollTime = 1000;

    function fail(e, f) {
        this.deferred.reject(e, f);

        clearTimeout(this.timeout);
    }

    function onTimeout() {
        this.create(this.data);
        this.deferred.notify();

        clearTimeout(this.timeout);
    }

    function success(data) {
        var nextPollTime = pollTime;

        if (data.pending) {
            if ((new Date()) - this.firstRequestAt > this.slower) {
                // After "this.slower" ms have elapsed, start polling at a slower rate.
                nextPollTime = pollTime * 2;
            }

            this.timeout = setTimeout(onTimeout.bind(this), nextPollTime);
        } else {
            this.deferred.resolve(data);

            clearTimeout(this.timeout);
        }
    }

    Poller.prototype = {
        deferred: null,
        poll: function () {
            this.deferred = $.Deferred();
            this.create($.extend(this.first_data, this.data));

            return this.deferred.promise();
        },
        create: function (data) {
            if (!this.firstRequestAt) {
                this.firstRequestAt = new Date();
            }

            Ajax.json(this.url, data, success.bind(this), fail.bind(this));
        }
    };

    /*
     * Poller (url [String], _data [Object], _first_data [Object]
     * Poller is an ajax loop that keeps looping until it no longer receives pending from
     * the server.
     *
     * _first_data is data that will only be send the first time.
     *
     * */

    function Poller(options) {
        this.url        = options.url;
        this.data       = options.data || {};
        this.first_data = options.first_data || {};
        this.slower     = options.slower || 10000;

        this.timeout = null;
    }

    return Poller;
}());
