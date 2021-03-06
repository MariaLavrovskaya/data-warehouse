import yfinance as yf
import pandas as pd


# # getting data for information table
pairs = ['BTC-USD', 'ETH-USD', 'HEX-USD', 'ADA-USD', 'USDT-USD', 'BNB-USD', 'XRP-USD', 'SOL1-USD', 'DOT1-USD', 'USDC-USD']
tickers = yf.Tickers('BTC-USD ETH-USD HEX-USD ADA-USD USDT-USD BNB-USD XRP-USD SOL1-USD DOT1-USD USDC-USD')
info_table = {pair: tickers.tickers[pair].info['name'] for pair in pairs}
info_dataframe = pd.DataFrame(data = {'abbr': info_table.keys(), 'name': info_table.values()}) #take only abbrevation and name from all available info
info_dataframe.to_csv('information.csv', index=False)

# # getting  historical data
for pair in pairs: 
    historical_data = yf.download("%s" %pair, start="2017-01-01", end="2021-09-23", group_by="ticker" )
    historical_data.to_csv('%s.csv' %pair, index=True)