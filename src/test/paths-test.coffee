# Import
{expect,assert} = require('chai')
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
				assert.equal(err||null, null)
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
				assert.deepEqual(scantree, writetree)
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
				assert.deepEqual(scantree,writetree)
				done()

	# Test readPath
	describe 'readPath', (describe,it) ->
		timeoutServerAddress = "127.0.0.1"
		timeoutServerPort = 9666
		timeoutServer = null

		# Normal
		it 'should read normal paths', (done) ->
			balUtil.readPath __filename, (err,data) ->
				return done(err)  if err
				assert.ok(data?)
				return done()

		# Should decode gzip
		describe 'gzip', (describe,it) ->
			it 'should read gzipped paths', (done) ->
				balUtil.readPath 'https://api.stackexchange.com/2.2/users/130638?order=desc&sort=reputation&site=stackoverflow', (err,data) ->
					# Check
					if process.version.indexOf('v0.4') is 0
						assert.ok(err?)
						return done()

					# Continue
					return done(err)  if err
					assert.ok(data?)
					assert.equal(data[0],'{')
					return done()

		# Server
		it 'should create our timeout server', ->
			# Server
			timeoutServer = require('http').createServer((req,res) ->
				res.writeHead(200, {'Content-Type': 'text/plain'})
			)
			timeoutServer.listen(timeoutServerPort, timeoutServerAddress)

		# Timeout
		it 'should timeout requests after a while of inactivity (10s)', (done) ->
			second = 0
			interval = setInterval(
				-> console.log("... #{++second} seconds")
				1*1000
			)
			timeout = setTimeout(
				->
					assert.ok(false, 'timeout did not kick in')
					return done()
				15*1000
			)
			balUtil.readPath "http://#{timeoutServerAddress}:#{timeoutServerPort}", (err,data) ->
				clearInterval(interval)
				clearTimeout(timeout)
				assert.ok(err?, 'timeout executed correctly with error')
				return done()

		# Close Server
		it 'should close the server', ->
			timeoutServer.close()

