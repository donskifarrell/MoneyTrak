Meteor.startup ->

    Template.navigation_menu.events "click .loadCsv": (e, tmpl) ->
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
                    )
            , (FPError) ->
                console.log(FPError.toString())
        );

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

