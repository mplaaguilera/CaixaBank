/* eslint-disable no-undef */
({
	onValueSelect: function(component) {
		let objectList = component.get('v.objectList');
		let selectedObjectIndex = component.get('v.selectedIndex');

		if (selectedObjectIndex !== undefined) {
			component.set('v.selectedObject', objectList[selectedObjectIndex]);
            let valorSel = objectList[selectedObjectIndex]['Name'];
			component.set('v.selectedObjectDisplayName', valorSel);
			component.set('v.value', objectList[selectedObjectIndex]);
			component.set('v.lookupId', objectList[selectedObjectIndex]['Id']);
			component.set('v.objectList', []);
			component.set('v.enteredValue', '');
			component.set('v.lookupInputFocused', false);
		}
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'type': tipo, 'title': titulo, 'message': mensaje, 'mode': 'dismissible', duration: 4000});
		toastEvent.fire();
	}
})