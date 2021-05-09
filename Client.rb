require 'socket'

=begin
  - By executing "ruby Client.rb" the client socket will be opened on port 1234, and the chat room will be General by
  default. You can chose another port and chat room by passing these parameters as arguments as follows:
  "ruby Client.rb another_port another_room".
  - The user, once identified in a chat room, can visualize a list of available commands by typing "/commands". We
  strongly suggest you to use this command unless you're already familiar with this chat.
=end

class Client
  def initialize(port = 1234, room = "General")
    @socket = TCPSocket.open("localhost", port)
    @socket.puts room
  end

  def send
    Thread.new do
      loop do
        message = $stdin.gets
        @socket.puts(message)
        if message.chomp == "/quit"
          Process.kill('INT', Process.pid)
        end
      end
    end
  end

  def receive
    Thread.new do
      loop do
        puts @socket.gets
      end
    end
  end

end

c = Client.new(*ARGV[0], *ARGV[1])
@sender = c.send
@receiver = c.receive

begin
  @sender.join
  @receiver.join
rescue Interrupt
  puts "You left the chat"
end

