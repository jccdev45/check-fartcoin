local function extractPrice(jsonString)
  local pricePattern = '"price":(%d+%.%d+)'
  local price = jsonString:match(pricePattern)
  return price or "Price not found"
end

local coin_ids = {
  fart = "fartcoin-fartcoin",
  doge = "doge-dogecoin",
  bit = "btc-bitcoin"
}

local function checkPrice(ctx)
  local args = ctx.words
  local coin_name = args[2] and args[2]:lower() or "fart" -- Default to "fart" if no argument is provided
  local message_type = args[3] and args[3]:lower() or "s" -- Default to "s" if no argument is provided

  local coin_id = coin_ids[coin_name]

  if not coin_id then
    ctx.channel:add_system_message("Invalid coin name. Supported coins: fart, doge, bit")
    return
  end

  if message_type ~= "c" and message_type ~= "s" then
    ctx.channel:add_system_message("Invalid message type. Use 'c' or 's'.")
    return
  end

  local url = "https://api.coinpaprika.com/v1/tickers/" .. coin_id
  local request = c2.HTTPRequest.create(c2.HTTPMethod.Get, url)

  request:set_timeout(5000)

  request:on_success(function(res)
    local data = res:data()
    local price = extractPrice(data)
    local message = coin_name:gsub("^%l", string.upper) .. 'coin price: $' .. price

    if message_type == "c" then
      ctx.channel:send_message(message)
    else
      ctx.channel:add_system_message(message)
    end
  end)

  request:on_error(function(res)
    ctx.channel:add_system_message('Error: ' .. res:error())
  end)

  request:execute()
end

local function coinHelp(ctx)
  ctx.channel:add_system_message("Coin Command:")
  ctx.channel:add_system_message(
    "/checkcoin <fart|doge|bit> <c|s>` - display price of specified coin, c - send as chat message, s to display just for you")
  ctx.channel:add_system_message("Ex: /checkcoin fart s")
end

c2.register_command("/checkcoin", checkPrice)
c2.register_command("/coinhelp", coinHelp)
