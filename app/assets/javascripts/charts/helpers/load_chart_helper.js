LoadChartHelper = {
  globalBrushExtent: undefined,
  charts: [],
  updateBrush: function(currentChartId){
    if(this.globalBrushExtent){
      for(var i = 0; i < this.charts.length; i++){
        if(this.charts[i]){
          this.charts[i].brushExtent(this.globalBrushExtent);
        }
      };

      currentChart = this.charts[currentChartId - 1];
      if(currentChart && currentChart.update){
        currentChart.update();
      }
    }
  }
};
