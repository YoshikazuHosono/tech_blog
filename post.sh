#!/bin/bash

if [ $# != 1 ]; then
    echo "引数の数が不正です。"
    exit 1
fi

if [ ! -e $1 ];then
  echo "指定された記事が存在しません。"
  exit 1
fi

if [ ! -e ${1}.json ];then
  echo "記事に対応する設定ファイルが存在しません。"
  exit 1
fi

curl -X POST \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer `cat ${1}.json | jq .token -r`" \
	-d "{\"body\":`cat ${1} | jq @text -Rs`, \"tags\":`cat ${1}.json | jq .tags | jq @json -r`, \"title\":`cat ${1}.json | jq .title`}" \
	https://qiita.com/api/v2/items
