"use strict"

imageResize = ->

  STANDARD_WIDTH = 1371
  STANDARD_HEIGHT = 850 

  com.ee.appWidth =  Math.max( $('.work-holder').width(), STANDARD_WIDTH )
  com.ee.appHeight = Math.max( $('.work-holder').height(), STANDARD_HEIGHT)

  #find out who is off the largest
  wDiff = com.ee.appWidth - STANDARD_WIDTH
  hDiff = com.ee.appHeight - STANDARD_HEIGHT

  if wDiff >= hDiff
    $(".project-img").height( '' )
    $(".project-img").width( Math.max(com.ee.appWidth, STANDARD_WIDTH) )
  else
    $(".project-img").width('')
    $(".project-img").height( Math.max(com.ee.appHeight, STANDARD_HEIGHT) )

  null

$(window).bind 'resize', ->
  imageResize()


$(document).ready ->

  setTimeout =>
    imageResize()
  , 50
