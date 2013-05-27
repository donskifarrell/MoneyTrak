Package.describe({
    summary: 'Parse CSV (Comma Separated Values) to Javascript arrays or dictionaries. Note: The JQuery-CSV.js file has been slightly modified from the official released version. This was to add in a "headerIndex" option to the toObjects(..) method.'
});

Npm.depends({
    cheerio: "0.11.0",
    jquery: "1.8.3"
});

Package.on_use(function (api) {
    api.use('jquery', 'client');
    api.add_files("lib/jquery-csv.min.js", 'client');

    api.add_files("jquery-csv.js", "server");
    api.add_files("lib/jquery-csv.min.js", 'server');
});

