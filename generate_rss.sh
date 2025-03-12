#!/bin/bash

# 設定
JSON_URL="https://www.jst.go.jp/moonshot/js/newsitem_js.json"
RSS_FILE="rss.xml"
TEMP_JSON="news.json"
TEMP_RSS="rss_temp.xml"
DAYS_LIMIT=14
TODAY=$(date -u +"%Y-%m-%d")
START_DATE=$(date -u -d "-${DAYS_LIMIT} days" +"%Y-%m-%d")

# JSONデータを取得
curl -s "$JSON_URL" -o "$TEMP_JSON"

# 最新14日間のデータを抽出し、日付を RFC-2822 形式に変換
jq --arg start_date "$START_DATE" --arg today "$TODAY" '
  map(.news_date |= gsub("/"; "-")) # YYYY/MM/DD → YYYY-MM-DD に変換
  | map(select(.news_date >= $start_date and .news_date <= $today))
  | sort_by(.news_date) | reverse
  | map({
      title: .top_and_news_title,
      link: if .news_url | startswith("/") then "https://www.jst.go.jp" + .news_url else .news_url end,
      date: (.news_date + " 00:00:00 UTC") | strptime("%Y-%m-%d %H:%M:%S %Z") | mktime | strftime("%a, %d %b %Y %H:%M:%S GMT")
    })
' "$TEMP_JSON" > filtered_news.json

# RSSヘッダー作成
cat <<EOF > "$TEMP_RSS"
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>Moonshot News RSS</title>
  <link>https://github.com/Moonshot/rss</link>
  <description>ムーンショット型研究開発制度の最新ニュース</description>
  <language>ja</language>
EOF

# 各ニュースアイテムをRSSに追加
jq -r '
  .[] | 
  "<item>
     <title>" + .title + "</title>
     <link>" + .link + "</link>
     <pubDate>" + .date + "</pubDate>
   </item>"
' filtered_news.json >> "$TEMP_RSS"

# RSSフッター
echo "</channel></rss>" >> "$TEMP_RSS"

# 差分チェックと更新
if [ -f "$RSS_FILE" ]; then
  if diff -q "$RSS_FILE" "$TEMP_RSS" >/dev/null; then
    echo "No changes in RSS feed."
    rm "$TEMP_RSS"
    exit 0
  fi
fi

# 更新がある場合、ファイルを置き換え
mv "$TEMP_RSS" "$RSS_FILE"

echo "RSS feed updated."
