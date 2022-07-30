{Stock} = require 'yahoo-stock'

describe 'hsi', ->

  it '365 days data', ->
    hsi = new Stock '^hsi'
    console.log await hsi.historicalPrice()
