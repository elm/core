/*

import Elm.Kernel.Utils exposing (cmp)

*/


var _List_Nil = { $: '[]' };

function _List_Cons(hd, tl)
{
	return { $: '::', a: hd, b: tl };
}

var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	var out = [];
	while (xs.$ !== '[]')
	{
		out.push(xs.a);
		xs = xs.b;
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	var arr = [];
	while (xs.$ !== '[]' && ys.$ !== '[]')
	{
		arr.push(A2(f, xs.a, ys.a));
		xs = xs.b;
		ys = ys.b;
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	var arr = [];
	while (xs.$ !== '[]' && ys.$ !== '[]' && zs.$ !== '[]')
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
		xs = xs.b;
		ys = ys.b;
		zs = zs.b;
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	var arr = [];
	while (   ws.$ !== '[]'
		   && xs.$ !== '[]'
		   && ys.$ !== '[]'
		   && zs.$ !== '[]')
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
		ws = ws.b;
		xs = xs.b;
		ys = ys.b;
		zs = zs.b;
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	var arr = [];
	while (   vs.$ !== '[]'
		   && ws.$ !== '[]'
		   && xs.$ !== '[]'
		   && ys.$ !== '[]'
		   && zs.$ !== '[]')
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
		vs = vs.b;
		ws = ws.b;
		xs = xs.b;
		ys = ys.b;
		zs = zs.b;
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return __Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = f(a)(b).$;
		return ord === 'EQ' ? 0 : ord === 'LT' ? -1 : 1;
	}));
});
