if Meteor.is_client
  Meteor.startup ->
    console.log "Started at " + location.href

  Meteor.Router.add
    "/AccountSummary": "account_summary_view"
    "/Transactions": "transactions_view"
    "/Hotspots": "hotspots_viewy"
    "/Bills": "bills_view"

    "/Import": "import_data_view"
    "/RequestFeature": "request_feature_view"
    "/About": "about_view"
