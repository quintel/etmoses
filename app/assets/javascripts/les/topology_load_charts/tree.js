/*globals ErrorDisplayer,Les,StatusUpdater,Strategies,TreeFetcher,TreeGraph*/
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
        this.lesses[1].strategies.toggleLoading();

        this.treeGraph.setData(data).reload();
    }

    function drawTree(data) {
        new StatusUpdater("Calculation finished!").append();

        this.treeGraph.setData(data).showGraph();

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
        create: function () {
            updateDomElements();

            this.treeGraph  = new TreeGraph(this.target.selector);
            this.strategies = new Strategies();
            this.lesses     = [ new Les(), new Les(this.strategies) ];
            this.set().reload();
        },

        set: function (nodes, resolution) {
            this.nodes      = nodes || [];
            this.resolution = resolution || 'low';

            return this;
        },

        reload: function () {
            new TreeFetcher(this.lesses)
                .fetch(this.nodes, this.resolution)
                .progress(updateProgress)
                .done(drawTree.bind(this))
                .fail(displayError);
        },

        updateStrategies: function () {
            this.update([this.lesses[1]]);
        },

        update: function (lesses) {
            new TreeFetcher(lesses || this.lesses)
                .fetch(this.nodes, this.resolution)
                .done(updateTree.bind(this))
                .fail(displayError);
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
