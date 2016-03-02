/*globals D3LoadChart,ErrorDisplayer,Les,StatusUpdater,Strategies,TreeFetcher,TreeGraph*/
var Tree = (function () {
    'use strict';

    function updateDomElements() {
        new StatusUpdater("Creating tree", 1).append();

        $("a.dropdown-toggle").first().addClass("disabled");
        $("#collapse-stakeholders select").prop('disabled', true);
    }

    function updateProgress(data) {
        if (data) {
            new StatusUpdater("Done calculating!", 1).append();
        } else {
            new StatusUpdater("..", 1).append();
        }
    }

    function updateTree(data) {
        this.toggleLoading()

        this.treeGraph.setData(data).reload();
    }

    function drawTree(data) {
        new StatusUpdater("Calculation finished!").append();

        this.treeGraph.setData(data).showGraph();

        $("#collapse-stakeholders select").prop('disabled', false);

        if (data.error) {
            $(".alert.alert-warning").removeClass("hidden")
                .find("span.error")
                .text(data.error);
        }
    }

    function displayError(error) {
        new ErrorDisplayer(
            error.responseJSON,
            $(".testing-ground-view")
        ).displayError();
    }

    Tree.prototype = {
        nodes: [],
        create: function () {
            updateDomElements();

            this.d3Chart    = new D3LoadChart(".load-graph .chart", "default");
            this.treeGraph  = new TreeGraph(this.target.selector);
            this.strategies = new Strategies();
            this.lesses     = [ new Les(), new Les(this.strategies) ];
            this.reload();
        },

        reload: function () {
            new TreeFetcher(this.lesses)
                .fetch(this.d3Chart.resolution)
                .progress(updateProgress)
                .done(drawTree.bind(this))
                .fail(displayError);
        },

        updateStrategies: function () {
            this.update([this.lesses[1]]);
        },

        update: function (lesses) {
            this.toggleLoading();

            new TreeFetcher(lesses || this.lesses)
                .fetch(this.d3Chart.resolution)
                .done(updateTree.bind(this))
                .fail(displayError);
        },

        toggleLoading: function () {
            var loadingSpinner = $(".load-graph-wrapper .loading-spinner");
            loadingSpinner.toggleClass("on");

            $("button.apply_strategies").prop("disabled", loadingSpinner.hasClass("on"));
        }
    };

    function Tree(target) {
        this.target        = target;
        this.data          = target.data();
        this.url           = this.data.url;
        this.strategiesUrl = this.data.strategiesUrl;
        this.id            = this.data.id;
    }

    return Tree;
}());
