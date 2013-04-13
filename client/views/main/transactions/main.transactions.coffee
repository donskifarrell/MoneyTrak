Meteor.startup ->

    Template.transactions_view.rendered = ->
        $('#tranGrid').datagrid({ 
            dataSource: new TransactionDataSource()
        }).on('loaded', ->            
            highlightValues()
        )
        highlightValues()

    TransactionDataSource = ->
        _data: []
        _formatter: (items) ->
            $.each items, (index, item) ->
                return

        columns: ->
            [
                {
                    property: 'date',
                    label: 'Date',
                    sortable: true
                },                
                {
                    property: 'transaction_type',
                    label: 'Transaction Type',
                    sortable: true
                },                
                {
                    property: 'description',
                    label: 'Description',
                    sortable: true
                },                
                {
                    property: 'value',
                    label: 'Transaction Amount (£)',
                    sortable: true
                },                
                {
                    property: 'balance',
                    label: 'Balance (£)',
                    sortable: true
                },
            ]

        data: (options, callback) ->
            if this._data.length == 0
                cursor = Transactions.find(
                    {
                        owner: Meteor.userId()
                    },
                    limit: 100
                )
                this._data = cursor.map (item) ->
                    item.date = item.date.toDateString()
                    item

            data = $.extend(true, [], this._data);

            # SEARCHING
            if options.search
              data = _.filter(data, (item) ->
                for prop of item
                  continue unless item.hasOwnProperty(prop)
                  continue unless item[prop] != undefined
                  continue unless item[prop] != null
                  return true if ~item[prop].toString()
                                            .toLowerCase()
                                            .indexOf(options.search.toLowerCase())
                false
              )

            count = data.length

            # SORTING
            if options.sortProperty
              data = _.sortBy(data, options.sortProperty)
              data.reverse()  if options.sortDirection is "desc"

            # PAGING
            options.pageSize = 25;
            startIndex = options.pageIndex * options.pageSize
            endIndex = startIndex + options.pageSize
            end = (if (endIndex > count) then count else endIndex)
            pages = Math.ceil(count / options.pageSize)
            page = options.pageIndex + 1
            start = startIndex + 1
            data = data.slice(startIndex, endIndex)

            # this._formatter data  if this._formatter

            callback
              data: data
              start: start
              end: end
              count: count
              pages: pages
              page: page

    highlightValues = ->
        $("td").each ->            
          cellvalue = $(this).html()
          return if isNaN cellvalue
          return $(this).addClass "neg" if cellvalue.substring(0, 1) is "-"
          return $(this).addClass "pos"
