
Meteor.startup ->

  Template.landing_page.events "click .head": (e, tmpl) ->
    e.preventDefault()
    e.stopPropagation()
    $('a.head').removeClass('active')
    $(e.currentTarget).addClass('active')

  barChartData = {
      labels : ["January","February","March","April","May","June","July"],
      datasets : [
        {
          fillColor : "rgba(220,220,220,0.5)",
          strokeColor : "rgba(220,220,220,1)",
          data : [65,59,90,81,56,55,40]
        },
        {
          fillColor : "rgba(151,187,205,0.5)",
          strokeColor : "rgba(151,187,205,1)",
          data : [28,48,40,19,96,27,100]
        }
      ]
    }

  Template.landing_page.rendered = ->
    myLine = new Chart($("#myChart")[0].getContext("2d"))
      .Bar(barChartData)
  
###
Simple test data generator
###
testData = ->
  stream_layers(3, 128, .1).map (data, i) ->
    key: "Stream" + i
    values: data

nv.addGraph ->
  chart = nv.models.lineWithFocusChart()
  chart.xAxis.tickFormat d3.format(",f")
  chart.yAxis.tickFormat d3.format(",.2f")
  chart.y2Axis.tickFormat d3.format(",.2f")
  d3.select("#chart3 svg").datum(testData()).transition().duration(500).call chart
  nv.utils.windowResize chart.update
  chart

exampleData = ->
  [
    key: "Cumulative Return"
    values: [
      label: "CDS / Options"
      value: 29.765957771107
    ,
      label: "Cash"
      value: 0
    ,
      label: "Corporate Bonds"
      value: 32.807804682612
    ,
      label: "Equity"
      value: 196.45946739256
    ,
      label: "Index Futures"
      value: 0.19434030906893
    ,
      label: "Options"
      value: 98.079782601442
    ,
      label: "Preferred"
      value: 13.925743130903
    ,
      label: "Not Available"
      value: 5.1387322875705
    ]
  ]

historicalBarChart = [
  key: "Cumulative Return"
  values: [
    label: "A"
    value: 29.765957771107
  ,
    label: "B"
    value: 0
  ,
    label: "C"
    value: 32.807804682612
  ,
    label: "D"
    value: -196.45946739256
  ,
    label: "E"
    value: 0.19434030906893
  ,
    label: "F"
    value: 98.079782601442
  ,
    label: "G"
    value: 13.925743130903
  ,
    label: "H"
    value: 5.1387322875705
  ]
]

nv.addGraph ->
  chart = nv.models.pieChart().x((d) ->
    d.label
  ).y((d) ->
    d.value
  ).showLabels(true)
  d3.select("#chart2 svg").datum(exampleData()).transition().duration(1200).call chart
  nv.utils.windowResize chart.update
  chart

nv.addGraph ->
  #.staggerLabels(historicalBarChart[0].values.length > 8)
  chart = nv.models.discreteBarChart().x((d) ->
    d.label
  ).y((d) ->
    d.value
  ).staggerLabels(true).tooltips(false).showValues(true)
  d3.select("#chart1 svg").datum(historicalBarChart).transition().duration(500).call chart
  nv.utils.windowResize chart.update
  chart

# Inspired by Lee Byron's test data generator. 
stream_layers = (n, m, o) ->
  bump = (a) ->
    x = 1 / (.1 + Math.random())
    y = 2 * Math.random() - .5
    z = 10 / (.1 + Math.random())
    i = 0

    while i < m
      w = (i / m - y) * z
      a[i] += x * Math.exp(-w * w)
      i++
  o = 0
  d3.range(n).map ->
    a = []
    i = undefined
    i = 0
    while i < m
      a[i] = o + o * Math.random()
      i++
    i = 0
    while i < 5
      bump a
      i++
    a.map stream_index


# Another layer generator using gamma distributions. 
stream_waves = (n, m) ->
  d3.range(n).map (i) ->
    d3.range(m).map((j) ->
      x = 20 * j / m - i / 3
      2 * x * Math.exp(-.5 * x)
    ).map stream_index

stream_index = (d, i) ->
  x: i
  y: Math.max(0, d)