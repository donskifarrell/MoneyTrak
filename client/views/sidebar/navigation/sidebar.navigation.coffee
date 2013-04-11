Meteor.startup ->

    Template.navigation_menu.events 
        "click .nav-import": (e, tmpl) ->
            setHeaderAsActive(e)
            Session.set("navMenuSelection", "import-data")

        "click .nav-transactions": (e, tmpl) ->
            setHeaderAsActive(e)
            Session.set("navMenuSelection", "transactions-view")

        "click .nav-graph": (e, tmpl) ->
            setHeaderAsActive(e)
            Session.set("navMenuSelection", "graph-view")
        
        "click .loadCsv": (e, tmpl) ->
            filepicker.setKey('Acx6unRqUSRK0I5s3NvEgz');
            filepicker.pick(
                {
                    extension: '.csv',
                    container: 'modal',
                    services:['COMPUTER', 'DROPBOX'],
                }
                , (FPFile) ->
                    filepicker.read(
                        FPFile, 
                        (data) ->
                            parseCsvFile(data)
                            Session.set("navMenuSelection", "transactions-view")
                        )
                , (FPError) ->
                    console.log(FPError.toString())
            );

    Template.navigation_menu.numTransactions = ->
        Transactions.find({owner: Meteor.userId()}).count()

    parseCsvFile = (csvData) ->
        data = $.csv.toObjects(
            csvData,
            {
                "headerIndex": 2,
                "start": 3,
                onParseValue: parseCsvValue
            }
        );
        console.log data
        Meteor.call(
            'addTransactions',
            {
                transactions: data
            }
        );

    parseCsvValue = (value) ->
        # Replace strings that have prevailing or trailing whitespace, 
        # or a ' at the start. Then convert to a number if valid.
        trimmedValue = value.replace(/^[\s+'?]|\s+$/g, "");
        return $.csv.hooks.castToScalar trimmedValue, ""

    setHeaderAsActive = (element)->
        clearAllHeaders()
        $(element.currentTarget).parent().addClass("active")


    clearAllHeaders = ->
        $(".nav-gradient").removeClass("active");