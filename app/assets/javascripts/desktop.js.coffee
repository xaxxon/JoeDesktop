

$(->


    # random crap for IE user-selectable in case I want it later
    #if ($.browser.msie) $('.draggable').find(':not(input)').attr('unselectable', 'on');

    # Not sure where this goes, but it's not here
    #$(document).bind "contextmenu", -> false

    desktop = new Desktop($('#desktop'))
    window['desktop'] = desktop # export desktop globally
    
    desktop.load_application_from_url("/assets/word_application.js", 'WordApplication')
    desktop.load_application_from_url("/assets/computer_info.js", 'ComputerInfo')
    
    desktop.register_application WordApplication
    desktop.register_application JoeApplication
    desktop.register_application ComputerInfo
)

