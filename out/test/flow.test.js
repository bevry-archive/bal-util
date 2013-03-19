// Generated by CoffeeScript 1.6.2
(function() {
  var assert, balUtil, joe, wait;

  assert = (typeof require === "function" ? require('assert') : void 0) || this.assert;

  joe = (typeof require === "function" ? require('joe') : void 0) || this.joe;

  balUtil = (typeof require === "function" ? require(__dirname + '/../lib/balutil') : void 0) || this.balUtil;

  wait = function(delay, fn) {
    return setTimeout(fn, delay);
  };

  joe.describe('misc', function(describe, it) {
    it('should suffix arrays', function(done) {
      var actual, expected;

      expected = ['ba', 'ca', 'da', 'ea'];
      actual = balUtil.suffixArray('a', 'b', ['c', 'd'], 'e');
      assert.deepEqual(expected, actual, 'actual was as expected');
      return done();
    });
    it('should detect arrays', function(done) {
      var arr, obj, str;

      arr = [];
      obj = {};
      str = '';
      assert.equal(true, balUtil.isArray(arr), 'array vs array comparison');
      assert.equal(false, balUtil.isArray(obj), 'object vs array comparison');
      assert.equal(false, balUtil.isArray(str), 'string vs array comparison');
      return done();
    });
    it('should cycle arrays', function(done) {
      var arr, out;

      arr = ['a', 'b', 'c'];
      out = [];
      balUtil.each(arr, function(value, key) {
        return out[key] = value;
      });
      assert.deepEqual(arr, out, 'cycling an array produced the expected results');
      return done();
    });
    it('should cycle objects', function(done) {
      var obj, out;

      obj = {
        'a': 1,
        'b': 2,
        'c': 3
      };
      out = {};
      balUtil.each(obj, function(value, key) {
        return out[key] = value;
      });
      assert.deepEqual(obj, out, 'cycling an object produced the expected results');
      return done();
    });
    it('should shallow extend correctly', function(done) {
      var out, src;

      src = {
        a: {
          b: 2
        }
      };
      out = balUtil.shallowExtendPlainObjects({}, src);
      out.a.b = 3;
      assert.deepEqual({
        a: {
          b: 3
        }
      }, out, 'out object was as expected');
      assert.deepEqual({
        a: {
          b: 3
        }
      }, src, 'src object was modified');
      return done();
    });
    it('should safe shallow extend correctly', function(done) {
      var actual, expected;

      expected = {
        a: 2
      };
      actual = balUtil.safeShallowExtendPlainObjects({
        a: 1
      }, {
        a: 2
      }, {
        a: null
      });
      assert.deepEqual(actual, expected, 'out object was as expected');
      return done();
    });
    it('should deep extend correctly', function(done) {
      var out, src;

      src = {
        a: {
          b: 2
        }
      };
      out = balUtil.deepExtendPlainObjects({}, src);
      out.a.b = 3;
      assert.deepEqual({
        a: {
          b: 3
        }
      }, out, 'out object was as expected');
      assert.deepEqual({
        a: {
          b: 2
        }
      }, src, 'src object was not modified');
      return done();
    });
    it('should safe deep extend correctly', function(done) {
      var actual, expected;

      expected = {
        a: {
          b: 2
        }
      };
      actual = balUtil.safeDeepExtendPlainObjects({
        a: {
          b: 2
        }
      }, {
        a: {
          b: 2
        }
      }, {
        a: {
          b: null
        }
      });
      assert.deepEqual(actual, expected, 'out object was as expected');
      return done();
    });
    it('should dereference correctly', function(done) {
      var out, src;

      src = {
        a: {
          b: 2
        }
      };
      out = balUtil.dereference(src);
      out.a.b = 3;
      assert.deepEqual({
        a: {
          b: 3
        }
      }, out, 'out object was as expected');
      assert.deepEqual({
        a: {
          b: 2
        }
      }, src, 'src object was not modified');
      return done();
    });
    it('should getdeep correctly', function(done) {
      var actual, expected, src;

      src = {
        a: {
          b: {
            attributes: {
              c: 1
            }
          }
        }
      };
      expected = 1;
      actual = balUtil.getDeep(src, 'a.b.c');
      assert.equal(expected, actual, 'out value was as expected');
      actual = balUtil.getDeep(src, 'a.b.unknown');
      assert.ok(typeof actual === 'undefined', 'undefined value was as expected');
      return done();
    });
    return it('should setdeep correctly', function(done) {
      var expected, src;

      src = {
        a: {
          unknown: 'asd',
          b: {
            attributes: {
              c: 1
            }
          }
        }
      };
      expected = {
        a: {
          b: {
            attributes: {
              c: 2
            }
          }
        }
      };
      balUtil.setDeep(src, 'a.unknown', void 0);
      balUtil.setDeep(src, 'a.b.c', 2);
      assert.deepEqual(expected, src, 'out value was as expected');
      return done();
    });
  });

  joe.describe('Group', function(describe, it) {
    it('should work when tasks are specified manually', function(done) {
      var finished, firstTaskFinished, secondTaskFinished, tasks, total;

      firstTaskFinished = false;
      secondTaskFinished = false;
      finished = false;
      total = 2;
      tasks = new balUtil.Group(function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      tasks.total = 2;
      wait(1000, function() {
        firstTaskFinished = true;
        assert.equal(true, secondTaskFinished, 'the first task ran second as expected');
        return tasks.complete();
      });
      wait(500, function() {
        secondTaskFinished = true;
        assert.equal(false, firstTaskFinished, 'the second task ran first as expected');
        return tasks.complete();
      });
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      return wait(2000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should work when run synchronously', function(done) {
      var finished, firstTaskFinished, firstTaskRun, secondTaskFinished, secondTaskRun, tasks, total;

      firstTaskRun = false;
      secondTaskRun = false;
      firstTaskFinished = false;
      secondTaskFinished = false;
      finished = false;
      total = 2;
      tasks = new balUtil.Group(function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      tasks.push(function(complete) {
        firstTaskRun = true;
        assert.equal(false, secondTaskRun, 'the first task ran first as expected');
        return wait(1000, function() {
          firstTaskFinished = true;
          assert.equal(false, secondTaskFinished, 'the first task completed first as expected');
          return complete();
        });
      });
      tasks.push(function(complete) {
        secondTaskRun = true;
        assert.equal(true, firstTaskRun, 'the second task ran second as expected');
        return wait(500, function() {
          secondTaskFinished = true;
          assert.equal(true, firstTaskFinished, 'the second task completed second as expected');
          return complete();
        });
      });
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      tasks.sync();
      assert.equal(true, tasks.isRunning(), 'isRunning() returned true');
      return wait(2000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should work when run synchronously via run', function(done) {
      var finished, firstTaskFinished, firstTaskRun, secondTaskFinished, secondTaskRun, tasks, total;

      firstTaskRun = false;
      secondTaskRun = false;
      firstTaskFinished = false;
      secondTaskFinished = false;
      finished = false;
      total = 2;
      tasks = new balUtil.Group(function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      tasks.push(function(complete) {
        firstTaskRun = true;
        assert.equal(false, secondTaskRun, 'the first task ran first as expected');
        return wait(1000, function() {
          firstTaskFinished = true;
          assert.equal(false, secondTaskFinished, 'the first task completed first as expected');
          return complete();
        });
      });
      tasks.push(function(complete) {
        secondTaskRun = true;
        assert.equal(true, firstTaskRun, 'the second task ran second as expected');
        return wait(500, function() {
          secondTaskFinished = true;
          assert.equal(true, firstTaskFinished, 'the second task completed second as expected');
          return complete();
        });
      });
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      tasks.run('sync');
      assert.equal(true, tasks.isRunning(), 'isRunning() returned true');
      return wait(2000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should work when run asynchronously', function(done) {
      var finished, firstTaskFinished, firstTaskRun, secondTaskFinished, secondTaskRun, tasks, total;

      firstTaskRun = false;
      secondTaskRun = false;
      firstTaskFinished = false;
      secondTaskFinished = false;
      finished = false;
      total = 2;
      tasks = new balUtil.Group(function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      tasks.push(function(complete) {
        firstTaskRun = true;
        assert.equal(false, secondTaskRun, 'the first task ran first as expected');
        return wait(1000, function() {
          firstTaskFinished = true;
          assert.equal(true, secondTaskFinished, 'the first task completed second as expected');
          return complete();
        });
      });
      tasks.push(function(complete) {
        secondTaskRun = true;
        assert.equal(true, firstTaskRun, 'the second task ran second as expected');
        return wait(500, function() {
          secondTaskFinished = true;
          assert.equal(false, firstTaskFinished, 'the second task completed first as expected');
          return complete();
        });
      });
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      tasks.async();
      assert.equal(true, tasks.isRunning(), 'isRunning() returned true');
      return wait(2000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should handle errors correctly', function(done) {
      var finished, firstTaskFinished, firstTaskRun, secondTaskFinished, secondTaskRun, tasks, total;

      firstTaskRun = false;
      secondTaskRun = false;
      firstTaskFinished = false;
      secondTaskFinished = false;
      finished = false;
      total = 1;
      tasks = new balUtil.Group(function(err) {
        assert.equal(true, err !== null, 'an error is present');
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      tasks.push(function(complete) {
        firstTaskRun = true;
        assert.equal(false, secondTaskRun, 'the first task ran first as expected');
        return wait(1000, function() {
          firstTaskFinished = true;
          assert.equal(false, secondTaskFinished, 'the first task completed first as expected');
          return complete();
        });
      });
      tasks.push(function(complete) {
        secondTaskRun = true;
        assert.equal(true, firstTaskRun, 'the second task ran second as expected');
        return wait(500, function() {
          secondTaskFinished = true;
          assert.equal(true, firstTaskFinished, 'the second task completed second as expected');
          return complete(new Error('deliberate error'));
        });
      });
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      tasks.sync();
      assert.equal(true, tasks.isRunning(), 'isRunning() returned true');
      return wait(2000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(false, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should work with optional completion callbacks', function(done) {
      var finished, tasks, total;

      finished = false;
      total = 2;
      tasks = new balUtil.Group(function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      tasks.push(function(done) {
        return done();
      });
      tasks.push(function() {});
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      tasks.sync();
      return wait(5000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should work when specifying contexts', function(done) {
      var finished, tasks, total;

      finished = false;
      total = 2;
      tasks = new balUtil.Group(function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      tasks.push({
        blah: 1
      }, function() {
        return assert.equal(1, this.blah, 'context was applied correctly');
      });
      tasks.push({
        blah: 2
      }, function() {
        return assert.equal(2, this.blah, 'context was applied correctly');
      });
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      tasks.sync();
      return wait(5000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should push and run synchronous tasks correctly', function(done) {
      var finished, firstTaskFinished, firstTaskRun, secondTaskFinished, secondTaskRun, tasks, total;

      firstTaskRun = false;
      secondTaskRun = false;
      firstTaskFinished = false;
      secondTaskFinished = false;
      finished = false;
      total = 2;
      tasks = new balUtil.Group('serial', function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      assert.equal('serial', tasks.mode, 'mode was correctly set to serial');
      tasks.pushAndRun(function(complete) {
        firstTaskRun = true;
        assert.equal(false, secondTaskRun, 'the first task ran first as expected');
        return wait(1000, function() {
          firstTaskFinished = true;
          assert.equal(false, secondTaskFinished, 'the first task completed first as expected');
          return complete();
        });
      });
      assert.equal(true, tasks.isRunning(), 'isRunning() returned true');
      tasks.pushAndRun(function(complete) {
        secondTaskRun = true;
        assert.equal(true, firstTaskRun, 'the second task ran second as expected');
        return wait(500, function() {
          secondTaskFinished = true;
          assert.equal(true, firstTaskFinished, 'the second task completed second as expected');
          return complete();
        });
      });
      return wait(4000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should push and run asynchronous tasks correctly (queued)', function(done) {
      var finished, firstTaskFinished, firstTaskRun, secondTaskFinished, secondTaskRun, tasks, total;

      firstTaskRun = false;
      secondTaskRun = false;
      firstTaskFinished = false;
      secondTaskFinished = false;
      finished = false;
      total = 2;
      tasks = new balUtil.Group('parallel', function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      assert.equal('parallel', tasks.mode, 'mode was correctly set to parallel');
      tasks.pushAndRun(function(complete) {
        firstTaskRun = true;
        assert.equal(false, secondTaskRun, 'the first task ran first as expected');
        return wait(1000, function() {
          firstTaskFinished = true;
          assert.equal(true, secondTaskFinished, 'the first task completed second as expected');
          return complete();
        });
      });
      assert.equal(true, tasks.isRunning(), 'isRunning() returned true');
      tasks.pushAndRun(function(complete) {
        secondTaskRun = true;
        assert.equal(true, firstTaskRun, 'the second task ran second as expected');
        return wait(500, function() {
          secondTaskFinished = true;
          assert.equal(false, firstTaskFinished, 'the second task completed first as expected');
          return complete();
        });
      });
      return wait(4000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    it('should push and run synchronous tasks correctly (multiple times)', function(done) {
      var finished, tasks, total;

      finished = 0;
      total = 2;
      tasks = new balUtil.Group('serial', {
        autoClear: true
      }, function(err) {
        if (err) {
          return done(err);
        }
        return ++finished;
      });
      assert.equal('serial', tasks.mode, 'mode was correctly set to serial');
      assert.equal(true, tasks.autoClear, 'autoClear was correctly set to true');
      tasks.pushAndRun(function(complete) {
        return complete();
      });
      wait(500, function() {
        tasks.pushAndRun(function(complete) {
          return wait(500, function() {
            return complete();
          });
        });
        return assert.equal(true, tasks.isRunning(), 'isRunning() returned true');
      });
      return wait(2000, function() {
        assert.equal(total, finished, 'it exited the correct number of times');
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(false, tasks.hasCompleted(), 'hasCompleted() returned false');
        assert.equal(false, tasks.hasExited(), 'hasExited() returned false');
        return done();
      });
    });
    it('should work when running ten thousand tasks synchronously', function(done) {
      var finished, i, tasks, total, _i;

      finished = false;
      total = 10000;
      tasks = new balUtil.Group(function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      for (i = _i = 0; 0 <= total ? _i < total : _i > total; i = 0 <= total ? ++_i : --_i) {
        tasks.push(function(complete) {
          return complete();
        });
      }
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      tasks.sync();
      return wait(5000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
    return it('should work when running ten thousand tasks asynchronously', function(done) {
      var finished, i, tasks, total, _i;

      finished = false;
      total = 10000;
      tasks = new balUtil.Group(function(err) {
        if (err) {
          return done(err);
        }
        assert.equal(false, finished, 'the group of tasks only finished once');
        return finished = true;
      });
      for (i = _i = 0; 0 <= total ? _i < total : _i > total; i = 0 <= total ? ++_i : --_i) {
        tasks.push(function(complete) {
          return setTimeout(complete, 50);
        });
      }
      assert.equal(0, tasks.completed, 'no tasks should have started yet');
      tasks.async();
      return wait(5000, function() {
        assert.equal(total, tasks.completed, 'the expected number of tasks ran ' + ("" + tasks.completed + "/" + total));
        assert.equal(false, tasks.isRunning(), 'isRunning() returned false');
        assert.equal(true, tasks.hasCompleted(), 'hasCompleted() returned true');
        assert.equal(true, tasks.hasExited(), 'hasExited() returned true');
        return done();
      });
    });
  });

}).call(this);
