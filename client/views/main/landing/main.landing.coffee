
Meteor.startup ->

  Template.landing_page.events "click .head": (e, tmpl) ->
    e.preventDefault()
    e.stopPropagation()
    $('a.head').removeClass('active')
    $(e.currentTarget).addClass('active')