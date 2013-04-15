Meteor.startup ->

    Template.transactions_view.rendered = ->
        $('#tranGrid').datagrid({ 
            dataSource: new TransactionDataSource(),
            rowTemplate: (data, columns, rowHtml) ->
                $.each data, (index, row) ->
                    rowHtml += '<tr data-collapse>'
                    $.each columns, (index, column) ->
                        rowHtml += '<td>' + row[column.property] + '</td>'
                    rowHtml += '<div>A section here!</div>'
                    rowHtml += '</tr>'
                return rowHtml
        }).on('loaded', ->            
            highlightValues()
            highlightUntagged()
            enableExpander()
        )
        highlightValues()
        highlightUntagged()
        enableExpander()

    TransactionDataSource = ->
        _data: []
        _formatter: (items) ->
            $.each items, (index, item) ->
                if (item.tags != null)
                    item.description_tagging = item.description
                else
                    item.description_tagging =
                        Template.transaction_description
                                desc: " " + item.description

        columns: ->
            [
                {
                    property: 'date',
                    label: 'Date',
                    sortable: true
                },                
                {
                    property: 'transaction_type',
                    label: 'Type',
                    sortable: true
                },                
                {
                    property: 'description_tagging',
                    label: 'Description',
                    sortable: true
                },             
                {
                    property: 'value',
                    label: 'Amount (£)',
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
                    }
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
              data.reverse() if options.sortDirection is "desc"

            # PAGING
            options.pageSize = 25;
            startIndex = options.pageIndex * options.pageSize
            endIndex = startIndex + options.pageSize
            end = (if (endIndex > count) then count else endIndex)
            pages = Math.ceil(count / options.pageSize)
            page = options.pageIndex + 1
            start = startIndex + 1
            data = data.slice(startIndex, endIndex)

            this._formatter data if this._formatter

            callback
              data: data
              start: start
              end: end
              count: count
              pages: pages
              page: page

    DataRowTemplate = (data, columns, rowHtml) ->
        $.each data, (index, row) ->
            rowHtml += '<tr>'
            $.each columns, (index, column) ->
                rowHtml += '<td>' + row[column.property] + '</td>'
            rowHtml += '</tr>'


    highlightValues = ->
        $("td").each ->            
          cellvalue = $(this).html()
          return if isNaN cellvalue
          return $(this).addClass "neg" if cellvalue.substring(0, 1) is "-"
          return $(this).addClass "pos"

    highlightUntagged = ->
        $(".untagged").each ->
          $(this).parent().parent().addClass "error"
          $(this).parent().parent().parent().data("data-collapse", "accordion")

    enableExpander = ->
        ###new jQueryCollapse(
            $(".tranGrid"), 
            {
                query: 'tbody tr'
            })###
