Meteor.startup ->

    Template.transactions_view.transactionList = ->
        Transactions.find(
            {owner: Meteor.userId()},
            limit: 100
        )

    Template.transactions_view.formatDate = (date) ->
        date.toDateString()