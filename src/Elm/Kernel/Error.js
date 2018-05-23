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
			throw new Error('Browser.fullscreen programs cannot handle URLs like this:\n\n    ' + url + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

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
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm-lang/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Error_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Error_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ __Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm-lang/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Error_regionToString(region)
{
	if (region.__$start.__$line === region.__$end.__$line)
	{
		return 'on line ' + region.__$start.__$line;
	}
	return 'on lines ' + region.__$start.__$line + ' through ' + region.__$end.__$line;
}

function _Error_dictBug()
{
	_Error_throw(0);
}
