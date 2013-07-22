angular.module('gearstackFilters', []).filter 'prettyStatus', () ->
    (input) ->
        if input = 'checkedin'
            return 'checked in'
        if input = 'checkedout'
            return 'checked out'
        else
            console.log 'error formatting pretty status!'