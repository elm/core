/*

import Elm.Kernel.Error exposing (throw)
import Elm.Kernel.Debug exposing (toString)

*/


function _Error_throw__PROD(identifier)
{
	throw new Error('https://github.com/elm-lang/core/blob/master/hints/' + identifier + '.md');
}


function _Error_throw__DEBUG(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('Internal red-black tree invariant violated');

		case 1:
			var url = fact1;
			throw new Error('Cannot navigate to the following URL. It seems to be invalid:\n' + url);

		case 2:
			var message = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + message);

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
			throw new Error('Bug in https://github.com/elm-lang/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Error_regionToString(region)
{
	if (region.__$start.__$line == region.__$end.__$line)
	{
		return 'on line ' + region.__$start.__$line;
	}
	return 'between lines ' + region.__$start.__$line + ' and ' + region.__$end.__$line;
}

function _Error_dictBug()
{
	_Error_throw(0);
}
