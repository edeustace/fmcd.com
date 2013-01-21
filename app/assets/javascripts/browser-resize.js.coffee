"use strict"

window.com = ({} || com)
com.ee = ({} || com.ee )

class @com.ee.BoxConstraints
  constructor: (@minWidth, @minHeight) ->
    if @minWidth == @minHeight
      @ratio = 
        w: 1
        h: 1
    else if @minWidth > @minHeight
      @ratio =
        w: @minWidth/@minHeight
        h: 1
    else
      @ratio = 
        w: 1
        h: @minHeight/@minWidth

    #console.log "ratio: #{@ratio.w}:#{@ratio.h}"

  ###
  Given a w and h
  return which value needs to constrained and at what value
  ###
  constrain: (w,h) ->
    wDiff = w - @minWidth
    hDiff = h - @minHeight

    if wDiff < 0 && hDiff < 0
      return w: @minWidth

    wProjection = 
      w: w
      h: w/@ratio.w

    hProjection = 
      w: h*@ratio.w
      h: h

    if wProjection.w >= w && wProjection.h >= h
      return w: w, h: wProjection.h
    else
      return w: hProjection.w, h: h


STANDARD_WIDTH = 1371
STANDARD_HEIGHT = 850 
bc = new com.ee.BoxConstraints(STANDARD_WIDTH, STANDARD_HEIGHT)


#console.log bc.constrain 1462, 1026 
#console.log bc.constrain 1328, 859 

imageResize = ->

  com.ee.appWidth =  Math.max( $('.work-holder').width(), STANDARD_WIDTH )
  com.ee.appHeight = Math.max( $('.work-holder').height(), STANDARD_HEIGHT)

  constrainResult = bc.constrain( $('.work-holder').width(), $('.work-holder').height() )

  $(".project-img").height( constrainResult.h )
  $(".project-img").width( constrainResult.w )

  null

$(window).bind 'resize', ->
  imageResize()


$(document).ready ->


  #console.log bc.constrain 10, 10
  #console.log bc.constrain 20, 1
  #console.log bc.constrain 12, 20
  #console.log bc.constrain 9, 30
  #console.log bc.constrain 30, 9

  setTimeout =>
    imageResize()
  , 50
