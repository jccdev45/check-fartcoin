function extractPrice(jsonString)
  local pricePattern = '"price":(%d+%.%d+)'
  local price = jsonString:match(pricePattern)
  return price or "Price not found"
end

function checkPrice(ctx)
  local url = "https://api.coinpaprika.com/v1/tickers/fartcoin-fartcoin"
  local request = c2.HTTPRequest.create(c2.HTTPMethod.Get, url)

  request:set_timeout(5000)

  request:on_success(function(res)
    local data = res:data()
    local price = extractPrice(data)
    ctx.channel:send_message('Fartcoin price: $' .. price)
  end)

  request:on_error(function(res)
    ctx.channel:add_system_message('Error: ' .. res:error())
  end)

  request:execute()
end

c2.register_command("/fartcoin", checkPrice)
