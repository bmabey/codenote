require 'socket'

# Stolen from selenium and webrat.
class TCPSocket

  def self.wait_for_service_with_timeout(options)
    start_time = Time.now

    until listening_service?(options)

      if options[:timeout] && (Time.now > start_time + options[:timeout])
        raise SocketError.new("Socket did not open within #{options[:timeout]} seconds")
      end
    end
  end

  def self.wait_for_service_termination_with_timeout(options)
    start_time = Time.now

    while listening_service?(options)
      if options[:timeout] && (Time.now > start_time + options[:timeout])
        raise SocketError.new("Socket did not terminate within #{options[:timeout]} seconds")
      end
    end
  end

  def self.listening_service?(options)
    Timeout::timeout(options[:timeout] || 20) do
      begin
        socket = TCPSocket.new(options[:host], options[:port])
        socket.close unless socket.nil?
        true
      rescue Errno::ECONNREFUSED, 
             Errno::EBADF           # Windows
        false
      end
    end
  end

end
