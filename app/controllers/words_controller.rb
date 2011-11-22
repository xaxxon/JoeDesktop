class WordsController < ApplicationController

  # Returns a random word
  def index
    @words = []
    File.open("/usr/share/dict/words") do |io|
	    line_count = 0
  	  io.each do |line|
  	    line_count += 1
  	    @words << line
  	  end
    end
    respond_to { |format|
      format.json { render :json => [@words[rand @words.size]]}
    }
  end

end
