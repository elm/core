var _elm_lang$core$Native_Bitwise = function() {

return {
	and: F2(function and(a, b) { return a & b; }),
	or: F2(function or(a, b) { return a | b; }),
	xor: F2(function xor(a, b) { return a ^ b; }),
	complement: function complement(a) { return ~a; },
	leftShift: F2(function(offset, a) { return a << offset; }),
	rightShift: F2(function(offset, a) { return a >> offset; }),
	logicalRightShift: F2(function(offset, a) { return a >>> offset; })
};

}();
