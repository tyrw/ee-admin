'use strict'

angular.module('app.core').controller 'productsCtrl', (eeDefiner, eeProducts, eeTaxonomies) ->

  products = this

  products.ee   = eeDefiner.exports
  products.data = eeProducts.data
  products.fns  = eeProducts.fns
  products.hideHidden = true

  eeProducts.fns.runSection 'search'

  products.taxonomyData = eeTaxonomies.data
  eeTaxonomies.fns.search()

  return
