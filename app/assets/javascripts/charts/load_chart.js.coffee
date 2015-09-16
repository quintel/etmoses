# Uses nvd3 in order to create a "focus" area so the user may zoom on and view
# the curve in greater detail.
class LoadChart
  intoSelector: null

  axisLabels:
    default: 'kW'
    flex: 'kW'
    inflex: 'kW'
    use: ''
    availability: ''
    price: '€'

  constructor: (@data, @capacity, @curve_type) ->
    # pass

  sampledData: (loads) ->
    if LoadChartHelper.currentWeek && LoadChartHelper.currentWeek != 0
      chunkSize = Math.floor(loads.length / 52)
      zeroWeek  = LoadChartHelper.currentWeek - 1

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

    console.log(@data)
    data = for datum, index in @data
      { key: datum.name, values: @sampledData(datum.values), area: datum.area, color: datum.color}

    $(intoSelector).empty()

    if @capacity
      data.push(@generateCapacity(data))

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
      if last
        datum.values.push(x: last.x + 1, y: last.y)

    nv.addGraph =>
      chart = @chart()
      d3.select(intoSelector).datum(data).call(chart)
      chart.update()

  generateCapacity: (data) =>
    top_line = data[0].values.map((sample) => { x: sample.x, y: @capacity })
    bottom_line = data[0].values.map((sample) => { x: sample.x, y: (@capacity * -1) })

    bottom_line.reverse().unshift(x: bottom_line[0].x + 1, y: bottom_line[0].y)

    total = bottom_line.concat top_line

    key:      "Capacity",
    color:    "darkred",
    values:   total,
    disabled: LoadChartHelper.disableCapacity

  formatDateFromFrame: (frame) =>
    multiplier =
      switch @data[0].values.length
        when 35040 then 900000
        when 8760  then 3600000
        else            -1

    if multiplier is -1
      frame
    else
      LoadChartHelper.formatDate(new Date(frame * multiplier))

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
      optionEl.text("#{ LoadChartHelper.formatDate(startWeek) } - #{ LoadChartHelper.formatDate(endWeek) }")

      dateEl.append(optionEl)

    dateEl.change =>
      value = parseInt(dateEl.val(), 10)
      LoadChartHelper.currentWeek = value
      LoadChartHelper.forceReload = true
      LoadChartHelper.clearBrush()

      $("select[name=date-select]").val(value)
      @renderChart(intoSelector, value)

    $(intoSelector).after(dateEl)

    if LoadChartHelper.currentWeek
      $("select[name=date-select]").val(LoadChartHelper.currentWeek)

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
         .axisLabel(@axisLabels[@curve_type])
         .axisLabelDistance(0)
         .tickFormat(d3.format(',.3r'))

    chart.y2Axis
         .axisLabel(@axisLabels[@curve_type])
         .axisLabelDistance(0)
         .tickFormat(d3.format(',.3r'))

    chart.brush.on('brushend', @setGlobalBrushFocus)

    LoadChartHelper.charts[@loadChartLocation() - 1] = chart
    LoadChartHelper.updateBrush(@loadChartLocation())

    $("g.tick.zero text").text("0.00")

    chart

  setGlobalBrushFocus: ()->
    LoadChartHelper.globalBrushExtent = d3.event.target.extent()
    localSettings.set('global_brush_extent', d3.event.target.extent());

  loadChartLocation: ->
    parseInt(@intoSelector.replace(/\D/g, ''))

window.LoadChart = LoadChart
