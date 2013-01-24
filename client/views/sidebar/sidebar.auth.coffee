Meteor.startup ->
  Template.loggedin.events "click #logout": (e, tmpl) ->
    Meteor.logout (err) ->
      if err
        # handle error
      else
        # something else

  Template.loggedout.events "click #login": (e, tmpl) ->
    Meteor.loginWithPassword
      requestPermissions: ["user"],
      (err) ->
        if err
          # handle error
        else
          # show an alert
