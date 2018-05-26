function [call_table,put_table] = YahooOptionScraper(ticker,ExpDate)

%FUNCTION
%   Function obtains stocks and indexes option chains from Yahoo finance
%
%INPUT arguments: 
%   Ticker: string format! Yahoo Finance compatible ticker, for index there should be
%   '^...', i.e. ^SPX for the S&P500 index
%   ExpDate: string format of 'yyyy-MM-dd'. Currently you need to look up a
%   real expiry date (possible improvement of this in the future to choose
%   nth out expiry. The code automatically converts this to UNIX time for
%   the Yahoo url
%
%OUTPUT arguments:
%   call and put option tables with structure 'Last_Trade_Date', 'Expiration', 'Strike', 'OptType',
%   'Last_Price', 'Bid', 'Ask', 'Change','Per Change', 'Volume',
%   'Open Interest', 'Implied Volatility'. These are then exported as
%   .xlsx files to the current directory
%
%EXAMPLE
%   The following would have extracted call and put options for SPY,IAU,
%   and TLT expiring on June 15th, 2018. This should all take around 30
%   second (and most of that is due to the writing of the excel files)
%
%   [call_table_SPY,put_table_SPY] = YahooOptionScraper('SPY','2018-06-15');
%   [call_table_IAU,put_table_GLD] = YahooOptionScraper('','2018-06-15');
%   [call_table_TLT,put_table_TLT] = YahooOptionScraper('TLT','2018-06-15');
%   [call_table_SPX,put_table_SPX] = YahooOptionScraper('^SPX','2018-06-15'); 

if nargin < 2
    error('input function has one agument, it require minimum two inputs')
    return;
end

%++ Change expiration date to UNIX time per Yahoo url format ++%
d = datetime(ExpDate);
d = num2str(posixtime(d));
%***************************************************%

%++ Contrust url ++%
Basename1 = 'https://finance.yahoo.com/quote/';
Basename2 = '/options?p=';
Basename3 = '&date=';
url = [Basename1,ticker,Basename2,ticker,Basename3,d];
%***************************************************%

%++ Grab Yahoo Finance url and html code ++%
html = webread(url);
%***************************************************%

%++ Start with call options first ++%
pattern1 = '{"calls":[{';% start of list
pattern2 = '"puts":[{';     % end of list
list = extractBetween(html, pattern1, pattern2); 
list = cell2str(list);
%***************************************************%

%++ First extract the formatted values ++%
%++ This applies to all values expect the percentages ++%
pattern1 = '"fmt":"';
pattern2 = '"';
floats = extractBetween(list, pattern1, pattern2); 
%***************************************************%

%++ Now extract the raw values ++%
%++ This is needed for the percetages ++%
pattern1 = '"raw":';
pattern2 = ',';
decimals = extractBetween(list, pattern1, pattern2); 
%***************************************************%

%++ Initialize string vectors to store values ++%
implied_volatilities = strings(length(decimals)/11,1);
expirations = strings(length(floats)/11,1);
changes = strings(length(floats)/11,1);
strikes = strings(length(floats)/11,1);
last_prices = strings(length(floats)/11,1);
open_interests = strings(length(floats)/11,1);
percentage_changes = strings(length(decimals)/11,1);
ask_prices = strings(length(floats)/11,1);
volumes = strings(length(floats)/11,1);
last_trade_dates = strings(length(floats)/11,1);
bid_prices = strings(length(floats)/11,1);
%***************************************************%

%++ Loop through, extracting option data ++%
count = 1;
for i=1:11:length(floats)
    implied_volatilities(count) = decimals{i};
    expirations(count) = floats{i+1};
    changes(count) = floats{i+2};
    strikes(count) = floats{i+3};
    last_prices(count) = floats{i+4};
    open_interests(count) = floats{i+5};
    percentage_changes(count) = decimals{i+6};
    ask_prices(count) = floats{i+7};
    volumes(count) = floats{i+8};
    last_trade_dates(count) = floats{i+9};
    bid_prices(count) = floats{i+10};
    count = count + 1;
end
%***************************************************%

%+++ Convert data points to appropriate formats +++%
implied_volatilities = str2double(implied_volatilities);
expirations = datetime(expirations,'InputFormat','yyyy-MM-dd');
changes = str2double(changes);
strikes = str2double(strikes);
last_prices = str2double(last_prices);
open_interests = str2double(open_interests);
percentage_changes = str2double(percentage_changes);
ask_prices = str2double(ask_prices);
volumes = str2double(volumes);
last_trade_dates = datetime(last_trade_dates,'InputFormat','yyyy-MM-dd');
bid_prices = str2double(bid_prices);
%***************************************************%

%++ Create table of option data ++%
call_table = table(last_trade_dates,expirations,strikes,last_prices,bid_prices,ask_prices,...
    changes,percentage_changes,volumes,open_interests,implied_volatilities);
call_table.Properties.VariableNames = {'Last_Trade_Date','Expiration','Strike','Last_Price','Bid',...
    'Ask','Change','Per_Change','Volume','Open_Interest','Implied_Volatility'};
%***************************************************%

%++ Now onto the put options ++%
pattern1 = '"puts":[{';% start of list
pattern2 = '}}],"sortColumn"';     % end of list
list = extractBetween(html, pattern1, pattern2); 
list = cell2str(list);
%***************************************************%

%++ First extract the formatted values ++%
%++ This applies to all values expect the percentages ++%
pattern1 = '"fmt":"';
pattern2 = '"';
floats = extractBetween(list, pattern1, pattern2); 
%***************************************************%

%++ Now extract the raw values ++%
%++ This is needed for the percetages ++%
pattern1 = '"raw":';
pattern2 = ',';
decimals = extractBetween(list, pattern1, pattern2); 
%***************************************************%

%++ Initialize string vectors to store values ++%
implied_volatilities = strings(length(decimals)/11,1);
expirations = strings(length(floats)/11,1);
changes = strings(length(floats)/11,1);
strikes = strings(length(floats)/11,1);
last_prices = strings(length(floats)/11,1);
open_interests = strings(length(floats)/11,1);
percentage_changes = strings(length(decimals)/11,1);
ask_prices = strings(length(floats)/11,1);
volumes = strings(length(floats)/11,1);
last_trade_dates = strings(length(floats)/11,1);
bid_prices = strings(length(floats)/11,1);
%***************************************************%

%++ Loop through, extracting option data ++%
count = 1;
for i=1:11:length(floats)
    implied_volatilities(count) = decimals{i};
    expirations(count) = floats{i+1};
    changes(count) = floats{i+2};
    strikes(count) = floats{i+3};
    last_prices(count) = floats{i+4};
    open_interests(count) = floats{i+5};
    percentage_changes(count) = decimals{i+6};
    ask_prices(count) = floats{i+7};
    volumes(count) = floats{i+8};
    last_trade_dates(count) = floats{i+9};
    bid_prices(count) = floats{i+10};
    count = count + 1;
end
%***************************************************%

%+++ Convert data points to appropriate formats +++%
implied_volatilities = str2double(implied_volatilities);
expirations = datetime(expirations,'InputFormat','yyyy-MM-dd');
changes = str2double(changes);
strikes = str2double(strikes);
last_prices = str2double(last_prices);
open_interests = str2double(open_interests);
percentage_changes = str2double(percentage_changes);
ask_prices = str2double(ask_prices);
volumes = str2double(volumes);
last_trade_dates = datetime(last_trade_dates,'InputFormat','yyyy-MM-dd');
bid_prices = str2double(bid_prices);
%***************************************************%

%++ Create table of option data ++%
put_table = table(last_trade_dates,expirations,strikes,last_prices,bid_prices,ask_prices,...
    changes,percentage_changes,volumes,open_interests,implied_volatilities);
put_table = put_table(1:(size(put_table,1)-size(call_table,1)),:);
put_table.Properties.VariableNames = {'Last_Trade_Date','Expiration','Strike','Last_Price','Bid',...
    'Ask','Change','Per_Change','Volume','Open_Interest','Implied_Volatility'};
%***************************************************%

%++ Save tables as Excel files ++%
call_file_name =[date,ticker,'CallOptionChain',ExpDate,'.xlsx'];
writetable(call_table,call_file_name)
put_file_name =[date,ticker,'PutOptionChain',ExpDate,'.xlsx'];
writetable(put_table,put_file_name)
%***************************************************%

end
