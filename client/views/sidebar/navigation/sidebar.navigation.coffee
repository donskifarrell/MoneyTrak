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
                        console.log(data);
                    );
            , (FPError) ->
                console.log(FPError.toString());
        );
