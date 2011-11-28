# BUGS / TODO
# min height / min width
# make sure window position stays in desktop
# windows show up on top of each other when created, instead of either looking
#   for an empty spot or offsetting each one
# Disallow dragging when maximized
# height doesn't right when the viewport is resized - width works fine
#   - use $(window).resize -> window.width() <== to find out what the new height/widths are


# jquery plugin for integrating mouse and touch events
#   as well as specialized geometry operations
( ($)->
    
    # This only responds to primary clicks
    # A "false" callback will just return false
    #   TODO: This may not work for touch devices
    $.fn.input_start = (callback, attributes = {}) ->
        this.each ->
            $(this).bind "mousedown touchstart", (event)->
                    
                return false if callback == false
                                
                # if which is 0, that means touch even, 1 means primary mouse click
                callback(event) if event.which == 1 or event.which == 0

                # clicks show up as touch starts first, need to return true to
                #   keep the event bubbling up to show up as a click event, but
                #   the default actions should not be taken
                event.preventDefault()
                true

    $.fn.unbind_input_start = ->
        this.each ->
            $(this).unbind("mousedown touchstart")

    $.fn.input_move = (callback)->
        this.each ->
            $(this).bind("mousemove touchmove", callback)

    $.fn.unbind_input_move = ->
        this.each ->
            $(this).unbind("mousemove touchmove")

    $.fn.input_end = (callback)->
        this.each ->
            $(this).bind("mouseup touchend", callback)

    $.fn.unbind_input_end = ->
        this.each ->
            $(this).unbind("mouseup touchstart")
                
    
    # Returns the total height of an element including the border
    #   this may should include other parts of the box like padding and margin, but it doesn't yet
    $.fn.total_height = ->
        number = this.height() + parseInt($($('.title-bar')[0]).css("border-bottom-width"),10) + parseInt($($('.title-bar')[0]).css("border-top-width"),10)
        return number

)(jQuery)



class Desktop
    
    # Stores information about the current positioning/location/size
    #   of the window
    class Position
        constructor:(@top, @left, @bottom, @right) ->
        height: (height) -> @bottom - @top
        width: (width) -> @right - @left
        set_max_height: -> @max_height = true; this
        set_max_width: -> @max_width = true; this
        set_max_dimensions: -> @set_max_width(); set_max_height()
        apply_to_element: (element) ->
            if @max_height then element.css("height", "100%") else element.width(@width())
            if @max_width then element.css("width", "100%") else element.height(@height())
            element.css("top", @top)
            element.css("left", @left)
            

    window_resized: ->
        #console.log "window resized: #{$(window).width()} x #{$(window).height()}"
    
    constructor: (@parent) ->
        alert("Parent must be specified") unless @parent
        @open_windows = [] # ordered list of windows [0] is on top
        @minimized_windows= [] # ordered from left to right in application bar
        # create application bar
        @init_application_bar()
        $(window).resize => @window_resized()
        
    init_application_bar: ->
        @application_bar = $("<div id='application-bar'></div>")
        @parent.append(@application_bar)
    
        # Application Launcher Button
        @application_bar.append($('<div class="launch-button"></div>'))
        
        # Minimized application space
        @application_bar.append(@minimized_applications = $('<div class="minimized-applications" />'))
        
    update_application_bar: ->
        # go through minimized windows and create elements for them
        @minimized_applications.empty()
        for window in @minimized_windows
            do (window) =>
                minimized = $("<div class='minimized'>#{window.application.name()}</div>")
                minimized.click => @restore_window(window)
                @minimized_applications.append(minimized)

    load_application_from_url: (url, application_name) ->
        $('head').append $("<script src='#{url}'></script>")
        # Create instance of application
        
        
    register_application: (application) ->
        # Load CSS for application
        new application(this).initialize()
        
    # returns a position
    maximized_position: ->
        new Position( 0, 0, @parent.height(), @parent.width() ).set_max_width().set_max_height()
    
    minimize_window: (minimized_window) ->
        # remove window from open_windows
        @open_windows = (window for window in @open_windows when window != minimized_window)
        
        # add to minimized_windows
        @minimized_windows.push minimized_window
        @update_application_bar()
        
    # bring a window back from being minimized
    restore_window: (restored_window) ->
        # remove window from minimized_windows
        @minimized_windows = (window for window in @minimized_windows when window != restored_window)
        
        # add back to open windows
        @open_windows.push restored_window
        
        @update_application_bar()
        restored_window.restore()

    # factory method for creating a new window
    new_window: (application, properties = {}) ->

        window = new Window(this, application, properties)
        @open_windows.push window

        # Have to update the window after adding it to the root of the DOM, 
        #   otherwise you can't find out about the dimensions
        @parent.append(window.element)
        window.update_window()
        
        # Need to listen for clicks on the window to bring it to the front
        window.mousedown (window, event) => this.window_select(window, event)

        # Application is only allowed access to the body
        return window.body()

    # called when a click event is completed on the window
    window_clicked: (clicked_window, event) ->
         
    width: -> @parent.width()
    height: -> @parent.height()

    # Called when a window is clicked to adjust
    #   its position relative to other windows
    window_select: (clicked_window, event) ->
        z_index = 0
        new_window_order = []
        for window in @open_windows when window isnt clicked_window
            new_window_order.push window
            window.selected(false)

        new_window_order.push clicked_window
        clicked_window.selected(true)

        @open_windows = new_window_order

        # set the z-index on the windows based on their new relative positions
        @open_windows[index].z_index(index) for index in [0...@open_windows.length]


    # starts a drag events
    #  - draggable: the object that will be dragged
    #  - drag_start_event: the event starting the drag
    start_drag: (@draggable, drag_start_event, @drag_callback) ->

        # Watch for input moves and update the part being moved
        @parent.input_move (event) =>
            this.update_drag event
            event.preventDefault()
        

        # watch for the drag to end and end the drag and update
        #   the part being dragged
        @parent.input_end (event) => this.end_drag event
        
        
        # When update_drag gets called, the initial even will be the "previous" one
        @previous_drag_event = drag_start_event

        # Don't start the drag until we get a first movement, so things
        #   like button clicks don't cause the drag window visual effects
        @drag_first_movement_detected = false
        
    # Called when a new movement is detected
    update_drag: (event) ->
        
        # is this the first movement detected?  if so, notify the dragged element
        unless @drag_first_movement_detected
            # Notify the element being dragged that it is being dragged
            @draggable.start_drag()
            @drag_first_movement_detected = true


        
        delta_x = event.pageX - @previous_drag_event.pageX
        delta_y = event.pageY - @previous_drag_event.pageY
        @drag_callback(event.pageX, event.pageY, delta_x, delta_y)
        @previous_drag_event = event

    # When the drag ends, stop watching for move events and 
    #   update the part being dragged that the drag has ended
    end_drag: (event) ->
        @parent.unbind_input_move()
        @parent.unbind_input_end()
        
        # no need to notify of end of drag unless it was notified 
        #   that one was started
        if @drag_first_movement_detected
            @draggable.end_drag()


    class Window 
        
        
        TITLE_BAR_HEIGHT: 25

        close: ->
            alert "Close"

        minimize: ->
            @minimized = true
            @desktop.minimize_window this
            @update_window()

        restore: ->
            
            @minimized = false
            @update_window()    
                
        maximize: ->
            if !@maximized()
                @status = 'MAXIMIZED'
            
                # disallow dragging
                # How to do this?
            else
                @status = 'NORMAL'
                @restore()
                
            @update_window()


        maximized: ->
            @status == 'MAXIMIZED'            

        constructor: (@desktop, @application, properties) ->
            # @desktop must be specified
            alert('desktop must be specified') unless @desktop
            @element = $("<div class='window'></div>")
            
            @title_bar = $("<div class='title-bar'</div>").height(@TITLE_BAR_HEIGHT)
            
            # Set the application icon in the status bar
            #@title_bar.css("background-image", "url(#{@application.get_icon_url})")
            @title_bar.append $("<img class='icon' src='#{@application.get_icon_url()}'></img>'")
                
            # block input_start so that the title_bar doesn't start dragging if the click starts on a button
            @title_bar.append $("<div class='button close'></div>").click( => @close() ).input_start(false)
            @title_bar.append $("<div class='button minimize'></div>").click( => @minimize()).input_start(false)
            @title_bar.append $("<div class='button maximize'></div>").click( => @maximize()).input_start(false)
            
            # Status is whether the window is a "normal" floating window or
            #   a fixed-position 'maximized' window.  This is different than minimized
            #   because minimized windows restore back to their previous state which
            #   needs to be stored - a window can have status MAXIMIZED and have MINIMIZED be true
            #   That just means when it is unminimized it will return to maximizedd
            @status = "NORMAL"
            @minimized = false
            
            @body_element = $("<div class='body'></div>")
                        
            initial_width = properties['width'] || 200
            initial_height = properties['height'] || 200
            
            @position = new Position(20, 20, 20 + initial_height, 20 + initial_width)

            @element.append(@title_bar)
            @element.append(@body_element)


            @body_element.height(@height() - @title_bar.total_height())
            
            # This whole resize thing is pretty annoying
            @left_resize_bar = $("<div class='resize side left'></div>").input_start (event) =>
                @desktop.start_drag this, event, (x) =>
                    this.update_resize({left: x})
            @element.append @left_resize_bar

            @right_resize_bar = $("<div class='resize side right'></div>").input_start (event) =>
                @desktop.start_drag this, event, (x) =>
                    this.update_resize({right: x})
            @element.append @right_resize_bar
            
            @top_resize_bar = $("<div class='resize corner top'></div>").input_start (event) =>
                @desktop.start_drag this, event, (nil, y) =>
                    this.update_resize({top: y})
            
            top_left_resize = $("<div class='resize corner top-left'></div>").input_start (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (x, y) =>
                    this.update_resize({top: y, left: x})
            @top_resize_bar.append(top_left_resize)
            
            top_right_resize = $("<div class='resize corner top-right'></div>").input_start (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (x, y) =>
                    this.update_resize({top: y, right: x})
            
            @top_resize_bar.append(top_right_resize)
            @element.append @top_resize_bar
            
            @bottom_resize_bar = $("<div class='resize bottom'></div>").input_start (event) =>
                @desktop.start_drag this, event, (nil, y) =>
                    this.update_resize({bottom: y})
                
            bottom_left_resize = $("<div class='resize corner bottom-left'></div>").input_start (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (x, y) =>
                    this.update_resize({left: x, bottom: y})
                
            @bottom_resize_bar.append(bottom_left_resize)
            
            bottom_right_resize = $("<div class='resize corner bottom-right'></div>").input_start (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (x, y) =>
                    this.update_resize({bottom: y, right: x})
                
            @bottom_resize_bar.append(bottom_right_resize)
            @element.append @bottom_resize_bar
            # END annoying resize bar stuff

            @title_bar.input_start (event) =>
                unless @maximized()
                    @desktop.start_drag this, event, (nil, nil, delta_x, delta_y)=>
                        this.update_position(delta_x, delta_y)
                    
            #@title_bar.bind 'touchstart', (event) =>
            #    @desktop.start_drag this, event, (nil, nil, delta_x, delta_y) =>
            #        this.update_position delta_x, delta_y


            # can't call update_window from here because it's not attached to 
            #   the root of the DOM

        # other things can register for events on the window
        mousedown: (callback) =>
            @element.input_start (event)=> 
                callback(this, event)

        # optionally sets and always returns the current/new z-index
        z_index: (z_index) ->
            @element.css('z-index', z_index) if z_index?
            return @element.css('z-index')

        element: ->
            @element

        title_bar: ->
            @title_bar

        body: ->
            @body_element

        start_drag: ->
            @element.addClass("dragging")

        height: ->
            @position.height()
            
            
        # move the entire window
        update_position: (delta_x, delta_y) ->
            @position = new Position(@position.top + delta_y, @position.left + delta_x, @position.bottom + delta_y, @position.right + delta_x)
            this.update_window()
                   
        # Change the aspect ratio of the window     
        # position: top/left/bottom/dight are keys
        update_resize:(position) ->
            @position = new Position( position['top'] ? @position.top, position['left'] ? @position.left, position['bottom'] ? @position.bottom, position['right'] ? @position.right)
            this.update_window()

        # updates CSS for window based on Window object properties
        update_window: ->
            
            # mark the window as minimized when it is minimized
            if @minimized then @element.addClass "minimized" else @element.removeClass "minimized"
            
            # disallow resizing when maximized
            if @maximized() then @element.addClass "not-resizeable" else @element.removeClass "not-resizeable"
            
            # pick the position to use based on whether the window is maximized
            if @maximized() then position = @desktop.maximized_position() else position = @position
            
            # update the window css to represent it's intended position
            position.apply_to_element(@element)
            @body_element.height(position.height() - @title_bar.total_height())

        
        # Called when the drag stops, the drag may not have been started
        #    must be idempotent
        end_drag: ->
            @element.removeClass("dragging")
            
        # sets whether this window is selected if is_selected is specified
        # returns whether this window is selected
        selected: (is_selected) ->
            if is_selected?
                @is_selected = is_selected
                
            if @is_selected
                @element.addClass('selected')
            else
                @element.removeClass('selected')
            @is_selected




# base class for applications in Joe
class JoeApplication
    
    constructor: (@desktop) ->

    # Returns the URL to the image to be used for the application
    #   if unimplemented, results in default image
    get_icon_url: ->
        '/assets/coffee-icon-77x77.png'

# test application
class MyApplication extends JoeApplication

    constructor: (desktop) ->
        super desktop

    name: ->
        "Words! #{@word}"

    initialize: ->
        # As far as the application is concerned, the body is the window
        @window = @desktop.new_window(this)
        @window.html("<P>HI</P>")
        # set up a timer to start loading words
        @update_word()
        
        # uncomment this to have it update the words periodically
        #setInterval(( => @update_word()), 1000)

    update_word: ->
        $.getJSON("/words", (data) =>
            @word = data[0]
            $(@window).html(data[0]))



$(->
    # random crap for IE user-selectable in case I want it later
    #if ($.browser.msie) $('.draggable').find(':not(input)').attr('unselectable', 'on');

    desktop = new Desktop($('#desktop'))
    desktop.register_application MyApplication
    desktop.register_application MyApplication
)

