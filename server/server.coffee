
Meteor.publish("transactions", ->
  Transactions.find({
    	$or: [{owner: this.userId}]
    })
);
