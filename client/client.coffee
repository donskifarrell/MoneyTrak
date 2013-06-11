Meteor.subscribe("transactions");

Handlebars.registerHelper(
    'title', ->
        return Session.get("title");
)

Handlebars.registerHelper(
    'activeNav', (nav) ->
        if Session.equals("activeNav", nav) then "active" else "";
)