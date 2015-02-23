# Created by phpStorm.
#
# User: Yuma Hori
# Date: 15/02/20
# Desc: PDFを1ページごとに分解し、差分をPDFにまとめる

gulp = require 'gulp'
del = require 'del'
fs = require 'fs'
run = require 'run-sequence'
plugins = do require 'gulp-load-plugins'

dir = {}
dir.old = './_old'
dir.new = './_new'
dir.tempOld = '.temp_old'
dir.tempNew = '.temp_new'
dir.tempOut = '.temp_out'

dir.diffOutput = './_diff.pdf'
dir.newOutput = './_new.pdf'
dir.oldOutput = './_old.pdf'

gm = {}
gm.density = '-density 150x150'
gm.number = '%03d'
gm.format = '.pdf'
gm.compareStyle = 'xor'

newImages = []
oldImages = []


# 入力・出力PDFをそれぞれJPEGに分割する
gulp.task 'splitPdfOld', ->
	gulp.src ["#{dir.old}/*.pdf"], { read: false }
	.pipe shell ["gm convert #{gm.density} #{dir.old}/<%= file.relative %> +adjoin #{dir.tempOld}/<%= file.relative %>#{gm.number}#{gm.format}"]

gulp.task 'splitPdfNew', ->
	gulp.src ["#{dir.new}/*.pdf"], { read: false }
	.pipe shell ["gm convert #{gm.density} #{dir.new}/<%= file.relative %> +adjoin #{dir.tempNew}/<%= file.relative %>#{gm.number}#{gm.format}"]

# new,oldを両方分割する
gulp.task 'split', ['splitPdfOld', 'splitPdfNew']

# 分割されたJPEGを順番に比較し、結果を出力する
gulp.task 'compare', ->

	gulp.src '.', ->
		fs.readdir "#{dir.tempNew}", (err, files) ->

			commands = []
			newImages = []
			newImages = files

			for path in newImages
				commands.push "gm compare -highlight-style #{gm.compareStyle} -file #{dir.tempOut}/#{path} #{dir.tempOld}/#{path} #{dir.tempNew}/#{path}\n"

			commands.push "gm convert #{dir.tempOut}/* #{dir.diffOutput}\n"
			commands.push "gm convert #{dir.tempNew}/* #{dir.newOutput}\n"
			commands.push "gm convert #{dir.tempOld}/* #{dir.oldOutput}\n"
			commands.push "open #{dir.diffOutput}\n"

			console.log commands

			gulp.src '.'
				.pipe shell(commands)

# クリーン
gulp.task 'clean', (cb) ->
	del [
		"_*.pdf"
		"./#{dir.tempNew}"
		"./#{dir.tempOld}"
		"./#{dir.tempOut}"
	], ->
		gulp.src '.'
		.pipe shell ["mkdir #{dir.tempOld}\nmkdir #{dir.tempNew}\nmkdir #{dir.tempOut}"]
		.on 'end', ->
			cb()

# ソースを含めて削除する
gulp.task 'cleanDeep', ['clean'], (cb) ->
	del [
		"#{dir.new}"
		"#{dir.old}"
	], cb()

# 実行
gulp.task 'default', ->
	run 'clean', 'split', 'compare'
