function _jp_stock_search() {
    local stock_search_dir="${HOME}/.stock-jp"
    local security_code
    # curl https://www.jpx.co.jp/markets/statistics-equities/misc/tvdivq0000001vg2-att/data_j.xls -o ${stock_search_dir}/stock.csv

    security_code=$(
            cat ${stock_search_dir}/stock.csv | \
            cut -d ',' -f 2-4 | \
            nkf -Z1 | \
            column -s ',' -t | \
            peco --prompt "Stock JP >" --query ${@:-''} | \
            sed -e 's/^.*\([0-9]\{4\}\).*/\1/g'
        )
    [ ! -z ${security_code} ] && {
        site=$({
            echo "Yahoo! Finance"
            echo "Google"
            echo "SBI証券"
            echo "Quick（株価）"
            echo "Quick（適時開示）"
            echo "会社四季報"
            echo "日経（株価）"
            echo "日経（適時開示）"
        } | peco )

        local url=''
        case ${site} in
            "Yahoo! Finance" )
                url="https://stocks.finance.yahoo.co.jp/stocks/detail/?code=${security_code}"
                ;;
            "Google" )
                url="https://www.google.com/search?q=${security_code}"
                ;;
            "SBI証券" )
                url="https://site1.sbisec.co.jp/ETGate/?_ControlID=WPLETsiR001Control&_PageID=WPLETsiR001Idtl10&_DataStoreID=DSWPLETsiR001Control&_ActionID=stockDetail&s_rkbn=2&s_btype=&i_stock_sec=${security_code}&i_dom_flg=1&i_exchange_code=JPN&i_output_type=0&exchange_code=TKY&stock_sec_code_mul=${security_code}&ref_from=1&ref_to=20&infoview_kbn=2&PER=&wstm4130_sort_id=&wstm4130_sort_kbn=&qr_keyword=1&qr_suggest=1&qr_sort=1"
                ;;
            "Quick（株価）" )
                url="https://moneyworld.jp/stock/${security_code}"
                ;;
            "Quick（適時開示）" )
                url="https://moneyworld.jp/stock/${security_code}/news"
                ;;
            "会社四季報" )
                url="https://shikiho.jp/stocks/${security_code}/"
                ;;
            "日経" )
                url="https://www.nikkei.com/nkd/company/?scode=${security_code}"
                ;;
            "日経（適時開示）" )
                url="https://www.nikkei.com/nkd/company/disclose/?scode=${security_code}"
                ;;
        esac
        open ${url}
    }
}
alias stock="_jp_stock_search"
