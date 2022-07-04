{browser, stockMqtt, Peers} = require 'aastocks'
{breadth} = require 'analysis'

describe 'hsi', ->
  hsi = []

  it 'hsi constituents', ->
    peers = new Peers
      browser: await browser()
      mqtt: stockMqtt()
    list = await peers.constituent 'http://www.aastocks.com/en/stocks/market/index/hk-index-con.aspx'
    for stock in list
      hsi.push stock['symbol']
    console.log hsi
    console.log await breadth hsi
