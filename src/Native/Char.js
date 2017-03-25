//import Native.Utils //

var _elm_lang$core$Native_Char = function() {

function toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function fromCode(code)
{
	if (code <= 0xFFFF)
	{
		return _elm_lang$core$Native_Utils.chr(String.fromCharCode(c));
	}
	var n = code - 0x10000;
	var hi = String.fromCharCode(Math.floor(n / 0x400) + 0xD800);
	var lo = String.fromCharCode(n % 0x400 + 0xDC00);
	return _elm_lang$core$Native_Utils.chr(hi + lo);
}

return {
	fromCode: fromCode,
	toCode: toCode,
	toUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toUpperCase()); },
	toLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLowerCase()); },
	toLocaleUpper: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleUpperCase()); },
	toLocaleLower: function(c) { return _elm_lang$core$Native_Utils.chr(c.toLocaleLowerCase()); }
};

}();