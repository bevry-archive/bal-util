# Import
{equal} = require('assert-helpers')
joe = require('joe')
balUtil = require('../')


# =====================================
# Tests

wait = (delay,fn) -> setTimeout(fn,delay)

# -------------------------------------
# Flow

joe.suite 'html', (suite,test) ->

	test 'replaceElement', ->
		# Prepare
		source = """
			breakfast
			<title>blah</title>
			brunch
			<t>
				a
					b
				c
			</t>
			lunch
			<text>
				one
					two
				three
			</text>
			dinner
			"""
		expected = """
			breakfast
			<title>blah</title>
			brunch
			A
				B
			C
			lunch
			ONE
				TWO
			THREE
			dinner
			"""
		replaceElementCallback = (outerHTML, elementNameMatched, attributes, innerHTML) ->
			return innerHTML.toUpperCase()
		actual = balUtil.replaceElement(source, "t(?:ext)?", replaceElementCallback)
		equal(expected, actual)

	test 'replaceElementAsync', (done) ->
		# Prepare
		source = """
			breakfast
			<title>blah</title>
			brunch
			<t>
				a
					b
				c
			</t>
			lunch
			<text>
				one
					two
				three
			</text>
			dinner
			"""
		expected = """
			breakfast
			<title>blah</title>
			brunch
			A
				B
			C
			lunch
			ONE
				TWO
			THREE
			dinner
			"""
		replaceElementCallback = (outerHTML, elementNameMatched, attributes, innerHTML, callback) ->
			balUtil.wait 1000, ->
				callback null, innerHTML.toUpperCase()
		balUtil.replaceElementAsync source, "t(?:ext)?", replaceElementCallback, (err,actual) ->
			return done(err)  if err
			equal(expected, actual)
			done()
