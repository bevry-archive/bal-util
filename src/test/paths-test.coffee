# Import
{equal, deepEqual, errorEqual} = require('assert-helpers')
{PassThrough} = require('stream')
urlUtil = require('url')
joe = require('joe')
balUtil = require('../../')
rimraf = require('rimraf')


# =====================================
# Configuration

# Test Data
srcPath = __dirname+'/src'
outPath = __dirname+'/out'
writetree =
	'blog':
		'post1.md': 'my post'
		'post2.md': 'my post2'
	'styles':
		'themes':
			'balupton':
				'style.css': 'body { display:none; }'
			'style.css': 'blah'
		'style.css': 'blah'
	'index.html': '<html>'

###
scantree =
	'index.html': true
	'blog':
		'post1.md': true
		'post2.md': true
	'styles':
		'style.css': true
		'themes':
			'balupton':
				'style.css': true
			'style.css': true
###


# =====================================
# Tests

joe.describe 'paths', (describe,it) ->

	# Cleanup
	describe 'cleanup', (describe,it) ->
		it 'should fail gracefully when the directory does not exist', (done) ->
			rimraf outPath, (err) ->
				equal(err||null, null)
				done()

	# Test writetree
	describe 'writetree', (describe,it) ->
		it 'should fire without error', (done) ->
			# Write the tree
			balUtil.writetree srcPath, writetree, (err) ->
				return done(err)

		# Check if the tree was written correctly
		it 'should write the files correctly', (done) ->
			balUtil.scantree srcPath, (err,scantree) ->
				return done(err)  if err
				deepEqual(scantree, writetree)
				done()

	# Test cpdir
	describe 'cpdir', (describe,it) ->
		it 'should fire without error', (done) ->
			# Copy the source path to the out path
			balUtil.cpdir srcPath, outPath, (err) ->
				return done(err)

		# Check if the tree was written correctly
		it 'should write the files correctly', (done) ->
			balUtil.scantree outPath, (err,scantree) ->
				return done(err)  if err
				deepEqual(scantree,writetree)
				done()

	# Test readPath
	describe 'readPath', (describe,it) ->
		serverAddress = "127.0.0.1"
		serverPort = 9666
		serverUrl = "http://#{serverAddress}:#{serverPort}"
		server = null

		# Normal
		it 'should read local paths', (done) ->
			balUtil.readPath __filename, (err,data) ->
				return done(err)  if err
				equal(data?, true, 'data exists')
				return done()

		# Server
		it 'should create our server', (done) ->
			# Server
			server = require('http').createServer (req,res) ->
				file = urlUtil.parse(req.url).pathname
				switch file
					when '/timeout'
						console.log('send timeout')
						res.writeHead(200, {'Content-Type': 'text/plain'})
						break
					when '/respond'
						console.log('send response')
						res.writeHead(200, {'Content-Type': 'text/plain'})
						res.end('alex')
					when '/redirect'
						console.log('send redirect')
						res.writeHead(200, {'Content-Type': 'text/plain', 'Location': "#{serverUrl}/respond"})
						res.end()
					when '/zip'
						console.log('send zip response')
						input = new PassThrough()
						input.end('bob')
						acceptEncoding = req.headers['accept-encoding'] or ''
						if acceptEncoding.match(/\bdeflate\b/)
							res.writeHead(200, {'Content-Encoding': 'deflate'})
							input.pipe(require('zlib').createDeflate()).pipe(res)
						else if acceptEncoding.match(/\bgzip\b/)
							res.writeHead(200, {'Content-Encoding': 'gzip'})
							input.pipe(require('zlib').createGzip()).pipe(res)
						else
							res.writeHead(200, {})
							input.pipe(res)
					else
						res.writeHead(404, {'Content-Type': 'text/plain'})
						res.end('404 not found')
			server.listen(serverPort, serverAddress, done)

		# Success
		it 'should read urls', (done) ->
			balUtil.readPath "#{serverUrl}/respond", (err,data) ->
				return done(err)  if err
				equal(data.toString(), 'alex', 'response is as expected')
				return done()

		# Success redirect
		it 'should handle redirects', (done) -># Check
			balUtil.readPath "#{serverUrl}/redirect", (err,data) ->
				return done(err)  if err
				equal(data.toString(), 'alex', 'response is as expected')
				return done()

		# Success zip
		it 'should read zip urls', (done) -># Check
			if process.version.indexOf('v0.4') is 0
				equal(err, 'gzip encoding not supported on this environment', 'error exists')
				return done()
			balUtil.readPath "#{serverUrl}/zip", (err,data) ->
				return done(err)  if err
				equal(data.toString(), 'bob', 'response is as expected')
				return done()

		# Timeout
		it 'should timeout requests after a while of inactivity (10s)', (done) ->
			second = 0
			interval = setInterval(
				-> console.log("... #{++second} seconds")
				1*1000
			)
			timeout = setTimeout(
				->
					equal(false, true, 'timeout did not kick in')
					return done()
				15*1000
			)
			balUtil.readPath "#{serverUrl}/timeout", (err,data) ->
				clearInterval(interval)
				clearTimeout(timeout)
				errorEqual(err, 'socket hang up', 'timeout executed correctly with error')
				return done()

		# Close Server
		it 'should close the server', ->
			server.close()
