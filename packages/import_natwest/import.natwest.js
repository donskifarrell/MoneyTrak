var $ = Npm.require('jquery');
var Future = Npm.require('fibers/future');
var Moment = Npm.require('moment');

Natwest = {
    nwolbUrl: 'https://www.nwolb.com/',

    loginDetails: {
        custNumber: undefined,
        pin: undefined,
        pass: undefined,
    },

    getAllData: function() {
        if (this.loginDetails.custNumber && 
            this.loginDetails.pin && 
            this.loginDetails.pass) {
                var Request = Npm.require('request').defaults({
                    headers: {
                        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/5XX.XX (KHTML, like Gecko) Chrome'
                    },
                    followAllRedirects: true
                });
                
                var requestStore = this.loginNatwest(Request);
                return this.getNatwestTransactions(requestStore);
        } else {
            console.log("No Login Details entered for Natwest login")
            return false;
        }
    },

    loginNatwest: function(Request) {
        /* login Page: */        
        var login_future = new Future();
        console.log("Requesting URL: " + this.nwolbUrl);
        Request.get(
                this.nwolbUrl, 
                function(error, r, page){
                    if (error || r.statusCode != 200) {
                        console.log("Unable to get Natwest login page: " + error);
                        return;
                    }
                    //console.log("!!!!!!!!!!!! Login Page " + page);
                    login_future.ret(page);
                });
        login_future.wait();

        /* Customer Details login Page: */
        var login_ref_url = $('frame', login_future.value).first().attr('src')
        var cust_detail_future = new Future();
        console.log("Requesting URL: " + this.nwolbUrl + login_ref_url);
        Request.get(
                this.nwolbUrl + login_ref_url, 
                function(error, r, page){
                    if (error || r.statusCode != 200) {
                        console.log("Unable to get customer details login page: " + error);
                        return;
                    }
                    //console.log("!!!!!!!!!!!! Cust Login Page " + page);
                    cust_detail_future.ret(page);
                });
        cust_detail_future.wait();

        /* customer pin and password details login Page: */
        var cust_details_form = $('form:first', cust_detail_future.value)
                                    .find('input:text')
                                    .val(Natwest.loginDetails.custNumber)
                                    .end();
        var cust_pin_pass_future = new Future();
        console.log("Requesting URL: " + this.nwolbUrl + cust_details_form.attr('action'));
        Request.post(
                {                     
                    uri: this.nwolbUrl + cust_details_form.attr('action'),
                    form: cust_details_form.serializeJSON()
                }, 
                function(error, r, page){
                    if (error || r.statusCode != 200) {
                        console.log("Unable to get customer pin and password details login page: " + error);
                        return;
                    }
                    //console.log("!!!!!!!!!!!! CustPin Pass apge: " + page);
                    cust_pin_pass_future.ret(page);
                });
        cust_pin_pass_future.wait();

        /* account summary logged in page Page: */
        var cust_pin_and_pass_form = $('form:first', cust_pin_pass_future.value);
        cust_pin_and_pass_form.each(function() {
            var a2f = 'ABCDEF'.split('');

            for (var i = 0; i < a2f.length; i++) {
                var input = $('input[name="ctl00$mainContent$Tab1$LI6PPE' + a2f[i] + '_edit"]', cust_pin_and_pass_form);
                var label = $('label[for="' + input.attr('id') + '"]', cust_pin_and_pass_form);

                var digit = label.text().replace(/[^\d]/g, '') - 1;

                if (i < a2f.length / 2) {
                    input.val(Natwest.loginDetails.pin[digit]);
                } else {
                    input.val(Natwest.loginDetails.pass[digit]);
                }
            }
        });
        var account_summary_future = new Future();
        console.log("Requesting URL: " + this.nwolbUrl + cust_pin_and_pass_form.attr('action'));
        Request.post(
                {
                    uri: this.nwolbUrl + cust_pin_and_pass_form.attr('action'), 
                    form: cust_pin_and_pass_form.serializeJSON()
                },                
                function(error, r, page){
                    if (error || r.statusCode != 200) {
                        console.log("Unable to get account summary logged in page: " + error);
                        return;
                    }
                    //console.log("!!!!!!!!!!!! Account Summary Page: " + page);
                    account_summary_future.ret(page);
                });
        account_summary_future.wait();

        console.log("Natwest Login All Done");

        return Request;
    },

    getNatwestTransactions: function(Request) {
        var urls = this.generateSpecificDateUrls();
        //var urls = ['StatementsDownloadSpecificDates.aspx?NavFrom=SpecificDates&StartDate=01%2f01%2f13&EndDate=31%2f05%2f13&DownLoadTo=1&Acounts=-1'];
        var nwolbUrl = this.nwolbUrl;

        var transaction_data_dl_futures = _.map(urls, function(url) {
            console.log("URL: " + nwolbUrl + url);
            /* Specific Date selection Page: */
            var specific_date_future = new Future();
            Request.post(
                {
                    uri: nwolbUrl + url
                },
                function(error, r, page){
                    if (error || r.statusCode != 200) {
                        console.log("Unable to get Specific Date selection page: " + error);
                        return;
                    }
                    //console.log("!!!!!!!!!!!! specific_date Page: " + page);
                    specific_date_future.ret(page);
                });
            specific_date_future.wait();

            /* Download Csv Page: */
            var download_csv_form = $('form:first', specific_date_future.value)
            var download_csv_json_form = download_csv_form.serializeJSON();
            var download_csv_future = new Future();

            Request.post(
                {
                    uri: nwolbUrl + download_csv_form.attr('action'),
                    form: download_csv_json_form
                },
                function(error, r, page){
                    if (error || r.statusCode != 200) {
                        console.log("Unable to get download csv page: " + error);
                        return;
                    }
                    //console.log("!!!!!!!!!!!! download_csv_future Page: " + page);
                    download_csv_future.ret(page);
                });
            download_csv_future.wait();

            /* Attempt Download Csv Page: */
            var click_download_csv_form = $('form:first', download_csv_future.value)
            var click_download_csv_json_form = click_download_csv_form.serializeJSON();
            click_download_csv_json_form['ctl00$mainContent$SS7-LWLA_button_button'] = 'Download transactions'
            var click_download_csv_future = new Future();
            Request.post(
                {
                    uri: nwolbUrl + click_download_csv_form.attr('action'),
                    form: click_download_csv_json_form
                },
                function(error, r, csv_page){
                    if (error || r.statusCode != 200) {
                        console.log("Unable to download csv data: " + error);
                        return;
                    }
                    //console.log("!!!!!!!!!!!! click_download_csv Page: " + csv_page);
                    click_download_csv_future.ret(csv_page);
                });

            return click_download_csv_future;
        });

        Future.wait(transaction_data_dl_futures);

        console.log("!!!!!!!!!!!! All futures done");
        return _.invoke(transaction_data_dl_futures, 'get');
    },

    // End Date = todays date
    // Start Date = some date in the past up to 1 year + 1 day from End Date
    // Earliest Start Date is 01/01/2006
    generateSpecificDateUrls: function() {
        var urls = []
        var endDate = Moment();
        var startDate = endDate.clone().startOf('year');

        while (startDate.isAfter('2005-12-31'))
        {
            urls.push("StatementsDownloadSpecificDates.aspx?NavFrom=SpecificDates&StartDate=" +
                        startDate.format("DD%2fMM%2fYY") + "&EndDate=" + 
                        endDate.format("DD%2fMM%2fYY") + "&DownLoadTo=1&Acounts=-1");

            endDate = startDate.clone().subtract('days', 1);
            startDate = endDate.clone().startOf('year');
        }

        return urls;
    }
}

$.fn.serializeJSON = function() {
    var json = {};

    $.map($(this).serializeArray(), function(n, i) {
        json[n['name']] = n['value'];
    });

    return json;
};

