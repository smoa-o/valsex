#!/bin/bash

curl -s -X GET --header 'Content-Type: application/json;charset=UTF-8' "https://gitee.com/api/v5/repos/smoa-new/valsex/raw/BUILD?access_token=$GITEE_APIKEY&ref=config" | tee /tmp/valsex-build

n=$(($(cat /tmp/valsex-build)+1))

curl -s -X GET --header 'Content-Type: application/json;charset=UTF-8' 'https://gitee.com/api/v5/repos/smoa-new/valsex/contents/BUILD?access_token=7892513aeb48b493ece8e05c17e3bd97&ref=config' | tee /tmp/valsex-buildsha

curl -X PUT --header 'Content-Type: application/json;charset=UTF-8' 'https://gitee.com/api/v5/repos/smoa-new/valsex/contents/BUILD' -d '{"access_token":"'"$GITEE_APIKEY"'","content":"'$(printf $n | base64)'","sha":"'"$(jq '.sha' /tmp/valsex-buildsha)"'","message":"test: update","branch":"config"}'

echo $(n)

