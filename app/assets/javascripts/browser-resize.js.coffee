#browser_resize
console.log "browser_resize"

imageResize = (className)->
  
  className = ".project-img" if !className?

  STANDARD_WIDTH = 1371
  STANDARD_HEIGHT = 850 

  com.ee.appWidth =  Math.max( $('.work-holder').width(), STANDARD_WIDTH )
  com.ee.appHeight = Math.max( $('.work-holder').height(), STANDARD_HEIGHT)

  console.log "w: #{com.ee.appWidth}, h: #{com.ee.appHeight}"

  #find out who is off the largest
  wDiff = com.ee.appWidth - STANDARD_WIDTH
  hDiff = com.ee.appHeight - STANDARD_HEIGHT
  
  console.log "className #{className}"
  com.ee.snapTo = if wDiff >= hDiff then "w" else "h"

  if wDiff >= hDiff
    $(className).height( '' )
    $(className).width( Math.max(com.ee.appWidth, STANDARD_WIDTH) )
  else
    $(className).width('')
    $(className).height( Math.max(com.ee.appHeight, STANDARD_HEIGHT) )

  null

window.imageResize = imageResize
