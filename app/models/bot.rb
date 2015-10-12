class Bot < ActiveRecord::Base
  belongs_to :user
  has_many :bots_interactions
  has_many :interactions, through: :bots_interactions

  validates :name, presence: true
  validates :gender, presence: true
  validates :age, presence: true, numericality: { only_integer: true }
  validates :age, numericality: { greater_than_or_equal_to: 18 }
  validates :age, numericality: { less_than_or_equal_to: 99 }
  validates :eye_color, presence: true
  validates :hair_color, presence: true
  validates :user_id, presence: true

  WELCOME_MESSAGE = 'Yeiii!'
  UNKNOWN_COMMAND_MESSAGE = "This is a test"

  def avatar
    gender + '-' + hair_color + '-' + eye_color + '.png'
  end

  def send_welcome_message
    self.send_message(self.user.full_phone_number,WELCOME_MESSAGE)
  end

  def send_message(recipient_phone,body)
    @twilio_number = ENV['TWILIO_PHONE_NUMBER']
    client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    client.account.messages.create(
      from: "#{@twilio_number}",
      to: self.user.full_phone_number,
      body: body
    )
  end

  class << self

      def route_incoming(params)
        message_body = params[:Body]
        message_sender = params[:From]
        user = User.find_by(phone_number: message_sender.sub("+1",""))
        reply_body = UNKNOWN_COMMAND_MESSAGE
        Bot.send_message(message_sender,reply_body)
      end

  end
end
