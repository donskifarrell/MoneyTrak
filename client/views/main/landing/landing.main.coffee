
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
