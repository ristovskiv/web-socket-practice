class AuctionSocket
  constructor: (@user_id, @auction_id, @$form)->
    @socket = new WebSocket("#{App.websocket_url}/auction/#{@auction_id}")
    @initBinds()

  initBinds: ()->
    @$form.submit((e)=>
      e.preventDefault()
      @sendBid($("#bid_value").val())
    )
    @socket.onmessage = (e)=>
      tokens = e.data.split(' ')
      switch tokens[0]
        when 'bidok'    then @bid()
        when 'underbid' then @underbid(tokens[1])
        when 'outbid'   then @outbid(tokens[1])
        when 'won'      then @won()
        when 'lost'     then @lost()
      console.log e

  sendBid: (value)->
    @value = value
    @socket.send("bid #{@auction_id} #{@user_id} #{@value}")

  bid: ->
    @$form.find('.message strong').html(
      "Your bid: #{@value}."
    )

  underbid: (value)->
    @$form.find('.message strong').html(
      "Your bid is under #{value}."
    )

  outbid: (value)->
    @$form.find('.message strong').html(
      "You were outbid. It is now #{value}."
    )

  won: ->
    @$form.find('.message strong').html(
      "You won!"
    )

  lost: ->
    @$form.find('.message strong').html(
      "You lost the auction!"
    )

window.AuctionSocket = AuctionSocket