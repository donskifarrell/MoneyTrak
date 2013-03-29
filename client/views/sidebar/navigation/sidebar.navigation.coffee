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
                "start": 3
            }
        );
        console.log data

