###
A representation of a Project.
It slides up or down when being shown and the images within the project slide left or right.
###
class @com.ee.ProjectView

  constructor: (@projectData, @index, @slideshowInterval, @defaultBgColor, @leftArrow, @rightArrow) ->
    @titleId = "project-view-title"
    @slideshowInterval = @slideshowInterval || 3000
    @descriptionId = "project-view-description"
    @imageHolderId = "project-view-images"
    @imageIds = []
    @$navHolder = $("#project-view-navigation-holder")
    @isSlideshowEnabled = false
    @contentUid = "project__#{@index}"
    @isTintEnabled = true

    @timeoutUids = []

    if @projectData.uid?
      @isTintEnabled = false

    if @projectData.contentUid?
      @contentUid = @projectData.contentUid
      @$holder().addClass('hidden')
    else
      imgHtml = ""
      for img_path, imgIndex in @projectData.images
        imageUid = """_project_#{@index}_img_#{imgIndex}"""
        imgHtml += """<img id="#{imageUid}" src="#{img_path}" class="project-img"/>"""
        @imageIds.push(imageUid)
   

      $("##{@imageHolderId}").append """<div id='#{@contentUid}' 
          class="project-holder hidden south">
          #{imgHtml}
        </div>"""

      @currentIndex = -1
      @setCurrentImage 0

  ###
  Start the slideshow if there are more than one images to show
  ###
  beginSlideshow: ->

    if !@isSlideshowEnabled 
      return

    if !@projectData?
      return

    if( !@projectData.images? || @projectData.images.length <= 1 )
      return 

    @isSlideshowEnabled = true 

    cb = =>
      @slideshowNext()

    @timeoutUids.push setTimeout( cb, @slideshowInterval )
    null

  ###
  Increment to next image
  ###
  slideshowNext: ->
    if !@isSlideshowEnabled
      @stopSlideshow()
      return

    @showNext()

    cb = =>
      @slideshowNext()

    @timeoutUids.push setTimeout( cb, @slideshowInterval )
    null


  ###
  Is this the last index of images?
  ###
  isLast: (index) -> 
    if @currentIndex?
      index == @currentIndex.length - 1
    else
      false


  ###
  Update navigation counter
  ### 
  updateCount: (index) ->
    if @a?
      $(".nav-count").html("""#{index + 1} of #{@imageIds.length}""")


  ###
  Just show the image at the given index - don't animate
  ###
  setCurrentImageNoAnimation: (index) ->
    for id, imgIndex in @imageIds
      if imgIndex == index 
        $("##{id}").removeClass("hidden")
      else
        $("##{id}").addClass("hidden")
    
    @currentIndex = index
    null


  ###
  Stops the slideshow from being triggered
  ###
  stopSlideshow: ->
    for item, index in @timeoutUids
      clearTimeout item 

    @timeoutUids = []
    @isSlideshowEnabled = false
    null

  ###
  Perform transition to the next or previous image 
  ###
  setCurrentImage: (index, direction) ->
    
    if @transitionInProgress
      return

    @updateCount index

    if @currentIndex == -1
      @setCurrentImageNoAnimation( index )
      return

    @stopSlideshow()
    @transitionInProgress = true

    appWidth = "#{com.ee.appWidth}px"

    outgoingPx = if direction == "left" then "-#{appWidth}" else appWidth
    incomingPx = if direction == "left" then appWidth else "-#{appWidth}"

    $currentImage = $("##{@imageIds[@currentIndex]}")

    $currentImage
      .addClass('left-animatable')

    setTimeout( =>
      $currentImage
        .css('left', outgoingPx)
    , 40)

    animationCompleted = =>
      $currentImage
        .removeClass('left-animatable')
        .addClass('hidden')
      @transitionInProgress = false
      @beginSlideshow() if @isSlideshowEnabled

    setTimeout animationCompleted, 550

    $nextImage = $("##{@imageIds[index]}")

    $nextImage
      .css('left', incomingPx)

    $nextImage
      .removeClass('hidden')

    cb = =>
      $nextImage
        .addClass('left-animatable')
        .css('left', '0px')

    setTimeout cb, 80

    @currentIndex = index

    null

   
  ###
  Get the holder - TODO - should be a var
  ###
  $holder: -> $("##{@contentUid}")

  ###
  If this project view contains multiple images show the next one to the right
  ###
  showNext: -> 
    if @imageIds.length <= 1
      return 

    nextIndex = if @currentIndex == @imageIds.length - 1 then 0 else @currentIndex + 1
    @setCurrentImage nextIndex, "left"

  ###
  If this project view contains multiple images show the next one to the left 
  ###
  showPrevious: ->
    if @imageIds.length <= 1
      return 

    index = if @currentIndex == 0 then @imageIds.length - 1 else @currentIndex - 1
    @setCurrentImage index, "right"

  ###
  Show this project view by either sliding from above or below the browser window
  ###
  show: (direction, callback, a) ->
    #console.log "ProjecView:show: #{@projectData.title}, #{direction}"
    @a = a
    dirClass = if direction == "up" then "south" else "north"
    
    height = $('.project-img').height() 
    topPos = if direction == "up" then "#{height}px" else "-#{height}px"

    applyTopPos = =>
      @$holder().css('top', topPos)

    triggerAnimation = =>
      @$holder()
        .addClass("top-animatable")
        .removeClass("hidden")
        .css('top', '0px')

    #TODO: Is there a better way than using timeouts?
    setTimeout applyTopPos, 0
    setTimeout triggerAnimation, 100

    @setBodyColor()
    setTimeout =>
      callback( @imageIds.length ) if callback?
      @addNavArrows a, @imageIds.length if @imageIds.length > 1 
      @updateCount @currentIndex
    , 550
      
    @setTitle()
    @setDescription()
    #@beginSlideshow()
    @addUidAsClass(@projectData.uid)
    @showTint()

  ###
  Transition this project view out of the page, then hide it 
  @param direction either 'up' or 'down'
  ###
  hide: (direction) ->
    #console.log "ProjectView:hide: #{@projectData.title}, #{direction}"
    height = $('.project-img').height() 
    topPos = if direction == "up" then "-#{height}px" else "#{height}px"
    
    @$holder()
      .addClass("top-animatable")
      .css('top', topPos )

    hideCompleted = =>
      @$holder()
        .addClass("hidden")
        .removeClass("top-animatable")
        .css('top', '0px' )
      @reset()
      #stopSlideshow again - just to be safe.
      @stopSlideshow()

    setTimeout hideCompleted, 700

    @removeNavArrows @a

    @isSlideshowEnabled = false
    @stopSlideshow()

  ###
  Reset the project view so that the first image is visible
  ###
  reset: ->
    for id, imgIndex in @imageIds
      $("##{id}").addClass("hidden")
      $("##{id}").css('left', '0px')
      $("##{id}").removeClass('left-animatable', '0px')
    
    $("##{@imageIds[0]}").removeClass('hidden')

    @currentIndex = 0
    null

  
  addUidAsClass: (uid) ->

    removeClassFn = (index,css) ->
      m = css.match(/\b_[a-z_]+/g)
      (m || []).join(" ")

    $(".left-bar").removeClass(removeClassFn)
    $(".right-bar").removeClass(removeClassFn)

    $(".left-bar").addClass(uid) 
    $(".right-bar").addClass(uid) 
    null

  ###
  Apply tint class to right bar if required
  ###
  showTint: ->
    if @isTintEnabled
      $(".left-bar").addClass('tint') 
      $(".left-bar").removeClass('no-tint') 
      $(".right-bar").addClass('tint') 
      $(".right-bar").removeClass('no-tint') 
    else 
      $(".left-bar").removeClass('tint')
      $(".left-bar").addClass('no-tint')
      $(".right-bar").removeClass('tint')
      $(".right-bar").addClass('no-tint')

  ###
  Set the body color if present
  ###
  setBodyColor: ->
    bgColor = if @projectData.bg_color? then @projectData.bg_color else @defaultBgColor
    $('body').css('background-color', bgColor )

  ###
  add < and > arrows to link
  ###
  addNavArrows: (a, count) ->

    @$navHolder.append """
     
      <a class="nav-arrow" id="left-arrow" href="javascript:void(0)"><img src="#{@leftArrow}"/></a>
      
      <span class="nav-count" style="color: white; font-size: 11px" ></span>

      <a class="nav-arrow" id="right-arrow" href="javascript:void(0)"><img src="#{@rightArrow}"</a>
    """

    $("#left-arrow").click =>
      @showPrevious()

    $("#right-arrow").click =>
      @showNext()

  ###
  remove < and > arrows from link
  ###
  removeNavArrows: (a) ->  
    $(".nav-arrow").remove()
    $(".nav-count").remove()
   


  setTitle: -> $("##{@titleId}").html(@projectData.title)
  setDescription: -> $("##{@descriptionId}").html(@projectData.description)