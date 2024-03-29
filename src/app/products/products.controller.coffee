'use strict'

angular.module('app.core').controller 'productsCtrl', (eeDefiner, eeProducts, eeProcessing, eeTaxonomies, tagTree) ->

  products = this

  products.ee   = eeDefiner.exports
  products.data = eeProducts.data
  products.fns  = eeProducts.fns
  products.tagTree = tagTree
  products.showTagMap = true
  products.hideHidden = true

  eeProducts.fns.runSection 'search'

  products.taxonomyData = eeTaxonomies.data
  eeTaxonomies.fns.search()

  products.processingFns = eeProcessing.fns

  return
