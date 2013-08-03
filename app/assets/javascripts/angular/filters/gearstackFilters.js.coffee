angular.module('gearstackFilters', []).filter 'prettyStatus', () ->
    (input) ->
        # console.log input
        # if input == 'onloan'
        #     'on loan'
        # if input == 'checkedout'
        #     'checked out'
        # if input == 'checkedin'
        #     'checked in'
        # else
        #     console.log 'error formatting pretty status!'
        switch input
            when 'onloan' then 'on loan'
            when 'checkedin' then 'checked in'
            when 'checkedout' then 'checked out'
            else console.log 'error formatting pretty status!'