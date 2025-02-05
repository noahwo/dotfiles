#!/bin/bash

# <swiftbar.hideAbout>false</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>false</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>false</swiftbar.hideSwiftBar>
# <swiftbar.font>Menlo</swiftbar.font>

# Function to fetch BTC price in USD from CoinGecko API
get_btc_price() {
    curl -s "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd,eur,gbp,jpy,cny" |
        jq '."bitcoin"'
}

# Get prices
PRICES=$(get_btc_price)

# Extract values using jq
USD=$(echo $PRICES | jq '.usd')
EUR=$(echo $PRICES | jq '.eur')
# GBP=$(echo $PRICES | jq '.gbp')
# JPY=$(echo $PRICES | jq '.jpy')
CNY=$(echo $PRICES | jq '.cny')

# Format numbers with thousands separator
format_number() {
    LC_NUMERIC="en_US.UTF-8" printf "%'d\n" ${1%.*}
}

# Display in menu bar
echo "₿ \$$(format_number $USD)"

# Display in dropdown
echo "---"
echo "🇪🇺 €$(format_number $EUR) (EUR)"
# echo "🇬🇧 £$(format_number $GBP) (GBP)"
# echo "🇯🇵 ¥$(format_number $JPY) (JPY)"
echo "🇨🇳 ¥$(format_number $CNY) (CNY)"
