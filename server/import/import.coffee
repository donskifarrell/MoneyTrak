Meteor.methods
    importNatwestData: (encryptedLoginDetails) ->
        this.unblock();
        console.log encryptedLoginDetails
        Natwest.loginDetails = encryptedLoginDetails;
        Natwest.getAllData();

this.parseCsvImport = (csvData) ->
    data = $.csv.toObjects(
        csvData,
        {
            "headerIndex": 2,
            "start": 3,
            onParseValue: this.parseCsvImportValue
        }
    );
    console.log data
    Fiber(->
        Meteor.call(
            'addTransactions',
            {
                transactions: data
            }
        );
    ).run();

this.parseCsvImportValue = (value) ->
    # Replace strings that have prevailing or trailing whitespace, 
    # or a ' at the start. Then convert to a number if valid.
    trimmedValue = value.replace(/^[\s+'?]|\s+$/g, "");
    return $.csv.hooks.castToScalar trimmedValue, ""

