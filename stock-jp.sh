#!/bin/bash

set -Ceu

SCRIPT_FILE_NAME=$(basename $0)
SCRIPT_NAME=${SCRIPT_FILE_NAME%.*}
SELF=$(cd $(dirname $0); pwd)
LOGGING=false
VERSION="0.1.0"
SEPARATER='---------------------------'

function _usage() {
    echo "Usage: ${SCRIPT_NAME} [OPTIONS] FILE"
    echo "  Search a security in stock market Tokyo@japan."
    echo
    echo "Options:"
    echo "  -h, --help                      Show help"
    echo "  -v, --version                   Show script version"
    echo "      --update                    Update stock data"
    echo "      --verbose                   Print various logging information"
    echo
    exit 0
}

function _log() {
    ${LOGGING} && echo "$@" || return 0
}

function _err() {
    echo "$1" && exit 1
}

function _is_cmd_exist() {
    type $@ > /dev/null 2>&1
}

function _is_file_exist() {
    [ -f $1 ] > /dev/null 2>&1
}

function _is_dir_exist() {
    [ -d $1 ] > /dev/null 2>&1
}

# -------------------------------------------------------------

ARG_VALUES=()
OPT_A=""
OPT_B=""
OPT_C=false
IS_FLAG_P=false
IS_FLAG_Z=false

# STOCK_SEARCH_DIR="${HOME}/.stock-jp"
STOCK_SEARCH_DIR="data/"
STOCK_DATA_FILE="stock.csv"


function _download_stock_data() {
    mkdir -p ${STOCK_SEARCH_DIR}
    url='https://www.jpx.co.jp/markets/statistics-equities/misc/tvdivq0000001vg2-att/data_j.xls'
    curl ${url} -o ${STOCK_SEARCH_DIR}/stock.xls && {
        echo 'updated!'
    }
}

function _jp_stock_search() {
    local security_code
    security_code=$(
            cat ${STOCK_SEARCH_DIR}/${STOCK_DATA_FILE} | \
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

    } && [ ! -z ${site} ] && {
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


function _main() {
    if ! type peco > /dev/null 2>&1; then
        echo "need peco."
        exit 1
    fi
    _jp_stock_search
}

# -------------------------------------------------------------

function _init() {
    while (( $# > 0 )); do
        case $1 in
            -h | --help)
                _usage
                exit 1
                ;;
            -v | --version)
                echo ${SCRIPT_NAME} v${VERSION}
                exit 0
                ;;
            --verbose)
                LOGGING=true
                shift
                ;;

            # Must have argument
            -a | --long-a)
                set +u
                if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                    _err "-a option requires a value."
                fi
                set -u
                OPT_A=$2
                shift 2
                ;;

            # Either with or without argument is possible
            -b | --long-b)
                set +u
                if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                    shift
                else
                    OPT_B=$2
                    shift 2
                fi
                set -u
                ;;

            # no argument
            -c | --long-c)
                shift 1
                ;;

            # after this all args include '-xx', will treat arg value
            -- | -)
                shift 1
                ARG_VALUES+=( "$@" )
                break
                ;;

            # for true or false flags, no argument
            --*)
                if [[ "$1" =~ 'update' ]]; then
                    _download_stock_data
                    exit 0
                fi
                shift
                ;;

            # for true or false flags, no argument
            -*)
                if [[ "$1" =~ 'b' ]]; then
                    IS_FLAG_P='true'
                fi
                shift
                ;;

            # arguments
            *)
                ARG_VALUES+=("$1")
                shift
                ;;
        esac
    done

    _set_static_var
}

function _set_static_var() {
    ARG_VALUES=$@
}

function _verbose() {
    _log "ARG_VALUES: ${ARG_VALUES[@]}"
    _log "OPT_A: ${OPT_A}"
    _log "OPT_B: ${OPT_B}"
    _log "IS_FLAG_P: ${IS_FLAG_P}"
    _log "${SEPARATER}"
}

function _verify_static_var() {
    :
}

function _args_check() {
    :
    #if [ ${#ARG_VALUES[@]} -eq 0 ]; then
    #    _err 'no argument.'
    #elif ! _is_file_exist ${ARG_VALUES[0]}; then
    #    _err 'No such file.'
    #fi
}

# -------------------------------------------------------------
# Main Routine
# -------------------------------------------------------------
_init $@ && _args_check && _verbose && {
    _log 'start main process..' && _log "${SEPARATER}"
    _main
}

exit 0

