_ = require 'lodash'
{Stock} = require 'yahoo-stock'
db = require('monk')(process.env.DB)

symbol = '^hsi'
days = 365 * 3

describe "get #{symbol} price data", ->
  it "for #{days} days", ->
    stock = new Stock symbol
    data = (await stock.historicalPrice days)
      .map (price) ->
        db
          .get 'price'
          .insert _.extend price, {symbol: symbol, date: new Date price.date * 1000}
