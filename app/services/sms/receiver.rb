class SMS::Receiver
  InvalidSid = Class.new StandardError

  def initialize sid: nil, to: nil, twilio: nil
    @twilio = twilio || TwilioAccount.where(sid: sid, number: to).first || raise(InvalidSid)
  end

  def handle from:, body:
    phone = Phone.for number: from
    user  = override_user(body) || phone.user
    sms   = phone.messages.create! \
      twilio_account: twilio,
      user:           user,
      number:         from,
      text:           body.strip,
      direction:      :incoming

    response = begin
      SMS::Dispatcher.new(sms: sms).handler.run!
    rescue SMS::Handler::PresentableError => e
      SMS::Assistant.new(sms: sms).run! e
    end

    twilio.send_text to: from, text: response if response
  end

  private

  attr_reader :twilio

  def override_user body
    body =~ /\A@(\w+)/ && User.find_by(pcv_id: $1)
  end
end
