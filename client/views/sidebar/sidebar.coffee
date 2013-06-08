Meteor.startup ->
  # for convenience
  loginButtonsSession = Accounts._loginButtonsSession

  Template.sidebar_user_details.events "click .logout": (e, tmpl) ->
    Meteor.logout (err) ->
      if err
        alert(currentUser.profile)
      else
        # something else

  Template.sidebar_content.events
    "click .login-btn": (e) ->
      e.preventDefault()
      e.stopPropagation()
      loginButtonsSession.resetMessages()
      loginButtonsSession.set('inSignupFlow', false)
      $('.register-btn').removeClass("glow")
      $('.login-btn').addClass("glow")
      $('.account-box').removeClass("register")

    "click .register-btn": (e) ->
      e.preventDefault()
      e.stopPropagation()
      loginButtonsSession.resetMessages()
      loginButtonsSession.set('inSignupFlow', true)
      $('.login-btn').removeClass("glow")
      $('.register-btn').addClass("glow")
      $('.account-box').addClass("register")
  