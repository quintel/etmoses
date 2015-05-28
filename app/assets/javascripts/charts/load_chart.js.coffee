# Creates a line chart to represent the load of a network component over time.
# Uses nvd3 in order to create a "focus" area so the user may zoom on and view
# the curve in greater detail.
class LoadChart
  intoSelector: null

  constructor: (@data, @capacity) ->
    # pass

  sampledData: (loads, week) ->
    if week
      chunkSize = Math.floor(loads.length / 52)
      zeroWeek  = week - 1

      startAt = zeroWeek * chunkSize
      endAt   = startAt + chunkSize

      window.downsampleCurve(loads.slice(startAt, endAt), chunkSize, startAt)
    else
      window.downsampleCurve(loads, 365)

  render: (intoSelector, week = 0) =>
    @intoSelector = intoSelector
    @renderChart(intoSelector, week)
    @drawDateSelect(intoSelector)

  renderChart: (intoSelector, week) ->
    self = this

    data = for datum, index in @data
      { key: datum.name, values: @sampledData(datum.values, week), area: datum.area, color: datum.color}

    $(intoSelector).empty()

    if @capacity
      data.push({
        key: 'Capacity',
        color: 'darkred',
        values: data[0].values.map((sample) => { x: sample.x, y: @capacity })
      })

    # data.forEach (series) ->
    for series in data
      if series.values.length == 1
        for frame in [1..364]
          series.values.push(
            x: series.values[0].x + frame,
            y: series.values[0].y
          )

    for datum in data
      # Add an extra data point to make the "step-after" smoothing fit better
      # (otherwise it appears that the last frame is not present).
      last = datum.values[datum.values.length - 1]
      datum.values.push(x: last.x + 1, y: last.y)

    nv.addGraph =>
      chart = @chart()
      d3.select(intoSelector).datum(data).call(chart)
      chart.update()

  formatDateFromFrame: (frame) =>
    multiplier =
      switch @data.length
        when 35040 then 900000
        when 8760  then 3600000
        else            -1

    if multiplier is -1
      frame
    else
      @formatDate(new Date(frame * multiplier))

  drawDateSelect: (intoSelector) ->
    epoch    = new Date(0)
    msInWeek = 604800000

    dateEl = $('<select name="date-select" class="form-control" style="max-width: 300px"></select>')
    dateEl.append($('<option value="0">Whole year</option>'))

    for week in [0...52]
      startWeek = new Date(epoch.getDate() + (msInWeek * week))
      endWeek   = new Date(startWeek.getDate() + (msInWeek * week) + msInWeek - (msInWeek / 7))

      if week is 51
        endWeek = new Date(endWeek.getDate() - 1000)

      optionEl = $("<option value='#{ week + 1 }'></option>")
      optionEl.text("#{ @formatDate(startWeek) } - #{ @formatDate(endWeek) }")

      dateEl.append(optionEl)

    dateEl.change =>
      value = parseInt(dateEl.val(), 10)
      @renderChart(intoSelector, value)

    $(intoSelector).after(dateEl)

  chart: ->
    chart = nv.models.lineWithFocusChart()

    chart.options({
      duration:           0
      transitionDuration: 0
      interpolate:        'linear'
      forceY:             [0.0]
    })

    chart.useVoronoi(false)
    chart.lines.duration(0)
    chart.lines2.duration(0)
    chart.lines2.forceY([0.0])

    chart.lines.interpolate('step-after')
    chart.lines2.interpolate('step-after')

    chart.xAxis
         .tickFormat(@formatDateFromFrame)

    chart.x2Axis
         .axisLabel("Time")
         .tickFormat(@formatDateFromFrame)

    chart.yAxis
         .axisLabel("kW")
         .axisLabelDistance(35)
         .tickFormat(d3.format(',.3r'))

    chart.y2Axis
         .axisLabel("kW")
         .axisLabelDistance(35)
         .tickFormat(d3.format(',.3r'))

    chart.dispatch.on('brush.end', @setGlobalBrushFocus.bind(this))

    LoadChartHelper.charts[@loadChartLocation() - 1] = chart
    LoadChartHelper.updateBrush(@loadChartLocation())

    chart

  setGlobalBrushFocus: (b)->
    LoadChartHelper.globalBrushExtent = b.extent

  loadChartLocation: ->
    parseInt(@intoSelector.replace(/\D/g, ''))

window.LoadChart = LoadChart
