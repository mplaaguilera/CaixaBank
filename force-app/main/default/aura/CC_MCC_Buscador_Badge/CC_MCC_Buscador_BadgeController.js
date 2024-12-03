({
	doInit: function(component) {
		//Resaltar coincidencia
		let textoBadge = component.get('v.text');
		let enteredValue = component.get('v.enteredValue');

		let destacar = false;

		let terminosBusqueda = enteredValue.trim().split(' ');

		if (textoBadge != null && terminosBusqueda != null) {	
			for (let i = 0; i < terminosBusqueda.length; i++) {
				if (textoBadge.search(new RegExp(terminosBusqueda[i], 'gi')) > -1) {
					destacar = true;
					component.set('v.text', '<mark>' + textoBadge + '</mark>');
					break;
				}
			}
		}

		//Apariencia de la badge
		let badgeStyle = 'background-color:' + (!destacar ? '#F8F9F9; ' : '#F1F7F9; ');
		badgeStyle += 'border-width:' + (!destacar ? '1px; ' : '2px; ');
		badgeStyle += 'font-weight:' + component.get('v.fontWeight') + '; ';

		badgeStyle += 'border-style: solid; border-radius: 6px; border-color: #2259A4; box-sizing: border-box; height: 24px; font-size: small; color: black; padding-bottom: 3px; white-space: pre;';
		component.set('v.badgeStyle', badgeStyle);
	}
});