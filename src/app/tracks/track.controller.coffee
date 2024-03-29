'use strict'

angular.module('tracks').controller 'trackCtrl', ($stateParams, eeDefiner, eeTrack, eeTracks, eeActivity, eeStep, eeModal) ->

  track = this

  track.id = parseInt $stateParams.id
  track.ee = eeDefiner.exports
  track.data = eeTrack.data
  track.modalFns = eeModal.fns

  eeTracks.fns.runSection()

  eeTrack.fns.get $stateParams.id
  .then (tr) -> track.data.track = tr

  track.toggleShow = (type, model) ->
    model.show = !model.show
    switch type
      when 'track'    then eeTrack.fns.update model
      when 'activity' then eeActivity.fns.update model
      when 'step'     then eeStep.fns.update model

  return
