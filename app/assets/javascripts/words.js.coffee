# BUGS
# drag right side past left, then drag back to the right.  Oops.



class Desktop
    # TODO: rename @parent to @desktop
    constructor: (@parent) ->
        @windows = []
        # @parent must be specified
        alert("Parent must be specified") unless @parent
        
    # factory method for creating a new window
    new_window: (@window_name) ->
        window = new Window(this)
        #@windows.push window
        #@parent.append(window.element)

    # starts a drag event
    #  - draggable: the object that will be dragged
    #  - drag_start_event: the event starting the drag
    start_drag: (@draggable, drag_start_event, @drag_callback) ->
        # watch for mouse movements anywhere in the window - sudden movements can
        #   move the cursor out of any smaller region too quickly
        @parent.mousemove (event) => this.update_drag event
        @parent.mouseup (event) => this.end_drag event
        #@parent.mouseout (event) => this.end_drag event
        @draggable.start_drag()
        # When update_drag gets called, the initial even will be the "previous" one
        @previous_drag_event = drag_start_event
        
    update_drag: (event) ->
        delta_x = event.pageX - @previous_drag_event.pageX
        delta_y = event.pageY - @previous_drag_event.pageY
        @drag_callback(event.pageX, event.pageY, delta_x, delta_y)
        @previous_drag_event = event

    end_drag: (event) ->
        @parent.unbind("mousemove").unbind("mouseup").unbind("mouseout")
        @draggable.end_drag()

        

    class Window
        constructor: (@desktop) ->
            # @desktop must be specified
            alert('desktop must be specified') unless @desktop
            @element = $("<div class='window'></div>")
            @title_bar = $("<div class='title-bar'</div>")
            @body = $("<div class='body'></div>")
            
            @top = 20
            @left = 20
            @bottom = 200
            @right = 200

            @element.append(@title_bar)
            @element.append(@body)
            $('#desktop').append @element

            @body.height(@element.height() - @title_bar.height())
            
            # This whole resize thing is pretty annoying
            @left_resize_bar = $("<div class='resize side left'></div>").mousedown (event) =>
                @desktop.start_drag this, event, (x) =>
                    this.update_resize({left: x})
            @element.append @left_resize_bar

            @right_resize_bar = $("<div class='resize side right'></div>").mousedown (event) =>
                @desktop.start_drag this, event, (x) =>
                    this.update_resize({right: x})
            @element.append @right_resize_bar
            
            @top_resize_bar = $("<div class='resize corner top'></div>").mousedown (event) =>
                @desktop.start_drag this, event, (nil, y) =>
                    this.update_resize({top: y})
            
            top_left_resize = $("<div class='resize corner top-left'></div>").mousedown (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (x, y) =>
                    this.update_resize({top: y, left: x})
            @top_resize_bar.append(top_left_resize)
            
            top_right_resize = $("<div class='resize corner top-right'></div>").mousedown (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (x, y) =>
                    this.update_resize({top: y, right: x})
            
            @top_resize_bar.append(top_right_resize)
            @element.append @top_resize_bar
            
            @bottom_resize_bar = $("<div class='resize bottom'></div>").mousedown (event) =>
                @desktop.start_drag this, event, (nil, y) =>
                    this.update_resize({bottom: y})
                
            bottom_left_resize = $("<div class='resize corner bottom-left'></div>").mousedown (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (x, y) =>
                    this.update_resize({left: x, bottom: y})
                
            @bottom_resize_bar.append(bottom_left_resize)
            
            bottom_right_resize = $("<div class='resize corner bottom-right'></div>").mousedown (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (x, y) =>
                    this.update_resize({bottom: y, right: x})
                
            @bottom_resize_bar.append(bottom_right_resize)
            @element.append @bottom_resize_bar
            # END annoying resize bar stuff

            @title_bar.mousedown (event) =>
                @desktop.start_drag this, event, (nil, nil, delta_x, delta_y)=>
                    this.update_position(delta_x, delta_y)
                    
            this.update_window()

        element: ->
            @element

        title_bar: ->
            @title_bar

        body: ->
            @body
                        
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
        # position: top/left/bottom/right are keys
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
            @element.offset({top: @top, left: @left})
            @body.height(@element.height() - @title_bar.height())
            @body.width(@element.width())
               
        end_drag: ->
            @element.removeClass("dragging")

$(->
    desktop = new Desktop($('#desktop'))
#    desktop.new_window()
    desktop.new_window()
)


