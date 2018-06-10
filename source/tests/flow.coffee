# Import
{deepEqual} = require('assert-helpers')
joe = require('joe')
balUtil = require('../')


# =====================================
# Tests

wait = (delay,fn) -> setTimeout(fn,delay)

# -------------------------------------
# Flow

joe.describe 'misc', (describe,it) ->

	it 'should suffix arrays', (done) ->
		# Prepare
		expected = ['ba','ca','da','ea']
		actual = balUtil.suffixArray('a', 'b', ['c', 'd'], 'e')
		deepEqual(expected, actual, 'actual was as expected')
		done()
