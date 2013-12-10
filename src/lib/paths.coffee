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
		balUtilPaths.scandir(
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
		balUtilPaths.scandir(
			path: path
			readFiles: true
			ignoreHiddenFiles: true
			next: (err,list,tree) ->
				return next(err,tree)
		)

		# Chain
		@

	# Recursively scan a directory
	# Usage:
	#	scandir(path,action,fileAction,dirAction,next)
	#	scandir(options)
	# Options:
	#	path: the path you want to read
	#	action: (default null) null, or a function to use for both the fileAction and dirACtion
	#	fileAction: (default null) null, or a function to run against each file, in the following format:
	#		fileAction(fileFullPath,fileRelativePath,next(err,skip),fileStat)
	#	dirAction: (default null) null, or a function to run against each directory, in the following format:
	#		dirAction(fileFullPath,fileRelativePath,next(err,skip),fileStat)
	#	next: (default null) null, or a function to run after the entire directory has been scanned, in the following format:
	#		next(err,list,tree)
	#	stat: (default null) null, or a file stat object for the path if we already have one (not actually used yet)
	#	recurse: (default true) null, or a boolean for whether or not to scan subdirectories too
	#	readFiles: (default false) null, or a boolean for whether or not we should read the file contents
	#   ignorePaths: (default false) null, or an array of paths that we should ignore
	#	ignoreHiddenFiles: (default false) null, or a boolean for if we should ignore files starting with a dot
	#	ignoreCommonPatterns: (default false) null, boolean, or regex
	#		if null, becomes true
	#		if false, does not do any ignore patterns
	#		if true, defaults to bevry/ignorepatterns
	#		if regex, uses this value instead of bevry/ignorepatterns
	#	ignoreCustomPatterns: (default false) null, boolean, or regex (same as ignoreCommonPatterns but for ignoreCustomPatterns instead)
	# Next Callback Arguments:
	#	err: null, or an error that has occured
	#	list: a collection of all the child nodes in a list/object format:
	#		{fileRelativePath: 'dir|file'}
	#	tree: a colleciton of all the child nodes in a tree format:
	#		{dir:{dir:{},file1:true}}
	#		if the readFiles option is true, then files will be returned with their contents instead
	scandir: (args...) ->
		# Prepare
		list = {}
		tree = {}

		# Arguments
		if args.length is 1
			opts = args[0]
		else if args.length >= 4
			opts =
				path: args[0]
				fileAction: args[1] or null
				dirAction: args[2] or null
				next: args[3] or null
		else
			err = new Error('balUtilPaths.scandir: unsupported arguments')
			throw err

		# Prepare defaults
		opts.recurse ?= true
		opts.readFiles ?= false
		opts.ignorePaths ?= false
		opts.ignoreHiddenFiles ?= false
		opts.ignoreCommonPatterns ?= false
		opts.next ?= (err) ->
			throw err  if err
		next = opts.next

		# Action
		if opts.action?
			opts.fileAction ?= opts.action
			opts.dirAction ?= opts.action

		# Check needed
		if opts.parentPath and !opts.path
			opts.path = opts.parentPath
		if !opts.path
			err = new Error('balUtilPaths.scandir: path is needed')
			return next(err)

		# Cycle
		safefs.readdir opts.path, (err,files) ->
			# Checks
			return next(err)  if err
			return next(null,list,tree)  if files.length is 0

			# Group
			tasks = new TaskGroup().setConfig(concurrency:0).once 'complete', (err) ->
				return opts.next(err, list, tree)

			# Cycle
			files.forEach (file) ->  tasks.addTask (complete) ->
				# Prepare
				fileFullPath = pathUtil.join(opts.path,file)
				fileRelativePath =
					if opts.relativePath
						pathUtil.join(opts.relativePath,file)
					else
						file

				# Check
				isIgnoredFile = ignorefs.isIgnoredPath(fileFullPath,{
					ignorePaths: opts.ignorePaths
					ignoreHiddenFiles: opts.ignoreHiddenFiles
					ignoreCommonPatterns: opts.ignoreCommonPatterns
					ignoreCustomPatterns: opts.ignoreCustomPatterns
				})
				return complete()  if isIgnoredFile

				# IsDirectory
				balUtilPaths.isDirectory fileFullPath, (err,isDirectory,fileStat) ->
					# Checks
					return complete(err)  if err
					return complete()     if tasks.paused

					# Directory
					if isDirectory
						# Prepare
						handle = (err,skip,subtreeCallback) ->
							# Checks
							return complete(err)  if err
							return complete()     if tasks.paused
							return complete()     if skip

							# Append
							list[fileRelativePath] = 'dir'
							tree[file] = {}

							# No Recurse
							return complete()  unless opts.recurse

							# Recurse
							return balUtilPaths.scandir(
								# Path
								path: fileFullPath
								relativePath: fileRelativePath

								# Options
								fileAction: opts.fileAction
								dirAction: opts.dirAction
								readFiles: opts.readFiles
								ignorePaths: opts.ignorePaths
								ignoreHiddenFiles: opts.ignoreHiddenFiles
								ignoreCommonPatterns: opts.ignoreCommonPatterns
								ignoreCustomPatterns: opts.ignoreCustomPatterns
								recurse: opts.recurse
								stat: opts.fileStat

								# Completed
								next: (err,_list,_tree) ->
									# Merge in children of the parent directory
									tree[file] = _tree
									for own filePath, fileType of _list
										list[filePath] = fileType

									# Checks
									return complete(err)  if err
									return complete()     if tasks.paused
									return subtreeCallback(complete)  if subtreeCallback
									return complete()
							)

						# Action
						if opts.dirAction
							return opts.dirAction(fileFullPath, fileRelativePath, handle, fileStat)
						else if opts.dirAction is false
							return handle(err,true)
						else
							return handle(err,false)

					# File
					else
						# Prepare
						handle = (err,skip) ->
							# Checks
							return complete(err)  if err
							return complete()     if tasks.paused
							return complete()     if skip

							# Append
							if opts.readFiles
								# Read file
								safefs.readFile fileFullPath, (err,data) ->
									# Check
									return complete(err)  if err

									# Append
									data = data.toString()  unless opts.readFiles is 'binary'
									list[fileRelativePath] = data
									tree[file] = data

									# Done
									return complete()

							else
								# Append
								list[fileRelativePath] = 'file'
								tree[file] = true

								# Done
								return complete()

						# Action
						if opts.fileAction
							return opts.fileAction(fileFullPath, fileRelativePath, handle, fileStat)
						else if opts.fileAction is false
							return handle(err,true)
						else
							return handle(err,false)

			# Run the tasks
			tasks.run()

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
		balUtilPaths.scandir(scandirOpts)

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
		balUtilPaths.scandir(scandirOpts)

		# Chain
		@


	# Remove a directory deeply
	# next(err)
	rmdirDeep: (parentPath,next) ->
		safefs.exists parentPath, (exists) ->
			# Skip
			return next()  unless exists
			# Remove
			balUtilPaths.scandir(
				# Path
				parentPath

				# File
				(fileFullPath,fileRelativePath,next) ->
					safefs.unlink fileFullPath, (err) ->
						# Forward
						return next(err)

				# Dir
				(fileFullPath,fileRelativePath,next) ->
					next null, false, (next) ->
						balUtilPaths.rmdirDeep fileFullPath, (err) ->
							# Forward
							return next(err)

				# Completed
				(err,list,tree) ->
					# Error
					if err
						return next(err, list, tree)
					# Success
					safefs.rmdir parentPath, (err) ->
						# Forward
						return next(err, list, tree)
			)

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
			tasks = new TaskGroup().setConfig(concurrency:0).once('complete',next)

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
			tasks = new TaskGroup().once 'complete', (err) ->
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