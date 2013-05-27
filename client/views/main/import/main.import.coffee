Meteor.startup ->

    Template.import_data.events
        "click .import": (e, tmpl) -> 
            e.preventDefault()
            e.stopPropagation()           
            importNatwestCsvData({});

    importNatwestCsvData = (options) ->
        # Need validation logic thenn encrypt
        loginDetails = 
            custNumber: trimmedElementValueById("cust-number")
            pin: trimmedElementValueById("cust-pin")
            pass: trimmedElementValueById("cust-pass")

        Meteor.call('importNatwestData', loginDetails)

    trimmedElementValueById = (id) ->
        element = document.getElementById(id)
        unless element
            null
        else # trim;
            element.value.replace /^\s*|\s*$/g, ""


        #natwest.getAllData();
###
    natwest =
        getAllData: ->
            this.get
                uri: undefined,
                this.login_page

        nwolb: 'https://www.nwolb.com'

        parse: (arguments_) ->
            arguments_ = Array::slice.call(arguments_)
            arguments_.unshift {}  if typeof (arguments_[0]) isnt "object"
            if arguments_[0].uri is `undefined`
                arguments_[0].uri = this.nwolb
            else
                arguments_[0].uri = this.nwolb + "/" + arguments_[0].uri  if arguments_[0].uri.indexOf(this.nwolb) is -1
            arguments_

        get: ->    
            console.log("Natwest Get - " + arguments[0].uri)
            args = this.parse(arguments);
            $.get(args[0].uri, this.login_page)

        post: ->    
            console.log("Natwest Post - " + arguments[0].uri)
            $.post.apply this, this.parse(arguments)

        login_page: (data, textStatus, jqXHR) ->
          console.log "Getting Natwest Login Requirements - login page"
          if not error and r.statusCode is 200
            natwest.get
              uri: $("frame", login).first().attr("src")
            , this.enter_customer_details

        login: (error, r, login) ->
          console.log "Getting Natwest Login Requirements"
          if not error and r.statusCode is 200
            natwest.get
              uri: $("frame", login).first().attr("src")
            , this.enter_customer_details

        enter_customer_details: (error, r, enter_customer_number) ->
          console.log "Entering Customer Details"
          if not error and r.statusCode is 200
            form = $("form:first", enter_customer_number)
            natwest.post
              uri: form.attr("action")
              form: form.find("input:text").val(account.customer_number).end().serializeJSON()
            , this.enter_pin_and_password

        enter_pin_and_password: (error, r, enter_pin_and_password) ->
          console.log "Entering Pin and Password Securely"
          if not error and r.statusCode is 200
            form = $("form:first", enter_pin_and_password)
            form.each ->
              a2f = "ABCDEF".split("")
              i = 0

              while i < a2f.length
                input = $("input[name=\"ctl00$mainContent$Tab1$LI6PPE" + a2f[i] + "_edit\"]", form)
                label = $("label[for=\"" + input.attr("id") + "\"]", form)
                digit = label.text().replace(/[^\d]/g, "") - 1
                if i < a2f.length / 2
                  input.val account.pin[digit]
                else
                  input.val account.password[digit]
                i++

            natwest.post
              uri: form.attr("action")
              form: form.serializeJSON()
            , this.logged_in

        logged_in: (error, r, logged_in) ->
          if not error and r.statusCode is 200
            console.log "Logged in"
            this.download_specific_dates_page()

        download_specific_dates_page: ->
          console.log "Navigating to Download Specific Statements Dates Page"
          
          # "StatementsDownloadSpecificDates.aspx?NavFrom=SpecificDates&StartDate=22%2f03%2f2012&EndDate=21%2f04%2f2012&DownLoadTo=1&Acounts=1"
          # Set series of dates logic here!
          # End Date = todays date
          # Start Date = some date in the past up to 1 year + 1 day from End Date
          todaysDate = new Date()
          endDay = todaysDate.getDate()
          endMonth = todaysDate.getMonth()
          endYear = todaysDate.getFullYear()
          startDay = todaysDate.getDate() + 1
          startMonth = todaysDate.getMonth()
          startYear = todaysDate.getFullYear() - 1
          i = todaysDate.getFullYear()

          while i > todaysDate.getFullYear() - 8
            startDate = startDay + "%2f" + startMonth + "%2f" + startYear
            endDate = endDay + "%2f" + endMonth + "%2f" + endYear
            urlWithDates = "StatementsDownloadSpecificDates.aspx?NavFrom=SpecificDates&StartDate=" + startDate + "&EndDate=" + endDate + "&DownLoadTo=1&Acounts=-1"
            natwest.post
              uri: urlWithDates
            , this.test_add_param(" - Getting range of transactions from: " + startDate + " to: " + endDate)
            endYear = endYear - 1
            startYear = startYear - 1
            i--

        test_add_param: (junktext) ->
          console.log junktext
          this.download_csv_form_page

        download_csv_form_page: (error, r, download_csv_form) ->
          console.log "Navigating to Download CSV page"
          
          #SelectAllChecked_SS8CBIB:on
          if not error and r.statusCode is 200
            form = $("form:first", download_csv_form)
            formJson = form.serializeJSON()
            
            #formJson['SelectAllChecked_SS8CBIB'] = 'on'
            natwest.post
              uri: form.attr("action")
              form: formJson
            , this.download_csv

        download_csv: (error, r, download_csv_page) ->
          console.log "Attempting to download CSV file"
          if not error and r.statusCode is 200
            form = $("form:first", download_csv_page)
            formJson = form.serializeJSON()
            formJson["ctl00$mainContent$SS7-LWLA_button_button"] = "Download transactions"
            natwest.post
              uri: form.attr("action")
              form: formJson
            , this.completed_csv_download

        completed_csv_download: (error, r, completed_csv) ->
          console.log "Finished downloading CSV details!"
          console.log completed_csv
          not error and r.statusCode is 200

    $.fn.serializeJSON = ->
        json = {}
        $.map $(this).serializeArray(), (n, i) ->
          json[n["name"]] = n["value"]

        json
###