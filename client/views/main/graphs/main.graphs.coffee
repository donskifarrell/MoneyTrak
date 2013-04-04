Meteor.startup ->
    dates = []
    balances = []

    Template.graph_view.events
        "click .refresh": (e, tmpl) ->
            renderSpendingChart(LineOptions());

    Template.graph_view.rendered = ->
        renderSpendingChart({});

    renderSpendingChart = (options) ->
        getSpending()
        chartCanvas = $("#lineChart")[0].getContext("2d")
        chart = new Chart(chartCanvas).Line(spendingData, options)

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

    getSpending = ->
        toDate = new Date()
        fromDate = new Date().setMonth(toDate.getMonth()-12)
        dates.length = 0;
        balances.length = 0;

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
                dates.push transaction.account_name
                balances.push transaction.balance
        )

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