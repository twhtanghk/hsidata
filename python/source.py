from binance import Client
client = Client()
klines = client.get_historical_klines("ETHBUSD", Client.KLINE_INTERVAL_1MINUTE)
print(klines)
