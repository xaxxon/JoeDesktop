class DesktopsController < ApplicationController

    def show
      render :inline =>"<div id='desktop'></div>", :layout => true
	  end
end
