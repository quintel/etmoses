LoadChartHelper = {
  globalBrushExtent: undefined,
  currentWeek: undefined,
  forceReload: false,
  disableCapacity: true,
  charts: [],

  toggleCapacity: function(currentChartId){
    currentChart = this.charts[currentChartId - 1];
    d3Chart = d3.select(".chart-id-" + currentChartId + " svg");
    d3ChartData = d3Chart.data();
    if(d3ChartData[0] && d3ChartData[0][1]){
      d3ChartData[0][1]["disabled"] = this.disableCapacity;
    }
    currentChart.update();
  },

  updateBrush: function(currentChartId){
    if(typeof(localSettings) !== 'undefined'){
      this.globalBrushExtent = localSettings.get('global_brush_extent')
    };

    if(this.globalBrushExtent){
      this.setBrushExtent();
      this.reloadChart(currentChartId);
    }
  },

  reloadChart: function(currentChartId){
    var currentChart = this.charts[currentChartId - 1];
    if(currentChart && currentChart.update){
      currentChart.update();
    };
  },

  setBrushExtent: function(){
    for(var i = 0; i < this.charts.length; i++){
      if(this.charts[i]){
        this.charts[i].brushExtent(this.globalBrushExtent);
      }
    };
  },

  clearBrush: function(){
    this.globalBrushExtent = undefined;
    for(var i = 0; i < this.charts.length; i++){
      if(this.charts[i]){
        d3.select(".brush").call(this.charts[i].brush.clear());
        this.charts[i].brushExtent([0,0]);
        this.charts[i].update();
      }
    };
  },

  formatDate: function(date){
    var monthNames = [
      "January", "February", "March",
      "April", "May", "June", "July",
      "August", "September", "October",
      "November", "December"
    ];

    return [date.getDate(), monthNames[date.getMonth()]].join(" ");
  }
};
