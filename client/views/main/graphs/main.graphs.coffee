Meteor.startup ->
    yearSpending = [];
    monthValueStore = undefined;

    Template.graph_view.events
        "click .refresh": (e, tmpl) ->
            renderSpendingChart({});

    Template.graph_view.rendered = ->
        renderSpendingChart({});

    renderSpendingChart = (options) ->
        nv.addGraph createSpendingChart();
    
    createSpendingChart = ->
        chart = nv
                .models
                .cumulativeLineChart()
                .color(
                    d3.scale.category10().range()
                )
                .clipVoronoi(false)

        d3.select(".spending svg").datum(getYearSpending()).call(chart)

        nv.utils.windowResize(chart.update)

        chart.dispatch.on(
            "stateChange", 
            (e) ->
                nv.log("New State:", JSON.stringify(e))
        )

        chart

    getYearSpending = ->
        toDate = new Date()
        fromDate = new Date().setMonth(toDate.getMonth()-12)

        yearSpending.length = 0;
        monthValueStore = GetMonthValueStore();

        transactions = Transactions.find(
            {
                owner: Meteor.userId(),
                date: {
                    $gte: fromDate,
                    $lt: toDate
                }
            },
        ).forEach( 
            (transaction) ->
                monthValueStore[transaction.date.getMonthName()]
                    .push [transaction.date, transaction.balance]
        )

        for key of monthValueStore
          yearSpending.push(buildMonthData(key)) if monthValueStore.hasOwnProperty(key)

        yearSpending

    buildMonthData = (month) ->
            key: month
            values: monthValueStore[month],

    GetMonthValueStore = ->
        months =
            August:     [], 
            September:  [], 
            October:    [], 
            November:   [], 
            December:   [],




            ###            January:    [], 
            February:   [], 
            March:      [], 
            April:      [], 
            May:        [], 
            June:       [], 
            July:       [], ###
###

    spendingData = {
        labels : [
            'January', 
            'February', 
            'March', 
            'April', 
            'May', 
            'June', 
            'July', 
            'August', 
            'September', 
            'October', 
            'November', 
            'December', 
            ],
        datasets : [
            {
                fillColor : "rgba(220,220,220,0.5)",
                strokeColor : "red",
                data : balances
            }
        ]
    }


    LineOptions = ->
        values =
            scaleOverlay: $('#scaleOverlay').val() == 'true'
            scaleOverride: $('#scaleOverride').val() == 'true'
            scaleSteps: parseInt($('#scaleSteps').val())
            scaleStepWidth: parseInt($('#scaleStepWidth').val())
            scaleStartValue: parseInt($('#scaleStartValue').val())
            scaleLineColor: $('#scaleLineColor').val()
            scaleLineWidth: parseInt($('#scaleLineWidth').val())
            scaleShowLabels: $('#scaleShowLabels').val() == 'true'
            scaleLabel: $('#scaleLabel').val()
            scaleFontFamily: "'Arial'"
            scaleFontSize: parseInt($('#scaleFontSize').val())
            scaleFontStyle: "normal"
            scaleFontColor: "#666"
            scaleShowGridLines: $('#scaleShowGridLines').val() == 'true'
            scaleGridLineColor: "rgba(0,0,0,.05)"
            scaleGridLineWidth: parseInt($('#scaleGridLineWidth').val())
            bezierCurve: $('#bezierCurve').val() == 'true'
            pointDot: $('#pointDot').val() == 'true'
            pointDotRadius: parseInt($('#pointDotRadius').val())
            pointDotStrokeWidth: parseInt($('#pointDotStrokeWidth').val())
            datasetStroke: $('#datasetStroke').val() == 'true'
            datasetStrokeWidth: parseInt($('#datasetStrokeWidth').val())
            datasetFill: $('#datasetFill').val() == 'true'
            animation: $('#animation').val() == 'true'
            animationSteps: parseInt($('#animationSteps').val())
            animationEasing: "easeOutQuart"
            onAnimationComplete: null
            ###