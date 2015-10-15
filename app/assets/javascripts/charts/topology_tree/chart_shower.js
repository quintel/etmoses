var ChartShower = (function(){
  var blue = '#1F77B4';
  var green = '#95BB95';

  ChartShower.prototype = {
    show: function(){
      if(this.nodeData === undefined){
        return false;
      };

      this.id = this.nodeData.id;
      this.uniqueId = ("chart-id-" + this.id);
      this.existingLoadPlatform = $(".load-graph ." + this.uniqueId);

      $(".load-graph .chart").hide();
      showLoadChart.call(this)
    },

    reload: function(){
      if(LoadChartHelper.forceReload){
        $(".load-graph .chart").remove();
        LoadChartHelper.forceReload = false;
      }
      return this;
    }
  };

  function showLoadChart(){
    showOrLoadPlatform.call(this);
    LoadChartHelper.reloadChart(this.id);
  };

  function showOrLoadPlatform(){
    if(this.existingLoadPlatform.length > 0){
      this.existingLoadPlatform.show();

      LoadChartHelper.updateBrush(this.id);
      LoadChartHelper.toggleCapacity(this.id);
    }
    else{
      addNewLoadChartPlatform.call(this, this.nodeData);
      LoadChartHelper.updateBrush(this.id);
    };

    toggleDomParts.call(this.nodeData);
  };

  function addNewLoadChartPlatform(d){
    var loadChartClass = ('.' + this.uniqueId + ' svg');
    var loadPlatform = $("<div>").addClass(this.uniqueId).addClass("chart");
        loadPlatform.html('<svg></svg>');

    $(".load-graph").prepend(loadPlatform);

    if (this.treeChart.strategyLoads && this.treeChart.strategyShown) {
      new LoadChart([
        { values: d.altLoad, name: d.name + ' (with strategies)', color: green, area: true },
        { values: d.load, name: d.name, area: false, color: blue }
      ], d.capacity, 'default').render(loadChartClass);
    } else {
      new LoadChart([
        { values: d.load, name: d.name, area: true, color: blue }
      ], d.capacity, 'default').render(loadChartClass);
    }
  };

  function toggleDomParts(){
    $('#technologies .row-fluid, p.info').hide();
    showTechnologies(this);
    setHeader.call(this);
    toggleSelectedNode.call(this);
  };

  function toggleSelectedNode(){
    d3.selectAll(".overlay circle, .overlay text").style("opacity", 0.3);
    d3.selectAll(".overlay text").style({
      "font-weight":     "normal",
      "text-decoration": "none"
    });

    d3.select(".overlay g.node.n" + this.id).select("circle").style("opacity", 1.0);
    d3.select(".overlay g.node.n" + this.id).select("text").style({
      "opacity":         1.0,
      "font-weight":     "bold"
    });
  };

  function showTechnologies(){
    var techTab = $('#technologies .row-fluid[data-node="' + this.name + '"]');
    if(techTab.length > 0){
      techTab.show();
      $(".technologies-button").parent().removeClass("disabled");
      $(".nav-tabs li a[href='#technologies']").removeClass("disabled-tab");
    }
    else{
      $(".technologies-button").parent().addClass("disabled");
      $(".nav-tabs li a[href='#technologies']").addClass("disabled-tab");
    };
  };

  function setHeader(){
    $("h1 span").removeClass("hidden");
    $("h1 span.current-chart").text(this.name);

    enableCsvDownloadCurveButton.call(this);
  };

  function enableCsvDownloadCurveButton(){
    var downloadBtn = $('li a.download-curve')
        downloadBtn.parent().removeClass("disabled");
        downloadBtn.text("Download curve for '" + this.name + "'");

    downloadBtn.off('click').on('click', function(event) {
      event.preventDefault();

      var loads = this.load.map(function(value, index) {
        return "" + value + "," + (this.altLoad ? this.altLoad[index] : '');
      });

      if (this.altLoad) {
        loads.unshift('Strategies On,Strategies Off');
      } else {
        loads.unshift('Strategies Off,');
      }

      CSV.download(loads.join("\n"),
        (this.name + ' Curve.csv'), "data:text/csv;charset=utf-8");
    });
  };

  function ChartShower(_treeChart, _nodeData){
    this.treeChart = _treeChart;
    this.nodeData = _nodeData;
  };

  return ChartShower;
})();
