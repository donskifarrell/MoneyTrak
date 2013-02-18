Meteor.startup ->
  # for convenience
  loginButtonsSession = Accounts._loginButtonsSession

  Template.sidebar_user_details.events "click .logout": (e, tmpl) ->
    Meteor.logout (err) ->
      if err
        alert(currentUser.profile)
      else
        # something else
  