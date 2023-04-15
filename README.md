# Wendigo

Wendigo is a collection of tools to enhance onchain trading of perps and small cap tokens. It offers two main features, a dex perp indexer/search engine for profitable traders, a Uniswap V3 analytics tool to determine the average balance weighted cost basis of pool participants, and a Uniswap V3 correlation calculator that determines the degree of crossover between pool participants in two Uniswap Pools. 



### To Run

`bundle install`

`rake db:create`

`rake db:migrate`

`rackup config.ru`

### To Seed Data

`irb -r ./app.rb`

`Trade.load_to_db`


