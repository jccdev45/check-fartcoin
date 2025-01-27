local coin_ids = {
  fart = "fartcoin-fartcoin",
  doge = "doge-dogecoin",
  bit = "btc-bitcoin"
}

function extractPrice(jsonString)
  local pricePattern = '"price":(%d+%.%d+)'
  local price = jsonString:match(pricePattern)
  return price or "Price not found"
end

function checkPrice(ctx)
  local args = ctx.words
  local coin_name = args[2] and args[2]:lower() or "fart" -- Default to "fart" if no argument is provided
  local coin_id = coin_ids[coin_name]

  if not coin_id then
    ctx.channel:add_system_message("Invalid coin name. Supported coins: fart, doge, bit")
    return
  end

  local url = "https://api.coinpaprika.com/v1/tickers/" .. coin_id
  local request = c2.HTTPRequest.create(c2.HTTPMethod.Get, url)

  request:set_timeout(5000)

  request:on_success(function(res)
    local data = res:data()
    local price = extractPrice(data)
    ctx.channel:send_message(coin_name:gsub("^%l", string.upper) .. 'coin price: $' .. price)
  end)

  request:on_error(function(res)
    ctx.channel:add_system_message('Error: ' .. res:error())
  end)

  request:execute()
end

c2.register_command("/checkcoin", checkPrice)