#!/bin/bash

# 下载并直接读值，不落盘
n=$(curl -s -X GET "https://gitee.com/api/v5/repos/smoa-new/valsex/raw/BUILD?access_token=$GITEE_APIKEY&ref=config")

echo "当前值: [$n]"

# 自增
new_val=$((n + 1))
echo "新值: [$new_val]"

# base64 编码
content_base64=$(echo -n "$new_val" | base64 -w 0)

# 构造 payload 并上传
payload="{\"access_token\":\"$GITEE_APIKEY\",\"content\":\"$content_base64\",\"sha\":\"56a6051ca2b02b04ef92d5150c9ef600403cb1de\",\"message\":\"test: update\",\"branch\":\"config\"}"

result=$(curl -s -X PUT \
  "https://gitee.com/api/v5/repos/smoa-new/valsex/contents/BUILD" \
  -H "Content-Type: application/json;charset=UTF-8" \
  -d "$payload")

echo "上传结果: $result"
echo "完成: $n -> $new_val"
