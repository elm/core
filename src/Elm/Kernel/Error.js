/*

import Elm.Kernel.Error exposing (throw)
import Elm.Kernel.Debug exposing (toString)

*/


function _Error_throw_prod(identifier)
{
	throw new Error('https://github.com/elm-lang/core/blob/master/help.md#' + identifier);
}


function _Error_throw_dev(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			var moduleName = fact1;
			throw new Error('The `' + moduleName + '` module does not need flags.\nInitialize it with no arguments and you should be all set!');

		case 1:
			var moduleName = fact1;
			throw new Error('Are you trying to sneak a Never value into Elm? Trickster!\nIt looks like ' + moduleName + '.main is defined with `programWithFlags` but has type `Program Never`.\nUse `program` instead if you do not want flags.');

		case 2:
			var moduleName = fact1;
			var message = fact2;
			throw new Error('Trying to initialize the `' + moduleName + '` module with an unexpected argument.\nI tried to convert it to an Elm value, but ran into this problem:\n\n' + message);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at http://package.elm-lang.org/packages/elm-lang/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			throw new Error('Comparison error: cannot compare tuples with more than 6 elements.');

		case 7:
			throw new Error('Comparison error: comparison is only defined on ints, floats, times, chars, strings, lists of comparable values, and tuples of comparable values.');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('Ran into a `Debug.crash` in module `' + moduleName + '` ' + _Error_regionToString(region) + '\n' + 'The message provided by the code author is:\n\n    ' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error('Ran into a `Debug.crash` in module `' + moduleName + '`\n\nThis was caused by the `case` expression ' + _Error_regionToString(region) + '.\nOne of the branches ended with a crash and the following value got through:\n\n    ' + __Debug_toString(value) + '\n\nThe message provided by the code author is:\n\n    ' + message);

		case 10:
			var tagName = fact1;
			throw new Error('Scheduler failed on unknown task ' + tagName);

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');

		case 12:
			throw new Error('Internal red-black tree invariant violated');

		case 13:
			throw new Error('Bug in https://github.com/elm-lang/virtual-dom/issues');
	}
}

function _Error_regionToString(region)
{
	if (region.start.line == region.end.line)
	{
		return 'on line ' + region.start.line;
	}
	return 'between lines ' + region.start.line + ' and ' + region.end.line;
}

function _Error_dictBug()
{
	__Error_throw(12);
}
