Meteor.startup ->
  # for convenience
  loginButtonsSession = Accounts._loginButtonsSession
  
  #
  # user_account_form template and related
  #
  Template.user_account_form.events
    "click #login-buttons-password": ->
      loginOrSignup()

    "keypress #login-username, keypress #login-email, keypress #login-username-or-email, keypress #login-password, keypress #login-password-again": (event) ->
      loginOrSignup()  if event.keyCode is 13
  
  # return all login services, with password last
  Template.user_account_form.services = ->
    Accounts._loginButtons.getLoginServices()

  Template.user_account_form.isPasswordService = ->
    @name is "password"

  Template.user_account_form.hasOtherServices = ->
    Accounts._loginButtons.getLoginServices().length > 1

  Template.user_account_form.hasPasswordService = ->
    Accounts._loginButtons.hasPasswordService()

  Template.user_account_form.fields = ->
    loginFields = [
      fieldName: "username-or-email"
      fieldLabel: "Username or Email"
      visible: ->
        _.contains ["USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL"], Accounts.ui._passwordSignupFields()
    ,
      fieldName: "username"
      fieldLabel: "Username"
      visible: ->
        Accounts.ui._passwordSignupFields() is "USERNAME_ONLY"
    ,
      fieldName: "email"
      fieldLabel: "Email"
      inputType: "email"
      visible: ->
        Accounts.ui._passwordSignupFields() is "EMAIL_ONLY"
    ,
      fieldName: "password"
      fieldLabel: "Password"
      inputType: "password"
      visible: ->
        true
    ]
    signupFields = [
      fieldName: "username"
      fieldLabel: "Username"
      visible: ->
        _.contains ["USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Accounts.ui._passwordSignupFields()
    ,
      fieldName: "email"
      fieldLabel: "Email"
      inputType: "email"
      visible: ->
        _.contains ["USERNAME_AND_EMAIL", "EMAIL_ONLY"], Accounts.ui._passwordSignupFields()
    ,
      fieldName: "email"
      fieldLabel: "Email (optional)"
      inputType: "email"
      visible: ->
        Accounts.ui._passwordSignupFields() is "USERNAME_AND_OPTIONAL_EMAIL"
    ,
      fieldName: "password"
      fieldLabel: "Password"
      inputType: "password"
      visible: ->
        true
    ,
      fieldName: "password-again"
      fieldLabel: "Password (again)"
      inputType: "password"
      visible: ->
        
        # No need to make users double-enter their password if
        # they'll necessarily have an email set, since they can use
        # the "forgot password" flow.
        _.contains ["USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Accounts.ui._passwordSignupFields()
    ]
    (if loginButtonsSession.get("inSignupFlow") then signupFields else loginFields)

  Template.user_account_form.inForgotPasswordFlow = ->
    loginButtonsSession.get "inForgotPasswordFlow"

  Template.user_account_form.inLoginFlow = ->
    not loginButtonsSession.get("inSignupFlow") and not loginButtonsSession.get("inForgotPasswordFlow")

  Template.user_account_form.inSignupFlow = ->
    loginButtonsSession.get "inSignupFlow"

  Template.user_account_form.showCreateAccountLink = ->
    not Accounts._options.forbidClientAccountCreation

  Template.user_account_form.showForgotPasswordLink = ->
    _.contains ["USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "EMAIL_ONLY"], Accounts.ui._passwordSignupFields()

  Template._loginButtonsFormField.inputType = ->
    @inputType or "text"

  
  #
  # loginButtonsChangePassword template
  #
  Template._loginButtonsChangePassword.events
    "keypress #login-old-password, keypress #login-password, keypress #login-password-again": (event) ->
      changePassword()  if event.keyCode is 13

    "click #login-buttons-do-change-password": ->
      changePassword()

  Template._loginButtonsChangePassword.fields = ->
    [
      fieldName: "old-password"
      fieldLabel: "Current Password"
      inputType: "password"
      visible: ->
        true
    ,
      fieldName: "password"
      fieldLabel: "New Password"
      inputType: "password"
      visible: ->
        true
    ,
      fieldName: "password-again"
      fieldLabel: "New Password (again)"
      inputType: "password"
      visible: ->
        
        # No need to make users double-enter their password if
        # they'll necessarily have an email set, since they can use
        # the "forgot password" flow.
        _.contains ["USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Accounts.ui._passwordSignupFields()
    ]

  
  #
  # helpers
  #
  elementValueById = (id) ->
    element = document.getElementById(id)
    unless element
      null
    else
      element.value

  trimmedElementValueById = (id) ->
    element = document.getElementById(id)
    unless element
      null
    else # trim;
      element.value.replace /^\s*|\s*$/g, ""

  loginOrSignup = ->
    if loginButtonsSession.get("inSignupFlow")
      signup()
    else
      login()

  login = ->
    loginButtonsSession.resetMessages()
    username = trimmedElementValueById("login-username")
    email = trimmedElementValueById("login-email")
    usernameOrEmail = trimmedElementValueById("login-username-or-email")
    
    # notably not trimmed. a password could (?) start or end with a space
    password = elementValueById("login-password")
    loginSelector = undefined
    if username isnt null
      unless Accounts._loginButtons.validateUsername(username)
        return
      else
        loginSelector = username: username
    else if email isnt null
      unless Accounts._loginButtons.validateEmail(email)
        return
      else
        loginSelector = email: email
    else if usernameOrEmail isnt null
      
      # XXX not sure how we should validate this. but this seems good enough (for now),
      # since an email must have at least 3 characters anyways
      unless Accounts._loginButtons.validateUsername(usernameOrEmail)
        return
      else
        loginSelector = usernameOrEmail
    else
      throw new Error("Unexpected -- no element to use as a login user selector")
    Meteor.loginWithPassword loginSelector, password, (error, result) ->
      if error
        loginButtonsSession.errorMessage error.reason or "Unknown error"
      else
        loginButtonsSession.closeDropdown()
        Meteor.Router.to("/AccountSummary");


  signup = ->
    loginButtonsSession.resetMessages()
    options = {} # to be passed to Accounts.createUser
    username = trimmedElementValueById("login-username")
    if username isnt null
      unless Accounts._loginButtons.validateUsername(username)
        return
      else
        options.username = username
    email = trimmedElementValueById("login-email")
    if email isnt null
      unless Accounts._loginButtons.validateEmail(email)
        return
      else
        options.email = email
    
    # notably not trimmed. a password could (?) start or end with a space
    password = elementValueById("login-password")
    unless Accounts._loginButtons.validatePassword(password)
      return
    else
      options.password = password
    return  unless matchPasswordAgainIfPresent()
    Accounts.createUser options, (error) ->
      if error
        loginButtonsSession.errorMessage error.reason or "Unknown error"
      else
        loginButtonsSession.closeDropdown()
        Meteor.Router.to("/ImportData");


  forgotPassword = ->
    loginButtonsSession.resetMessages()
    email = trimmedElementValueById("forgot-password-email")
    if email.indexOf("@") isnt -1
      Accounts.forgotPassword
        email: email
      , (error) ->
        if error
          loginButtonsSession.errorMessage error.reason or "Unknown error"
        else
          loginButtonsSession.infoMessage "Email sent"

    else
      loginButtonsSession.errorMessage "Invalid email"

  changePassword = ->
    loginButtonsSession.resetMessages()
    
    # notably not trimmed. a password could (?) start or end with a space
    oldPassword = elementValueById("login-old-password")
    
    # notably not trimmed. a password could (?) start or end with a space
    password = elementValueById("login-password")
    return  unless Accounts._loginButtons.validatePassword(password)
    return  unless matchPasswordAgainIfPresent()
    Accounts.changePassword oldPassword, password, (error) ->
      if error
        loginButtonsSession.errorMessage error.reason or "Unknown error"
      else
        loginButtonsSession.set "inChangePasswordFlow", false
        loginButtonsSession.set "inMessageOnlyFlow", true
        loginButtonsSession.infoMessage "Password changed"


  matchPasswordAgainIfPresent = ->
    
    # notably not trimmed. a password could (?) start or end with a space
    passwordAgain = elementValueById("login-password-again")
    if passwordAgain isnt null
      
      # notably not trimmed. a password could (?) start or end with a space
      password = elementValueById("login-password")
      if password isnt passwordAgain
        loginButtonsSession.errorMessage "Passwords don't match"
        return false
    true

  correctDropdownZIndexes = ->
    
    # IE <= 7 has a z-index bug that means we can't just give the
    # dropdown a z-index and expect it to stack above the rest of
    # the page even if nothing else has a z-index.  The nature of
    # the bug is that all positioned elements are considered to
    # have z-index:0 (not auto) and therefore start new stacking
    # contexts, with ties broken by page order.
    #
    # The fix, then is to give z-index:1 to all ancestors
    # of the dropdown having z-index:0.
    n = document.getElementById("login-dropdown-list").parentNode

    while n.nodeName isnt "BODY"
      n.style.zIndex = 1  if n.style.zIndex is 0
      n = n.parentNode

  Template.login_message.errorMessage = ->
    loginButtonsSession.get "errorMessage"

  Template.login_message.infoMessage = ->
    loginButtonsSession.get "infoMessage"

