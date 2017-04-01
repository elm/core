
function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	if (code <= 0xFFFF)
	{
		return _Utils_chr(String.fromCharCode(c));
	}
	var n = code - 0x10000;
	var hi = String.fromCharCode(Math.floor(n / 0x400) + 0xD800);
	var lo = String.fromCharCode(n % 0x400 + 0xDC00);
	return _Utils_chr(hi + lo);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}
