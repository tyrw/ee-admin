'use strict'

angular.module('users').config ($stateProvider) ->

  views =
    header:
      controller: 'usersCtrl as users'
      templateUrl: 'app/users/users.header.html'
    top:
      controller: 'usersCtrl as users'
      templateUrl: 'app/users/users.html'

  data =
    pageTitle:        'Users'
    padTop:           '100px'

  $stateProvider
    .state 'users',
      url:   '/users'
      views: views
      data:  data
    .state 'users.info',
      url:    '/info'
      views:  views
    .state 'users.social',
      url:    '/social'
      views:  views
    .state 'users.branding',
      url:    '/branding'
      views:  views
    .state 'users.activity',
      url:    '/activity'
      views:  views
    .state 'user',
      url: '/users/:id'
      views:
        header:
          # controller: 'userCtrl as user'
          templateUrl: 'app/users/users.header.html'
        top:
          controller: 'userCtrl as user'
          templateUrl: 'app/users/user.html'
      data:
        pageTitle: 'User details'
        padTop:    '100px'

  return
