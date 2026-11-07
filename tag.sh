#!/bin/bash

# 1. 读当前值
n=$(curl -s -X GET "https://gitee.com/api/v5/repos/smoa-new/valsex/raw/BUILD?access_token=$GITEE_APIKEY&ref=config")
echo "当前值: [$n]"

# 2. 动态获取最新 SHA
sha=$(curl -s "https://gitee.com/api/v5/repos/smoa-new/valsex/contents/BUILD?access_token=$GITEE_APIKEY&ref=config" | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$sha" ]; then
  echo "❌ 获取 SHA 失败"
  exit 1
fi
echo "最新 SHA: [$sha]"

# 3. 自增
new_val=$((n + 1))
echo "新值: [$new_val]"

# 4. base64 编码
content_base64=$(echo -n "$new_val" | base64 -w 0)

# 5. 构造 payload 并上传（用动态 SHA）
payload="{\"access_token\":\"$GITEE_APIKEY\",\"content\":\"$content_base64\",\"sha\":\"$sha\",\"message\":\"test: update\",\"branch\":\"config\"}"

result=$(curl -s -X PUT \
  "https://gitee.com/api/v5/repos/smoa-new/valsex/contents/BUILD" \
  -H "Content-Type: application/json;charset=UTF-8" \
  -d "$payload")

echo "上传结果: $result"
echo "完成: $n -> $new_val"
