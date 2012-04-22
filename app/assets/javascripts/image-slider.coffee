window.com = (window.com || {})
com.ee = (com.ee || {})


com.ee.mod = (a,b) -> ( (a % b) + b) % b


class @com.ee.ImageSlider

  constructor: (@parentDiv, @images ) ->
    console.log "ImageSlider"
    
    @imageIds = []
    
    @currentIndex = 0
    @_setMainPane @currentIndex
    #html = ""
    #for img_path, imageIndex in @images
    #  uid = "_image_slider_#{imageIndex}"
    #  html += """<img id="#{uid}" src="#{img_path}" class="project-img"/>"""
    #  @imageIds.push(uid)
    #
    #$(parentDiv).append html

  showPrevious: ->
    
    leftIndex = com.ee.mod @currentIndex - 1, @images.length
    @_buildPane(leftIndex, @currentIndex, 1)

    $(@parentDiv).find("#transition-pane").animate
      left: "0px"
    , 500,
      =>
      #, 1500,
        console.log "transition completed"
        @_setMainPane leftIndex
      #  @_setMainPane leftIndex
        @_removeTransitionPane()
      #  @_removeTransitionPane()
  
  showNext: ->

    rightIndex = com.ee.mod @currentIndex + 1, @images.length
    @_buildPane(@currentIndex, rightIndex, 0)
    #$(@parentDiv).find("#main-pane").css('visibility', 'hidden')

    $(@parentDiv).find("#transition-pane").animate
      left: "-#{com.ee.appWidth}px"
      leaveTransform: true
    , 500,
      =>
        console.log "transition completed"
        @_setMainPane rightIndex
        @_removeTransitionPane()
        


    
    null
  
  reset: ->
    null

  ###
  Private
  ###
  #
  
  _setMainPane: (index) ->
    @currentIndex= index
    imageIndex = com.ee.mod (index), @images.length

    $(@parentDiv).find("#main-pane").remove()

    html = """
    <span id="main-pane" style="opacity: 1">
    #{@_imgTag(imageIndex, @images[imageIndex])}
      </span>
    """
    $(@parentDiv).append(html)

  _buildPane: (leftIndex, mainIndex, whichIndexToShow) ->
    
    leftImage = @images[leftIndex]
    mainImage = @images[mainIndex]
    
    $(@parentDiv).remove("#transition-pane")

    position = if whichIndexToShow == 0 then 0 else com.ee.appWidth
    html = """
      <span id="transition-pane" 
            style="opacity: 1; position: absolute; top:0px; left: -#{position}px; float: left; width: #{com.ee.appWidth * 2}px">
        #{@_imgTag(leftIndex, leftImage)}#{@_imgTag(mainIndex, mainImage)}
      </span>
    """

    $(@parentDiv).append(html)



  _removeTransitionPane: -> $(@parentDiv).find("#transition-pane").remove()

  _imgTag: (index, path) -> 
    
    dimension = if com.ee.snapTo == "w" then "width: #{com.ee.appWidth}px" else "height: #{com.ee.appHeight}px"

    
    """<img 
      class='image-slider-images'
      style='#{dimension}'
      src='#{path}' 
      id='#{index}'/>"""
    
