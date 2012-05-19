#project-view.js.coffee

class @com.ee.ProjectView

  constructor: (@projectData, @index, @slideshowInterval, @defaultBgColor) ->
    @titleId = "project-view-title"
    @descriptionId = "project-view-description"
    @imageHolderId = "project-view-images"
    @imageIds = []
    @$navHolder = $("#project-view-navigation-holder")

    @slideshowIntervalUid
    @isSlideshowEnabled = false

    @contentUid = "project__#{@index}"
    @isTintEnabled = true

    if @projectData.uid?
      @isTintEnabled = false

    if @projectData.contentUid?
      @contentUid = @projectData.contentUid
      @$holder().addClass('hidden')
      console.log "this view is already linked to some content ignore images"
    else
      imgHtml = ""
      console.log "project data images: #{@projectData.images}"
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
  Start the slideshow if there are more than one image to show
  ###
  beginSlideshow: ->

    if !@projectData?
      return

    if( !@projectData.images? || @projectData.images.length <= 1 )
      return 

    @isSlideshowEnabled = true 

    cb = =>
      @slideshowNext()

    setTimeout cb, @slideshowInterval 
    null

  ###
  Increment to next image
  ###
  slideshowNext: ->
    if !@isSlideshowEnabled
      clearInterval @slideshowIntervalUid
      return

    @showNext()

    cb = =>
      @slideshowNext()

    @slideshowIntervalUid = setTimeout( cb, @slideshowInterval )
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
      $(".nav-count").html("""#{index + 1}/#{@imageIds.length}""")

  ###
  Perform transition to the next or previous image 
  ###
  setCurrentImage: (index, direction) ->
    
    if @transitionInProgress
      return


    @updateCount index
    if @currentIndex == -1
      for id, imgIndex in @imageIds
        if imgIndex == index 
          $("##{id}").removeClass("hidden")
        else
          $("##{id}").addClass("hidden")
      
      @currentIndex = index
      return
    else

      @transitionInProgress = true


      appWidth = "#{com.ee.appWidth}px"

      outgoingPx = if direction == "left" then "-#{appWidth}" else appWidth
      incomingPx = if direction == "left" then appWidth else "-#{appWidth}"

      $currentImage = $("##{@imageIds[@currentIndex]}")
      $currentImage
        .addClass('left-animatable')
        .css('left', outgoingPx)

      currentCb = =>
        $currentImage
          .removeClass('left-animatable')
          .addClass('hidden')
        @transitionInProgress = false

      setTimeout currentCb, 550

      $nextImage = $("##{@imageIds[index]}")

      $nextImage
        .css('left', incomingPx)
        .removeClass('hidden')


      cb = =>
        $nextImage
          .addClass('left-animatable')
          .css('left', '0px')

      setTimeout cb, 0

      @currentIndex = index

    null

   
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
  Transition this project view out of the page, then hide it 
  @param direction either 'up' or 'down'
  ###
  hide: (direction) ->
    console.log "ProjectView:hide: #{@projectData.title}, #{direction}"
    directionClass = if direction == "up" then "north" else "south"
    height = com.ee.appHeight
    height = 1200
    ## TODO: TopPos needs to be the height of the scaled image.
    topPos = if "up" then "-#{height}px" else "#{height}px"
    console.log "top to -> #{topPos}"
    
    @$holder()
      .addClass("top-animatable")
      .addClass(directionClass )

    cb1 = =>
      @$holder()
        .addClass("hidden")
        .removeClass("top-animatable")
        .removeClass( directionClass )
        @reset()

    setTimeout cb1, 700

    @removeNavArrows @a

    @isSlideshowEnabled = false
    clearInterval @slideshowIntervalUid

  reset: ->
    for id, imgIndex in @imageIds
      $("##{id}").addClass("hidden")
      $("##{id}").css('left', '0px')
      $("##{id}").removeClass('left-animatable', '0px')
    
    $("##{@imageIds[0]}").removeClass('hidden')

    @currentIndex = 0
    null

  show: (direction, callback, a) ->
    console.log "ProjecView:show: #{@projectData.title}, #{direction}"
    @a = a
    dirClass = if direction == "up" then "south" else "north"


    cb0 = =>
      @$holder().addClass(dirClass)

    cb = =>
      @$holder()
        .addClass("top-animatable")
        .removeClass("hidden")
        .removeClass(dirClass)

    setTimeout cb0, 0
    setTimeout cb, 10

    setTimeout =>
      callback( @imageIds.length )
      @addNavArrows a, @imageIds.length if @imageIds.length > 1 
      @setBodyColor()
      @updateCount @currentIndex
    , 550
      
    @setTitle()
    @setDescription()
    @beginSlideshow()
    @showTint()

  ###
  Apply tint class to right bar if required
  ###
  showTint: ->
    if @isTintEnabled
      $(".right-bar").addClass('tint') 
      $(".right-bar").removeClass('no-tint') 
    else 
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
      <span class="nav-count" style="color: white; font-size: 11px" ></span>
      <a class="nav-arrow" id="left-arrow" href="javascript:void(0)"><</a>
      <a class="nav-arrow" id="right-arrow" href="javascript:void(0)">></a>
    """

    $(a).parent().find("#left-arrow").click =>
      @showPrevious()

    $(a).parent().find("#right-arrow").click =>
      @showNext()

  ###
  remove < and > arrows from link
  ###
  removeNavArrows: (a) ->  
    $(".nav-arrow").remove()
    $(".nav-count").remove()
   


  setTitle: -> $("##{@titleId}").html(@projectData.title)
  setDescription: -> $("##{@descriptionId}").html(@projectData.description)