require 'socket'
require 'concurrent'
require 'colorize'

=begin
  - You have to install Colorize gem in order to run this chat, you can do this by typing "sudo gem install colorize" on
  your terminal.
  - By executing "ruby Server.rb" the server socket will listen to port 1234 by default. You can chose another port by
  passing it as first argument as follows: "ruby Server.rb another_port".
=end

class Server
  def initialize(port = 1234)
    @server_socket = TCPServer.new("127.0.0.1", "#{port}")
    @rooms = Concurrent::Hash.new
    puts "Server started at #{Time.now.strftime("%k:%M")} running on port #{port}".colorize(:green)
    run
  end

  def run
    loop do
      client_socket = @server_socket.accept
      Thread.start(client_socket) do |socket|
        room = socket.gets.chomp.to_sym
        socket.puts "You have entered #{room}, please chose your username".colorize(:green)
        connection_key = socket.gets.chomp.to_sym

        if @rooms[room] == nil
          @rooms[room] = Concurrent::Hash.new
        end

        while @rooms[room].keys.include? connection_key
          socket.puts "Username already in use, please try again"
          connection_key = socket.gets.chomp.to_sym
        end

        new_user = Concurrent::Hash.new
        new_user[connection_key] = socket
        @rooms[room].merge!(new_user)
        puts "#{Time.now.strftime("[%k:%M]")} #{connection_key} has joined #{room}"
        socket.puts "Connection established, welcome #{connection_key}!, type /commands to see a list of available commands"
        start_chatting(room, connection_key, socket)

      end
    end.join

  end

  def start_chatting(room, user_key, socket)
    begin
      loop do
        message = socket.gets.chomp
        case message.split(" ")[0]
        when "/who"
          who(room, socket)
        when "/quit"
          socket.kill self
        when "/whisper"
          if message.split(" ").length < 3
            broadcast(room, user_key, message)
          else
          whisper(message, room, user_key)
          end
        when "/commands"
          show_commands(room, user_key)
        else
          broadcast(room, user_key, message)
        end
      end
    rescue
      @rooms[room].delete(user_key)
      puts "#{Time.now.strftime("[%k:%M]")} #{user_key} has left #{room}"
    end
  end

  def broadcast(room, user_key, message)
    @rooms[room].keys.each do |key|
      if key != user_key
        @rooms[room][key].puts "#{Time.now.strftime("%k:%M")} [#{user_key}]: #{message}"
      end
    end
  end

  def who(room, socket)
    users = Array.new
    @rooms[room].keys.each do |user|
      users << user.to_s
      users.sort!
    end
    socket.puts "Currently online users: #{users.join(", ")}"
  end

  def whisper(message, room, user_key)
    to_user_key = message.split(" ")[1].to_sym

    @rooms[room].keys.each do |key|
      if key == to_user_key
        aux = message.split(" ")
        aux.slice!(0..1)
        final_message = aux.join(" ")
        @rooms[room][key].puts "#{Time.now.strftime("%k:%M")} Whisper from [#{user_key}]: #{final_message}".colorize(:cyan)
      end
    end
  end

  def show_commands(room, user_key)
    @rooms[room].keys.each do |key|
      if key == user_key
        @rooms[room][user_key].puts "        List of available commands:
        /who: Prints the name of all users connected to this room
        /quit: The user exits the chat and the connection gets closed
        /whisper: Allows the user to send a private message to another user connected to the current room.
        This command has the syntax: /whisper destUserName yourMessage.
        "
      end
    end
  end

end

Server.new(*ARGV[0])


