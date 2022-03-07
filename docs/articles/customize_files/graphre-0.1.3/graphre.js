"use strict";

function _instanceof(left, right) { if (right != null && typeof Symbol !== "undefined" && right[Symbol.hasInstance]) { return !!right[Symbol.hasInstance](left); } else { return left instanceof right; } }

function _wrapNativeSuper(Class) { var _cache = typeof Map === "function" ? new Map() : undefined; _wrapNativeSuper = function _wrapNativeSuper(Class) { if (Class === null || !_isNativeFunction(Class)) return Class; if (typeof Class !== "function") { throw new TypeError("Super expression must either be null or a function"); } if (typeof _cache !== "undefined") { if (_cache.has(Class)) return _cache.get(Class); _cache.set(Class, Wrapper); } function Wrapper() { return _construct(Class, arguments, _getPrototypeOf(this).constructor); } Wrapper.prototype = Object.create(Class.prototype, { constructor: { value: Wrapper, enumerable: false, writable: true, configurable: true } }); return _setPrototypeOf(Wrapper, Class); }; return _wrapNativeSuper(Class); }

function _construct(Parent, args, Class) { if (_isNativeReflectConstruct()) { _construct = Reflect.construct; } else { _construct = function _construct(Parent, args, Class) { var a = [null]; a.push.apply(a, args); var Constructor = Function.bind.apply(Parent, a); var instance = new Constructor(); if (Class) _setPrototypeOf(instance, Class.prototype); return instance; }; } return _construct.apply(null, arguments); }

function _isNativeFunction(fn) { return Function.toString.call(fn).indexOf("[native code]") !== -1; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }

function _createSuper(Derived) { var hasNativeReflectConstruct = _isNativeReflectConstruct(); return function _createSuperInternal() { var Super = _getPrototypeOf(Derived), result; if (hasNativeReflectConstruct) { var NewTarget = _getPrototypeOf(this).constructor; result = Reflect.construct(Super, arguments, NewTarget); } else { result = Super.apply(this, arguments); } return _possibleConstructorReturn(this, result); }; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

function _toConsumableArray(arr) { return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _unsupportedIterableToArray(arr) || _nonIterableSpread(); }

function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }

function _iterableToArray(iter) { if (typeof Symbol !== "undefined" && Symbol.iterator in Object(iter)) return Array.from(iter); }

function _arrayWithoutHoles(arr) { if (Array.isArray(arr)) return _arrayLikeToArray(arr); }

function _createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e2) { throw _e2; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e3) { didErr = true; err = _e3; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function _classCallCheck(instance, Constructor) { if (!_instanceof(instance, Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _typeof(obj) { "@babel/helpers - typeof"; if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

!function (e, r) {
  "object" == (typeof exports === "undefined" ? "undefined" : _typeof(exports)) && "undefined" != typeof module ? r(exports) : "function" == typeof define && define.amd ? define(["exports"], r) : r((e = "undefined" != typeof globalThis ? globalThis : e || self).graphre = {});
}(void 0, function (e) {
  "use strict";

  var r = /*#__PURE__*/function () {
    function r() {
      _classCallCheck(this, r);

      var e = {};
      e._next = e._prev = e, this._sentinel = e;
    }

    _createClass(r, [{
      key: "dequeue",
      value: function dequeue() {
        var e = this._sentinel,
            r = e._prev;
        if (r !== e) return n(r), r;
      }
    }, {
      key: "enqueue",
      value: function enqueue(e) {
        var r = this._sentinel,
            t = e;
        t._prev && t._next && n(t), t._next = r._next, r._next._prev = t, r._next = t, t._prev = r;
      }
    }, {
      key: "toString",
      value: function toString() {
        for (var e = [], r = this._sentinel, n = r._prev; n !== r;) {
          e.push(JSON.stringify(n, t)), n = n._prev;
        }

        return "[" + e.join(", ") + "]";
      }
    }]);

    return r;
  }();

  function n(e) {
    e._prev._next = e._next, e._next._prev = e._prev, delete e._next, delete e._prev;
  }

  function t(e, r) {
    if ("_next" !== e && "_prev" !== e) return r;
  }

  var o = Object.freeze({
    __proto__: null,
    List: r
  });
  var i = {};

  function a(e) {
    var r = [];

    var _iterator = _createForOfIteratorHelper(e),
        _step;

    try {
      for (_iterator.s(); !(_step = _iterator.n()).done;) {
        var n = _step.value;
        r.push.apply(r, _toConsumableArray(n));
      }
    } catch (err) {
      _iterator.e(err);
    } finally {
      _iterator.f();
    }

    return r;
  }

  function s(e, r) {
    return null != e && e.hasOwnProperty(r);
  }

  function d(e) {
    var r = null == e ? 0 : e.length;
    return r ? e[r - 1] : void 0;
  }

  function u(e, r) {
    e = Object(e);
    var n = {};
    return Object.keys(e).forEach(function (t) {
      n[t] = r(e[t], t);
    }), n;
  }

  function f(e, r) {
    var n = Number.POSITIVE_INFINITY,
        t = void 0;

    var _iterator2 = _createForOfIteratorHelper(e),
        _step2;

    try {
      for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
        var o = _step2.value;
        var i = r(o);
        i < n && (n = i, t = o);
      }
    } catch (err) {
      _iterator2.e(err);
    } finally {
      _iterator2.f();
    }

    return t;
  }

  function h(e, r) {
    var n = e < r ? 1 : -1;
    var t = -1,
        o = Math.max(Math.ceil((r - e) / (n || 1)), 0);
    var i = new Array(o);

    for (; o--;) {
      i[++t] = e, e += n;
    }

    return i;
  }

  function c(e, r) {
    return e.slice().sort(function (e, n) {
      return r(e) - r(n);
    });
  }

  function v(e) {
    i[e] || (i[e] = 0);
    return "".concat(e).concat(++i[e]);
  }

  function l(e) {
    return e ? Object.keys(e).map(function (r) {
      return e[r];
    }) : [];
  }

  function g(e, r) {
    for (var n = [], t = 0; t < e; t++) {
      n.push(r());
    }

    return n;
  }

  function p(e) {
    return void 0 === e;
  }

  function m(e, r) {
    for (var _i = 0, _Object$keys = Object.keys(e); _i < _Object$keys.length; _i++) {
      var n = _Object$keys[_i];
      r(e[n], n);
    }
  }

  function w(e) {
    return 0 === Object.keys(e).length;
  }

  function _(e) {
    var r = {},
        n = e.nodes().filter(function (r) {
      return !e.children(r).length;
    }),
        t = g(Math.max.apply(Math, _toConsumableArray(n.map(function (r) {
      return e.node(r).rank;
    }))) + 1, function () {
      return [];
    });
    return c(n, function (r) {
      return e.node(r).rank;
    }).forEach(function n(o) {
      if (!s(r, o)) {
        r[o] = !0;
        var i = e.node(o);
        t[i.rank].push(o), e.successors(o).forEach(n);
      }
    }), t;
  }

  function b(e, r) {
    for (var n = 0, t = 1; t < r.length; ++t) {
      n += y(e, r[t - 1], r[t]);
    }

    return n;
  }

  function y(e, r, n) {
    for (var t = {}, o = 0; o < n.length; o++) {
      t[n[o]] = o;
    }

    for (var i = a(r.map(function (r) {
      return c(e.outEdges(r).map(function (r) {
        return {
          pos: t[r.w],
          weight: e.edge(r).weight
        };
      }), function (e) {
        return e.pos;
      });
    })), s = 1; s < n.length;) {
      s <<= 1;
    }

    var d = 2 * s - 1;
    s -= 1;
    var u = g(d, function () {
      return 0;
    }),
        f = 0;
    return i.forEach(function (e) {
      var r = e.pos + s;
      u[r] += e.weight;

      for (var n = 0; r > 0;) {
        r % 2 && (n += u[r + 1]), u[r = r - 1 >> 1] += e.weight;
      }

      f += e.weight * n;
    }), f;
  }

  function k(e, r) {
    return r ? r.map(function (r) {
      var n = e.inEdges(r);

      if (n.length) {
        var t = n.reduce(function (r, n) {
          var t = e.edge(n),
              o = e.node(n.v);
          return {
            sum: r.sum + t.weight * o.order,
            weight: r.weight + t.weight
          };
        }, {
          sum: 0,
          weight: 0
        });
        return {
          v: r,
          barycenter: t.sum / t.weight,
          weight: t.weight
        };
      }

      return {
        v: r
      };
    }) : [];
  }

  function E(e, r) {
    for (var n = {}, t = 0; t < e.length; t++) {
      var o = e[t],
          i = n[o.v] = {
        indegree: 0,
        in: [],
        out: [],
        vs: [o.v],
        i: t
      };
      void 0 !== o.barycenter && (i.barycenter = o.barycenter, i.weight = o.weight);
    }

    var _iterator3 = _createForOfIteratorHelper(r.edges()),
        _step3;

    try {
      for (_iterator3.s(); !(_step3 = _iterator3.n()).done;) {
        var a = _step3.value;
        var s = n[a.v],
            d = n[a.w];
        void 0 !== s && void 0 !== d && (d.indegree++, s.out.push(n[a.w]));
      }
    } catch (err) {
      _iterator3.e(err);
    } finally {
      _iterator3.f();
    }

    return function (e) {
      var r = [];

      function n(e) {
        return function (r) {
          r.merged || (void 0 === r.barycenter || void 0 === e.barycenter || r.barycenter >= e.barycenter) && function (e, r) {
            var n = 0,
                t = 0;
            e.weight && (n += e.barycenter * e.weight, t += e.weight);
            r.weight && (n += r.barycenter * r.weight, t += r.weight);
            e.vs = r.vs.concat(e.vs), e.barycenter = n / t, e.weight = t, e.i = Math.min(r.i, e.i), r.merged = !0;
          }(e, r);
        };
      }

      function t(r) {
        return function (n) {
          n.in.push(r), 0 == --n.indegree && e.push(n);
        };
      }

      for (; e.length;) {
        var o = e.pop();
        r.push(o), o.in.reverse().forEach(n(o)), o.out.forEach(t(o));
      }

      return r.filter(function (e) {
        return !e.merged;
      }).map(function (e) {
        var r = {
          vs: e.vs,
          i: e.i
        };
        return "barycenter" in e && (r.barycenter = e.barycenter), "weight" in e && (r.weight = e.weight), r;
      });
    }(l(n).filter(function (e) {
      return !e.indegree;
    }));
  }

  var N = "\0";

  var x = /*#__PURE__*/function () {
    function x() {
      var e = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};

      _classCallCheck(this, x);

      this._label = void 0, this._nodeCount = 0, this._edgeCount = 0, this._isDirected = !s(e, "directed") || e.directed, this._isMultigraph = !!s(e, "multigraph") && e.multigraph, this._isCompound = !!s(e, "compound") && e.compound, this._defaultNodeLabelFn = function () {}, this._defaultEdgeLabelFn = function () {}, this._nodes = {}, this._isCompound && (this._parent = {}, this._children = {}, this._children["\0"] = {}), this._in = {}, this._preds = {}, this._out = {}, this._sucs = {}, this._edgeObjs = {}, this._edgeLabels = {};
    }

    _createClass(x, [{
      key: "isDirected",
      value: function isDirected() {
        return this._isDirected;
      }
    }, {
      key: "isMultigraph",
      value: function isMultigraph() {
        return this._isMultigraph;
      }
    }, {
      key: "isCompound",
      value: function isCompound() {
        return this._isCompound;
      }
    }, {
      key: "setGraph",
      value: function setGraph(e) {
        return this._label = e, this;
      }
    }, {
      key: "graph",
      value: function graph() {
        return this._label;
      }
    }, {
      key: "setDefaultNodeLabel",
      value: function setDefaultNodeLabel(e) {
        var r;
        return r = e, this._defaultNodeLabelFn = "function" != typeof r ? function () {
          return e;
        } : e, this;
      }
    }, {
      key: "nodeCount",
      value: function nodeCount() {
        return this._nodeCount;
      }
    }, {
      key: "nodes",
      value: function nodes() {
        return Object.keys(this._nodes);
      }
    }, {
      key: "sources",
      value: function sources() {
        var e = this;
        return this.nodes().filter(function (r) {
          return w(e._in[r]);
        });
      }
    }, {
      key: "sinks",
      value: function sinks() {
        var e = this;
        return this.nodes().filter(function (r) {
          return w(e._out[r]);
        });
      }
    }, {
      key: "setNodes",
      value: function setNodes(e, r) {
        var _iterator4 = _createForOfIteratorHelper(e),
            _step4;

        try {
          for (_iterator4.s(); !(_step4 = _iterator4.n()).done;) {
            var n = _step4.value;
            void 0 !== r ? this.setNode(n, r) : this.setNode(n);
          }
        } catch (err) {
          _iterator4.e(err);
        } finally {
          _iterator4.f();
        }

        return this;
      }
    }, {
      key: "setNode",
      value: function setNode(e, r) {
        return s(this._nodes, e) ? (arguments.length > 1 && (this._nodes[e] = r), this) : (this._nodes[e] = arguments.length > 1 ? r : this._defaultNodeLabelFn(e), this._isCompound && (this._parent[e] = N, this._children[e] = {}, this._children["\0"][e] = !0), this._in[e] = {}, this._preds[e] = {}, this._out[e] = {}, this._sucs[e] = {}, ++this._nodeCount, this);
      }
    }, {
      key: "node",
      value: function node(e) {
        return this._nodes[e];
      }
    }, {
      key: "hasNode",
      value: function hasNode(e) {
        return s(this._nodes, e);
      }
    }, {
      key: "removeNode",
      value: function removeNode(e) {
        var _this = this;

        var r = this;

        if (s(this._nodes, e)) {
          var n = function n(e) {
            r.removeEdge(_this._edgeObjs[e]);
          };

          if (delete this._nodes[e], this._isCompound) {
            var _iterator5 = _createForOfIteratorHelper((this._removeFromParentsChildList(e), delete this._parent[e], this.children(e))),
                _step5;

            try {
              for (_iterator5.s(); !(_step5 = _iterator5.n()).done;) {
                var t = _step5.value;
                r.setParent(t);
              }
            } catch (err) {
              _iterator5.e(err);
            } finally {
              _iterator5.f();
            }

            delete this._children[e];
          }

          for (var _i2 = 0, _Object$keys2 = Object.keys(this._in[e]); _i2 < _Object$keys2.length; _i2++) {
            var o = _Object$keys2[_i2];
            n(o);
          }

          for (var _i3 = 0, _arr = (delete this._in[e], delete this._preds[e], Object.keys(this._out[e])); _i3 < _arr.length; _i3++) {
            var o = _arr[_i3];
            n(o);
          }

          delete this._out[e], delete this._sucs[e], --this._nodeCount;
        }

        return this;
      }
    }, {
      key: "setParent",
      value: function setParent(e, r) {
        if (!this._isCompound) throw new Error("Cannot set parent in a non-compound graph");
        if (void 0 === r) r = N;else {
          for (var n = r += ""; !p(n); n = this.parent(n)) {
            if (n === e) throw new Error("Setting ".concat(r, " as parent of ").concat(e, " would create a cycle"));
          }

          this.setNode(r);
        }
        return this.setNode(e), this._removeFromParentsChildList(e), this._parent[e] = r, this._children[r][e] = !0, this;
      }
    }, {
      key: "_removeFromParentsChildList",
      value: function _removeFromParentsChildList(e) {
        delete this._children[this._parent[e]][e];
      }
    }, {
      key: "parent",
      value: function parent(e) {
        if (this._isCompound) {
          var r = this._parent[e];
          if (r !== N) return r;
        }
      }
    }, {
      key: "children",
      value: function children(e) {
        if (p(e) && (e = N), this._isCompound) {
          var r = this._children[e];
          return r ? Object.keys(r) : void 0;
        }

        return e === N ? this.nodes() : this.hasNode(e) ? [] : void 0;
      }
    }, {
      key: "predecessors",
      value: function predecessors(e) {
        var r = this._preds[e];
        if (r) return Object.keys(r);
      }
    }, {
      key: "successors",
      value: function successors(e) {
        var r = this._sucs[e];
        if (r) return Object.keys(r);
      }
    }, {
      key: "neighbors",
      value: function neighbors(e) {
        var r = this.predecessors(e);
        if (r) return function (e, r) {
          var n = _toConsumableArray(e);

          var _iterator6 = _createForOfIteratorHelper(r),
              _step6;

          try {
            for (_iterator6.s(); !(_step6 = _iterator6.n()).done;) {
              var t = _step6.value;
              -1 === n.indexOf(t) && n.push(t);
            }
          } catch (err) {
            _iterator6.e(err);
          } finally {
            _iterator6.f();
          }

          return n;
        }(r, this.successors(e));
      }
    }, {
      key: "isLeaf",
      value: function isLeaf(e) {
        return 0 === (this.isDirected() ? this.successors(e) : this.neighbors(e)).length;
      }
    }, {
      key: "filterNodes",
      value: function filterNodes(e) {
        var r = new x({
          directed: this._isDirected,
          multigraph: this._isMultigraph,
          compound: this._isCompound
        });
        r.setGraph(this.graph());
        var n = this;
        m(this._nodes, function (n, t) {
          e(t) && r.setNode(t, n);
        }), m(this._edgeObjs, function (e) {
          r.hasNode(e.v) && r.hasNode(e.w) && r.setEdge(e, n.edge(e));
        });
        var t = {};

        function o(e) {
          var i = n.parent(e);
          return void 0 === i || r.hasNode(i) ? (t[e] = i, i) : i in t ? t[i] : o(i);
        }

        if (this._isCompound) {
          var _iterator7 = _createForOfIteratorHelper(r.nodes()),
              _step7;

          try {
            for (_iterator7.s(); !(_step7 = _iterator7.n()).done;) {
              var i = _step7.value;
              r.setParent(i, o(i));
            }
          } catch (err) {
            _iterator7.e(err);
          } finally {
            _iterator7.f();
          }
        }

        return r;
      }
    }, {
      key: "setDefaultEdgeLabel",
      value: function setDefaultEdgeLabel(e) {
        var r;
        return r = e, this._defaultEdgeLabelFn = "function" != typeof r ? function () {
          return e;
        } : e, this;
      }
    }, {
      key: "edgeCount",
      value: function edgeCount() {
        return this._edgeCount;
      }
    }, {
      key: "edges",
      value: function edges() {
        return Object.values(this._edgeObjs);
      }
    }, {
      key: "setPath",
      value: function setPath(e, r) {
        var n = this,
            t = arguments;
        return e.reduce(function (e, o) {
          return t.length > 1 ? n.setEdge(e, o, r) : n.setEdge(e, o), o;
        }), this;
      }
    }, {
      key: "setEdge",
      value: function setEdge(e, r, n, t) {
        var o = !1,
            i = e;
        "object" == _typeof(i) && null !== i && "v" in i ? (e = i.v, r = i.w, t = i.name, 2 === arguments.length && (n = arguments[1], o = !0)) : (e = i, r = arguments[1], t = arguments[3], arguments.length > 2 && (n = arguments[2], o = !0)), e = "" + e, r = "" + r, p(t) || (t = "" + t);
        var a = j(this._isDirected, e, r, t);
        if (s(this._edgeLabels, a)) return o && (this._edgeLabels[a] = n), this;
        if (!p(t) && !this._isMultigraph) throw new Error("Cannot set a named edge when isMultigraph = false");
        this.setNode(e), this.setNode(r), this._edgeLabels[a] = o ? n : this._defaultEdgeLabelFn(e, r, t);

        var d = function (e, r, n, t) {
          var o = "" + r,
              i = "" + n;

          if (!e && o > i) {
            var a = o;
            o = i, i = a;
          }

          var s = {
            v: o,
            w: i
          };
          t && (s.name = t);
          return s;
        }(this._isDirected, e, r, t);

        return e = d.v, r = d.w, Object.freeze(d), this._edgeObjs[a] = d, C(this._preds[r], e), C(this._sucs[e], r), this._in[r][a] = d, this._out[e][a] = d, this._edgeCount++, this;
      }
    }, {
      key: "edge",
      value: function edge(e, r, n) {
        var t = "object" == _typeof(e) ? M(this._isDirected, e) : j(this._isDirected, e, r, n);
        return this._edgeLabels[t];
      }
    }, {
      key: "hasEdge",
      value: function hasEdge(e, r, n) {
        var t = 1 === arguments.length ? M(this._isDirected, arguments[0]) : j(this._isDirected, e, r, n);
        return s(this._edgeLabels, t);
      }
    }, {
      key: "removeEdge",
      value: function removeEdge(e, r, n) {
        var t = "object" == _typeof(e) ? M(this._isDirected, e) : j(this._isDirected, e, r, n),
            o = this._edgeObjs[t];
        return o && (e = o.v, r = o.w, delete this._edgeLabels[t], delete this._edgeObjs[t], O(this._preds[r], e), O(this._sucs[e], r), delete this._in[r][t], delete this._out[e][t], this._edgeCount--), this;
      }
    }, {
      key: "inEdges",
      value: function inEdges(e, r) {
        var n = this._in[e];

        if (n) {
          var t = Object.values(n);
          return r ? t.filter(function (e) {
            return e.v === r;
          }) : t;
        }
      }
    }, {
      key: "outEdges",
      value: function outEdges(e, r) {
        var n = this._out[e];

        if (n) {
          var t = Object.values(n);
          return r ? t.filter(function (e) {
            return e.w === r;
          }) : t;
        }
      }
    }, {
      key: "nodeEdges",
      value: function nodeEdges(e, r) {
        var n = this.inEdges(e, r);
        if (n) return n.concat(this.outEdges(e, r));
      }
    }]);

    return x;
  }();

  var I = /*#__PURE__*/function (_x) {
    _inherits(I, _x);

    var _super = _createSuper(I);

    function I() {
      _classCallCheck(this, I);

      return _super.apply(this, arguments);
    }

    return I;
  }(x);

  function C(e, r) {
    e[r] ? e[r]++ : e[r] = 1;
  }

  function O(e, r) {
    --e[r] || delete e[r];
  }

  function j(e, r, n, t) {
    var o = "" + r,
        i = "" + n;

    if (!e && o > i) {
      var a = o;
      o = i, i = a;
    }

    return o + "" + i + "" + (p(t) ? "\0" : t);
  }

  function M(e, r) {
    return j(e, r.v, r.w, r.name);
  }

  function L(e, r, n, t) {
    var o;

    do {
      o = v(t);
    } while (e.hasNode(o));

    return n.dummy = r, e.setNode(o, n), o;
  }

  function T(e) {
    var r = new x().setGraph(e.graph());

    var _iterator8 = _createForOfIteratorHelper(e.nodes()),
        _step8;

    try {
      for (_iterator8.s(); !(_step8 = _iterator8.n()).done;) {
        var n = _step8.value;
        r.setNode(n, e.node(n));
      }
    } catch (err) {
      _iterator8.e(err);
    } finally {
      _iterator8.f();
    }

    var _iterator9 = _createForOfIteratorHelper(e.edges()),
        _step9;

    try {
      for (_iterator9.s(); !(_step9 = _iterator9.n()).done;) {
        var t = _step9.value;
        var o = r.edge(t.v, t.w) || {
          weight: 0,
          minlen: 1
        },
            i = e.edge(t);
        r.setEdge(t.v, t.w, {
          weight: o.weight + i.weight,
          minlen: Math.max(o.minlen, i.minlen)
        });
      }
    } catch (err) {
      _iterator9.e(err);
    } finally {
      _iterator9.f();
    }

    return r;
  }

  function S(e) {
    var r = new x({
      multigraph: e.isMultigraph()
    }).setGraph(e.graph());

    var _iterator10 = _createForOfIteratorHelper(e.nodes()),
        _step10;

    try {
      for (_iterator10.s(); !(_step10 = _iterator10.n()).done;) {
        var n = _step10.value;
        e.children(n).length || r.setNode(n, e.node(n));
      }
    } catch (err) {
      _iterator10.e(err);
    } finally {
      _iterator10.f();
    }

    var _iterator11 = _createForOfIteratorHelper(e.edges()),
        _step11;

    try {
      for (_iterator11.s(); !(_step11 = _iterator11.n()).done;) {
        var t = _step11.value;
        r.setEdge(t, e.edge(t));
      }
    } catch (err) {
      _iterator11.e(err);
    } finally {
      _iterator11.f();
    }

    return r;
  }

  function P(e, r) {
    var n,
        t,
        o = e.x,
        i = e.y,
        a = r.x - o,
        s = r.y - i,
        d = e.width / 2,
        u = e.height / 2;
    if (!a && !s) throw new Error("Not possible to find intersection inside of the rectangle");
    return Math.abs(s) * d > Math.abs(a) * u ? (s < 0 && (u = -u), n = u * a / s, t = u) : (a < 0 && (d = -d), n = d, t = d * s / a), {
      x: o + n,
      y: i + t
    };
  }

  function R(e) {
    var r = g(G(e) + 1, function () {
      return [];
    });

    var _iterator12 = _createForOfIteratorHelper(e.nodes()),
        _step12;

    try {
      for (_iterator12.s(); !(_step12 = _iterator12.n()).done;) {
        var n = _step12.value;
        var t = e.node(n),
            o = t.rank;
        void 0 !== o && (r[o][t.order] = n);
      }
    } catch (err) {
      _iterator12.e(err);
    } finally {
      _iterator12.f();
    }

    return r;
  }

  function F(e) {
    var r = Math.min.apply(Math, _toConsumableArray(e.nodes().map(function (r) {
      return e.node(r).rank;
    }).filter(function (e) {
      return void 0 !== e;
    })));

    var _iterator13 = _createForOfIteratorHelper(e.nodes()),
        _step13;

    try {
      for (_iterator13.s(); !(_step13 = _iterator13.n()).done;) {
        var n = _step13.value;
        var t = e.node(n);
        s(t, "rank") && (t.rank -= r);
      }
    } catch (err) {
      _iterator13.e(err);
    } finally {
      _iterator13.f();
    }
  }

  function D(e) {
    var r = Math.min.apply(Math, _toConsumableArray(e.nodes().map(function (r) {
      return e.node(r).rank;
    }).filter(function (e) {
      return void 0 !== e;
    }))),
        n = [];

    var _iterator14 = _createForOfIteratorHelper(e.nodes()),
        _step14;

    try {
      for (_iterator14.s(); !(_step14 = _iterator14.n()).done;) {
        var t = _step14.value;
        var o = e.node(t).rank - r;
        n[o] || (n[o] = []), n[o].push(t);
      }
    } catch (err) {
      _iterator14.e(err);
    } finally {
      _iterator14.f();
    }

    for (var i = 0, a = e.graph().nodeRankFactor, s = 0; s < n.length; s++) {
      var d = n[s];
      if (void 0 === d && s % a != 0) --i;else if (i && null != d) {
        var _iterator15 = _createForOfIteratorHelper(d),
            _step15;

        try {
          for (_iterator15.s(); !(_step15 = _iterator15.n()).done;) {
            var t = _step15.value;
            e.node(t).rank += i;
          }
        } catch (err) {
          _iterator15.e(err);
        } finally {
          _iterator15.f();
        }
      }
    }
  }

  function z(e, r, n, t) {
    var o = {
      width: 0,
      height: 0
    };
    return arguments.length >= 4 && (o.rank = n, o.order = t), L(e, "border", o, r);
  }

  function G(e) {
    var r = e.nodes().map(function (r) {
      return e.node(r).rank;
    }).filter(function (e) {
      return void 0 !== e;
    });
    return Math.max.apply(Math, _toConsumableArray(r));
  }

  function V(e, r) {
    var n = [],
        t = [];

    var _iterator16 = _createForOfIteratorHelper(e),
        _step16;

    try {
      for (_iterator16.s(); !(_step16 = _iterator16.n()).done;) {
        var o = _step16.value;
        r(o) ? n.push(o) : t.push(o);
      }
    } catch (err) {
      _iterator16.e(err);
    } finally {
      _iterator16.f();
    }

    return {
      lhs: n,
      rhs: t
    };
  }

  function Y(e, r) {
    var n = Date.now();

    try {
      return r();
    } finally {
      console.log(e + " time: " + (Date.now() - n) + "ms");
    }
  }

  function B(e, r) {
    return r();
  }

  var A = Object.freeze({
    __proto__: null,
    addDummyNode: L,
    simplify: T,
    asNonCompoundGraph: S,
    successorWeights: function successorWeights(e) {
      var r = {};

      var _iterator17 = _createForOfIteratorHelper(e.nodes()),
          _step17;

      try {
        for (_iterator17.s(); !(_step17 = _iterator17.n()).done;) {
          var n = _step17.value;
          var t = {};

          var _iterator18 = _createForOfIteratorHelper(e.outEdges(n)),
              _step18;

          try {
            for (_iterator18.s(); !(_step18 = _iterator18.n()).done;) {
              var o = _step18.value;
              t[o.w] = (t[o.w] || 0) + e.edge(o).weight;
            }
          } catch (err) {
            _iterator18.e(err);
          } finally {
            _iterator18.f();
          }

          r[n] = t;
        }
      } catch (err) {
        _iterator17.e(err);
      } finally {
        _iterator17.f();
      }

      return r;
    },
    predecessorWeights: function predecessorWeights(e) {
      var r = {};

      var _iterator19 = _createForOfIteratorHelper(e.nodes()),
          _step19;

      try {
        for (_iterator19.s(); !(_step19 = _iterator19.n()).done;) {
          var n = _step19.value;
          var t = {};

          var _iterator20 = _createForOfIteratorHelper(e.inEdges(n)),
              _step20;

          try {
            for (_iterator20.s(); !(_step20 = _iterator20.n()).done;) {
              var o = _step20.value;
              t[o.v] = (t[o.v] || 0) + e.edge(o).weight;
            }
          } catch (err) {
            _iterator20.e(err);
          } finally {
            _iterator20.f();
          }

          r[n] = t;
        }
      } catch (err) {
        _iterator19.e(err);
      } finally {
        _iterator19.f();
      }

      return r;
    },
    intersectRect: P,
    buildLayerMatrix: R,
    normalizeRanks: F,
    removeEmptyRanks: D,
    addBorderNode: z,
    maxRank: G,
    partition: V,
    time: Y,
    notime: B
  });

  function q(e, r) {
    var n,
        t = V(e, function (e) {
      return s(e, "barycenter");
    }),
        o = t.lhs,
        i = c(t.rhs, function (e) {
      return -e.i;
    }),
        d = [],
        u = 0,
        f = 0,
        h = 0;

    var _iterator21 = _createForOfIteratorHelper((o.sort((n = !!r, function (e, r) {
      return e.barycenter < r.barycenter ? -1 : e.barycenter > r.barycenter ? 1 : n ? r.i - e.i : e.i - r.i;
    })), h = W(d, i, h), o)),
        _step21;

    try {
      for (_iterator21.s(); !(_step21 = _iterator21.n()).done;) {
        var v = _step21.value;
        h += v.vs.length, d.push(v.vs), u += v.barycenter * v.weight, f += v.weight, h = W(d, i, h);
      }
    } catch (err) {
      _iterator21.e(err);
    } finally {
      _iterator21.f();
    }

    var l = {
      vs: a(d)
    };
    return f && (l.barycenter = u / f, l.weight = f), l;
  }

  function W(e, r, n) {
    for (var t; r.length && (t = d(r)).i <= n;) {
      r.pop(), e.push(t.vs), n++;
    }

    return n;
  }

  function $(e, r, n, t) {
    var o = e.children(r),
        i = e.node(r),
        d = i ? i.borderLeft : void 0,
        u = i ? i.borderRight : void 0,
        f = {};
    d && (o = o.filter(function (e) {
      return e !== d && e !== u;
    }));
    var h = k(e, o);

    var _iterator22 = _createForOfIteratorHelper(h),
        _step22;

    try {
      for (_iterator22.s(); !(_step22 = _iterator22.n()).done;) {
        var c = _step22.value;

        if (e.children(c.v).length) {
          var v = $(e, c.v, n, t);
          f[c.v] = v, s(v, "barycenter") && J(c, v);
        }
      }
    } catch (err) {
      _iterator22.e(err);
    } finally {
      _iterator22.f();
    }

    var l = E(h, n);
    !function (e, r) {
      var _iterator23 = _createForOfIteratorHelper(e),
          _step23;

      try {
        for (_iterator23.s(); !(_step23 = _iterator23.n()).done;) {
          var n = _step23.value;
          n.vs = a(n.vs.map(function (e) {
            return r[e] ? r[e].vs : [e];
          }));
        }
      } catch (err) {
        _iterator23.e(err);
      } finally {
        _iterator23.f();
      }
    }(l, f);
    var g = q(l, t);

    if (d && (g.vs = [d].concat(_toConsumableArray(g.vs), [u]), e.predecessors(d).length)) {
      var p = e.node(e.predecessors(d)[0]),
          m = e.node(e.predecessors(u)[0]);
      s(g, "barycenter") || (g.barycenter = 0, g.weight = 0), g.barycenter = (g.barycenter * g.weight + p.order + m.order) / (g.weight + 2), g.weight += 2;
    }

    return g;
  }

  function J(e, r) {
    void 0 !== e.barycenter ? (e.barycenter = (e.barycenter * e.weight + r.barycenter * r.weight) / (e.weight + r.weight), e.weight += r.weight) : (e.barycenter = r.barycenter, e.weight = r.weight);
  }

  function Q(e, r, n) {
    var t = function (e) {
      var r;

      for (; e.hasNode(r = v("_root"));) {
        ;
      }

      return r;
    }(e),
        o = new x({
      compound: !0
    }).setGraph({
      root: t
    }).setDefaultNodeLabel(function (r) {
      return e.node(r);
    });

    var _iterator24 = _createForOfIteratorHelper(e.nodes()),
        _step24;

    try {
      for (_iterator24.s(); !(_step24 = _iterator24.n()).done;) {
        var i = _step24.value;
        var a = e.node(i),
            d = e.parent(i);

        if (a.rank === r || a.minRank <= r && r <= a.maxRank) {
          var _iterator25 = _createForOfIteratorHelper((o.setNode(i), o.setParent(i, d || t), e[n](i))),
              _step25;

          try {
            for (_iterator25.s(); !(_step25 = _iterator25.n()).done;) {
              var u = _step25.value;
              var f = u.v === i ? u.w : u.v,
                  h = o.edge(f, i),
                  c = void 0 !== h ? h.weight : 0;
              o.setEdge(f, i, {
                weight: e.edge(u).weight + c
              });
            }
          } catch (err) {
            _iterator25.e(err);
          } finally {
            _iterator25.f();
          }

          s(a, "minRank") && o.setNode(i, {
            borderLeft: a.borderLeft[r],
            borderRight: a.borderRight[r]
          });
        }
      }
    } catch (err) {
      _iterator24.e(err);
    } finally {
      _iterator24.f();
    }

    return o;
  }

  function K(e, r, n) {
    var t,
        o = {};

    var _iterator26 = _createForOfIteratorHelper(n),
        _step26;

    try {
      for (_iterator26.s(); !(_step26 = _iterator26.n()).done;) {
        var i = _step26.value;
        !function () {
          for (var n, a = e.parent(i); a;) {
            var s = e.parent(a);
            if (s ? (n = o[s], o[s] = a) : (n = t, t = a), n && n !== a) return void r.setEdge(n, a);
            a = s;
          }
        }();
      }
    } catch (err) {
      _iterator26.e(err);
    } finally {
      _iterator26.f();
    }
  }

  function X(e) {
    var r = G(e),
        n = H(e, h(1, r + 1), "inEdges"),
        t = H(e, h(r - 1, -1), "outEdges"),
        o = _(e);

    Z(e, o);

    for (var i, a = Number.POSITIVE_INFINITY, s = 0, d = 0; d < 4; ++s, ++d) {
      U(s % 2 ? n : t, s % 4 >= 2);
      var u = b(e, o = R(e));
      u < a && (d = 0, i = o.map(function (e) {
        return e.slice(0);
      }), a = u);
    }

    Z(e, i);
  }

  function H(e, r, n) {
    return r.map(function (r) {
      return Q(e, r, n);
    });
  }

  function U(e, r) {
    var n = new x();

    var _iterator27 = _createForOfIteratorHelper(e),
        _step27;

    try {
      for (_iterator27.s(); !(_step27 = _iterator27.n()).done;) {
        var t = _step27.value;
        var o = t.graph().root,
            i = $(t, o, n, r);
        i.vs.map(function (e, r) {
          t.node(e).order = r;
        }), K(t, n, i.vs);
      }
    } catch (err) {
      _iterator27.e(err);
    } finally {
      _iterator27.f();
    }
  }

  function Z(e, r) {
    var _iterator28 = _createForOfIteratorHelper(r),
        _step28;

    try {
      for (_iterator28.s(); !(_step28 = _iterator28.n()).done;) {
        var n = _step28.value;
        n.map(function (r, n) {
          e.node(r).order = n;
        });
      }
    } catch (err) {
      _iterator28.e(err);
    } finally {
      _iterator28.f();
    }
  }

  var ee = Object.freeze({
    __proto__: null,
    order: X,
    addSubgraphConstraints: K,
    barycenter: k,
    buildLayerGraph: Q,
    crossCount: b,
    initOrder: _,
    resolveConflicts: E,
    sortSubgraph: $,
    sort: q
  });

  function re(e, r) {
    var n = {};
    return r.reduce(function (r, t) {
      for (var o = 0, i = 0, a = r.length, s = d(t), u = 0; u < t.length; u++) {
        var f = t[u],
            h = te(e, f),
            c = h ? e.node(h).order : a;

        if (h || f === s) {
          var _iterator29 = _createForOfIteratorHelper(t.slice(i, u + 1)),
              _step29;

          try {
            for (_iterator29.s(); !(_step29 = _iterator29.n()).done;) {
              var v = _step29.value;

              var _iterator30 = _createForOfIteratorHelper(e.predecessors(v)),
                  _step30;

              try {
                for (_iterator30.s(); !(_step30 = _iterator30.n()).done;) {
                  var l = _step30.value;
                  var g = e.node(l),
                      p = g.order;
                  !(p < o || c < p) || g.dummy && e.node(v).dummy || oe(n, l, v);
                }
              } catch (err) {
                _iterator30.e(err);
              } finally {
                _iterator30.f();
              }
            }
          } catch (err) {
            _iterator29.e(err);
          } finally {
            _iterator29.f();
          }

          i = u + 1, o = c;
        }
      }

      return t;
    }), n;
  }

  function ne(e, r) {
    var n = {};

    function t(r, t, o, i, a) {
      var s;

      var _iterator31 = _createForOfIteratorHelper(h(t, o)),
          _step31;

      try {
        for (_iterator31.s(); !(_step31 = _iterator31.n()).done;) {
          var d = _step31.value;

          if (s = r[d], e.node(s).dummy) {
            var _iterator32 = _createForOfIteratorHelper(e.predecessors(s)),
                _step32;

            try {
              for (_iterator32.s(); !(_step32 = _iterator32.n()).done;) {
                var u = _step32.value;
                var f = e.node(u);
                f.dummy && (f.order < i || f.order > a) && oe(n, u, s);
              }
            } catch (err) {
              _iterator32.e(err);
            } finally {
              _iterator32.f();
            }
          }
        }
      } catch (err) {
        _iterator31.e(err);
      } finally {
        _iterator31.f();
      }
    }

    return r.reduce(function (r, n) {
      for (var o, i = -1, a = 0, s = 0; s < n.length; s++) {
        var d = s,
            u = n[s];

        if (void 0 !== u) {
          if ("border" === e.node(u).dummy) {
            var f = e.predecessors(u);
            f.length && (t(n, a, d, i, o = e.node(f[0]).order), a = d, i = o);
          }

          t(n, a, n.length, o, r.length);
        }
      }

      return n;
    }), n;
  }

  function te(e, r) {
    if (e.node(r).dummy) {
      var _iterator33 = _createForOfIteratorHelper(e.predecessors(r)),
          _step33;

      try {
        for (_iterator33.s(); !(_step33 = _iterator33.n()).done;) {
          var n = _step33.value;
          if (e.node(n).dummy) return n;
        }
      } catch (err) {
        _iterator33.e(err);
      } finally {
        _iterator33.f();
      }
    }
  }

  function oe(e, r, n) {
    if (r > n) {
      var t = r;
      r = n, n = t;
    }

    var o = e[r];
    o || (e[r] = o = {}), o[n] = !0;
  }

  function ie(e, r, n) {
    if (r > n) {
      var t = r;
      r = n, n = t;
    }

    return s(e[r], n);
  }

  function ae(e, r, n, t) {
    var o = {},
        i = {},
        a = {};

    var _iterator34 = _createForOfIteratorHelper(r),
        _step34;

    try {
      for (_iterator34.s(); !(_step34 = _iterator34.n()).done;) {
        var s = _step34.value;

        for (var d = 0; d < s.length; d++) {
          o[f = s[d]] = f, i[f] = f, a[f] = d;
        }
      }
    } catch (err) {
      _iterator34.e(err);
    } finally {
      _iterator34.f();
    }

    var _iterator35 = _createForOfIteratorHelper(r),
        _step35;

    try {
      for (_iterator35.s(); !(_step35 = _iterator35.n()).done;) {
        var s = _step35.value;
        var u = -1;

        var _iterator36 = _createForOfIteratorHelper(s),
            _step36;

        try {
          for (_iterator36.s(); !(_step36 = _iterator36.n()).done;) {
            var f = _step36.value;
            var h = t(f);
            if (h.length) for (var v = ((h = c(h, function (e) {
              return a[e];
            })).length - 1) / 2, l = Math.floor(v), g = Math.ceil(v); l <= g; ++l) {
              var p = h[l];
              i[f] === f && u < a[p] && !ie(n, f, p) && (i[p] = f, i[f] = o[f] = o[p], u = a[p]);
            }
          }
        } catch (err) {
          _iterator36.e(err);
        } finally {
          _iterator36.f();
        }
      }
    } catch (err) {
      _iterator35.e(err);
    } finally {
      _iterator35.f();
    }

    return {
      root: o,
      align: i
    };
  }

  function se(e, r, n, t, o) {
    var i = {},
        a = function (e, r, n, t) {
      var o = new x(),
          i = e.graph(),
          a = ce(i.nodesep, i.edgesep, t);

      var _iterator37 = _createForOfIteratorHelper(r),
          _step37;

      try {
        for (_iterator37.s(); !(_step37 = _iterator37.n()).done;) {
          var s = _step37.value;
          var d = null;

          var _iterator38 = _createForOfIteratorHelper(s),
              _step38;

          try {
            for (_iterator38.s(); !(_step38 = _iterator38.n()).done;) {
              var u = _step38.value;
              var f = n[u];

              if (o.setNode(f), d) {
                var h = n[d],
                    c = o.edge(h, f);
                o.setEdge(h, f, Math.max(a(e, u, d), c || 0));
              }

              d = u;
            }
          } catch (err) {
            _iterator38.e(err);
          } finally {
            _iterator38.f();
          }
        }
      } catch (err) {
        _iterator37.e(err);
      } finally {
        _iterator37.f();
      }

      return o;
    }(e, r, n, o),
        s = o ? "borderLeft" : "borderRight";

    function d(e, r) {
      for (var n = a.nodes(), t = n.pop(), o = {}; t;) {
        o[t] ? e(t) : (o[t] = !0, n.push(t), n = n.concat(r(t))), t = n.pop();
      }
    }

    for (var _i4 = 0, _arr2 = (d(function (e) {
      i[e] = a.inEdges(e).reduce(function (e, r) {
        return Math.max(e, i[r.v] + a.edge(r));
      }, 0);
    }, function (e) {
      return a.predecessors(e);
    }), d(function (r) {
      var n = a.outEdges(r).reduce(function (e, r) {
        return Math.min(e, i[r.w] - a.edge(r));
      }, Number.POSITIVE_INFINITY),
          t = e.node(r);
      n !== Number.POSITIVE_INFINITY && t.borderType !== s && (i[r] = Math.max(i[r], n));
    }, function (e) {
      return a.successors(e);
    }), Object.keys(t)); _i4 < _arr2.length; _i4++) {
      var u = _arr2[_i4];
      var f = t[u];
      i[f] = i[n[f]];
    }

    return i;
  }

  function de(e, r) {
    return f(l(r), function (r) {
      var n = Number.NEGATIVE_INFINITY,
          t = Number.POSITIVE_INFINITY;

      for (var o in r) {
        var i = r[o],
            a = ve(e, o) / 2;
        n = Math.max(i + a, n), t = Math.min(i - a, t);
      }

      return n - t;
    });
  }

  function ue(e, r) {
    var n = l(r),
        t = Math.min.apply(Math, _toConsumableArray(n)),
        o = Math.max.apply(Math, _toConsumableArray(n));

    for (var _i5 = 0, _arr3 = ["ul", "ur", "dl", "dr"]; _i5 < _arr3.length; _i5++) {
      var i = _arr3[_i5];
      var a = i[1],
          s = e[i];

      if (s !== r) {
        var d = l(s),
            f = "l" === a ? t - Math.min.apply(Math, _toConsumableArray(d)) : o - Math.max.apply(Math, _toConsumableArray(d));
        f && (e[i] = u(s, function (e) {
          return e + f;
        }));
      }
    }
  }

  function fe(e, r) {
    return u(e.ul, function (n, t) {
      if (r) return e[r.toLowerCase()][t];
      var o = c([e.ul[t], e.ur[t], e.dl[t], e.dr[t]], function (e) {
        return e;
      });
      return (o[1] + o[2]) / 2;
    });
  }

  function he(e) {
    var r,
        n = R(e),
        t = Object.assign(Object.assign({}, re(e, n)), ne(e, n)),
        o = {
      ul: {},
      ur: {},
      dl: {},
      dr: {}
    };

    for (var _i6 = 0, _arr4 = ["u", "d"]; _i6 < _arr4.length; _i6++) {
      var i = _arr4[_i6];

      for (var _i7 = 0, _arr5 = (r = "u" === i ? n : n.map(function (e) {
        return e;
      }).reverse(), ["l", "r"]); _i7 < _arr5.length; _i7++) {
        var a = _arr5[_i7];
        "r" === a && (r = r.map(function (e) {
          return e.map(function (e) {
            return e;
          }).reverse();
        }));
        var s = ae(0, r, t, ("u" === i ? e.predecessors : e.successors).bind(e)),
            d = se(e, r, s.root, s.align, "r" === a);
        "r" === a && (d = u(d, function (e) {
          return -e;
        })), o[i + a] = d;
      }
    }

    return ue(o, de(e, o)), fe(o, e.graph().align);
  }

  function ce(e, r, n) {
    return function (t, o, i) {
      var a,
          d = t.node(o),
          u = t.node(i),
          f = 0;
      if (f += d.width / 2, s(d, "labelpos")) switch (d.labelpos.toLowerCase()) {
        case "l":
          a = -d.width / 2;
          break;

        case "r":
          a = d.width / 2;
      }
      if (a && (f += n ? a : -a), a = 0, f += (d.dummy ? r : e) / 2, f += (u.dummy ? r : e) / 2, f += u.width / 2, s(u, "labelpos")) switch (u.labelpos.toLowerCase()) {
        case "l":
          a = u.width / 2;
          break;

        case "r":
          a = -u.width / 2;
      }
      return a && (f += n ? a : -a), a = 0, f;
    };
  }

  function ve(e, r) {
    return e.node(r).width;
  }

  var le = Object.freeze({
    __proto__: null,
    findType1Conflicts: re,
    findType2Conflicts: ne,
    findOtherInnerSegmentNode: te,
    addConflict: oe,
    hasConflict: ie,
    verticalAlignment: ae,
    horizontalCompaction: se,
    findSmallestWidthAlignment: de,
    alignCoordinates: ue,
    balance: fe,
    positionX: he,
    sep: ce,
    width: ve
  });

  function ge(e) {
    !function (e) {
      var r = R(e),
          n = e.graph().ranksep,
          t = 0;

      var _iterator39 = _createForOfIteratorHelper(r),
          _step39;

      try {
        for (_iterator39.s(); !(_step39 = _iterator39.n()).done;) {
          var o = _step39.value;
          var i = Math.max.apply(Math, _toConsumableArray(o.map(function (r) {
            return e.node(r).height;
          })));

          var _iterator40 = _createForOfIteratorHelper(o),
              _step40;

          try {
            for (_iterator40.s(); !(_step40 = _iterator40.n()).done;) {
              var a = _step40.value;
              e.node(a).y = t + i / 2;
            }
          } catch (err) {
            _iterator40.e(err);
          } finally {
            _iterator40.f();
          }

          t += i + n;
        }
      } catch (err) {
        _iterator39.e(err);
      } finally {
        _iterator39.f();
      }
    }(e = S(e));
    var r = he(e);

    for (var n in r) {
      e.node(n).x = r[n];
    }
  }

  var pe = Object.freeze({
    __proto__: null,
    bk: le,
    position: ge
  });

  function me(e) {
    var r = {};
    e.sources().forEach(function n(t) {
      var o = e.node(t);
      if (s(r, t)) return o.rank;
      r[t] = !0;
      var i = Math.min.apply(Math, _toConsumableArray(e.outEdges(t).map(function (r) {
        return n(r.w) - e.edge(r).minlen;
      })));
      return i !== Number.POSITIVE_INFINITY && null != i || (i = 0), o.rank = i;
    });
  }

  function we(e, r) {
    return e.node(r.w).rank - e.node(r.v).rank - e.edge(r).minlen;
  }

  function _e(e) {
    var r,
        n = new x({
      directed: !1
    }),
        t = e.nodes()[0],
        o = e.nodeCount();

    for (n.setNode(t, {}); i(e) < o;) {
      r = a(e), s(e, n.hasNode(r.v) ? we(e, r) : -we(e, r));
    }

    return n;

    function i(e) {
      return n.nodes().forEach(function r(t) {
        var _iterator41 = _createForOfIteratorHelper(e.nodeEdges(t)),
            _step41;

        try {
          for (_iterator41.s(); !(_step41 = _iterator41.n()).done;) {
            var o = _step41.value;
            var i = o.v,
                a = t === i ? o.w : i;
            n.hasNode(a) || we(e, o) || (n.setNode(a, {}), n.setEdge(t, a, {}), r(a));
          }
        } catch (err) {
          _iterator41.e(err);
        } finally {
          _iterator41.f();
        }
      }), n.nodeCount();
    }

    function a(e) {
      return f(e.edges(), function (r) {
        if (n.hasNode(r.v) !== n.hasNode(r.w)) return we(e, r);
      });
    }

    function s(e, r) {
      var _iterator42 = _createForOfIteratorHelper(n.nodes()),
          _step42;

      try {
        for (_iterator42.s(); !(_step42 = _iterator42.n()).done;) {
          var t = _step42.value;
          e.node(t).rank += r;
        }
      } catch (err) {
        _iterator42.e(err);
      } finally {
        _iterator42.f();
      }
    }
  }

  var be = /*#__PURE__*/function () {
    function be() {
      _classCallCheck(this, be);

      this._arr = [], this._keyIndices = {};
    }

    _createClass(be, [{
      key: "size",
      value: function size() {
        return this._arr.length;
      }
    }, {
      key: "keys",
      value: function keys() {
        return this._arr.map(function (e) {
          return e.key;
        });
      }
    }, {
      key: "has",
      value: function has(e) {
        return e in this._keyIndices;
      }
    }, {
      key: "priority",
      value: function priority(e) {
        var r = this._keyIndices[e];
        if (void 0 !== r) return this._arr[r].priority;
      }
    }, {
      key: "min",
      value: function min() {
        if (0 === this.size()) throw new Error("Queue underflow");
        return this._arr[0].key;
      }
    }, {
      key: "add",
      value: function add(e, r) {
        var n = this._keyIndices;

        if (!((e = String(e)) in n)) {
          var t = this._arr,
              o = t.length;
          return n[e] = o, t.push({
            key: e,
            priority: r
          }), this._decrease(o), !0;
        }

        return !1;
      }
    }, {
      key: "removeMin",
      value: function removeMin() {
        this._swap(0, this._arr.length - 1);

        var e = this._arr.pop();

        return delete this._keyIndices[e.key], this._heapify(0), e.key;
      }
    }, {
      key: "decrease",
      value: function decrease(e, r) {
        var n = this._keyIndices[e];
        if (r > this._arr[n].priority) throw new Error("New priority is greater than current priority. Key: " + e + " Old: " + this._arr[n].priority + " New: " + r);
        this._arr[n].priority = r, this._decrease(n);
      }
    }, {
      key: "_heapify",
      value: function _heapify(e) {
        var r = this._arr,
            n = 2 * e,
            t = n + 1,
            o = e;
        n < r.length && (o = r[n].priority < r[o].priority ? n : o, t < r.length && (o = r[t].priority < r[o].priority ? t : o), o !== e && (this._swap(e, o), this._heapify(o)));
      }
    }, {
      key: "_decrease",
      value: function _decrease(e) {
        for (var r, n = this._arr, t = n[e].priority; 0 !== e && !(n[r = e >> 1].priority < t);) {
          this._swap(e, r), e = r;
        }
      }
    }, {
      key: "_swap",
      value: function _swap(e, r) {
        var n = this._arr,
            t = this._keyIndices,
            o = n[e],
            i = n[r];
        n[e] = i, n[r] = o, t[i.key] = e, t[o.key] = r;
      }
    }]);

    return be;
  }();

  var ye = function ye() {
    return 1;
  };

  function ke(e, r, n, t) {
    return function (e, r, n, t) {
      var o,
          i,
          a = {},
          s = new be(),
          d = function d(e) {
        var r = e.v !== o ? e.v : e.w,
            t = a[r],
            d = n(e),
            u = i.distance + d;
        if (d < 0) throw new Error("dijkstra does not allow negative edge weights. Bad edge: " + e + " Weight: " + d);
        u < t.distance && (t.distance = u, t.predecessor = o, s.decrease(r, u));
      };

      e.nodes().forEach(function (e) {
        var n = e === r ? 0 : Number.POSITIVE_INFINITY;
        a[e] = {
          distance: n
        }, s.add(e, n);
      });

      for (; s.size() > 0 && (o = s.removeMin(), (i = a[o]).distance !== Number.POSITIVE_INFINITY);) {
        t(o).forEach(d);
      }

      return a;
    }(e, String(r), n || ye, t || function (r) {
      return e.outEdges(r);
    });
  }

  function Ee(e) {
    var r = 0,
        n = [],
        t = {},
        o = [];

    function i(a) {
      var s = t[a] = {
        onStack: !0,
        lowlink: r,
        index: r++
      };

      if (n.push(a), e.successors(a).forEach(function (e) {
        e in t ? t[e].onStack && (s.lowlink = Math.min(s.lowlink, t[e].index)) : (i(e), s.lowlink = Math.min(s.lowlink, t[e].lowlink));
      }), s.lowlink === s.index) {
        var d,
            u = [];

        do {
          d = n.pop(), t[d].onStack = !1, u.push(d);
        } while (a !== d);

        o.push(u);
      }
    }

    return e.nodes().forEach(function (e) {
      e in t || i(e);
    }), o;
  }

  var Ne = function Ne() {
    return 1;
  };

  var xe = /*#__PURE__*/function (_Error) {
    _inherits(xe, _Error);

    var _super2 = _createSuper(xe);

    function xe() {
      _classCallCheck(this, xe);

      return _super2.apply(this, arguments);
    }

    return xe;
  }( /*#__PURE__*/_wrapNativeSuper(Error));

  function Ie(e) {
    var r = {},
        n = {},
        t = [];

    function o(i) {
      if (i in n) throw new xe();

      if (!(i in r)) {
        var _iterator43 = _createForOfIteratorHelper((n[i] = !0, r[i] = !0, e.predecessors(i))),
            _step43;

        try {
          for (_iterator43.s(); !(_step43 = _iterator43.n()).done;) {
            var a = _step43.value;
            o(a);
          }
        } catch (err) {
          _iterator43.e(err);
        } finally {
          _iterator43.f();
        }

        delete n[i], t.push(i);
      }
    }

    var _iterator44 = _createForOfIteratorHelper(e.sinks()),
        _step44;

    try {
      for (_iterator44.s(); !(_step44 = _iterator44.n()).done;) {
        var i = _step44.value;
        o(i);
      }
    } catch (err) {
      _iterator44.e(err);
    } finally {
      _iterator44.f();
    }

    if (Object.keys(r).length !== e.nodeCount()) throw new xe();
    return t;
  }

  function Ce(e, r, n) {
    var t = Array.isArray(r) ? r : [r],
        o = (e.isDirected() ? e.successors : e.neighbors).bind(e),
        i = [],
        a = {};

    var _iterator45 = _createForOfIteratorHelper(t),
        _step45;

    try {
      for (_iterator45.s(); !(_step45 = _iterator45.n()).done;) {
        var s = _step45.value;
        if (!e.hasNode(s)) throw new Error("Graph does not have node: " + s);
        Oe(e, s, "post" === n, a, o, i);
      }
    } catch (err) {
      _iterator45.e(err);
    } finally {
      _iterator45.f();
    }

    return i;
  }

  function Oe(e, r, n, t, o, i) {
    if (!(r in t)) {
      var _iterator46 = _createForOfIteratorHelper((t[r] = !0, n || i.push(r), o(r))),
          _step46;

      try {
        for (_iterator46.s(); !(_step46 = _iterator46.n()).done;) {
          var a = _step46.value;
          Oe(e, a, n, t, o, i);
        }
      } catch (err) {
        _iterator46.e(err);
      } finally {
        _iterator46.f();
      }

      n && i.push(r);
    }
  }

  function je(e, r) {
    return Ce(e, r, "post");
  }

  function Me(e, r) {
    return Ce(e, r, "pre");
  }

  var Le = Object.freeze({
    __proto__: null,
    components: function components(e) {
      var r,
          n = {},
          t = [];

      function o(t) {
        if (!(t in n)) {
          var _iterator47 = _createForOfIteratorHelper((n[t] = !0, r.push(t), e.successors(t))),
              _step47;

          try {
            for (_iterator47.s(); !(_step47 = _iterator47.n()).done;) {
              var i = _step47.value;
              o(i);
            }
          } catch (err) {
            _iterator47.e(err);
          } finally {
            _iterator47.f();
          }

          var _iterator48 = _createForOfIteratorHelper(e.predecessors(t)),
              _step48;

          try {
            for (_iterator48.s(); !(_step48 = _iterator48.n()).done;) {
              var a = _step48.value;
              o(a);
            }
          } catch (err) {
            _iterator48.e(err);
          } finally {
            _iterator48.f();
          }
        }
      }

      var _iterator49 = _createForOfIteratorHelper(e.nodes()),
          _step49;

      try {
        for (_iterator49.s(); !(_step49 = _iterator49.n()).done;) {
          var i = _step49.value;
          r = [], o(i), r.length && t.push(r);
        }
      } catch (err) {
        _iterator49.e(err);
      } finally {
        _iterator49.f();
      }

      return t;
    },
    dijkstra: ke,
    dijkstraAll: function dijkstraAll(e, r, n) {
      var t = {};

      var _iterator50 = _createForOfIteratorHelper(e.nodes()),
          _step50;

      try {
        for (_iterator50.s(); !(_step50 = _iterator50.n()).done;) {
          var o = _step50.value;
          t[o] = ke(e, o, r, n);
        }
      } catch (err) {
        _iterator50.e(err);
      } finally {
        _iterator50.f();
      }

      return t;
    },
    findCycles: function findCycles(e) {
      return Ee(e).filter(function (r) {
        return r.length > 1 || 1 === r.length && e.hasEdge(r[0], r[0]);
      });
    },
    floydWarshall: function floydWarshall(e, r, n) {
      return function (e, r, n) {
        var t = {},
            o = e.nodes();
        return o.forEach(function (e) {
          t[e] = {}, t[e][e] = {
            distance: 0
          }, o.forEach(function (r) {
            e !== r && (t[e][r] = {
              distance: Number.POSITIVE_INFINITY
            });
          }), n(e).forEach(function (n) {
            var o = n.v === e ? n.w : n.v,
                i = r(n);
            t[e][o] = {
              distance: i,
              predecessor: e
            };
          });
        }), o.forEach(function (e) {
          var r = t[e];
          o.forEach(function (n) {
            var i = t[n];
            o.forEach(function (n) {
              var t = i[e],
                  o = r[n],
                  a = i[n],
                  s = t.distance + o.distance;
              s < a.distance && (a.distance = s, a.predecessor = o.predecessor);
            });
          });
        }), t;
      }(e, r || Ne, n || function (r) {
        return e.outEdges(r);
      });
    },
    isAcyclic: function isAcyclic(e) {
      try {
        Ie(e);
      } catch (e) {
        if (_instanceof(e, xe)) return !1;
        throw e;
      }

      return !0;
    },
    postorder: je,
    preorder: Me,
    prim: function prim(e, r) {
      var n,
          t = new I({}),
          o = {},
          i = new be();

      function a(e) {
        var t = e.v === n ? e.w : e.v,
            a = i.priority(t);

        if (void 0 !== a) {
          var s = r(e);
          s < a && (o[t] = n, i.decrease(t, s));
        }
      }

      if (0 === e.nodeCount()) return t;

      var _iterator51 = _createForOfIteratorHelper(e.nodes()),
          _step51;

      try {
        for (_iterator51.s(); !(_step51 = _iterator51.n()).done;) {
          n = _step51.value;
          i.add(n, Number.POSITIVE_INFINITY), t.setNode(n);
        }
      } catch (err) {
        _iterator51.e(err);
      } finally {
        _iterator51.f();
      }

      i.decrease(e.nodes()[0], 0);

      for (var s = !1; i.size() > 0;) {
        if ((n = i.removeMin()) in o) t.setEdge(n, o[n]);else {
          if (s) throw new Error("Input graph is not connected: " + e);
          s = !0;
        }
        e.nodeEdges(n).forEach(a);
      }

      return t;
    },
    tarjan: Ee,
    topsort: Ie
  });

  function Te(e) {
    me(e = T(e));

    var r,
        n = _e(e);

    for (Fe(n), Se(n, e); r = ze(n);) {
      Ve(n, e, r, Ge(n, e, r));
    }
  }

  function Se(e, r) {
    var n = je(e, e.nodes());

    var _iterator52 = _createForOfIteratorHelper(n = n.slice(0, n.length - 1)),
        _step52;

    try {
      for (_iterator52.s(); !(_step52 = _iterator52.n()).done;) {
        var t = _step52.value;
        Pe(e, r, t);
      }
    } catch (err) {
      _iterator52.e(err);
    } finally {
      _iterator52.f();
    }
  }

  function Pe(e, r, n) {
    var t = e.node(n).parent;
    e.edge(n, t).cutvalue = Re(e, r, n);
  }

  function Re(e, r, n) {
    var t,
        o,
        i = e.node(n).parent,
        a = !0,
        s = r.edge(n, i),
        d = 0;

    var _iterator53 = _createForOfIteratorHelper((s || (a = !1, s = r.edge(i, n)), d = s.weight, r.nodeEdges(n))),
        _step53;

    try {
      for (_iterator53.s(); !(_step53 = _iterator53.n()).done;) {
        var u = _step53.value;
        var f = u.v === n,
            h = f ? u.w : u.v;

        if (h !== i) {
          var c = f === a,
              v = r.edge(u).weight;

          if (d += c ? v : -v, t = n, o = h, e.hasEdge(t, o)) {
            var l = e.edge(n, h).cutvalue;
            d += c ? -l : l;
          }
        }
      }
    } catch (err) {
      _iterator53.e(err);
    } finally {
      _iterator53.f();
    }

    return d;
  }

  function Fe(e, r) {
    arguments.length < 2 && (r = e.nodes()[0]), De(e, {}, 1, r);
  }

  function De(e, r, n, t, o) {
    var i = n,
        a = e.node(t);

    var _iterator54 = _createForOfIteratorHelper((r[t] = !0, e.neighbors(t))),
        _step54;

    try {
      for (_iterator54.s(); !(_step54 = _iterator54.n()).done;) {
        var d = _step54.value;
        s(r, d) || (n = De(e, r, n, d, t));
      }
    } catch (err) {
      _iterator54.e(err);
    } finally {
      _iterator54.f();
    }

    return a.low = i, a.lim = n++, o ? a.parent = o : delete a.parent, n;
  }

  function ze(e) {
    var _iterator55 = _createForOfIteratorHelper(e.edges()),
        _step55;

    try {
      for (_iterator55.s(); !(_step55 = _iterator55.n()).done;) {
        var r = _step55.value;
        if (e.edge(r).cutvalue < 0) return r;
      }
    } catch (err) {
      _iterator55.e(err);
    } finally {
      _iterator55.f();
    }
  }

  function Ge(e, r, n) {
    var t = n.v,
        o = n.w;
    r.hasEdge(t, o) || (t = n.w, o = n.v);
    var i = e.node(t),
        a = e.node(o),
        s = i,
        d = !1;
    return i.lim > a.lim && (s = a, d = !0), f(r.edges().filter(function (r) {
      return d === Ye(e, e.node(r.v), s) && d !== Ye(e, e.node(r.w), s);
    }), function (e) {
      return we(r, e);
    });
  }

  function Ve(e, r, n, t) {
    var o = n.v,
        i = n.w;
    e.removeEdge(o, i), e.setEdge(t.v, t.w, {}), Fe(e), Se(e, r), function (e, r) {
      var n = function (e, r) {
        var _iterator56 = _createForOfIteratorHelper(e.nodes()),
            _step56;

        try {
          for (_iterator56.s(); !(_step56 = _iterator56.n()).done;) {
            var n = _step56.value;
            if (!r.node(n).parent) return n;
          }
        } catch (err) {
          _iterator56.e(err);
        } finally {
          _iterator56.f();
        }

        return;
      }(e, r),
          t = Me(e, n);

      var _iterator57 = _createForOfIteratorHelper(t = t.slice(1)),
          _step57;

      try {
        for (_iterator57.s(); !(_step57 = _iterator57.n()).done;) {
          var o = _step57.value;
          var i = e.node(o).parent,
              a = r.edge(o, i),
              s = !1;
          a || (a = r.edge(i, o), s = !0), r.node(o).rank = r.node(i).rank + (s ? a.minlen : -a.minlen);
        }
      } catch (err) {
        _iterator57.e(err);
      } finally {
        _iterator57.f();
      }
    }(e, r);
  }

  function Ye(e, r, n) {
    return n.low <= r.lim && r.lim <= n.lim;
  }

  function Be(e) {
    switch (e.graph().ranker) {
      case "network-simplex":
        We(e);
        break;

      case "tight-tree":
        qe(e);
        break;

      case "longest-path":
        Ae(e);
        break;

      default:
        We(e);
    }
  }

  Te.initLowLimValues = Fe, Te.initCutValues = Se, Te.calcCutValue = Re, Te.leaveEdge = ze, Te.enterEdge = Ge, Te.exchangeEdges = Ve;
  var Ae = me;

  function qe(e) {
    me(e), _e(e);
  }

  function We(e) {
    Te(e);
  }

  var $e = Object.freeze({
    __proto__: null,
    rank: Be,
    tightTreeRanker: qe,
    networkSimplexRanker: We,
    networkSimplex: Te,
    feasibleTree: _e,
    longestPath: me
  }),
      Je = function Je(e) {
    return 1;
  };

  function Qe(e, n) {
    if (e.nodeCount() <= 1) return [];

    var t = function (e, n) {
      var t = new x(),
          o = 0,
          i = 0;

      var _iterator58 = _createForOfIteratorHelper(e.nodes()),
          _step58;

      try {
        for (_iterator58.s(); !(_step58 = _iterator58.n()).done;) {
          var a = _step58.value;
          t.setNode(a, {
            v: a,
            in: 0,
            out: 0
          });
        }
      } catch (err) {
        _iterator58.e(err);
      } finally {
        _iterator58.f();
      }

      var _iterator59 = _createForOfIteratorHelper(e.edges()),
          _step59;

      try {
        for (_iterator59.s(); !(_step59 = _iterator59.n()).done;) {
          var s = _step59.value;
          var d = t.edge(s.v, s.w) || 0,
              u = n(s),
              f = d + u;
          t.setEdge(s.v, s.w, f), i = Math.max(i, t.node(s.v).out += u), o = Math.max(o, t.node(s.w).in += u);
        }
      } catch (err) {
        _iterator59.e(err);
      } finally {
        _iterator59.f();
      }

      var h = g(i + o + 3, function () {
        return new r();
      }),
          c = o + 1;

      var _iterator60 = _createForOfIteratorHelper(t.nodes()),
          _step60;

      try {
        for (_iterator60.s(); !(_step60 = _iterator60.n()).done;) {
          var a = _step60.value;
          Xe(h, c, t.node(a));
        }
      } catch (err) {
        _iterator60.e(err);
      } finally {
        _iterator60.f();
      }

      return {
        graph: t,
        buckets: h,
        zeroIdx: c
      };
    }(e, n || Je);

    return a(function (e, r, n) {
      var t,
          o = [],
          i = r[r.length - 1],
          a = r[0];

      for (; e.nodeCount();) {
        for (; t = a.dequeue();) {
          Ke(e, r, n, t);
        }

        for (; t = i.dequeue();) {
          Ke(e, r, n, t);
        }

        if (e.nodeCount()) for (var s = r.length - 2; s > 0; --s) {
          if (t = r[s].dequeue()) {
            o = o.concat(Ke(e, r, n, t, !0));
            break;
          }
        }
      }

      return o;
    }(t.graph, t.buckets, t.zeroIdx).map(function (r) {
      return e.outEdges(r.v, r.w);
    }));
  }

  function Ke(e, r, n, t, o) {
    var i = o ? [] : void 0;

    var _iterator61 = _createForOfIteratorHelper(e.inEdges(t.v)),
        _step61;

    try {
      for (_iterator61.s(); !(_step61 = _iterator61.n()).done;) {
        var a = _step61.value;
        var s = e.edge(a),
            d = e.node(a.v);
        o && i.push({
          v: a.v,
          w: a.w
        }), d.out -= s, Xe(r, n, d);
      }
    } catch (err) {
      _iterator61.e(err);
    } finally {
      _iterator61.f();
    }

    var _iterator62 = _createForOfIteratorHelper(e.outEdges(t.v)),
        _step62;

    try {
      for (_iterator62.s(); !(_step62 = _iterator62.n()).done;) {
        var a = _step62.value;
        s = e.edge(a);
        var u = a.w,
            f = e.node(u);
        f.in -= s, Xe(r, n, f);
      }
    } catch (err) {
      _iterator62.e(err);
    } finally {
      _iterator62.f();
    }

    return e.removeNode(t.v), i;
  }

  function Xe(e, r, n) {
    n.out ? n.in ? e[n.out - n.in + r].enqueue(n) : e[e.length - 1].enqueue(n) : e[0].enqueue(n);
  }

  var He = {
    run: function run(e) {
      var r = "greedy" === e.graph().acyclicer ? Qe(e, function (e) {
        return function (r) {
          return e.edge(r).weight;
        };
      }(e)) : function (e) {
        var r = [],
            n = {},
            t = {};

        function o(i) {
          if (!s(t, i)) {
            var _iterator63 = _createForOfIteratorHelper((t[i] = !0, n[i] = !0, e.outEdges(i))),
                _step63;

            try {
              for (_iterator63.s(); !(_step63 = _iterator63.n()).done;) {
                var a = _step63.value;
                s(n, a.w) ? r.push(a) : o(a.w);
              }
            } catch (err) {
              _iterator63.e(err);
            } finally {
              _iterator63.f();
            }

            delete n[i];
          }
        }

        return e.nodes().forEach(o), r;
      }(e);

      var _iterator64 = _createForOfIteratorHelper(r),
          _step64;

      try {
        for (_iterator64.s(); !(_step64 = _iterator64.n()).done;) {
          var n = _step64.value;
          var t = e.edge(n);
          e.removeEdge(n), t.forwardName = n.name, t.reversed = !0, e.setEdge(n.w, n.v, t, v("rev"));
        }
      } catch (err) {
        _iterator64.e(err);
      } finally {
        _iterator64.f();
      }
    },
    undo: function undo(e) {
      var _iterator65 = _createForOfIteratorHelper(e.edges()),
          _step65;

      try {
        for (_iterator65.s(); !(_step65 = _iterator65.n()).done;) {
          var r = _step65.value;
          var n = e.edge(r);

          if (n.reversed) {
            e.removeEdge(r);
            var t = n.forwardName;
            delete n.reversed, delete n.forwardName, e.setEdge(r.w, r.v, n, t);
          }
        }
      } catch (err) {
        _iterator65.e(err);
      } finally {
        _iterator65.f();
      }
    }
  };

  function Ue(e) {
    e.children().forEach(function r(n) {
      var t = e.children(n),
          o = e.node(n);

      if (t.length && t.forEach(r), s(o, "minRank")) {
        o.borderLeft = [], o.borderRight = [];

        for (var i = o.minRank, a = o.maxRank + 1; i < a; ++i) {
          Ze(e, "borderLeft", "_bl", n, o, i), Ze(e, "borderRight", "_br", n, o, i);
        }
      }
    });
  }

  function Ze(e, r, n, t, o, i) {
    var a = {
      width: 0,
      height: 0,
      rank: i,
      borderType: r
    },
        s = o[r][i - 1],
        d = L(e, "border", a, n);
    o[r][i] = d, e.setParent(d, t), s && e.setEdge(s, d, {
      weight: 1
    });
  }

  var er = {
    adjust: function adjust(e) {
      var r = e.graph().rankdir.toLowerCase();
      "lr" !== r && "rl" !== r || rr(e);
    },
    undo: function undo(e) {
      var r = e.graph().rankdir.toLowerCase();
      "bt" !== r && "rl" !== r || function (e) {
        var _iterator66 = _createForOfIteratorHelper(e.nodes()),
            _step66;

        try {
          for (_iterator66.s(); !(_step66 = _iterator66.n()).done;) {
            var r = _step66.value;
            tr(e.node(r));
          }
        } catch (err) {
          _iterator66.e(err);
        } finally {
          _iterator66.f();
        }

        var _iterator67 = _createForOfIteratorHelper(e.edges()),
            _step67;

        try {
          for (_iterator67.s(); !(_step67 = _iterator67.n()).done;) {
            var n = _step67.value;
            var t = e.edge(n);
            t.points.forEach(tr), s(t, "y") && tr(t);
          }
        } catch (err) {
          _iterator67.e(err);
        } finally {
          _iterator67.f();
        }
      }(e);
      "lr" !== r && "rl" !== r || (!function (e) {
        var _iterator68 = _createForOfIteratorHelper(e.nodes()),
            _step68;

        try {
          for (_iterator68.s(); !(_step68 = _iterator68.n()).done;) {
            var r = _step68.value;
            or(e.node(r));
          }
        } catch (err) {
          _iterator68.e(err);
        } finally {
          _iterator68.f();
        }

        var _iterator69 = _createForOfIteratorHelper(e.edges()),
            _step69;

        try {
          for (_iterator69.s(); !(_step69 = _iterator69.n()).done;) {
            var n = _step69.value;
            var t = e.edge(n);
            t.points.forEach(or), s(t, "x") && or(t);
          }
        } catch (err) {
          _iterator69.e(err);
        } finally {
          _iterator69.f();
        }
      }(e), rr(e));
    }
  };

  function rr(e) {
    var _iterator70 = _createForOfIteratorHelper(e.nodes()),
        _step70;

    try {
      for (_iterator70.s(); !(_step70 = _iterator70.n()).done;) {
        var r = _step70.value;
        nr(e.node(r));
      }
    } catch (err) {
      _iterator70.e(err);
    } finally {
      _iterator70.f();
    }

    var _iterator71 = _createForOfIteratorHelper(e.edges()),
        _step71;

    try {
      for (_iterator71.s(); !(_step71 = _iterator71.n()).done;) {
        var n = _step71.value;
        nr(e.edge(n));
      }
    } catch (err) {
      _iterator71.e(err);
    } finally {
      _iterator71.f();
    }
  }

  function nr(e) {
    var r = e.width;
    e.width = e.height, e.height = r;
  }

  function tr(e) {
    e.y = -e.y;
  }

  function or(e) {
    var r = e.x;
    e.x = e.y, e.y = r;
  }

  var ir = Object.freeze({
    __proto__: null,
    debugOrdering: function debugOrdering(e) {
      var r = R(e),
          n = new x({
        compound: !0,
        multigraph: !0
      }).setGraph({});

      var _iterator72 = _createForOfIteratorHelper(e.nodes()),
          _step72;

      try {
        for (_iterator72.s(); !(_step72 = _iterator72.n()).done;) {
          var t = _step72.value;
          n.setNode(t, {
            label: t
          }), n.setParent(t, "layer" + e.node(t).rank);
        }
      } catch (err) {
        _iterator72.e(err);
      } finally {
        _iterator72.f();
      }

      var _iterator73 = _createForOfIteratorHelper(e.edges()),
          _step73;

      try {
        for (_iterator73.s(); !(_step73 = _iterator73.n()).done;) {
          var o = _step73.value;
          n.setEdge(o.v, o.w, {}, o.name);
        }
      } catch (err) {
        _iterator73.e(err);
      } finally {
        _iterator73.f();
      }

      var i = 0;

      var _iterator74 = _createForOfIteratorHelper(r),
          _step74;

      try {
        for (_iterator74.s(); !(_step74 = _iterator74.n()).done;) {
          var a = _step74.value;
          var s = "layer" + i;
          i++, n.setNode(s, {
            rank: "same"
          }), a.reduce(function (e, r) {
            return n.setEdge(e.toString(), r, {
              style: "invis"
            }), r;
          });
        }
      } catch (err) {
        _iterator74.e(err);
      } finally {
        _iterator74.f();
      }

      return n;
    }
  }),
      ar = {
    run: function run(e) {
      var _iterator75 = _createForOfIteratorHelper((e.graph().dummyChains = [], e.edges())),
          _step75;

      try {
        for (_iterator75.s(); !(_step75 = _iterator75.n()).done;) {
          var r = _step75.value;
          sr(e, r);
        }
      } catch (err) {
        _iterator75.e(err);
      } finally {
        _iterator75.f();
      }
    },
    undo: function undo(e) {
      var _iterator76 = _createForOfIteratorHelper(e.graph().dummyChains),
          _step76;

      try {
        for (_iterator76.s(); !(_step76 = _iterator76.n()).done;) {
          var r = _step76.value;
          var n,
              t = e.node(r),
              o = t.edgeLabel;

          for (e.setEdge(t.edgeObj, o); t.dummy;) {
            n = e.successors(r)[0], e.removeNode(r), o.points.push({
              x: t.x,
              y: t.y
            }), "edge-label" === t.dummy && (o.x = t.x, o.y = t.y, o.width = t.width, o.height = t.height), r = n, t = e.node(r);
          }
        }
      } catch (err) {
        _iterator76.e(err);
      } finally {
        _iterator76.f();
      }
    }
  };

  function sr(e, r) {
    var n = r.v,
        t = e.node(n).rank,
        o = r.w,
        i = e.node(o).rank,
        a = r.name,
        s = e.edge(r),
        d = s.labelRank;

    if (i !== t + 1) {
      var u, f, h;

      for (e.removeEdge(r), h = 0, ++t; t < i; ++h, ++t) {
        s.points = [], u = L(e, "edge", f = {
          width: 0,
          height: 0,
          edgeLabel: s,
          edgeObj: r,
          rank: t
        }, "_d"), t === d && (f.width = s.width, f.height = s.height, f.dummy = "edge-label", f.labelpos = s.labelpos), e.setEdge(n, u, {
          weight: s.weight
        }, a), 0 === h && e.graph().dummyChains.push(u), n = u;
      }

      e.setEdge(n, o, {
        weight: s.weight
      }, a);
    }
  }

  function dr(e) {
    var r = function (e) {
      var r = {},
          n = 0;

      function t(o) {
        var i = n;
        e.children(o).forEach(t), r[o] = {
          low: i,
          lim: n++
        };
      }

      return e.children().forEach(t), r;
    }(e);

    var _iterator77 = _createForOfIteratorHelper(e.graph().dummyChains),
        _step77;

    try {
      for (_iterator77.s(); !(_step77 = _iterator77.n()).done;) {
        var n = _step77.value;

        for (var t = e.node(n), o = t.edgeObj, i = ur(e, r, o.v, o.w), a = i.path, s = i.lca, d = 0, u = a[d], f = !0; n !== o.w;) {
          if (t = e.node(n), f) {
            for (; (u = a[d]) !== s && e.node(u).maxRank < t.rank;) {
              d++;
            }

            u === s && (f = !1);
          }

          if (!f) {
            for (; d < a.length - 1 && e.node(u = a[d + 1]).minRank <= t.rank;) {
              d++;
            }

            u = a[d];
          }

          e.setParent(n, u), n = e.successors(n)[0];
        }
      }
    } catch (err) {
      _iterator77.e(err);
    } finally {
      _iterator77.f();
    }
  }

  function ur(e, r, n, t) {
    var o,
        i,
        a = [],
        s = [],
        d = Math.min(r[n].low, r[t].low),
        u = Math.max(r[n].lim, r[t].lim);
    o = n;

    do {
      o = e.parent(o), a.push(o);
    } while (o && (r[o].low > d || u > r[o].lim));

    for (i = o, o = t; (o = e.parent(o)) !== i;) {
      s.push(o);
    }

    return {
      path: a.concat(s.reverse()),
      lca: i
    };
  }

  var fr = {
    run: function run(e) {
      var r = L(e, "root", {}, "_root"),
          n = function (e) {
        var r = {};

        function n(t, o) {
          var i = e.children(t);

          if (i && i.length) {
            var _iterator78 = _createForOfIteratorHelper(i),
                _step78;

            try {
              for (_iterator78.s(); !(_step78 = _iterator78.n()).done;) {
                var a = _step78.value;
                n(a, o + 1);
              }
            } catch (err) {
              _iterator78.e(err);
            } finally {
              _iterator78.f();
            }
          }

          r[t] = o;
        }

        var _iterator79 = _createForOfIteratorHelper(e.children()),
            _step79;

        try {
          for (_iterator79.s(); !(_step79 = _iterator79.n()).done;) {
            var t = _step79.value;
            n(t, 1);
          }
        } catch (err) {
          _iterator79.e(err);
        } finally {
          _iterator79.f();
        }

        return r;
      }(e),
          t = Math.max.apply(Math, _toConsumableArray(l(n))) - 1,
          o = 2 * t + 1;

      var _iterator80 = _createForOfIteratorHelper((e.graph().nestingRoot = r, e.edges())),
          _step80;

      try {
        for (_iterator80.s(); !(_step80 = _iterator80.n()).done;) {
          var i = _step80.value;
          e.edge(i).minlen *= o;
        }
      } catch (err) {
        _iterator80.e(err);
      } finally {
        _iterator80.f();
      }

      var a = function (e) {
        return e.edges().reduce(function (r, n) {
          return r + e.edge(n).weight;
        }, 0);
      }(e) + 1;

      var _iterator81 = _createForOfIteratorHelper(e.children()),
          _step81;

      try {
        for (_iterator81.s(); !(_step81 = _iterator81.n()).done;) {
          var s = _step81.value;
          hr(e, r, o, a, t, n, s);
        }
      } catch (err) {
        _iterator81.e(err);
      } finally {
        _iterator81.f();
      }

      e.graph().nodeRankFactor = o;
    },
    cleanup: function cleanup(e) {
      var r = e.graph();

      var _iterator82 = _createForOfIteratorHelper((e.removeNode(r.nestingRoot), delete r.nestingRoot, e.edges())),
          _step82;

      try {
        for (_iterator82.s(); !(_step82 = _iterator82.n()).done;) {
          var n = _step82.value;
          e.edge(n).nestingEdge && e.removeEdge(n);
        }
      } catch (err) {
        _iterator82.e(err);
      } finally {
        _iterator82.f();
      }
    }
  };

  function hr(e, r, n, t, o, i, a) {
    var s = e.children(a);

    if (s.length) {
      var d = z(e, "_bt"),
          u = z(e, "_bb"),
          f = e.node(a);

      var _iterator83 = _createForOfIteratorHelper((e.setParent(d, a), f.borderTop = d, e.setParent(u, a), f.borderBottom = u, s)),
          _step83;

      try {
        for (_iterator83.s(); !(_step83 = _iterator83.n()).done;) {
          var h = _step83.value;
          hr(e, r, n, t, o, i, h);
          var c = e.node(h),
              v = c.borderTop ? c.borderTop : h,
              l = c.borderBottom ? c.borderBottom : h,
              g = c.borderTop ? t : 2 * t,
              p = v !== l ? 1 : o - i[a] + 1;
          e.setEdge(d, v, {
            weight: g,
            minlen: p,
            nestingEdge: !0
          }), e.setEdge(l, u, {
            weight: g,
            minlen: p,
            nestingEdge: !0
          });
        }
      } catch (err) {
        _iterator83.e(err);
      } finally {
        _iterator83.f();
      }

      e.parent(a) || e.setEdge(r, d, {
        weight: 0,
        minlen: o + i[a]
      });
    } else a !== r && e.setEdge(r, a, {
      weight: 0,
      minlen: n
    });
  }

  function cr(e) {
    return "edge-proxy" == e.dummy;
  }

  function vr(e) {
    return "selfedge" == e.dummy;
  }

  var lr = 50,
      gr = 20,
      pr = 50,
      mr = "tb",
      wr = 1,
      _r = 1,
      br = 0,
      yr = 0,
      kr = 10,
      Er = "r";

  function Nr() {
    var e = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
    var r = {};

    for (var _i8 = 0, _Object$keys3 = Object.keys(e); _i8 < _Object$keys3.length; _i8++) {
      var n = _Object$keys3[_i8];
      r[n.toLowerCase()] = e[n];
    }

    return r;
  }

  function xr(e) {
    return e.nodes().map(function (r) {
      var n = e.node(r),
          t = e.parent(r),
          o = {
        v: r
      };
      return void 0 !== n && (o.value = n), void 0 !== t && (o.parent = t), o;
    });
  }

  function Ir(e) {
    return e.edges().map(function (r) {
      var n = e.edge(r),
          t = {
        v: r.v,
        w: r.w
      };
      return void 0 !== r.name && (t.name = r.name), void 0 !== n && (t.value = n), t;
    });
  }

  var Cr = Object.freeze({
    __proto__: null,
    write: function write(e) {
      var r = {
        options: {
          directed: e.isDirected(),
          multigraph: e.isMultigraph(),
          compound: e.isCompound()
        },
        nodes: xr(e),
        edges: Ir(e)
      };
      return void 0 !== e.graph() && (r.value = JSON.parse(JSON.stringify(e.graph()))), r;
    },
    read: function read(e) {
      var r = new x(e.options).setGraph(e.value);

      var _iterator84 = _createForOfIteratorHelper(e.nodes),
          _step84;

      try {
        for (_iterator84.s(); !(_step84 = _iterator84.n()).done;) {
          var n = _step84.value;
          r.setNode(n.v, n.value), n.parent && r.setParent(n.v, n.parent);
        }
      } catch (err) {
        _iterator84.e(err);
      } finally {
        _iterator84.f();
      }

      var _iterator85 = _createForOfIteratorHelper(e.edges),
          _step85;

      try {
        for (_iterator85.s(); !(_step85 = _iterator85.n()).done;) {
          var n = _step85.value;
          r.setEdge({
            v: n.v,
            w: n.w,
            name: n.name
          }, n.value);
        }
      } catch (err) {
        _iterator85.e(err);
      } finally {
        _iterator85.f();
      }

      return r;
    }
  }),
      Or = {
    Graph: x,
    GraphLike: I,
    alg: Le,
    json: Cr,
    PriorityQueue: be
  };
  e.Graph = x, e.GraphLike = I, e.PriorityQueue = be, e.acyclic = He, e.addBorderSegments = Ue, e.alg = Le, e.coordinateSystem = er, e.data = o, e.debug = ir, e.graphlib = Or, e.greedyFAS = Qe, e.json = Cr, e.layout = function (e, r) {
    var n = r && r.debugTiming ? Y : B;
    n("layout", function () {
      var r = n("  buildLayoutGraph", function () {
        return function (e) {
          var r,
              n,
              t,
              o,
              i,
              a,
              s,
              d,
              u,
              f,
              h,
              c,
              v,
              l,
              g,
              p = new x({
            multigraph: !0,
            compound: !0
          }),
              m = Nr(e.graph()),
              w = {
            nodesep: null !== (r = m.nodesep) && void 0 !== r ? r : pr,
            edgesep: null !== (n = m.edgesep) && void 0 !== n ? n : gr,
            ranksep: null !== (t = m.ranksep) && void 0 !== t ? t : lr,
            marginx: +(null !== (o = m.marginx) && void 0 !== o ? o : 0),
            marginy: +(null !== (i = m.marginy) && void 0 !== i ? i : 0),
            acyclicer: m.acyclicer,
            ranker: null !== (a = m.ranker) && void 0 !== a ? a : "network-simplex",
            rankdir: null !== (s = m.rankdir) && void 0 !== s ? s : mr,
            align: m.align
          };

          var _iterator86 = _createForOfIteratorHelper((p.setGraph(w), e.nodes())),
              _step86;

          try {
            for (_iterator86.s(); !(_step86 = _iterator86.n()).done;) {
              var _ = _step86.value;
              var b = Nr(e.node(_)),
                  y = {
                width: +(null !== (d = b && b.width) && void 0 !== d ? d : 0),
                height: +(null !== (u = b && b.height) && void 0 !== u ? u : 0)
              };
              p.setNode(_, y), p.setParent(_, e.parent(_));
            }
          } catch (err) {
            _iterator86.e(err);
          } finally {
            _iterator86.f();
          }

          var _iterator87 = _createForOfIteratorHelper(e.edges()),
              _step87;

          try {
            for (_iterator87.s(); !(_step87 = _iterator87.n()).done;) {
              var k = _step87.value;
              var E = Nr(e.edge(k)),
                  N = {
                minlen: null !== (f = E.minlen) && void 0 !== f ? f : wr,
                weight: null !== (h = E.weight) && void 0 !== h ? h : _r,
                width: null !== (c = E.width) && void 0 !== c ? c : br,
                height: null !== (v = E.height) && void 0 !== v ? v : yr,
                labeloffset: null !== (l = E.labeloffset) && void 0 !== l ? l : kr,
                labelpos: null !== (g = E.labelpos) && void 0 !== g ? g : Er
              };
              p.setEdge(k, N);
            }
          } catch (err) {
            _iterator87.e(err);
          } finally {
            _iterator87.f();
          }

          return p;
        }(e);
      });
      n("  runLayout", function () {
        !function (e, r) {
          r("    makeSpaceForEdgeLabels", function () {
            !function (e) {
              var r = e.graph();

              var _iterator88 = _createForOfIteratorHelper((r.ranksep /= 2, e.edges())),
                  _step88;

              try {
                for (_iterator88.s(); !(_step88 = _iterator88.n()).done;) {
                  var n = _step88.value;
                  var t = e.edge(n);
                  t.minlen *= 2, "c" !== t.labelpos.toLowerCase() && ("TB" === r.rankdir || "BT" === r.rankdir ? t.width += t.labeloffset : t.height += t.labeloffset);
                }
              } catch (err) {
                _iterator88.e(err);
              } finally {
                _iterator88.f();
              }
            }(e);
          }), r("    removeSelfEdges", function () {
            !function (e) {
              var _iterator89 = _createForOfIteratorHelper(e.edges()),
                  _step89;

              try {
                for (_iterator89.s(); !(_step89 = _iterator89.n()).done;) {
                  var r = _step89.value;

                  if (r.v === r.w) {
                    var n = e.node(r.v);
                    n.selfEdges || (n.selfEdges = []), n.selfEdges.push({
                      e: r,
                      label: e.edge(r)
                    }), e.removeEdge(r);
                  }
                }
              } catch (err) {
                _iterator89.e(err);
              } finally {
                _iterator89.f();
              }
            }(e);
          }), r("    acyclic", function () {
            He.run(e);
          }), r("    nestingGraph.run", function () {
            fr.run(e);
          }), r("    rank", function () {
            Be(S(e));
          }), r("    injectEdgeLabelProxies", function () {
            !function (e) {
              var _iterator90 = _createForOfIteratorHelper(e.edges()),
                  _step90;

              try {
                for (_iterator90.s(); !(_step90 = _iterator90.n()).done;) {
                  var r = _step90.value;
                  var n = e.edge(r);

                  if (n.width && n.height) {
                    var t = e.node(r.v),
                        o = e.node(r.w);
                    L(e, "edge-proxy", {
                      rank: (o.rank - t.rank) / 2 + t.rank,
                      e: r
                    }, "_ep");
                  }
                }
              } catch (err) {
                _iterator90.e(err);
              } finally {
                _iterator90.f();
              }
            }(e);
          }), r("    removeEmptyRanks", function () {
            D(e);
          }), r("    nestingGraph.cleanup", function () {
            fr.cleanup(e);
          }), r("    normalizeRanks", function () {
            F(e);
          }), r("    assignRankMinMax", function () {
            !function (e) {
              var r = 0;

              var _iterator91 = _createForOfIteratorHelper(e.nodes()),
                  _step91;

              try {
                for (_iterator91.s(); !(_step91 = _iterator91.n()).done;) {
                  var n = _step91.value;
                  var t = e.node(n);
                  t.borderTop && (t.minRank = e.node(t.borderTop).rank, t.maxRank = e.node(t.borderBottom).rank, r = Math.max(r, t.maxRank));
                }
              } catch (err) {
                _iterator91.e(err);
              } finally {
                _iterator91.f();
              }

              e.graph().maxRank = r;
            }(e);
          }), r("    removeEdgeLabelProxies", function () {
            !function (e) {
              var _iterator92 = _createForOfIteratorHelper(e.nodes()),
                  _step92;

              try {
                for (_iterator92.s(); !(_step92 = _iterator92.n()).done;) {
                  var r = _step92.value;
                  var n = e.node(r);
                  cr(n) && (e.edge(n.e).labelRank = n.rank, e.removeNode(r));
                }
              } catch (err) {
                _iterator92.e(err);
              } finally {
                _iterator92.f();
              }
            }(e);
          }), r("    normalize.run", function () {
            ar.run(e);
          }), r("    parentDummyChains", function () {
            dr(e);
          }), r("    addBorderSegments", function () {
            Ue(e);
          }), r("    order", function () {
            X(e);
          }), r("    insertSelfEdges", function () {
            !function (e) {
              var r,
                  n = R(e);

              var _iterator93 = _createForOfIteratorHelper(n),
                  _step93;

              try {
                for (_iterator93.s(); !(_step93 = _iterator93.n()).done;) {
                  var t = _step93.value;

                  for (var o = 0, i = 0; i < t.length; i++) {
                    var a = t[i],
                        s = e.node(a);

                    var _iterator94 = _createForOfIteratorHelper((s.order = i + o, null !== (r = s.selfEdges) && void 0 !== r ? r : [])),
                        _step94;

                    try {
                      for (_iterator94.s(); !(_step94 = _iterator94.n()).done;) {
                        var d = _step94.value;
                        L(e, "selfedge", {
                          width: d.label.width,
                          height: d.label.height,
                          rank: s.rank,
                          order: i + ++o,
                          e: d.e,
                          label: d.label
                        }, "_se");
                      }
                    } catch (err) {
                      _iterator94.e(err);
                    } finally {
                      _iterator94.f();
                    }

                    delete s.selfEdges;
                  }
                }
              } catch (err) {
                _iterator93.e(err);
              } finally {
                _iterator93.f();
              }
            }(e);
          }), r("    adjustCoordinateSystem", function () {
            er.adjust(e);
          }), r("    position", function () {
            ge(e);
          }), r("    positionSelfEdges", function () {
            !function (e) {
              var _iterator95 = _createForOfIteratorHelper(e.nodes()),
                  _step95;

              try {
                for (_iterator95.s(); !(_step95 = _iterator95.n()).done;) {
                  var r = _step95.value;
                  var n = e.node(r);

                  if (vr(n)) {
                    var t = e.node(n.e.v),
                        o = t.x + t.width / 2,
                        i = t.y,
                        a = n.x - o,
                        s = t.height / 2;
                    e.setEdge(n.e, n.label), e.removeNode(r), n.label.points = [{
                      x: o + 2 * a / 3,
                      y: i - s
                    }, {
                      x: o + 5 * a / 6,
                      y: i - s
                    }, {
                      x: o + a,
                      y: i
                    }, {
                      x: o + 5 * a / 6,
                      y: i + s
                    }, {
                      x: o + 2 * a / 3,
                      y: i + s
                    }], n.label.x = n.x, n.label.y = n.y;
                  }
                }
              } catch (err) {
                _iterator95.e(err);
              } finally {
                _iterator95.f();
              }
            }(e);
          }), r("    removeBorderNodes", function () {
            !function (e) {
              var _iterator96 = _createForOfIteratorHelper(e.nodes()),
                  _step96;

              try {
                for (_iterator96.s(); !(_step96 = _iterator96.n()).done;) {
                  var r = _step96.value;

                  if (e.children(r).length) {
                    var n = e.node(r),
                        t = e.node(n.borderTop),
                        o = e.node(n.borderBottom),
                        i = e.node(d(n.borderLeft)),
                        a = e.node(d(n.borderRight));
                    n.width = Math.abs(a.x - i.x), n.height = Math.abs(o.y - t.y), n.x = i.x + n.width / 2, n.y = t.y + n.height / 2;
                  }
                }
              } catch (err) {
                _iterator96.e(err);
              } finally {
                _iterator96.f();
              }

              var _iterator97 = _createForOfIteratorHelper(e.nodes()),
                  _step97;

              try {
                for (_iterator97.s(); !(_step97 = _iterator97.n()).done;) {
                  var r = _step97.value;
                  "border" === e.node(r).dummy && e.removeNode(r);
                }
              } catch (err) {
                _iterator97.e(err);
              } finally {
                _iterator97.f();
              }
            }(e);
          }), r("    normalize.undo", function () {
            ar.undo(e);
          }), r("    fixupEdgeLabelCoords", function () {
            !function (e) {
              var _iterator98 = _createForOfIteratorHelper(e.edges()),
                  _step98;

              try {
                for (_iterator98.s(); !(_step98 = _iterator98.n()).done;) {
                  var r = _step98.value;
                  var n = e.edge(r);
                  if (s(n, "x")) switch ("l" !== n.labelpos && "r" !== n.labelpos || (n.width -= n.labeloffset), n.labelpos) {
                    case "l":
                      n.x -= n.width / 2 + n.labeloffset;
                      break;

                    case "r":
                      n.x += n.width / 2 + n.labeloffset;
                  }
                }
              } catch (err) {
                _iterator98.e(err);
              } finally {
                _iterator98.f();
              }
            }(e);
          }), r("    undoCoordinateSystem", function () {
            er.undo(e);
          }), r("    translateGraph", function () {
            !function (e) {
              var r,
                  n,
                  t,
                  o = Number.POSITIVE_INFINITY,
                  i = 0,
                  a = Number.POSITIVE_INFINITY,
                  d = 0,
                  u = e.graph(),
                  f = null !== (r = u.marginx) && void 0 !== r ? r : 0,
                  h = null !== (n = u.marginy) && void 0 !== n ? n : 0;

              function c(e) {
                var r = e.x,
                    n = e.y,
                    t = e.width,
                    s = e.height;
                o = Math.min(o, r - t / 2), i = Math.max(i, r + t / 2), a = Math.min(a, n - s / 2), d = Math.max(d, n + s / 2);
              }

              var _iterator99 = _createForOfIteratorHelper(e.nodes()),
                  _step99;

              try {
                for (_iterator99.s(); !(_step99 = _iterator99.n()).done;) {
                  var v = _step99.value;
                  c(e.node(v));
                }
              } catch (err) {
                _iterator99.e(err);
              } finally {
                _iterator99.f();
              }

              var _iterator100 = _createForOfIteratorHelper(e.edges()),
                  _step100;

              try {
                for (_iterator100.s(); !(_step100 = _iterator100.n()).done;) {
                  var l = _step100.value;
                  s(p = e.edge(l), "x") && c(p);
                }
              } catch (err) {
                _iterator100.e(err);
              } finally {
                _iterator100.f();
              }

              var _iterator101 = _createForOfIteratorHelper((o -= f, a -= h, e.nodes())),
                  _step101;

              try {
                for (_iterator101.s(); !(_step101 = _iterator101.n()).done;) {
                  var v = _step101.value;
                  var g = e.node(v);
                  g.x -= o, g.y -= a;
                }
              } catch (err) {
                _iterator101.e(err);
              } finally {
                _iterator101.f();
              }

              var _iterator102 = _createForOfIteratorHelper(e.edges()),
                  _step102;

              try {
                for (_iterator102.s(); !(_step102 = _iterator102.n()).done;) {
                  var l = _step102.value;
                  var p = e.edge(l);

                  var _iterator103 = _createForOfIteratorHelper(null !== (t = p.points) && void 0 !== t ? t : []),
                      _step103;

                  try {
                    for (_iterator103.s(); !(_step103 = _iterator103.n()).done;) {
                      var m = _step103.value;
                      m.x -= o, m.y -= a;
                    }
                  } catch (err) {
                    _iterator103.e(err);
                  } finally {
                    _iterator103.f();
                  }

                  p.hasOwnProperty("x") && (p.x -= o), p.hasOwnProperty("y") && (p.y -= a);
                }
              } catch (err) {
                _iterator102.e(err);
              } finally {
                _iterator102.f();
              }

              u.width = i - o + f, u.height = d - a + h;
            }(e);
          }), r("    assignNodeIntersects", function () {
            !function (e) {
              var _iterator104 = _createForOfIteratorHelper(e.edges()),
                  _step104;

              try {
                for (_iterator104.s(); !(_step104 = _iterator104.n()).done;) {
                  var r = _step104.value;
                  var n,
                      t,
                      o = e.edge(r),
                      i = e.node(r.v),
                      a = e.node(r.w);
                  o.points ? (n = o.points[0], t = o.points[o.points.length - 1]) : (o.points = [], n = a, t = i), o.points.unshift(P(i, n)), o.points.push(P(a, t));
                }
              } catch (err) {
                _iterator104.e(err);
              } finally {
                _iterator104.f();
              }
            }(e);
          }), r("    reversePoints", function () {
            !function (e) {
              var _iterator105 = _createForOfIteratorHelper(e.edges()),
                  _step105;

              try {
                for (_iterator105.s(); !(_step105 = _iterator105.n()).done;) {
                  var r = _step105.value;
                  var n = e.edge(r);
                  n.reversed && n.points.reverse();
                }
              } catch (err) {
                _iterator105.e(err);
              } finally {
                _iterator105.f();
              }
            }(e);
          }), r("    acyclic.undo", function () {
            He.undo(e);
          });
        }(r, n);
      }), n("  updateInputGraph", function () {
        !function (e, r) {
          var _iterator106 = _createForOfIteratorHelper(e.nodes()),
              _step106;

          try {
            for (_iterator106.s(); !(_step106 = _iterator106.n()).done;) {
              var n = _step106.value;
              var t = e.node(n),
                  o = r.node(n);
              t && (t.x = o.x, t.y = o.y, r.children(n).length && (t.width = o.width, t.height = o.height));
            }
          } catch (err) {
            _iterator106.e(err);
          } finally {
            _iterator106.f();
          }

          var _iterator107 = _createForOfIteratorHelper(e.edges()),
              _step107;

          try {
            for (_iterator107.s(); !(_step107 = _iterator107.n()).done;) {
              var i = _step107.value;
              var a = e.edge(i),
                  d = r.edge(i);
              a.points = d.points, s(d, "x") && (a.x = d.x, a.y = d.y);
            }
          } catch (err) {
            _iterator107.e(err);
          } finally {
            _iterator107.f();
          }

          e.graph().width = r.graph().width, e.graph().height = r.graph().height;
        }(e, r);
      });
    });
  }, e.nestingGraph = fr, e.normalize = ar, e.order = ee, e.parentDummyChains = dr, e.position = pe, e.rank = $e, e.util = A, e.version = "0.1.3", Object.defineProperty(e, "__esModule", {
    value: !0
  });
});