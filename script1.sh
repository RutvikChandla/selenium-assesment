echo_notice() {
    msg=$1
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    printf "\n${GREEN}${msg}${NC}"
}
bst_flag=0

optspec=":-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                browserstack)
                    bst_flag=1
                    ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                    fi
                    ;;
            esac;;
    esac
done


if [[ $bst_flag -eq 1 ]]
then
    echo_notice "Running session orowserstack" >&2
    USERNAME="YOUR_USER_NAME"
    ACCESSKEY="YOUR_ACCESS_KEY"
    ROOT="https://${USERNAME}:${ACCESSKEY}@hub-cloud.browserstack.com/wd/hub"
else
    echo_notice "Running session on selenium.." 
    ROOT=http://192.168.0.101:4444
fi

main() {
    if [[ $bst_flag -eq 1 ]]
    then
        SESSION_ID=$(get_session_id_bst)
    else
        SESSION_ID=$(get_session_id)
    fi

    navigate_to 'https://google.co.in'
    searchBox=$(find_element 'name' 'q')
    send_keys $searchBox "rutvik\n"
    curl ${BASE_URL}/title | jq '.value'
    curl -X DELETE ${BASE_URL}
}

get_session_id() {
    curl -s -X POST -H 'Content-Type: application/json;charset=UTF-8' \
        -d '{
            "desiredCapabilities": {
                "browserName": "chrome"
            }
        }' \
        ${ROOT}/session | jq -r '.sessionId'
}

get_session_id_bst() {
    curl -s -X POST -H 'Content-Type: application/json;charset=UTF-8' -H 'Accept-CH: RTT' -H 'Keep-Alive: true'\
        -d '{
            "desiredCapabilities": {
                "browserName": "Chrome",
                "os": "OS X",
                "os_version": "Sierra",
                "browser_version": "65.0",
                "build": "selenium-bash-assesment",
                "acceptSslCerts": true,
                "browserstack.debug": true,
                "browserstack.console": "verbose"
            }
        }' \
        ${ROOT}/session | jq -r '.sessionId'
}

navigate_to() {
    local url=$1
    curl -s -X POST -H 'Content-Type: application/json;charset=UTF-8' -d '{"url":"'${url}'"}' ${BASE_URL}/url
}

find_element() {
    local property=$1
    local value=$2
    curl -s -X POST -H 'Content-Type: application/json;charset=UTF-8' \
    -d '{"using":"'$property'", "value": "'$value'"}' ${BASE_URL}/element | jq -r '.value.ELEMENT'
}

send_keys() {
    local elementId=$1
    local value=$2
    curl -s -X POST -H 'Content-Type: application/json;charset=UTF-8' \
    -d '{"value": ["'$value'"]}' ${BASE_URL}/element/${elementId}/value >/dev/null 
}

main
