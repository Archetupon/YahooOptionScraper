function [call_table,put_table] = YahooOptionScraper(ticker)

%FUNCTION
%   Function obtains stocks and indexes option chains from Yahoo finance
%   ****Note that you need to have cell2str.m in your directory as well. This is available for download on the FileExchange
%
%INPUT arguments: 
%   Ticker: string format! Yahoo Finance compatible ticker, for index there should be
%   '^...', i.e. ^SPX for the S&P500 index
%
%OUTPUT arguments:
%   call and put option tables with structure 'Last_Trade_Date', 'Expiration', 'Strike', 'OptType',
%   'Last_Price', 'Bid', 'Ask', 'Change','Per Change', 'Volume',
%   'Open Interest', 'Implied Volatility'. These are then exported as
%   .xlsx files to the current directory
%
%EXAMPLE
%   The following would have extracted call and put options for SPY
%   expiring on June 15th, 2018, and June 20th, 2018. At the time,
%   these were the 2nd and 3rd contracts
%
%   [call_table,put_table] = YahooOptionScraper('SPY');
%   **after prompt [2;3] <enter>

%++ Contrust url ++%   
Basename1 = 'https://finance.yahoo.com/quote/';
Basename2 = '/options?p=';
url1 = [Basename1,ticker,Basename2,ticker];

%++ Grab Yahoo Finance base url and html code ++%
html1 = webread(url1);
%***************************************************%

%++ Grab html code which contains active maturities ++%
pattern1 = 'OptionContractsStore';% start of list
pattern2 = 'hasMiniOptions';     % end of list
list = extractBetween(html1, pattern1, pattern2); 
list = cell2str(list);
%***************************************************%

%++ Grab active maturities and prompt user for choice ++%
pattern1 = '"expirationDates":[';% start of list
pattern2 = '],"';     % end of list
maturities = extractBetween(list, pattern1, pattern2);
maturities = cell2str(maturities);
maturities = maturities(3:end-3);
maturities = strsplit(maturities,',');
maturities_store = strings(length(maturities),1);
for i=1:length(maturities_store)
    maturities_store(i) = maturities{i};
end
maturities_store = str2double(maturities_store); 
epoch = '01-Jan-1970';
formatIn = 'dd-mmm-yyyy';
time_matlab = ones(length(maturities_store),1).*datenum(epoch,formatIn) + maturities_store./86400;
maturities_hooman_read = datestr(time_matlab,'yyyy-mm-dd');
maturities_index = ones(size(maturities_hooman_read,1),1);
maturities_index = cumsum(maturities_index);
pad = strings(length(maturities_index),1);
fprintf('Currently Active Maturities for ');
fprintf(ticker);
fprintf(' are: \n');
disp([maturities_index pad maturities_hooman_read])
fprintf('Please enter the indexes (left side numbers) for the maturities you want and press enter. \n');
fprintf('If you simply want all currently available, enter 0. \n');
prompt = 'For multiple maturities, you need to enter in array of the form [x;y;z] \n';
user_choice = input(prompt);
if user_choice == 0
    user_choice = (1:1:length(maturities_index))';
end
user_maturities = maturities_hooman_read(user_choice,:);
%***************************************************%

for k=1:length(user_choice)

 %++ Change expiration date back to UNIX time per Yahoo url format ++%
 d = datetime(user_maturities(k,:));
 d = num2str(posixtime(d));
 %***************************************************%

 %++ Contruct url ++%
 Basename3 = 'https://finance.yahoo.com/quote/';
 Basename4 = '/options?p=';
 Basename5 = '&date=';
 url2 = [Basename3,ticker,Basename4,ticker,Basename5,d];
 
 %++ Grab Yahoo Finance base url and html code ++%
 html2 = webread(url2);
 %***************************************************%

 %++ Start with call options first ++%
 pattern1 = '{"calls":[{';% start of list
 pattern2 = '"puts":[{';     % end of list
 list = extractBetween(html2, pattern1, pattern2); 
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
 list = extractBetween(html2, pattern1, pattern2); 
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
 call_file_name =[date,ticker,'CallOptionChain',user_maturities(k,:),'.xlsx'];
 writetable(call_table,call_file_name)
 put_file_name =[date,ticker,'PutOptionChain',user_maturities(k,:),'.xlsx'];
 writetable(put_table,put_file_name)
 %***************************************************%
end
end
