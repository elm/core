Elm.Native.Signal = {};
Elm.Native.Signal.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Signal = localRuntime.Native.Signal || {};
	if (localRuntime.Native.Signal.values)
	{
		return localRuntime.Native.Signal.values;
	}


	var Utils = Elm.Native.Utils.make(localRuntime);


	function broadcastToKids(node, timestamp, update)
	{
		var kids = node.kids;
		for (var i = kids.length; i--; )
		{
			kids[i].notify(timestamp, update, node.id);
		}
	}


	// INPUT

	function input(base)
	{
		var node = {
			id: Utils.guid(),
			initialValue: base,
			value: base,
			kids: []
		};

		node.notify = function(timestamp, targetId, value) {
			var update = targetId === node.id;
			if (update)
			{
				node.value = value;
			}
			broadcastToKids(node, timestamp, update);
			return update;
		};

		localRuntime.inputs.push(node);

		return node;
	}


	var never = input(null);


	// OUTPUT

	function output(handler, parent)
	{
		var node = {
			id: Utils.guid(),
			isOutput: true
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (update)
			{
				handler(parent.value);
			}
		};

		parent.kids.push(node);

		return node;
	}

	// CONVERSION

	function streamToVarying(initial, stream)
	{
		var node = {
			id: Utils.guid(),
			initialValue: initial,
			value: initial,
			kids: []
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				node.value = stream.value;
			}
			broadcastToKids(node, timestamp, parentUpdate);
		}

		return node;
	}


	function varyingToStream(varying)
	{
		var node = {
			id: Utils.guid(),
			kids: []
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				node.value = varying.value;
			}
			broadcastToKids(node, timestamp, parentUpdate);
		}

		return Utils.Tuple2(varying.initialValue, node);
	}


	// STREAM MAP

	function streamMap(func, stream)
	{
		var node = {
			id: Utils.guid(),
			kids: []
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				node.value = func(stream.value);
			}
			broadcastToKids(node, timestamp, parentUpdate);
		}

		return node;
	}


	// VARYING MAP

	function mapMany(refreshValue, args)
	{
		var initialValue = refreshValue();
		var node = {
			id: Utils.guid(),
			initialValue: initialValue,
			value: initialValue,
			kids: []
		};

		var numberOfParents = args.length;
		var count = 0;
		var update = false;

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			++count;

			update = update || parentUpdate;

			if (count === numberOfParents)
			{
				if (update)
				{
					node.value = refreshValue();
				}
				broadcastToKids(node, timestamp, update);
				update = false;
				count = 0;
			}
		};

		for (var i = numberOfParents; i--; )
		{
			args[i].kids.push(node);
		}

		return node;
	}


	function map(func, a)
	{
		function refreshValue()
		{
			return func(a.value);
		}
		return mapMany(refreshValue, [a]);
	}


	function map2(func, a, b)
	{
		function refreshValue()
		{
			return A2( func, a.value, b.value );
		}
		return mapMany(refreshValue, [a,b]);
	}


	function map3(func, a, b, c)
	{
		function refreshValue()
		{
			return A3( func, a.value, b.value, c.value );
		}
		return mapMany(refreshValue, [a,b,c]);
	}


	function map4(func, a, b, c, d)
	{
		function refreshValue()
		{
			return A4( func, a.value, b.value, c.value, d.value );
		}
		return mapMany(refreshValue, [a,b,c,d]);
	}


	function map5(func, a, b, c, d, e)
	{
		function refreshValue()
		{
			return A5( func, a.value, b.value, c.value, d.value, e.value );
		}
		return mapMany(refreshValue, [a,b,c,d,e]);
	}



	// FOLD

	function fold(update, state, stream)
	{
		var node = {
			id: Utils.guid(),
			kids: [],
			initialValue: state,
			value: state
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				node.value = A2( update, stream.value, node.value );
			}
			broadcastToKids(node, timestamp, parentUpdate);
		};

		stream.kids.push(node);

		return node;
	}


	// TIME

	function timestamp(stream)
	{
		var node = {
			id: Utils.guid(),
			kids: []
		};

		if ('initialValue' in stream)
		{
			node.initialValue = Utils.Tuple2(localRuntime.timer.programStart, stream.initialValue);
			node.value = node.initialValue;
		}

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				node.value = Utils.Tuple2(timestamp, stream.value);
			}
			broadcastToKids(node, timestamp, parentUpdate);
		};

		stream.kids.push(node);

		return node;
	}


	// MERGING

	function genericMerge(tieBreaker, leftStream, rightStream) {
		var node = {
			id: Utils.guid(),
			kids: []
		};

		var left = { touched: false, update: false, value: null };
		var right = { touched: false, update: false, value: null };

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentID === leftStream.id)
			{
				left.touched = true;
				left.update = parentUpdate;
				left.value = leftStream.value;
			}
			if (parentID === rightStream.id)
			{
				right.touched = true;
				right.update = parentUpdate;
				right.value = rightStream.value;
			}

			if (left.touched && right.touched)
			{
				var update = false;
				if (left.update && right.update)
				{
					node.value = A2(tieBreaker, left.value, right.value);
					update = true;
				}
				else if (left.update)
				{
					node.value = left.value;
					update = true;
				}
				else if (right.update)
				{
					node.value = right.value;
					update = true;
				}
				left.touched = false;
				right.touched = false;

				broadcastToKids(node, timestamp, update);
			}
		};

		leftStream.kids.push(node);
		rightStream.kids.push(node);

		return node;
	}


 	// FILTERING

	function filterMap(toMaybe, stream)
	{
		var node = {
			id: Utils.guid(),
			kids: []
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			var update = false;
			if (parentUpdate)
			{
				var maybe = toMaybe(stream.value);
				if (maybe.ctor === 'Just')
				{
					update = true;
					node.value = stream.value;
				}
			}
			broadcastToKids(node, timestamp, update);
		};

		stream.kids.push(node);

		return node;
	}


	return localRuntime.Native.Signal.values = {
		input: input,
		output: output,
		never: never,
		streamToVarying: F2(streamToVarying),
		varyingToStream: varyingToStream,
		streamMap: F2(streamMap),
		map: F2(map),
		map2: F3(map2),
		map3: F4(map3),
		map4: F5(map4),
		map5: F6(map5),
		fold: F3(fold),
		genericMerge: F2(genericMerge),
		filterMap: F2(filterMap),
		timestamp: timestamp
	};
};
