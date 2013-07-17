# custom directive for verifying floats
# necessary because different browsers behave inconsistently when validating Number fields - Chrome, for example, doesn't expose the value of the field if it doesn't validate, so Angular doesn't see that it's a bad value
# borrowed and modified from Angular guide: http://docs.angularjs.org/guide/forms


FLOAT_REGEXP = /^(\-?\d+((\.|\,)\d+)?)?$/
App.directive 'smartFloat', ->
    require: 'ngModel'
    link: (scope, elm, attrs, ctrl) ->
        ctrl.$parsers.unshift (viewValue) ->
            if FLOAT_REGEXP.test(viewValue)
                ctrl.$setValidity 'float', true
                parseFloat viewValue.replace(',', '.')
            else
                ctrl.$setValidity 'float', false
                undefined
