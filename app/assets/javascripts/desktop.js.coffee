

$(->


    # random crap for IE user-selectable in case I want it later
    #if ($.browser.msie) $('.draggable').find(':not(input)').attr('unselectable', 'on');

    # Not sure where this goes, but it's not here
    #$(document).bind "contextmenu", -> false

    desktop = new Desktop($('#desktop'))
    window['desktop'] = desktop # export desktop globally
    
    desktop.register_application WordApplication
)

