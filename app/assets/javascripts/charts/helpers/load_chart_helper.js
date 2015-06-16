LoadChartHelper = {
  globalBrushExtent: undefined,
  currentWeek: undefined,
  forceReload: false,
  charts: [],

  updateBrush: function(currentChartId){
    if(this.globalBrushExtent){
      this.setBrushExtent();
      currentChart = this.charts[currentChartId - 1];
      if(currentChart && currentChart.update){
        currentChart.update();
      }
    }
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
