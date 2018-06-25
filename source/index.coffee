# Import
balUtil = require('extendr').extend(
	{},
	require('./lib/compare'),
	require('./lib/events'),
	require('./lib/flow'),
	require('./lib/paths')
)

# Export
module.exports = balUtil