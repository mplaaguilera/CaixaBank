({
	doInit: function(component) {
		let alternateFieldValueList = [];
		component.get("v.alternateFieldList").forEach(field => alternateFieldValueList.push(component.get("v.object")[field]));
		component.set("v.alternateFieldValueList", alternateFieldValueList);
	}
})