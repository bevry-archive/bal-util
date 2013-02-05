// Generated by CoffeeScript 1.4.0
(function() {
  var assert, balUtil, joe, nonPath, outPath, srcPath, writetree,
    __hasProp = {}.hasOwnProperty;

  assert = require('assert');

  joe = require('joe');

  balUtil = require(__dirname + '/../lib/balutil');

  srcPath = __dirname + '/src';

  outPath = __dirname + '/out';

  nonPath = __dirname + '/asd';

  writetree = {
    'index.html': '<html>',
    'blog': {
      'post1.md': 'my post',
      'post2.md': 'my post2'
    },
    'styles': {
      'style.css': 'blah',
      'themes': {
        'balupton': {
          'style.css': 'body { display:none; }'
        },
        'style.css': 'blah'
      }
    }
  };

  /*
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
  */


  joe.describe('paths', function(describe, it) {
    describe('ignoreCommonPatterns', function(describe, it) {
      var ignoreExpected, resultExpected, str, testName, _results;
      ignoreExpected = {
        "~": true,
        "~something": true,
        "something~": false,
        "something~something": false,
        ".#": true,
        ".#something": true,
        "something.#": false,
        "something.#something": false,
        ".swp": true,
        "aswp": false,
        "something.swp": true,
        ".swpsomething": false,
        ".svn": true,
        "asvn": false,
        "something.svn": false,
        "something.svnsomething": false,
        ".git": true,
        "agit": false,
        "something.git": false,
        "something.gitsomething": false,
        ".hg": true,
        "ahg": false,
        "something.hg": false,
        "something.hgsomething": false,
        ".DS_Store": true,
        "something.DS_Store": false,
        "something.DS_Storesomething": false,
        "node_modules": true,
        "somethingnode_modules": false,
        "somethingnode_modulessomething": false,
        "CVS": true,
        "somethingCVS": false,
        "somethingCVSsomething": false,
        "thumbs.db": true,
        "thumbsadb": false,
        "desktop.ini": true,
        "desktopaini": false
      };
      _results = [];
      for (str in ignoreExpected) {
        if (!__hasProp.call(ignoreExpected, str)) continue;
        resultExpected = ignoreExpected[str];
        testName = "" + (resultExpected ? "should" : "should not") + " ignore [" + str + "]";
        _results.push(it(testName, function() {
          var resultActual;
          resultActual = balUtil.testIgnorePatterns(str);
          return assert.equal(resultActual, resultExpected);
        }));
      }
      return _results;
    });
    describe('rmdir', function(describe, it) {
      return it('should fail gracefully when the directory does not exist', function(done) {
        return balUtil.rmdirDeep(nonPath, function(err) {
          assert.equal(err || null, null);
          return done();
        });
      });
    });
    describe('writetree', function(describe, it) {
      it('should fire without error', function(done) {
        return balUtil.writetree(srcPath, writetree, function(err) {
          return done(err);
        });
      });
      return it('should write the files correctly', function(done) {
        return balUtil.scantree(srcPath, function(err, scantree) {
          if (err) {
            return done(err);
          }
          assert.deepEqual(scantree, writetree);
          return done();
        });
      });
    });
    describe('cpdir', function(describe, it) {
      it('should fire without error', function(done) {
        return balUtil.cpdir(srcPath, outPath, function(err) {
          return done(err);
        });
      });
      return it('should write the files correctly', function(done) {
        return balUtil.scantree(outPath, function(err, scantree) {
          if (err) {
            return done(err);
          }
          assert.deepEqual(scantree, writetree);
          return done();
        });
      });
    });
    describe('rmdirDeep', function(describe, it) {
      it('should clean up the srcPath', function(done) {
        return balUtil.rmdirDeep(srcPath, function(err) {
          var exists;
          if (err) {
            return done(err);
          }
          exists = balUtil.existsSync(srcPath);
          assert.equal(exists, false);
          return done();
        });
      });
      return it('should clean up the outPath', function(done) {
        return balUtil.rmdirDeep(outPath, function(err) {
          var exists;
          if (err) {
            return done(err);
          }
          exists = balUtil.existsSync(outPath);
          assert.equal(exists, false);
          return done();
        });
      });
    });
    return describe('readPath', function(describe, it) {
      var timeoutServer, timeoutServerAddress, timeoutServerPort;
      timeoutServerAddress = "127.0.0.1";
      timeoutServerPort = 9666;
      timeoutServer = null;
      it('should read normal paths', function(done) {
        return balUtil.readPath(__filename, function(err, data) {
          if (err) {
            return done(err);
          }
          assert.ok(data != null);
          return done();
        });
      });
      it('should create our timeout server', function() {
        timeoutServer = require('http').createServer(function(req, res) {
          return res.writeHead(200, {
            'Content-Type': 'text/plain'
          });
        });
        return timeoutServer.listen(timeoutServerPort, timeoutServerAddress);
      });
      it('should timeout requests after a while of inactivity (10s)', function(done) {
        var interval, second, timeout;
        second = 0;
        interval = setInterval(function() {
          return console.log("... " + (++second) + " seconds");
        }, 1 * 1000);
        timeout = setTimeout(function() {
          assert.ok(false, 'timeout did not kick in');
          return done();
        }, 15 * 1000);
        return balUtil.readPath("http://" + timeoutServerAddress + ":" + timeoutServerPort, function(err, data) {
          clearInterval(interval);
          clearTimeout(timeout);
          assert.ok(err != null, 'timeout executed correctly with error');
          return done();
        });
      });
      return it('should close the server', function() {
        return timeoutServer.close();
      });
    });
  });

}).call(this);
