class WordsController < ApplicationController

    def index
    
	File.open("/usr/share/dict/words") do |io|

	end

	render :text => 'hi'

    end

    def show

    @words = []
    File.open("/usr/share/dict/words") do |io|
	  line_count = 0
	  io.each do |line|
	    line_count += 1
	    break if line_count > 100
	    @words << line
	  end
	end
    end 
end
