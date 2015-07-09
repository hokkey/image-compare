image-compare
===============

GraphicsMagickによるPDFの比較ツール

# インストール

```
git clone (このリポジトリパスのパス)
brew update && brew upgrade
brew install node graphicsmagick gs
cd (cloneしたワーキングコピーのパス)
npm install
```

# 使い方

<pre>
image-compare/
├── _old/
├── _new/
├── package.json
└── gulpfile.coffee
</pre>

1. `_old/` ディレクトリを作成し、そこへ比較元のPDFデータを入れる
2. `_new/` ディレクトリを作成し、そこへ比較先のPDFデータを入れる
3. 新旧のPDFは **必ずファイル名が完全に一致** しているようにする。複数ファイルをまとめて入れても良い
4. gulpfile.coffee と同じ階層上で `gulp` を実行
5. _diff.pdf に差分が出力される

# やっていること

1. `_old` 以下のPDFをすべて分解し、不可視階層 `.temp_old/` 以下に保存
2. `_new/` 以下のPDFをすべて分解し、不可視階層 `.temp_new/` 以下に保存
3. `.temp_old, .temp_new` 以下のファイルを順番に `gm compare` し、結果を `.temp_out/` 以下に保存
4. 各不可視フォルダ内のPDFをすべて結合して保存する

# 注意点

不可視フォルダ内のゴミは、gulpを行う度に削除される。
削除せずに比較だけをやり直したい場合は `gulp compare` コマンドを実行すること

不可視フォルダ内のゴミ削除は `gulp clean` コマンドでも可能