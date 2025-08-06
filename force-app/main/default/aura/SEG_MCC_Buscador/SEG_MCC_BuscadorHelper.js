({
	onValueSelect: function(component) {
		let objectList = component.get('v.objectList');
		let selectedObjectIndex = component.get('v.selectedIndex');
		if (selectedObjectIndex !== null) {
			component.set('v.selectedObject', objectList[selectedObjectIndex]);
			component.set('v.selectedObjectDisplayName', objectList[selectedObjectIndex]['Name']);
			component.set('v.value', objectList[selectedObjectIndex]);
			component.set('v.lookupId', objectList[selectedObjectIndex]['Id']);
			component.set('v.objectList', []);
			component.set('v.enteredValue', '');
			component.set('v.lookupInputFocused', false);  
		}
	}
});