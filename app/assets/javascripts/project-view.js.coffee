#project-view.js.coffee

class @com.ee.ProjectView

  constructor: (@projectData, @index) ->
    @titleId = "project-view-title"
    @descriptionId = "project-view-description"
    @imageHolderId = "project-view-images"
    @imageIds = []

    @contentUid = "project__#{@index}"

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

  isLast: (index) -> 
    if @currentIndex?
      index == @currentIndex.length - 1
    else
      false

 
  updateCount: (index) ->
    if @a?
      $(@a).parent().find(".nav-count").html("""#{index + 1}/#{@imageIds.length}""")

  setCurrentImage: (index, direction) ->
    
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
    @setCurrentImage nextIndex, "right"

  ###
  If this project view contains multiple images show the next one to the left 
  ###
  showPrevious: ->
    if @imageIds.length <= 1
      return 

    index = if @currentIndex == 0 then @imageIds.length - 1 else @currentIndex - 1
    @setCurrentImage index, "left"

  hide: (direction) ->

    directionClass = if direction == "up" then "north" else "south"

    @$holder()
      .addClass("top-animatable")
      .addClass( directionClass )

    cb1 = =>
      @$holder()
        .addClass("hidden")
        .removeClass("top-animatable")
        .removeClass(directionClass)
    
    setTimeout cb1, 500

    @removeNavArrows @a


  show: (direction, callback, a) ->
    @a = a
    dirClass = if direction == "up" then "south" else "north"

    @$holder()
      .addClass(dirClass)

    cb = =>
      @$holder()
        .addClass("top-animatable")
        .removeClass("hidden")
        .removeClass(dirClass)

    setTimeout cb, 0

    setTimeout =>
      callback( @imageIds.length )
      @addNavArrows a, @imageIds.length if @imageIds.length > 1
      @updateCount @currentIndex
    , 550
      
    @setTitle()
    @setDescription()

  ###
  add < and > arrows to link
  ###
  addNavArrows: (a, count) ->
    $(a).parent().append """

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
    $(a).parent().find(".nav-arrow").remove()
    $(a).parent().find(".nav-count").remove()
   


  setTitle: -> $("##{@titleId}").html(@projectData.title)
  setDescription: -> $("##{@descriptionId}").html(@projectData.description)