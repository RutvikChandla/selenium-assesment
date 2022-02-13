echo_notice() {
    msg=$1
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    printf "\n${GREEN}${msg}${NC}"
}

echo_notice "Running session on selenium.." 
ROOT=http://192.168.0.101:4444

main() {
    SESSION_ID=$(get_session_id)
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