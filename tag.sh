#!/bin/bash

curl -X GET --header 'Content-Type: application/json;charset=UTF-8' "https://gitee.com/api/v5/repos/smoa-new/valsex/raw/BUILD?access_token=$GITEE_APIKEY&ref=config" | tee /tmp/valsex-build

n=$(($(cat /tmp/valsex-build)+1))

curl -X PUT --header 'Content-Type: application/json;charset=UTF-8' 'https://gitee.com/api/v5/repos/smoa-new/valsex/contents/BUILD' -d '{"access_token":"'"$GITEE_APIKEY"'","content":"'$(printf $n | base64)'","sha":"56a6051ca2b02b04ef92d5150c9ef600403cb1de","message":"test: update","branch":"config"}'

echo $(n)

