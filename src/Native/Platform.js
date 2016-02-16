
function program(details)
{
	return details;
}

function dummyRenderer(parent, tagger, initialUnit)
{
	return {
		update: function(newUnit) {}
	};
}

return {
	program: program,
	dummyRenderer: dummyRenderer
};
