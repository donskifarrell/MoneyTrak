Package.describe({
    summary: "HTTP Requests"
});

Npm.depends({
    request: "2.21.0",
    jquery: "1.8.3"
});

Package.on_use(function (api) {
    api.add_files("import.natwest.js", "server");
});