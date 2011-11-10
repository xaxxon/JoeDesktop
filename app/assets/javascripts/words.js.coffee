### BUGS
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
    #  - drag_data: data that will be passed on each callback to the draggable
    start_drag: (@draggable, drag_start_event, @drag_callback) ->
        # watch for mouse movements anywhere in the window - sudden movements can
        #   move the cursor out of any smaller region too quickly
        @parent.mousemove (event) => this.update_drag event
        @parent.mouseup (event) => this.end_drag event
        #@parent.mouseout (event) => this.end_drag event
        @draggable.start_drag(@drag_data)
        console.log("Start drag")
        # When update_drag gets called, the initial even will be the "previous" one
        @previous_drag_event = drag_start_event
        
    update_drag: (event) ->
        delta_x = event.pageX - @previous_drag_event.pageX
        delta_y = event.pageY - @previous_drag_event.pageY
        @drag_callback(delta_x, delta_y, @drag_data)
        @previous_drag_event = event

    end_drag: (event) ->
        console.log("End drag")
        @parent.unbind("mousemove").unbind("mouseup").unbind("mouseout")
        @draggable.end_drag(@drag_data)

        

    class Window
        constructor: (@desktop) ->
            # @desktop must be specified
            alert('desktop must be specified') unless @desktop
            @element = $("<div class='window'></div>")
            @title_bar = $("<div class='title-bar'</div>")
            @body = $("<div class='body'></div>")

            @element.append(@title_bar)
            @element.append(@body)
            $('#desktop').append @element

            @body.height(@element.height() - @title_bar.height())
            
            # This whole resize thing is pretty annoying
            @left_resize_bar = $("<div class='resize side left'></div>").mousedown (event) =>
                @desktop.start_drag this, event, (delta_x, delta_y, data) =>
                    this.update_resize(0, delta_x, 0, 0)
            @element.append @left_resize_bar

            @right_resize_bar = $("<div class='resize side right'></div>").mousedown (event) =>
                @desktop.start_drag this, event, (delta_x, delta_y, data) =>
                    this.update_resize(0, 0, 0, delta_x)
            @element.append @right_resize_bar
            
            @top_resize_bar = $("<div class='resize corner top'></div>").mousedown (event) =>
                @desktop.start_drag this, event, (delta_x, delta_y, data) =>
                    this.update_resize(delta_y, 0, 0, 0)
            
            top_left_resize = $("<div class='resize corner top-left'></div>").mousedown (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (delta_x, delta_y, data) =>
                    this.update_resize(delta_y, delta_x, 0, 0)
            @top_resize_bar.append(top_left_resize)
            
            top_right_resize = $("<div class='resize corner top-right'></div>").mousedown (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (delta_x, delta_y, data) =>
                    this.update_resize(delta_y, 0, 0, delta_x)
            
            @top_resize_bar.append(top_right_resize)
            @element.append @top_resize_bar
            
            @bottom_resize_bar = $("<div class='resize bottom'></div>").mousedown (event) =>
                @desktop.start_drag this, event, (delta_x, delta_y, data) =>
                    console.log("Bottom")
                    this.update_resize(0, 0, delta_y, 0)
                
            bottom_left_resize = $("<div class='resize corner bottom-left'></div>").mousedown (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (delta_x, delta_y, data) =>
                    this.update_resize(0, delta_x, delta_y, 0)
                
            @bottom_resize_bar.append(bottom_left_resize)
            
            bottom_right_resize = $("<div class='resize corner bottom-right'></div>").mousedown (event) =>
                event.stopPropagation()
                @desktop.start_drag this, event, (delta_x, delta_y, data) =>
                    console.log("Bottom right")
                    this.update_resize(0, 0, delta_y, delta_x)
                
            @bottom_resize_bar.append(bottom_right_resize)
            @element.append @bottom_resize_bar
            # END annoying resize bar stuff

            @title_bar.mousedown (event) =>
                @desktop.start_drag this, event, (delta_x, delta_y, data)=>
                    this.update_position(delta_x, delta_y)

        element: ->
            @element

        title_bar: ->
            @title_bar

        body: ->
            @body

        # element that allows dragging is the title bar
        drag_element: ->
            @title_bar
                        
        start_drag: ->
            @element.addClass("dragging")
            
        # move the entire window
        update_position: (delta_x, delta_y, data) ->
            new_x = @element.offset().left + delta_x
            new_y = @element.offset().top + delta_y
            @element.offset({top: new_y, left: new_x})
                        
        update_resize:(delta_top, delta_left, delta_bottom, delta_right) ->
            new_top = @element.offset().top + delta_top
            new_left = @element.offset().left + delta_left
            @element.width(@element.width() + (delta_right - delta_left))
            @element.height(@element.height() + (delta_bottom - delta_top))
            @element.offset({top: new_top, left: new_left})
            this.update_body()

            
        # update the size of the body section based on the current window sizes
        update_body: ->
            console.log(@element.height() + " : " + @title_bar.height())
            @body.height(@element.height() - @title_bar.height())
            @body.width(@element.width())   
               
        end_drag: ->
            @element.removeClass("dragging")

$(->
    desktop = new Desktop($('#desktop'))
    desktop.new_window()
    desktop.new_window()
)


