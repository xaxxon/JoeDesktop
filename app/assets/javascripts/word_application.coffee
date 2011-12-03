class WordApplication extends JoeApplication
        
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


window['WordApplication'] = WordApplication