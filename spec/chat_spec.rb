require_relative './../actions/chat_response'

describe ChatResponseAction do
  describe '.action' do
    it 'returns a generic message' do
      msg = Class.new do
        def self.message; ''; end
        def self.reply(reply = nil)
          @reply = reply unless reply.nil?
          @reply
        end
      end

      ChatResponseAction.action(msg)
      msg.reply.should == 'You know I can hear you talking about me, right?'
    end
  end
end
