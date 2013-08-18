// directive for delaying model change until blur on input element
// from http://stackoverflow.com/a/15292977/866192

App.directive('modelChangeBlur', function() {
    return {
        restrict: 'A',
        require: 'ngModel',
            link: function(scope, elm, attr, ngModelCtrl) {
            if (attr.type === 'radio' || attr.type === 'checkbox') return;

            elm.unbind('input').unbind('keydown').unbind('change');
            elm.bind('blur', function() {
                scope.$apply(function() {
                    ngModelCtrl.$setViewValue(elm.val());
                });         
            });
        }
    };
});