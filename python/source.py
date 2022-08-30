from datetime import datetime
from binance import Client
client = Client()
df = {
  'date': [],
  'open': [],
  'high': [],
  'low': [],
  'close': [],
  'volume': []
}

for row in client.get_historical_klines("ETHBUSD", Client.KLINE_INTERVAL_1MINUTE):
  openTime, open, high, low, close, volume, closeTime, quote, trade, baseVol, quoteVol, ignore = row
  df['date'].append(datetime.fromtimestamp(closeTime/1000))
  df['open'].append(float(open))
  df['high'].append(float(high))
  df['low'].append(float(low))
  df['close'].append(float(close))
  df['volume'].append(float(volume))

import pandas as pd
import ta
data = pd.DataFrame(df)
data = ta.add_all_ta_features(data, 'open', 'high', 'low', 'close', 'volume', fillna=True)
print(data)
