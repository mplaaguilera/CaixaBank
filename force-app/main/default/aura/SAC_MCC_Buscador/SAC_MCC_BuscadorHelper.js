/*eslint-disable no-undef */
({
	onValueSelect: function(component) {
		let objectList = component.get('v.objectList');
		let selectedObjectIndex = component.get('v.selectedIndex');
		if (selectedObjectIndex !== null) {
			component.set('v.selectedObject', objectList[selectedObjectIndex]);
			if (component.get('v.negocio') === 'OS' && (objectList[selectedObjectIndex].CBK_Traslado_Remitido__c === 'Remitido' || objectList[selectedObjectIndex].CBK_Traslado_Remitido__c === 'Traslado')) {
				component.set('v.trasladoRemitidoCops', objectList[selectedObjectIndex].CBK_Traslado_Remitido__c.toLowerCase());
			}
			component.set('v.selectedObjectDisplayName', objectList[selectedObjectIndex].Name);

			/*let valorSel = objectList[selectedObjectIndex]['SEG_Detalle_Formula__c'];
            if (valorSel === undefined || valorSel === null)
            {
                valorSel = objectList[selectedObjectIndex]['SEG_Motivo_Formula__c'];
            }
			if(valorSel === undefined || valorSel === null){
				valorSel = objectList[selectedObjectIndex]['CC_Producto_Servicio_Formula__c'];
			}*/

			//component.set('v.selectedObjectDisplayName', valorSel);
			component.set('v.value', objectList[selectedObjectIndex]);
			component.set('v.lookupId', objectList[selectedObjectIndex].Id);
			component.set('v.objectList', []);
			component.set('v.enteredValue', '');
			component.set('v.lookupInputFocused', false);
		}
	},
	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			'type': tipo,
			'title': titulo,
			'message': mensaje,
			'mode': 'dismissible',
			'duration': 4000
		});
		toastEvent.fire();
	}
});