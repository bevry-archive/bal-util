<!-- TITLE/ -->

<h1>Benjamin Lupton's Utility Functions</h1>

<!-- /TITLE -->


<!-- BADGES/ -->

<span class="badge-travisci"><a href="http://travis-ci.org/balupton/bal-util" title="Check this project's build status on TravisCI"><img src="https://img.shields.io/travis/balupton/bal-util/master.svg" alt="Travis CI Build Status" /></a></span>
<span class="badge-npmversion"><a href="https://npmjs.org/package/bal-util" title="View this project on NPM"><img src="https://img.shields.io/npm/v/bal-util.svg" alt="NPM version" /></a></span>
<span class="badge-npmdownloads"><a href="https://npmjs.org/package/bal-util" title="View this project on NPM"><img src="https://img.shields.io/npm/dm/bal-util.svg" alt="NPM downloads" /></a></span>
<span class="badge-daviddm"><a href="https://david-dm.org/balupton/bal-util" title="View the status of this project's dependencies on DavidDM"><img src="https://img.shields.io/david/balupton/bal-util.svg" alt="Dependency Status" /></a></span>
<span class="badge-daviddmdev"><a href="https://david-dm.org/balupton/bal-util#info=devDependencies" title="View the status of this project's development dependencies on DavidDM"><img src="https://img.shields.io/david/dev/balupton/bal-util.svg" alt="Dev Dependency Status" /></a></span>
<br class="badge-separator" />
<span class="badge-patreon"><a href="https://patreon.com/bevry" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-flattr"><a href="https://flattr.com/profile/balupton" title="Donate to this project using Flattr"><img src="https://img.shields.io/badge/flattr-donate-yellow.svg" alt="Flattr donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
<span class="badge-bitcoin"><a href="https://bevry.me/bitcoin" title="Donate once-off to this project using Bitcoin"><img src="https://img.shields.io/badge/bitcoin-donate-yellow.svg" alt="Bitcoin donate button" /></a></span>
<span class="badge-wishlist"><a href="https://bevry.me/wishlist" title="Buy an item on our wishlist for us"><img src="https://img.shields.io/badge/wishlist-donate-yellow.svg" alt="Wishlist browse button" /></a></span>
<br class="badge-separator" />
<span class="badge-slackin"><a href="https://slack.bevry.me" title="Join this project's slack community"><img src="https://slack.bevry.me/badge.svg" alt="Slack community badge" /></a></span>

<!-- /BADGES -->


<!-- DESCRIPTION/ -->

Common utility functions for Node.js used and maintained by Benjamin Lupton

<!-- /DESCRIPTION -->


<!-- INSTALL/ -->

<h2>Install</h2>

<a href="https://npmjs.com" title="npm is a package manager for javascript"><h3>NPM</h3></a><ul>
<li>Install: <code>npm install --save bal-util</code></li>
<li>Module: <code>require('bal-util')</code></li></ul>

<a href="http://browserify.org" title="Browserify lets you require('modules') in the browser by bundling up all of your dependencies"><h3>Browserify</h3></a><ul>
<li>Install: <code>npm install --save bal-util</code></li>
<li>Module: <code>require('bal-util')</code></li>
<li>CDN URL: <code>//wzrd.in/bundle/bal-util@2.8.0</code></li></ul>

<a href="http://enderjs.com" title="Ender is a full featured package manager for your browser"><h3>Ender</h3></a><ul>
<li>Install: <code>ender add bal-util</code></li>
<li>Module: <code>require('bal-util')</code></li></ul>

<h3><a href="https://github.com/bevry/editions" title="Editions are the best way to produce and consume packages you care about.">Editions</a></h3>

<p>This package is published with the following editions:</p>

<ul><li><code>bal-util</code> aliases <code>bal-util/index.js</code> which uses <a href="https://github.com/bevry/editions" title="Editions are the best way to produce and consume packages you care about.">Editions</a> to automatically select the correct edition for the consumers environment</li>
<li><code>bal-util/source/index.coffee</code> is Source + CoffeeScript + <a href="https://nodejs.org/dist/latest-v5.x/docs/api/modules.html" title="Node/CJS Modules">Require</a></li>
<li><code>bal-util/esnext/index.js</code> is CoffeeScript Compiled + <a href="https://babeljs.io/docs/learn-es2015/" title="ECMAScript Next">ESNext</a> + <a href="https://nodejs.org/dist/latest-v5.x/docs/api/modules.html" title="Node/CJS Modules">Require</a></li>
<li><code>bal-util/es2015/index.js</code> is CoffeeScript Compiled + <a href="http://babeljs.io/docs/plugins/preset-es2015/" title="ECMAScript 2015">ES2015</a> + <a href="https://nodejs.org/dist/latest-v5.x/docs/api/modules.html" title="Node/CJS Modules">Require</a></li></ul>

<p>Older environments may need <a href="https://babeljs.io/docs/usage/polyfill/" title="A polyfill that emulates missing ECMAScript environment features">Babel's Polyfill</a> or something similar.</p>

<!-- /INSTALL -->


## Usage
Best off looking at source, it's well documented, and there are plenty of tests



## Abstraction
We're working to breaking out every part of bal-util into their own modules, or to use existing modules where there is now a more abstract version. Below are the list of the following abstractions that have been made:

- [@bevry/fs-*](https://github.com/orgs/bevry/repositories?language=&q=fs-&sort=&type=all) < `balUtilPaths.(openFile|closeFile|etc)`
- [@bevry/fs-remove](https://github.com/bevry/fs-remove) < `balUtilPaths.rmdirDeep`
- [@bevry/fs-tree](https://github.com/bevry/fs-tree) < `balUtilPaths.writetree`, `balUtilPaths.scandir`
- [ambi](https://github.com/bevry/ambi) < `balUtilFlow.fireWithOptionalCallback`
- [binaryextensions](https://github.com/bevry/binaryextensions) < `balUtilPaths.binaryExtensions`
- [detect-indentation](https://github.com/bevry/detect-indentation) < `balUtilHTML.detectIndentation`
- [eachr](https://github.com/bevry/eachr) < `balUtilFlow.each`
- [event-emitter-grouped](https://github.com/bevry/event-emitter-grouped) < `balUtilEvents.EventEmitterEnhanced`
- [extendr](https://github.com/bevry/extendr) < `balUtilFlow.(extend|clone|etc)`
- [extract-opts](https://github.com/bevry/extract-opts) < `balUtilFlow.extractOptsAndCallback`
- [getsetdeep](https://github.com/bevry/getsetdeep) < `balUtilFlow.(get|set)Deep`
- [ignorefs](https://github.com/bevry/ignorefs) < `balUtilPaths.isIgnoredPath`
- [ignorepatterns](https://github.com/bevry/ignorepatterns) < `balUtilPaths.ignoreCommonPatterns`
- [istextorbinary](https://github.com/bevry/istextorbinary) < `balUtilPaths.(isTextSync|isText|getEncodingSync|getEncoding)`
- [remove-indentation](https://github.com/bevry/remove-indentation) < `balUtilHTML.removeIndentation`
- [ropo](https://github.com/bevry/ropo) < `balUtilHTML.(getAttribute|replaceElement|replaceElementAsync)`
- [safecallback](https://github.com/bevry/safecallback) < `balUtilFlow.safeCallback`
- [safeps](https://github.com/bevry/safeps) < `balUtilModules`
- [scandirectory](https://github.com/bevry/scandirectory) < `balUtilPaths.scandir`
- [taskgroup](https://github.com/bevry/taskgroup) < `balUtilFlow.Group`
- [textextensions](https://github.com/bevry/textextensions) < `balUtilPaths.textExtensions`
- [trim-indentation](https://github.com/bevry/trim-indentation) < `balUtilHTML.removeIndentation`
- [typechecker](https://github.com/bevry/typechecker) < `balUtilTypes`


<!-- CONTRIBUTE/ -->

<h2>Contribute</h2>

<a href="https://github.com/balupton/bal-util/blob/master/CONTRIBUTING.md#files">Discover how you can contribute by heading on over to the <code>CONTRIBUTING.md</code> file.</a>

<!-- /CONTRIBUTE -->


<!-- HISTORY/ -->

<h2>History</h2>

<a href="https://github.com/balupton/bal-util/blob/master/HISTORY.md#files">Discover the release history by heading on over to the <code>HISTORY.md</code> file.</a>

<!-- /HISTORY -->


<!-- BACKERS/ -->

<h2>Backers</h2>

<h3>Maintainers</h3>

These amazing people are maintaining this project:

<ul><li><a href="http://balupton.com">Benjamin Lupton</a> — <a href="https://github.com/balupton/bal-util/commits?author=balupton" title="View the GitHub contributions of Benjamin Lupton on repository balupton/bal-util">view contributions</a></li></ul>

<h3>Sponsors</h3>

No sponsors yet! Will you be the first?

<span class="badge-patreon"><a href="https://patreon.com/bevry" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-flattr"><a href="https://flattr.com/profile/balupton" title="Donate to this project using Flattr"><img src="https://img.shields.io/badge/flattr-donate-yellow.svg" alt="Flattr donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
<span class="badge-bitcoin"><a href="https://bevry.me/bitcoin" title="Donate once-off to this project using Bitcoin"><img src="https://img.shields.io/badge/bitcoin-donate-yellow.svg" alt="Bitcoin donate button" /></a></span>
<span class="badge-wishlist"><a href="https://bevry.me/wishlist" title="Buy an item on our wishlist for us"><img src="https://img.shields.io/badge/wishlist-donate-yellow.svg" alt="Wishlist browse button" /></a></span>

<h3>Contributors</h3>

These amazing people have contributed code to this project:

<ul><li><a href="http://balupton.com">Benjamin Lupton</a> — <a href="https://github.com/balupton/bal-util/commits?author=balupton" title="View the GitHub contributions of Benjamin Lupton on repository balupton/bal-util">view contributions</a></li>
<li><a href="http://seanfridman.com">Sean Fridman</a> — <a href="https://github.com/balupton/bal-util/commits?author=sfrdmn" title="View the GitHub contributions of Sean Fridman on repository balupton/bal-util">view contributions</a></li></ul>

<a href="https://github.com/balupton/bal-util/blob/master/CONTRIBUTING.md#files">Discover how you can contribute by heading on over to the <code>CONTRIBUTING.md</code> file.</a>

<!-- /BACKERS -->


<!-- LICENSE/ -->

<h2>License</h2>

Unless stated otherwise all works are:

<ul><li>Copyright &copy; 2011+ <a href="http://balupton.com">Benjamin Lupton</a></li></ul>

and licensed under:

<ul><li><a href="http://spdx.org/licenses/MIT.html">MIT License</a></li></ul>

<!-- /LICENSE -->
