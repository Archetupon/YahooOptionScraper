# YahooOptionScraper
This MATLAB function allows one to scrape the entire option chain of multiple expiries for stocks, ETFs, and indices from the Options tab on Yahoo Finance. The code works with the current html format, as previous codes on FileExchange such as Peter Radkov's are out of date and not useable. The function only needs one input, the ticker, and the user is able to choose which maturities they would like to retrieve chains for via a prompt. The option chains are then exported as Excel files to the directory with a descriptive filename. For example, if one desired the 2nd and 3rd maturity out option chains for the the SPDR SPY ETF, and the 2nd, 3rd, and 5th out for the S&P 500 index, you would call:

[call_table_SPY,put_table_SPY] = YahooOptionScraper('SPY');
after prompt -> [2;3] <enter>

[call_table_SPX,put_table_SPX] = YahooOptionScraper('^SPX');
after prompt -> [2;3;5] <enter>

****Note that you need to have cell2str.m in your directory as well. This is available for download on the FileExchange****
