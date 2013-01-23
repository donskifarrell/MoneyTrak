if Meteor.isClient
  Template.hello.greeting = ->
    "Welcome to lifecrt."

  Template.hello.events "click input": ->
    
    # template data, if any, is available in 'this'
    console.log "You pressed coffee button"  if typeof console isnt "undefined"

if Meteor.isServer
  Meteor.startup ->


# code to run on server at startup