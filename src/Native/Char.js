//import Native.Utils as Utils

return {
	fromCode: function(c) { return Utils.chr(String.fromCharCode(c)); },
	toCode: function(c) { return c.charCodeAt(0); },
	toUpper: function(c) { return Utils.chr(c.toUpperCase()); },
	toLower: function(c) { return Utils.chr(c.toLowerCase()); },
	toLocaleUpper: function(c) { return Utils.chr(c.toLocaleUpperCase()); },
	toLocaleLower: function(c) { return Utils.chr(c.toLocaleLowerCase()); }
};
