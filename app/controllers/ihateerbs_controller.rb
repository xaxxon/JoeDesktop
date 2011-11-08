class IhateerbsController < ApplicationController
  # GET /ihateerbs
  # GET /ihateerbs.json
  def index
    @ihateerbs = Ihateerb.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @ihateerbs }
    end
  end

  # GET /ihateerbs/1
  # GET /ihateerbs/1.json
  def show
    @ihateerb = Ihateerb.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @ihateerb }
    end
  end

  # GET /ihateerbs/new
  # GET /ihateerbs/new.json
  def new
    @ihateerb = Ihateerb.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @ihateerb }
    end
  end

  # GET /ihateerbs/1/edit
  def edit
    @ihateerb = Ihateerb.find(params[:id])
  end

  # POST /ihateerbs
  # POST /ihateerbs.json
  def create
    @ihateerb = Ihateerb.new(params[:ihateerb])

    respond_to do |format|
      if @ihateerb.save
        format.html { redirect_to @ihateerb, :notice => 'Ihateerb was successfully created.' }
        format.json { render :json => @ihateerb, :status => :created, :location => @ihateerb }
      else
        format.html { render :action => "new" }
        format.json { render :json => @ihateerb.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ihateerbs/1
  # PUT /ihateerbs/1.json
  def update
    @ihateerb = Ihateerb.find(params[:id])

    respond_to do |format|
      if @ihateerb.update_attributes(params[:ihateerb])
        format.html { redirect_to @ihateerb, :notice => 'Ihateerb was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @ihateerb.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ihateerbs/1
  # DELETE /ihateerbs/1.json
  def destroy
    @ihateerb = Ihateerb.find(params[:id])
    @ihateerb.destroy

    respond_to do |format|
      format.html { redirect_to ihateerbs_url }
      format.json { head :ok }
    end
  end
end
