# Created by phpStorm.
#
# User: Yuma Hori
# Date: 15/02/20
# Desc: PDFを1ページごとに分解し、差分をPDFにまとめる

gulp = require 'gulp'
del = require 'del'
fs = require 'fs'
run = require 'run-sequence'
shell = require 'gulp-shell'

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
gm.density = '-density 200x200'
gm.number = '%03d'
gm.format = '.pdf'
gm.compareStyle = 'assign'

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

gulp.task 'metric', ->
  gulp.src '.', ->
		fs.readdir "#{dir.tempNew}", (err, files) ->

			commands = []
			newImages = []
			newImages = files

			for path in newImages
				commands.push "echo 'Next #{path}:'\ngm compare -metric MAE #{dir.tempOld}/#{path} #{dir.tempNew}/#{path}\n"
			console.log commands

			gulp.src '.'
				.pipe shell(commands)


# 分割されたJPEGを順番に比較し、結果を出力する
gulp.task 'compare', ->

	gulp.src '.', ->
		fs.readdir "#{dir.tempNew}", (err, files1) ->

			fs.readdir "#{dir.tempOld}", (err, files2) -> 
				commands = []
				
				console.log files1
				console.log files2
				
				try
				  if newImages.length != oldImages.length
	  			  throw new Error('Not Enough Length!!')

				for path, i in files1
					commands.push "echo 'Next #{path}:'\ngm compare -metric MAE #{dir.tempOld}/#{files2[i]} #{dir.tempNew}/#{path}\ngm compare -highlight-style #{gm.compareStyle} -file #{dir.tempOut}/#{files1[i]} #{dir.tempOld}/#{files2[i]} #{dir.tempNew}/#{files1[i]}\n"

				commands.push "gm convert #{dir.tempOut}/* #{dir.diffOutput}\n"
				commands.push "open #{dir.diffOutput}\n"
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
	],  ->
		gulp.src '.'
		.pipe shell ["mkdir #{dir.old}\nmkdir #{dir.new}\n"]
		.on 'end', ->
			cb()

# 実行
gulp.task 'default', ->
	run 'clean', 'split', 'compare'
