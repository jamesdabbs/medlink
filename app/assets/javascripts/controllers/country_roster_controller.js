angular.module("medlink", []).

controller("countryRosterController", ["$scope", "$http", function($scope, $http) {
    $scope.filter = ""

    $scope.toggleSort = function(field) {
        if ($scope.sort === field) {
            $scope.reverse = !$scope.reverse
        } else {
            $scope.sort    = field
            $scope.reverse = false
        }
    }

    $scope.toggleSort("last_name")

    $http.get("/api/v1/users").success(function(data) {
        $scope.users = data.users
    })
}]).

// TODO: move this
controller("responseTrackerController", ["$scope", "$http", function($scope, $http) {
    $scope.textFilter = ""

    $scope.toggleSort = function(field) {
        if ($scope.sort === field) {
            $scope.reverse = !$scope.reverse
        } else {
            $scope.sort    = field
            $scope.reverse = false
        }
    }

    $scope.toggleSort("last_name")

    $scope.select = function(label) {
        console.log(label, self)
    }

    $http.get("/api/v1/responses").success(function(data) {
        $scope.responses = data.responses
    })
}])
