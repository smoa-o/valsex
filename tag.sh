#!/bin/bash
curl -s -X GET \
  "https://gitee.com/api/v5/repos/smoa-new/valsex/raw/BUILD?access_token=$GITEE_APIKEY&ref=config" \
  -o /tmp/valsex-build
n=$(cat /tmp/valsex-build)
content_base64=$(echo -n $(($(printf $n) + 1)) | base64 -w 0)
payload=$(jq -n \
  --arg tok "$GITEE_APIKEY" \
  --arg content "$content_base64" \
  '{
    access_token: $tok,
    content: $content,
    sha: "56a6051ca2b02b04ef92d5150c9ef600403cb1de",
    message: "test: update",
    branch: "config"
  }')
curl -s -X PUT \
  "https://gitee.com/api/v5/repos/smoa-new/valsex/contents/BUILD" \
  -H "Content-Type: application/json;charset=UTF-8" \
  -d "$payload"

echo $"\n$n"

