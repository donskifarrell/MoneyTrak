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

  Template.login.events "click .enrollBtn": (e, tmpl) ->
    e.preventDefault()
    e.stopPropagation()
    alert('Clickiasd')
