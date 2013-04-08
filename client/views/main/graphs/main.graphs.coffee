Meteor.startup ->
    yearSpending = [];
    dailyValueStore = {};

    ###
        Outline of chart data structure:
        [
            {
                key: "Label of each separate line in chart"
                values: [
                    [ X, Y ], ...
                ]
            },
            ...
        ]
    ###

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
                .lineChart()                
                .x((dataPoint) ->
                    dataPoint[0] 
                )
                .y((dataPoint) ->
                    dataPoint[1]
                )

        chart.yAxis
               .axisLabel('Spend')
               .tickFormat( (value) ->
                    return value
                )

        chart.xAxis
               .axisLabel('Date')
               .rotateLabels(-45)
               .tickFormat( (date) ->
                    d3.time.format('%b %d')(new Date(date))
                )

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
        dailyValueStore = {};

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
                if dailyValueStore.hasOwnProperty(transaction.date)
                    dailyValueStore[transaction.date] += transaction.value
                else                 
                    dailyValueStore[transaction.date] = transaction.balance
        )

        for key of dailyValueStore
          yearSpending.push [
            new Date(key),
            sumDailyBalance(key) if dailyValueStore.hasOwnProperty(key)
          ]
        
        return [
            key: "Year Spend",
            values: yearSpending
        ]
       
    sumDailyBalance = (date) ->
        balance = 0
        balance += value for value in dailyValueStore[date]
        return balance
