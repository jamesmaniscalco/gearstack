gearstackFilters = angular.module('gearstackFilters', [])

gearstackFilters.filter 'prettyStatus', () ->
    (input) ->
        switch input
            when 'onloan' then 'on loan'
            when 'checkedin' then 'checked in'
            when 'checkedout' then 'checked out'
            else console.log 'error formatting pretty status: ', input

gearstackFilters.filter 'titleCase', () ->
    (input) ->
        wordsIn = input.split(' ');
        wordsOut = []
        for word in wordsIn
            word = word[0].toUpperCase() + word[1..-1];
            wordsOut.push word
        return wordsOut.join(' ');