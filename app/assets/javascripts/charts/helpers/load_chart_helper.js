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
  },

  clearBrush: function(dateValue){
    for(var i = 0; i < this.charts.length; i++){
      if(this.charts[i]){
        this.charts[i].dispatch.brush('');
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
