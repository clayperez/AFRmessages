class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # GET /broadcast
  # GET /broadcast.json
  def create
    sender = params['From'] =~ /\A[+][1]/ ? params['From'].sub(/\+1/, '') : params['From']
    users = User.where.not(phone_number: sender)
    message = Message.new(body: params['Body'], from: params['From'])

    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    from = ENV['TWILIO_NUMBER']

    client = Twilio::REST::Client.new account_sid, auth_token


    users.each do |user|
      client.account.messages.create(
        :from => "AFR",
        :to => user.phone_number,
        :body => message.body
      )
    end

    respond_to do |format|
      if message.save
        #format.html { redirect_to message, notice: 'Message was successfully created.' }
        #format.json { render action: 'show', status: :created, location: message }
      else
        #format.html { render action: 'new' }
        format.json { render json: message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:body, :from)
    end
end
