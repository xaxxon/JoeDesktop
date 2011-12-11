
class ComputerInfo extends JoeApplication
    
    constructor: (desktop) ->
        super desktop
        
        
    get_icon_url: ->
        "/assets/computer-64x64.png"
        
    initialize: ->
        @window = @desktop.new_window(this)


window['ComputerInfo'] = ComputerInfo