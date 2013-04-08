Meteor.startup ->

    Template.main_content.isPageSelected = (page) ->
        isSelected = false
        selected = Session.get("navMenuSelection")
        if selected == page
            isSelected = true

        isSelected

