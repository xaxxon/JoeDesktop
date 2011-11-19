# BUGS / TODO
# min height / min width

# jquery plugin for integrating mouse and touch events
( ($)->
    $.fn.input_start = (callback)->
        this.each ->
            $(this).bind("mousedown touchstart", callback)
            
    $.fn.unbind_input_start = (callback)->
        this.each ->
            $(this).unbind("mousedown touchstart")
                    
    $.fn.input_move = (callback)->
        this.each ->
            $(this).bind("mousemove touchmove", callback)
            
    $.fn.unbind_input_move = (callback)->
        this.each ->
            $(this).unbind("mousemove touchmove")
            
    $.fn.input_end = (callback)->
        this.each ->
            $(this).bind("mouseup touchend", callback)

    $.fn.unbind_input_end = (callback)->
        this.each ->
            $(this).unbind("mouseup touchstart")       
)(jQuery)


class Desktop
    constructor: (@parent) ->
        alert("Parent must be specified") unless @parent
        @windows = [] # ordered list of windows [0] is on top
        # create application bar
        #@parent.append($("<div id='application-bar'></div>"))
        
    load_application_from_url: (url, application_name) ->
        $('head').append $("<script src='#{url}'></script>")
        # Create instance of application
        
        
    register_application: (application) ->
        # Load CSS for application
        new application(this).initialize()
        

    # factory method for creating a new window
    new_window: (properties = {}) ->
        window = new Window(this, properties)
        @windows.push window
        @parent.append(window.element)
        # Need to listen for clicks on the window to bring it to the front
        window.mousedown (window, event) => this.window_click(window, event)

        # Application is only allowed access to the body
        return window.body()

    # Called when a window is clicked to adjust
    #   its position relative to other windows
    window_click: (clicked_window, event) ->
        z_index = 0
        new_window_order = []
        for window in @windows when window isnt clicked_window
            new_window_order.push window
            window.selected(false)

        new_window_order.push clicked_window
        clicked_window.selected(true)

        @windows = new_window_order

        # set the z-index on the windows based on their new relative positions
        @windows[index].z_index(index) for index in [0...@windows.length]


    # starts a drag event
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
        
        # Notify the element being dragged that it is being dragged
        @draggable.start_drag()
        
        # When update_drag gets called, the initial even will be the "previous" one
        @previous_drag_event = drag_start_event
        
    # Called when a new movement is detected
    update_drag: (event) ->
        delta_x = event.pageX - @previous_drag_event.pageX
        delta_y = event.pageY - @previous_drag_event.pageY
        @drag_callback(event.pageX, event.pageY, delta_x, delta_y)
        @previous_drag_event = event

    # When the drag ends, stop watching for move events and 
    #   update the part being dragged that the drag has ended
    end_drag: (event) ->
        @parent.unbind_input_move()
        @parent.unbind_input_end()
        @draggable.end_drag()


    class Window 
        TITLE_BAR_HEIGHT: 25
        constructor: (@desktop, properties) ->
            # @desktop must be specified
            alert('desktop must be specified') unless @desktop
            @element = $("<div class='window'></div>")
            @title_bar = $("<div class='title-bar'</div>").height(@TITLE_BAR_HEIGHT)
            @body_element = $("<div class='body'></div>")
                        
            initial_width = properties['width'] || 200
            initial_height = properties['height'] || 200
            
            @top = 20
            @left = 20
            @bottom = @top + initial_height
            @right = @left + initial_width

            @element.append(@title_bar)
            @element.append(@body_element)

            @body_element.height(@element.height() - @title_bar.height())
            
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
                @desktop.start_drag this, event, (nil, nil, delta_x, delta_y)=>
                    this.update_position(delta_x, delta_y)
                    
            #@title_bar.bind 'touchstart', (event) =>
            #    @desktop.start_drag this, event, (nil, nil, delta_x, delta_y) =>
            #        this.update_position delta_x, delta_y


            this.update_window()

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

        # move the entire window
        update_position: (delta_x, delta_y) ->
            @top += delta_y
            @bottom += delta_y
            @left += delta_x
            @right += delta_x
            this.update_window()
                   
        # Change the aspect ratio of the window     
        # position: top/left/bottom/dight are keys
        update_resize:(position) ->
            @top = position['top'] if position['top']
            @left = position['left'] if position['left']
            @bottom = position['bottom'] if position['bottom']
            @right = position['right'] if position['right']
            this.update_window()

        # updates CSS for window based on Window object properties
        update_window: ->
            @element.width(@right - @left)
            @element.height(@bottom - @top)
            @element.css("top", @top)
            @element.css("left", @left)
            # this doesn't work because it sets the css to position:relative which FF hates
            #@element.offset({top: @top, left: @left})
            @body_element.height(@element.height() - @title_bar.height())
            @body_element.width(@element.width())
               
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
        




class JoeApplication
    
    # stores the desktop object the application is associated with
    constructor: (@desktop) ->
        console.log "Storing application desktop"
        
    # Returns the desktop object the application is associated with
    desktop: ->
        @desktop
    



# test application
class MyApplication extends JoeApplication

    constructor: (desktop) ->
        super desktop
        console.log "Created new MyApplication"

    initialize: ->
        # As far as the application is concerned, the body is the window
        @window = @desktop.new_window()
        console.log @window
        @window.html("<P>HI</P>")
        # set up a timer to start loading words
        @update_word()
        setInterval(( => @update_word()), 10000)
        
        
    update_word: ->
        console.log "updating word"
        $.getJSON("/words", (data) =>
            console.log @window
            $(@window).html(data[0]))

$(->
    # random crap for IE user-selectable in case I want it later
    #if ($.browser.msie) $('.draggable').find(':not(input)').attr('unselectable', 'on');

    desktop = new Desktop($('#desktop'))
    desktop.register_application MyApplication
    desktop.register_application MyApplication
)

