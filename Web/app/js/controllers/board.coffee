﻿queensEight.factory "SolutionService", ->
  solutions: $.connection.solutionHub.server.fetchSolutions()

queensEight.controller "GameController", ['$scope', ($scope) ->
  $scope.solutionUnavailable = false
  solutionsHub = $.connection.solutionsHub
  solutionsHub.client.solutionAvailable = (serializedSolution) ->
    solution = JSON.parse(serializedSolution)
    if( solution.positions.length == 0 )
      if( $scope.activeSolutions[0].requestHash == solution.requestHash )
        $scope.solutionUnavailable = true
        $scope.$apply()
    else
      $scope.solutions.push solution
      if( $scope.activeSolutions[0].requestHash == solution.requestHash )
        $scope.solutionUnavailable = false
        $scope.activeSolutions[0].positions = solution.positions
        $scope.activeSolutions[0].hash = solution.hash
      $scope.$apply()

  $scope.clearErrors = ->
    $scope.solutionUnavailable = false

  $.connection.hub.start().done ->
    $.connection.solutionsHub.server.fetchSolutions().done (solutionsJson) ->
      $scope.solutions = JSON.parse solutionsJson
      $scope.activeSolutions = []
      solution = {}
      solution.positions = []
      $scope.activeSolutions.push solution

      $scope.$apply()
]

queensEight.controller "SolutionsController", ['$scope', ($scope) ->
]

queensEight.controller "BoardController", ['$scope', ($scope) ->
  $scope.solution ||= {}
  $scope.solution.positions ||= []

  $scope.rowIndicies = [0..7]
  $scope.columnIndicies = [0..7]
  
  $scope.toggleQueen = (row, column) ->
    return unless $scope.isInteractive
    position = { row: row, column: column }
    $scope.$parent.$parent.clearErrors()
    if ($scope.hasQueen(row, column))
      $scope.$apply ->
        positions = $scope.solution.positions
        existingPosition = _(positions).find (p)->
          p.row == position.row and p.column == position.column
        positions.splice(positions.indexOf(existingPosition), 1)
    else
      $scope.$apply -> $scope.solution.positions.push(position)

  $scope.hasQueen = (row, column) ->
    return _($scope.solution.positions).any (position) ->
      position.row == row and position.column == column

  $scope.requestSolution = ->
    hash = queensEight.hashFromPositions $scope.solution.positions
    $scope.solution.requestHash = hash
    $.connection.solutionsHub.server.requestSolution($scope.solution)

  $scope.clearBoard = ->
    $scope.solution.hash = ''
    $scope.solution.positions = []
    $scope.$parent.$parent.clearErrors()
]

