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

	function input(name, base)
	{
		var node = {
			id: Utils.guid(),
			name: 'input-' + name,
			parents: [],
			kids: []
		};

		if (typeof base !== 'undefined')
		{
			node.initialValue = base;
			node.value = base;
		}

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

	function constant(value)
	{
		return input('constant', value);
	}

	var never = input('never');


	// OUTPUT

	function output(name, handler, parent)
	{
		var node = {
			id: Utils.guid(),
			name: 'output-' + name,
			parents: [parent],
			isOutput: true
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				handler(parent.value);
			}
		};

		parent.kids.push(node);

		return node;
	}

	// CONVERSION

	function streamToSignal(initial, stream)
	{
		var node = {
			id: Utils.guid(),
			name: 'streamToSignal',
			parents: [stream],
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

		stream.kids.push(node);

		return node;
	}


	function signalToStream(signal)
	{
		var node = {
			id: Utils.guid(),
			name: 'signalToStream',
			parents: [signal],
			kids: []
		};

		node.notify = function(timestamp, parentUpdate, parentID)
		{
			if (parentUpdate)
			{
				node.value = signal.value;
			}
			broadcastToKids(node, timestamp, parentUpdate);
		}

		signal.kids.push(node);

		return node;
	}


	function initialValue(signal)
	{
		return signal.initialValue;
	}


	// STREAM MAP

	function streamMap(func, stream)
	{
		var node = {
			name: 'streamMap',
			parents: [stream],
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

		stream.kids.push(node);

		return node;
	}


	// VARYING MAP

	function mapMany(refreshValue, args)
	{
		var initialValue = refreshValue();
		var node = {
			id: Utils.guid(),
			name: 'map' + args.length,
			parents: args,
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
			name: 'fold',
			parents: [stream],
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
			name: 'timestamp',
			parents: [stream],
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

	function genericMerge(tieBreaker, leftStream, rightStream)
	{
		var node = {
			id: Utils.guid(),
			name: 'merge',
			parents: [leftStream, rightStream],
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
			name: 'filterMap',
			parents: [stream],
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
					node.value = maybe._0;
				}
			}
			broadcastToKids(node, timestamp, update);
		};

		stream.kids.push(node);

		return node;
	}


	return localRuntime.Native.Signal.values = {
		input: input,
		never: never,
		constant: constant,
		output: output,
		streamToSignal: F2(streamToSignal),
		signalToStream: signalToStream,
		initialValue: initialValue,
		streamMap: F2(streamMap),
		map: F2(map),
		map2: F3(map2),
		map3: F4(map3),
		map4: F5(map4),
		map5: F6(map5),
		fold: F3(fold),
		genericMerge: F3(genericMerge),
		filterMap: F2(filterMap),
		timestamp: timestamp
	};
};
