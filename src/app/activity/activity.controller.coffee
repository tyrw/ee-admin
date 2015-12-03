'use strict'

angular.module('app.core').controller 'activityCtrl', ($rootScope) ->

  activity = this

  Keen.ready () ->

    # DAILY ACTIVE SELLERS
    das = new Keen.Query 'count_unique', {
      eventCollection: 'builder',
      interval: 'daily'
      targetProperty: 'user',
      groupBy: 'user',
      timeframe: 'this_30_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw das, document.getElementById('das'), {
      title: 'Daily Active Sellers',
      chartType: 'columnchart',
      chartOptions:
        isStacked: true
        legend:
          position: 'none'
        titleTextStyle:
          fontSize: 16
          bold: false
    }

    # MOST ACTIVE SELLERS
    active_sellers = new Keen.Query 'count', {
      eventCollection: 'builder',
      groupBy: 'user',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw active_sellers, document.getElementById('active_sellers'), {
      title: '14-day Visits',
      chartType: 'piechart',
      chartOptions:
        legend: position: 'none'
        chartArea: width: '100%'
        titleTextStyle:
          fontSize: 16
          bold: false
    }

    # DAILY ACTIVE CUSTOMERS
    dac = new Keen.Query 'count_unique', {
      eventCollection: 'store',
      filters: [{
        operator: 'eq',
        property_name: 'self',
        property_value: false
      },{
        operator: 'exists'
        property_name: 'host',
        property_value: true
      }],
      interval: 'daily'
      targetProperty: '_ee',
      groupBy: 'host',
      timeframe: 'this_30_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw dac, document.getElementById('dac'), {
      title: 'Daily Active Customers (by store)'
      chartType: 'columnchart'
      chartOptions:
        isStacked: true
        legend: position: 'none'
        titleTextStyle:
          fontSize: 16
          bold: false
    }

    # TOP PERFORMERS
    top_performers = new Keen.Query 'count_unique', {
      eventCollection: 'store',
      filters: [{
        operator: 'eq',
        property_name: 'self',
        property_value: false
      },{
        operator: 'exists'
        property_name: 'host',
        property_value: true
      }],
      groupBy: 'host',
      targetProperty: 'user',
      timeframe: 'this_14_days',
      timezone: 'US/Pacific'
    }
    $rootScope.keenio.draw top_performers, document.getElementById('top_performers'), {
      title: '14-day Performers',
      chartType: 'piechart',
      chartOptions:
        legend: position: 'none'
        chartArea: width: '100%'
        titleTextStyle:
          fontSize: 16
          bold: false
    }


  return
