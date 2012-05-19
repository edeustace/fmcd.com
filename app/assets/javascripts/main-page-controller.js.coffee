#main-page-controller

window.com = (window.com || {})
com.ee = (com.ee || {})

class @com.ee.MainPageController


  constructor: (@mainPageData, @slideshowInteval, @defaultBgColor)->

    @LEFT = 37
    @RIGHT = 39
    @UP = 38
    @DOWN = 40

    @transitionComplete = true

    ###
    A store of all the links that are 'project views'
    ###
    @links = []
    
    for data, index in @mainPageData

      if data.uid?
        console.log "not creating link for #{data.uid}"
        linkUid = data.uid
      else
        linkUid = "__project__#{index}"
        $(".project-menu").append """ 
          <li><a href="javascript:void(0)" id="#{linkUid}">#{@formatIndex(index)} | #{data.title}</a></li>
          """
      $link = $("##{linkUid}")
      link = $link[0]
      pv = new com.ee.ProjectView(data, index, @slideshowInteval, @defaultBgColor)
      $.data link, 'projectView', pv
      $link.click (e) => @onMenuLinkClick e
      @links.push(link)


    $('body').keydown (e) => @onKeyDown e

    @navigateToLink @links[0]

  formatIndex: (index) ->
    if( index < 10 ) then "0#{index}" else "#{index}"

  onKeyDown: (e) ->
    console.log "key down: #{e.keyCode}"

    if !@transitionComplete
      return


    if @currentLink?
      if e.keyCode == @DOWN
        nextLink = @getNextLink()
        @navigateToLink nextLink
      else if e.keyCode == @UP
        previousLink = @getPreviousLink()
        @navigateToLink previousLink 
      else if e.keyCode == @LEFT
        @currentProject().showPrevious()
      else if e.keyCode == @RIGHT
        @currentProject().showNext()

  getNextLink: -> @_getLink(1, @links.length - 1)
  getPreviousLink: -> @_getLink( -1, 0 )


  _getLink: ( increment, endIndex ) ->
    index = @links.indexOf @currentLink

    if index == endIndex 
      return null

    @links[index +  increment ]

  currentProject: -> $.data(@currentLink, 'projectView')

  onMenuLinkClick: (e) ->

    if !@transitionComplete
      return

    a = e.currentTarget
    @navigateToLink a
    null


  navigateToLink: (a) ->

    if !a?
      return 

    $(a).addClass('link-selected')

    
    incomingProject = $.data(a, 'projectView')
    currentProject = null
    direction = "up"
    

    if @currentLink?
      if a == @currentLink
        return 
      $(@currentLink).removeClass 'link-selected'
      currentProject = $.data(@currentLink, 'projectView')
      direction = if incomingProject.index < currentProject.index then "down" else "up"
      currentProject.hide direction 
    
    onShowCallback = (count) =>
      @transitionComplete = true
      
    incomingProject.show direction, onShowCallback, a
    
    @transitionComplete = false

    @currentLink = a
    
  
  








