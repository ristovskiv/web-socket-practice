class AuctionSocket
  def initialize(app)
    @app = app
    @clients = []
  end

  def call(env)
    @env = env
    if socket_request?
      socket = spawn_socket
      @clients << socket
      socket.rack_response
    else
      @app.call env 
    end
  end

  private

  attr_reader :env

  def socket_request?
    Faye::WebSocket.websocket? env
  end

  def spawn_socket
    socket = Faye::WebSocket.new env
    socket.on :open do
      socket.send 'Hello!'
    end

    socket.on :message do |event|
      socket.send event.data
      begin
        tokens = event.data.split(' ')
        operation = tokens.delete_at 0

        case operation
        when 'bid'
          bid socket, tokens
        end

      rescue Exception => e
        p e
        p e.backtrace
      end
    end

    socket
  end

  def bid socket, tokens
    service = PlaceBid.new(
      auction_id: tokens[0],
      user_id: tokens[1],
      value: tokens[2]
    )

    if service.execute
      socket.send 'bidok'
      notify_outbids socket, tokens[2]
    else
      socket.send "underbid #{service.auction.current_bid}"
    end
  end

  def notify_outbids(socket, value)
    @clients.reject{|client| client == socket}.each do |client|
      client.send "outbid #{value}"
    end
  end
end
