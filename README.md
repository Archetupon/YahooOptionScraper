# YahooOptionScraper
This MATLAB function allows one to scrape the entire option chain of a given expiry for stocks, ETFs, and indices from the Options tab on Yahoo Finance. The code works with the current html format, as previous codes on FileExchange such as Peter Radkov's are out of date and not useable. The function only needs two inputs, and the option chains are exported as Excel files to the directory with a descriptive filename. For example, if one desired the current option chains for the the SPDR SPY ETF, the GLD Gold ETF, the TLT Long Bond ETF, and the S&P 500 index, you would call:

[call_table_SPY,put_table_SPY] = YahooOptionScraper('SPY','2018-06-15');

[call_table_GLD,put_table_GLD] = YahooOptionScraper('GLD','2018-06-15');

[call_table_TLT,put_table_TLT] = YahooOptionScraper('TLT','2018-06-15');

[call_table_SPX,put_table_SPX] = YahooOptionScraper('^SPX','2018-06-15');

This should all take around 30 seconds, and the majority of this time is due to the writing of the Excel files.

****Note that you need to have cell2str.m in your directory as well. This is available for download on the FileExchange
