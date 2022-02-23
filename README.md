# nac_tech_blog

---

## なにこれ

みんなが外部に公開する記事を置いとく場所。

---

## 執筆する環境

とりあえずホソノ環境を書いとく

エディタ

- VSCODE
- VSCODE Plugins
  - Prettier - Code formatter
  - markdownlint

---

## 記事を書く流れ

```zsh
# リポジトリを落としてくる
git clone https://github.com/nac-care/nac_tech_blog.git

# 移動して
cd nac_tech_blog

# 適当なブランチ作って
git checkout -b hosono_document

# マークダウンで記事を書いて
touch blogs/my_demo_article.md
vi blogs/my_demo_article.md

# Qiita投稿用の設定ファイル書いて(記事のファイル名の後ろに.jsonをつけてね)
touch blogs/my_demo_article.md.json

# pushして
git add .
git commit -m "hosono demo article"
git push

# CIの結果を確認して
# UI : https://github.com/nac-care/nac_tech_blog/actions
gh run list --limit 5

# OKならmasterブランチに対してPRを作成して
# UI : https://github.com/nac-care/nac_tech_blog/pulls > New pull request
gh pr create --base master --title "hosono article : demo" --body "hosono article : demo"

# 誰かにレビューしてもらう

# マージしてもらう

# 記事が投稿される
```

---

## りんく

- hogehoge <https://gitlab.com/naccare/biz-solutions/tech-div>
