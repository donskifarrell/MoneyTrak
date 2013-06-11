
Handlebars.registerHelper(
    'title', ->
        return Session.get("title");
)

Handlebars.registerHelper(
    'subtitle', ->
        return Session.get("subtitle");
)

Handlebars.registerHelper(
    'activeNav', (nav) ->
        if Session.equals("activeNav", nav) then "active" else "";
)