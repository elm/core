//import Native.Utils //

var _elm_lang$core$Native_Char = function() {

function fromCodepoint(cp)
{
	if (cp > 0xFFFF && cp <= 0x10FFFF)
	{
		cp -= 0x10000;
		return String.fromCharCode(Math.floor(cp / 0x400) + 0xD800, cp % 0x400 + 0xDC00);
	}
	else
	{
		return String.fromCharCode(cp);
	}
}

function toCode(ch)
{
	if (ch.length == 2)
	{
		return (ch.charCodeAt(0) - 0xD800) * 0x400 + (ch.charCodeAt(1) - 0xDC00) + 0x10000;
	}
	else
	{
		return ch.charCodeAt(0);
	}
}


return {
	fromCode: function(c) { return _elm_lang$core$Native_Utils.chr(fromCodepoint(c)); },
	toCode: toCode,
	toUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toUpperCase()); },
	toLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLowerCase()); },
	toLocaleUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleUpperCase()); },
	toLocaleLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleLowerCase()); }
};

}();
