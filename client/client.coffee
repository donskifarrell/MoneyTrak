
Meteor.subscribe("transactions");
###
// If no party selected, select one.
Meteor.startup( ->
	Deps.autorun( ->
		if (! Session.get("selected"))
			var party = Parties.findOne()
		if (party)
			Session.set("selected", party._id)
	);
);###