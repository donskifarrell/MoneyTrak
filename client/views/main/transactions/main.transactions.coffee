Meteor.startup ->

    Template.transactions_view.transactionList = ->
        Transactions.find(
            {owner: Meteor.userId()},
            limit: 100
        );

