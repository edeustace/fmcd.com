#browser_resize
console.log "browser_resize"

imageResize = ->
  newWidth = $('.work-holder').width()
  finalWidth = if newWidth < 1371 then 1371 else newWidth
  com.ee.appWidth = finalWidth

  console.log "setting width to: #{finalWidth}"
  $(".project-img").width( finalWidth )

  null

$(window).bind 'resize', ->
  imageResize()


$(document).ready ->

  setTimeout =>
    imageResize()
  , 50
