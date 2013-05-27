var $ = Npm.require('jquery');

Natwest = {
    loginDetails: {
        custNumber: undefined,
        pin: undefined,
        pass: undefined,
    },

    getAllData: function() {
        if (this.loginDetails.custNumber && 
            this.loginDetails.pin && 
            this.loginDetails.pass) {
                this.site().get(Natwest.nwolb.login);
        } else {
            console.log("No Login Details entered for Natwest login")
            return false;
        }
    },

    site: function() {
        var nwolbUrl = 'https://www.nwolb.com';

        var request = Npm.require('request').defaults({
            headers: {
                'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/5XX.XX (KHTML, like Gecko) Chrome'
            },
            followAllRedirects: true
        });

        var parse = function(arguments) {
            var arguments = Array.prototype.slice.call(arguments);

            if (typeof(arguments[0]) !== 'object') {
                arguments.unshift({});
            }

            if (arguments[0].uri === undefined) {
                arguments[0].uri = nwolbUrl;
            } else {
                if (arguments[0].uri.indexOf(nwolbUrl) === -1) {
                    arguments[0].uri = nwolbUrl + '/' + arguments[0].uri
                }
            }

            return arguments;
        }

        return {
            get: function() {
                //console.log("Natwest Get - " + arguments[0].uri)
                return request.get.apply(this, parse(arguments));
            },
            post: function() {
                //console.log("Natwest Post - " + arguments[0].uri)
                return request.post.apply(this, parse(arguments));
            }
        }
    },

    nwolb: {
        login: function (error, r, login) {
            console.log("Getting Natwest Login Requirements")
            if (!error && r.statusCode == 200) {
                Natwest.site().get(
                    {
                      uri: $('frame', login).first().attr('src'),
                    },
                    Natwest.nwolb.enter_customer_details
                );
            }
        },

        enter_customer_details: function (error, r, enter_customer_number) {
            console.log("Entering Customer Details")
            console.log(Natwest.loginDetails)
            if (!error && r.statusCode == 200) {
                var form = $('form:first', enter_customer_number);

                Natwest.site().post(
                    {
                        uri: form.attr('action'),
                        form: form
                            .find('input:text')
                                .val(Natwest.loginDetails.custNumber)
                                .end()
                            .serializeJSON()
                    },
                    Natwest.nwolb.enter_pin_and_password
                );
            }
        },

        enter_pin_and_password: function (error, r, enter_pin_and_password) {
            console.log("Entering Pin and Password Securely")
            if (!error && r.statusCode == 200) {
                var form = $('form:first', enter_pin_and_password);

                form.each(function() {
                    var a2f = 'ABCDEF'.split('');

                    for (var i = 0; i < a2f.length; i++) {
                        var input = $('input[name="ctl00$mainContent$Tab1$LI6PPE' + a2f[i] + '_edit"]', form);
                        var label = $('label[for="' + input.attr('id') + '"]', form);

                        var digit = label.text().replace(/[^\d]/g, '') - 1;

                        if (i < a2f.length / 2) {
                            input.val(Natwest.loginDetails.pin[digit]);
                        } else {
                            input.val(Natwest.loginDetails.pass[digit]);
                        }
                    }
                });

                Natwest.site().post(
                    {
                        uri: form.attr('action'),
                        form: form.serializeJSON()
                    },
                    Natwest.nwolb.logged_in
                );
            }
        },

        logged_in: function (error, r, logged_in) {
            if (!error && r.statusCode == 200) {
                console.log("Logged in")
                Natwest.nwolb.download_specific_dates_page();
            }
        },

        download_specific_dates_page: function () {
            console.log("Navigating to Download Specific Statements Dates Page")
            // "StatementsDownloadSpecificDates.aspx?NavFrom=SpecificDates&StartDate=22%2f03%2f2012&EndDate=21%2f04%2f2012&DownLoadTo=1&Acounts=1"
            // Set series of dates logic here!
            // End Date = todays date
            // Start Date = some date in the past up to 1 year + 1 day from End Date

            var todaysDate = new Date();
            var endDay = todaysDate.getDate();
            var endMonth = todaysDate.getMonth();
            var endYear = todaysDate.getFullYear();

            var startDay = todaysDate.getDate() + 1;
            var startMonth = todaysDate.getMonth();
            var startYear = todaysDate.getFullYear() - 1;

            //for (var i = todaysDate.getFullYear(); i > todaysDate.getFullYear() - 1; i--)
            //{
                var startDate = startDay + "%2f" + startMonth + "%2f" + startYear;
                var endDate = endDay + "%2f" + endMonth + "%2f" + endYear;

                var urlWithDates = "StatementsDownloadSpecificDates.aspx?NavFrom=SpecificDates&StartDate=" +
                            startDate + "&EndDate=" +
                            endDate + "&DownLoadTo=1&Acounts=-1"
                console.log(" - Getting range of transactions from: " + startDate + " to: " + endDate)
                Natwest.site().post(
                    {
                        uri: urlWithDates
                    },                
                    Natwest.nwolb.download_csv_form_page
                );

                endYear = endYear -1;
                startYear = startYear -1;

                ///sadasdasd
                var startDate = startDay + "%2f" + startMonth + "%2f" + startYear;
                var endDate = endDay + "%2f" + endMonth + "%2f" + endYear;

                var urlWithDates = "StatementsDownloadSpecificDates.aspx?NavFrom=SpecificDates&StartDate=" +
                            startDate + "&EndDate=" +
                            endDate + "&DownLoadTo=1&Acounts=-1"
                console.log(" - Getting range of transactions from: " + startDate + " to: " + endDate)
                Natwest.site().post(
                    {
                        uri: urlWithDates
                    },                
                    Natwest.nwolb.download_csv_form_page
                );
            //}
        },


        download_csv_form_page: function (error, r, download_csv_form) {
            console.log("Navigating to Download CSV page")
            if (!error && r.statusCode == 200) {
                var form = $('form:first', download_csv_form);
                var formJson = form.serializeJSON();
                //formJson['SelectAllChecked_SS8CBIB'] = 'on'

                Natwest.site().post(
                    {
                        uri: form.attr('action'),
                        form: formJson
                    },
                    Natwest.nwolb.download_csv
                );
            }
        },

        download_csv: function (error, r, download_csv_page) {
            console.log("Attempting to download CSV file")
            if (!error && r.statusCode == 200) {
                var form = $('form:first', download_csv_page);
                var formJson = form.serializeJSON();
                formJson['ctl00$mainContent$SS7-LWLA_button_button'] = 'Download transactions'

                Natwest.site().post(
                    {
                        uri: form.attr('action'),
                        form: formJson
                    },
                    Natwest.nwolb.completed_csv_download
                );
            }
        },

        completed_csv_download: function (error, r, completed_csv) {
            console.log("*********************************************************************Finished downloading CSV details!")
            //console.log(completed_csv);
            if (!error && r.statusCode == 200) {
                Meteor.bindEnvironment(parseCsvImport(completed_csv));
            }
        }
    }
}

$.fn.serializeJSON = function() {
    var json = {};

    $.map($(this).serializeArray(), function(n, i) {
        json[n['name']] = n['value'];
    });

    return json;
};

