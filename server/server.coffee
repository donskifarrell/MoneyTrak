


Meteor.startup( ->
    Future = Npm.require('fibers/future')
);


Meteor.publish("transactions", ->
  Transactions.find({
    	$or: [{owner: this.userId}]
    })
);
