Meteor.startup ->
    dates = []
    balances = []

    Template.graph_view.rendered = ->
        getSpending()
        chartCanvas = $("#lineChart")[0].getContext("2d")
        chart = new Chart(chartCanvas).Line(spendingData)

    spendingData = {
      labels : dates,
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

        transactions = Transactions.find(
            {
                owner: Meteor.userId(),
                date: {
                    $gte: fromDate,
                    $lt: toDate
                }
            },
            limit: 100
        ).forEach( 
            (transaction) ->
                dates.push transaction.account_name
                balances.push transaction.balance
        )

