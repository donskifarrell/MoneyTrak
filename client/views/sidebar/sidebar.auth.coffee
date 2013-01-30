Meteor.startup ->
  Template.loggedIn.events "click #logout": (e, tmpl) ->
    Meteor.logout (err) ->
      if err
        # handle error
      else
        # something else

  Template.loggedOut.events "click #login": (e, tmpl) ->
    Meteor.loginWithPassword
      requestPermissions: ["user"],
      (err) ->
        if err
          # handle error
        else
          # show an alert

  Template.login.events "click #loginBtn": (e, tmpl) ->
    Meteor.loginWithPassword
      requestPermissions: ["user"],
      (err) ->
        if err
          # handle error
        else
          # show an alert

  Template.login.events "click .toEnrollBtn": (e, tmpl) ->
    e.preventDefault()
    e.stopPropagation()
    Session.set("has_account", false)

  Template.enroll.events "click .toLoginBtn": (e, tmpl) ->
    e.preventDefault()
    e.stopPropagation()
    Session.set("has_account", true)

  Template.loggedOut.has_account = ->
    Session.equals("has_account", true)


