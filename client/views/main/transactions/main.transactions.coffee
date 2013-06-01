Meteor.startup ->

    Template.transactions_view.rendered = ->
        $('#tranGrid').datagrid({ 
            dataSource: new TransactionDataSource(),
            rowTemplate: (data, columns, rowHtml) ->
                $.each data, (index, row) ->
                    rowHtml += '<tr class="master" data-master="' + index + '">'
                    $.each columns, (index, column) ->
                        rowHtml += '<td>' + row[column.property] + '</td>'
                    rowHtml += '</tr>'                    
                    rowHtml += '<tr id="detail' + index + '" class="hide-detail">
                        <td colspan="5"><div>' + row.description_tagging + '</div></td>
                        </tr>'
                return rowHtml
        }).on('loaded', ->            
            highlightValues()
            highlightUntagged()
            setupMasterDetail()
            triggerFirstRowDetail()
        )
        highlightValues()
        highlightUntagged()
        setupMasterDetail()
        triggerFirstRowDetail()

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
                    },
                    {
                        sort: { date: -1 }
                    }
                );
                this._data = cursor.map (item) ->
                    item.date = item.date.toDateString()
                    item
                #_.sortBy(this._data, )
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

    showDetails = (id) ->
        $(".show-detail").each ->
          $(this).removeClass("show-detail")
          $(this).addClass("hide-detail")
        $(id).removeClass("hide-detail").addClass("show-detail")

    setupMasterDetail = ->
        $(".master").on "click", ->
            num = $(this).data("master")
            showDetails("#detail" + num)

    triggerFirstRowDetail = ->
        $(".master").first().trigger('click')

