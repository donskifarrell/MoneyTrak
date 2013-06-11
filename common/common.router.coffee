if Meteor.is_client
  Meteor.startup ->
    console.log "Started at " + location.href

  Meteor.Router.add
    "/AccountSummary": 
      to: "account_summary_view"
      and: ->
        Session.set("title", ": Account Summary");
        console.log(Meteor.Router.page())
        Session.set("activeNav", "accSummary");
    "/Transactions": 
      to: "transactions_view"
      and: ->
        Session.set("title", ": Transactions");
        Session.set("activeNav", "trans");
    "/Hotspots": 
      to: "hotspots_view"
      and: ->
        Session.set("title", ": Hotspots");
        Session.set("activeNav", "hotspots");
    "/Bills": 
      to: "bills_view"
      and: ->
        Session.set("title", ": Bills");
        Session.set("activeNav", "bills");

    "/Import": 
      to: "import_data_view"
      and: ->
        Session.set("title", ": Import Data");
        Session.set("activeNav", "import");
    "/RequestFeature": 
      to: "request_feature_view"
      and: ->
        Session.set("title", ": Request A New Feature");
        Session.set("activeNav", "reqFeature");
    "/About": 
      to: "about_view"
      and: ->
        Session.set("title", ": About");
        Session.set("activeNav", "about");

      
