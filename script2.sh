
echo_notice() {
    msg=$1
    RED='\033[0;32m'
    NC='\033[0m' # No Color
    printf "\n${RED}${msg}${NC}"
}


bst_flag=0
ip_check=0
parallel_threads=1

optspec=":c:-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                browserstack)
                    bst_flag=1
                    ;;
                ip-check)
                    ip_check=1
                    ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                    fi
                    ;;
            esac;;
        c) parallel_threads=$OPTARG;;
    esac
done


if [[ $bst_flag -eq 1 ]]
then
    echo_notice "Running session orowserstack" >&2
    ROOT=https://rutvikchandla_2MEern:QRRxxzZRAZxqQFLsocrk@hub-cloud.browserstack.com/wd/hub
else
    echo_notice "Running session on selenium.." 
    ROOT=http://192.168.0.101:4444
fi

main() {
    echo_notice "Fetching status ... \n" 
    echo ${ROOT}/status 
    curl ${ROOT}/status | jq '.status'

    for ((i = 1 ; i <= $parallel_threads ; i++)); do
        run_session &
    done

    wait
}

run_session(){
    if [[ $bst_flag -eq 1 ]]
        then
            SESSION_ID=$(get_session_id_bst) 
        else
            SESSION_ID=$(get_session_id)
        fi
        SESSION_IDS+=($SESSION_ID)
        BASE_URL=${ROOT}/session/${SESSION_ID}
        local rtt=$(navigate_to 'https://requestbin.net/ip')
        local body=$(find_body_element)
        local ip_add=$(curl --silent ${BASE_URL}/element/${body}/text | jq -r '.value')
        curl --silent -o /dev/null -X DELETE ${BASE_URL}
        echo_notice "$ip_add \n$rtt\n\n"
}

get_session_id_bst() {
    curl --silent -s -X POST -H 'Content-Type: application/json;charset=UTF-8'\
        -d '{
            "desiredCapabilities": {
                "browserName": "Chrome",
                "os": "OS X",
                "os_version": "Sierra",
                "browser_version": "65.0",
                "build": "selenium-bash-assesment",
                "acceptSslCerts": true,
                "browserstack.debug": true,
                "browserstack.console": "verbose",
                "name": "Session no '${i}' starts-at '$(date +"%T")'",
                "javascriptEnabled": true
            }
        }' \
        -s ${ROOT}/session | jq -r '.sessionId' 
}

get_session_id() {
    curl --silent -s -X POST -H 'Content-Type: application/json;charset=UTF-8'\
        -d '{
            "desiredCapabilities": {
                "browserName": "chrome"
            }
        }' \
        ${ROOT}/session | jq -r '.sessionId'
}

find_body_element() {
    local property=$1
    local value=$2
    curl --silent -s -X POST -H 'Content-Type: application/json;charset=UTF-8' \
    -d '{"using":"tag name", "value": "body"}' ${BASE_URL}/element | jq -r '.value.ELEMENT'
}

navigate_to() {
    local url=$1
    curl --silent -w "@curl-format.txt" -s -X POST -H 'Content-Type: application/json;charset=UTF-8' -d '{"url":"'${url}'"}' ${BASE_URL}/url 
}

main