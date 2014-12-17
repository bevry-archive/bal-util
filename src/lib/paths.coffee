# Import
pathUtil = require('path')
eachr = require('eachr')
typeChecker = require('typechecker')
extendr = require('extendr')
safefs = require('safefs')
{extractOptsAndCallback} = require('extract-opts')
{TaskGroup} = require('taskgroup')
balUtilFlow = require('./flow')
ignorefs = require('ignorefs')
scandir = require('scandirectory')

# Define
balUtilPaths =


	# =====================================
	# Our Extensions

	# Resolve a Case Sensitive Path
	# next(err, result)
	resolveCaseSensitivePath: (path, next) ->
		# Resolve the parent path
		parentPath = safefs.getParentPathSync(path) or '/'
		return next(null, parentPath)  if parentPath is '/'
		safefs.resolveCaseSensitivePath parentPath, (err, parentPath) ->
			safefs.readdir parentPath, (err, files) ->
				return next(err)  if err

				relativePathLowerCase = relativePath.toLowerCase()
				for file in files
					if file.toLowerCase() is relativePathLowerCase
						return next(null, pathUtil.join(parentPath, relativePath))

				err = new Error("Could not find the path #{relativePath} inside #{parentPath}")
				return next(err)

		# Chain
		safefs

	# Copy a file
	# Or rather overwrite a file, regardless of whether or not it was existing before
	# next(err)
	cp: (src,dst,next) ->
		# Copy
		safefs.readFile src, 'binary', (err,data) ->
			# Error
			return next(err)  if err

			# Success
			safefs.writeFile dst, data, 'binary', (err) ->
				# Forward
				return next(err)

		# Chain
		@


	# Prefix path
	prefixPathSync: (path,parentPath) ->
		path = path.replace /[\/\\]$/, ''
		if /^([a-zA-Z]\:|\/)/.test(path) is false
			path = pathUtil.join(parentPath,path)
		return path


	# Is it a directory?
	# path can also be a stat object
	# next(err,isDirectory,fileStat)
	isDirectory: (path,next) ->
		# Check if path is a stat object
		if path?.isDirectory?
			return next(null, path.isDirectory(), path)

		# Otherwise fetch the stat and do the check
		else
			safefs.stat path, (err,stat) ->
				# Error
				return next(err)  if err

				# Success
				return next(null, stat.isDirectory(), stat)

		# Chain
		@


	# Generate a slug for a file
	generateSlugSync: (path) ->
		# Slugify
		result = path.replace(/[^a-zA-Z0-9]/g,'-').replace(/^-/,'').replace(/-+/,'-')

		# Return
		return result


	# Scan a directory into a list
	# next(err,list)
	scanlist: (path,next) ->
		# Handle
		scandir(
			path: path
			readFiles: true
			ignoreHiddenFiles: true
			next: (err,list) ->
				return next(err,list)
		)

		# Chain
		@

	# Scan a directory into a tree
	# next(err,tree)
	scantree: (path,next) ->
		# Handle
		scandir(
			path: path
			readFiles: true
			ignoreHiddenFiles: true
			next: (err,list,tree) ->
				return next(err,tree)
		)

		# Chain
		@

	# Copy a directory
	# If the same file already exists, we will keep the source one
	# Usage:
	# 	cpdir({srcPath,outPath,next})
	# 	cpdir(srcPath,outPath,next)
	# Callbacks:
	# 	next(err)
	cpdir: (args...) ->
		# Prepare
		opts = {}
		if args.length is 1
			opts = args[0]
		else if args.length >= 3
			[srcPath,outPath,next] = args
			opts = {srcPath,outPath,next}
		else
			err = new Error('balUtilPaths.cpdir: unknown arguments')
			if next
				return next(err)
			else
				throw err

		# Create opts
		scandirOpts = {
			path: opts.srcPath
			fileAction: (fileSrcPath,fileRelativePath,next) ->
				# Prepare
				fileOutPath = pathUtil.join(opts.outPath,fileRelativePath)
				# Ensure the directory that the file is going to exists
				safefs.ensurePath pathUtil.dirname(fileOutPath), (err) ->
					# Error
					if err
						return next(err)
					# The directory now does exist
					# So let's now place the file inside it
					balUtilPaths.cp fileSrcPath, fileOutPath, (err) ->
						# Forward
						return next(err)
			next: opts.next
		}

		# Passed Scandir Opts
		for opt in ['ignorePaths','ignoreHiddenFiles','ignoreCommonPatterns','ignoreCustomPatterns']
			scandirOpts[opt] = opts[opt]

		# Scan all the files in the diretory and copy them over asynchronously
		scandir(scandirOpts)

		# Chain
		@


	# Replace a directory
	# If the same file already exists, we will keep the newest one
	# Usage:
	# 	rpdir({srcPath,outPath,next})
	# 	rpdir(srcPath,outPath,next)
	# Callbacks:
	# 	next(err)
	rpdir: (args...) ->
		# Prepare
		opts = {}
		if args.length is 1
			opts = args[0]
		else if args.length >= 3
			[srcPath,outPath,next] = args
			opts = {srcPath,outPath,next}
		else
			err = new Error('balUtilPaths.cpdir: unknown arguments')
			if next
				return next(err)
			else
				throw err

		# Create opts
		scandirOpts = {
			path: opts.srcPath
			fileAction: (fileSrcPath,fileRelativePath,next) ->
				# Prepare
				fileOutPath = pathUtil.join(opts.outPath,fileRelativePath)
				# Ensure the directory that the file is going to exists
				safefs.ensurePath pathUtil.dirname(fileOutPath), (err) ->
					# Error
					return next(err)  if err
					# Check if it is worthwhile copying that file
					balUtilPaths.isPathOlderThan fileOutPath, fileSrcPath, (err,older) ->
						# The src path has been modified since the out path was generated
						if older is true or older is null
							# The directory now does exist
							# So let's now place the file inside it
							balUtilPaths.cp fileSrcPath, fileOutPath, (err) ->
								# Forward
								return next(err)
						# The out path is new enough
						else
							return next()
			next: opts.next
		}

		# Passed Scandir Opts
		for opt in ['ignorePaths','ignoreHiddenFiles','ignoreCommonPatterns','ignoreCustomPatterns']
			scandirOpts[opt] = opts[opt]

		# Scan all the files in the diretory and copy them over asynchronously
		scandir(scandirOpts)

		# Chain
		@


	# Write tree
	# next(err)
	writetree: (dstPath,tree,next) ->
		# Ensure Destination
		safefs.ensurePath dstPath, (err) ->
			# Checks
			return next(err)  if err

			# Group
			tasks = new TaskGroup(concurrency:0).done(next)

			# Cycle
			eachr tree, (value,fileRelativePath) ->  tasks.addTask (complete) ->
				fileFullPath = pathUtil.join(dstPath, fileRelativePath.replace(/^\/+/,''))
				if typeChecker.isObject(value)
					balUtilPaths.writetree(fileFullPath, value, complete)
				else
					safefs.writeFile(fileFullPath, value, complete)

			# Run the tasks
			tasks.run()

		# Chain
		@


	# Read path
	# Reads a path be it local or remote
	# next(err,data)
	readPath: (filePath,opts,next) ->
		[opts,next] = extractOptsAndCallback(opts,next)

		# Request
		if /^http/.test(filePath)
			# Prepare
			data = ''
			tasks = new TaskGroup().done (err) ->
				return next(err)  if err
				return next(null,data)

			# Request
			requestOpts = require('url').parse(filePath)
			requestOpts.path ?= requestOpts.pathname
			requestOpts.method ?= 'GET'
			requestOpts.headers ?= {}
			requestOpts.headers['user-agent'] ?= 'Wget/1.14 (linux-gnu)'

			# Import
			http = if requestOpts.protocol is 'https:' then require('https') else require('http')
			zlib = null

			# Gzip
			try
				zlib = require('zlib')
				# requestOpts.headers['accept-encoding'] ?= 'gzip'
				# do not prefer gzip, it is buggy
			catch err
				# do nothing

			# Request
			req = http.request requestOpts, (res) ->
				# Listend
				res.on 'data', (chunk) ->  tasks.addTask (complete) ->
					if res.headers['content-encoding'] is 'gzip' and Buffer.isBuffer(chunk)
						# Check
						if zlib is null
							err = new Error('Gzip encoding not supported on this environment')
							return complete(err)
						# Continue
						zlib.unzip chunk, (err,chunk) ->
							return complete(err)  if err
							data += chunk
							return complete()
					else
						data += chunk
						return complete()

				# Completed
				res.on 'end', ->
					# Redirect?
					locationHeader = res.headers?.location or null
					if locationHeader and locationHeader isnt requestOpts.href
						# Follow the redirect
						balUtilPaths.readPath locationHeader, (err,_data) ->
							return tasks.exit(err)  if err
							data = _data
							return tasks.exit()
					else
						# All done
						tasks.run()

			# Timeout
			req.setTimeout ?= (delay) ->
				setTimeout(
					->
						req.abort()
						err = new Error('Request timed out')
						tasks.exit(err)
					delay
				)
			req.setTimeout(opts.timeout ? 10*1000)  # 10 second timeout

			# Listen
			req
				# do not put these on the same line, will cause problems
				.on 'error', (err) ->
					tasks.exit(err)
				.on 'timeout', ->
					req.abort()  # must abort manually, will trigger error event

			# Start
			req.end()

		# Local
		else
			safefs.readFile filePath, (err,data) ->
				return next(err)  if err
				return next(null,data)

		# Chain
		@


	# Empty
	# Check if the file does not exist, or is empty
	# next(err,empty)
	empty: (filePath,next) ->
		# Check if we exist
		safefs.exists filePath, (exists) ->
			# Return empty if we don't exist
			return next(null,true)  unless exists

			# We do exist, so check if we have content
			safefs.stat filePath, (err,stat) ->
				# Check
				return next(err)  if err
				# Return whether or not we are actually empty
				return next(null,stat.size is 0)

		# Chain
		@


	# Is Path Older Than
	# Checks if a path is older than a particular amount of millesconds
	# next(err,older)
	# older will be null if the path does not exist
	isPathOlderThan: (aPath,bInput,next) ->
		# Handle mtime
		bMtime = null
		if typeChecker.isNumber(bInput)
			mode = 'time'
			bMtime = new Date(new Date() - bInput)
		else
			mode = 'path'
			bPath = bInput

		# Check if the path exists
		balUtilPaths.empty aPath, (err,empty) ->
			# If it doesn't then we should return right away
			return next(err,null)  if empty or err

			# We do exist, so let's check how old we are
			safefs.stat aPath, (err,aStat) ->
				# Check
				return next(err)  if err

				# Prepare
				compare = ->
					# Time comparison
					if aStat.mtime < bMtime
						older = true
					else
						older = false

					# Return result
					return next(null,older)

				# Perform the comparison
				if mode is 'path'
					# Check if the bPath exists
					balUtilPaths.empty bPath, (err,empty) ->
						# Return result if we are empty
						return next(err,null)  if empty or err

						# It does exist so lets get the stat
						safefs.stat bPath, (err,bStat) ->
							# Check
							return next(err)  if err

							# Assign the outer bMtime variable
							bMtime = bStat.mtime

							# Perform the comparison
							return compare()
				else
					# We already have the bMtime
					return compare()

		# Chain
		@


# Export
module.exports = balUtilPaths