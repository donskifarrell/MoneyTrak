Meteor.methods
    importNatwestData: (encryptedLoginDetails) ->
        this.unblock();
        console.log encryptedLoginDetails
        Natwest.loginDetails = encryptedLoginDetails;
        parseCsvImport(csvData) for csvData in Natwest.getAllData();

this.parseCsvImport = (csvData) ->
    data = $.csv.toObjects(
        csvData,
        {
            "headerIndex": 2,
            "start": 3,
            onParseValue: this.parseCsvImportValue
        }
    );
    Meteor.call(
            'addTransactions',
            {
                transactions: data
            }
        );

this.parseCsvImportValue = (value) ->
    # Replace strings that have prevailing or trailing whitespace, 
    # or a ' at the start. Then convert to a number if valid.
    trimmedValue = value.replace(/^[\s+'?]|\s+$/g, "");
    return $.csv.hooks.castToScalar trimmedValue, ""

