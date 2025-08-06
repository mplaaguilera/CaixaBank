({
	init: function(component) {
		//Inicializar acciones y columnas de la datatable de correos
		component.set('v.contactosColumns', [{label: 'Fecha', fieldName: 'anoMes', type: 'data', initialWidth: 120, iconName: 'utility:dayview'},
			{label: 'numPerson', fieldName: 'numPerson', type: 'text', initialWidth: 120},
                                          	{label: 'descFuente', fieldName: 'descFuente', type: 'text', initialWidth: 120},
			{label: 'código de contacto', fieldName: 'codContacto', type: 'text', initialWidth: 150},
			{label: 'desc Origen', fieldName: 'descOrigen', type: 'text', initialWidth: 150},
			{label: 'desc Medio', fieldName: 'descMedio', type: 'text', initialWidth: 150},
			{label: 'desc Comunic', fieldName: 'descComunic', type: 'text', initialWidth: 150}
		]);
	},
	consultaRuc: function(component, event, helper) {
		let recordId = component.get('v.recordId');
		let fechaIni = component.get('v.fechaIni');
		let fechaFin = component.get('v.fechaFin');

		if (fechaFin >= fechaIni && fechaFin != null && fechaIni != null) {

			console.log('la fecha de origen es mayor');
			let obtenerDatos = component.get('c.ejecutarConsulta');
			obtenerDatos.setParams({
				'numPerso': recordId,
           				'fechaIni': fechaIni,
          				'fechaFin': fechaFin
			});
			obtenerDatos.setCallback (this, response => {
				let state = response.getState();
				if (state === 'SUCCESS' && response.getReturnValue() != null && response.getReturnValue() != '') {
					component.set('v.contactos', response.getReturnValue());

             	} else {
            	console.log('resultado - KO');
					const toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						type: 'error',
						message: 'error al obtener los datos.',
						mode: 'pester'
					});
					toastEvent.fire();
				}
			});

			$A.enqueueAction(obtenerDatos);

		} else {
            	console.log('resultado - KO');
			const toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				type: 'error',
				message: 'las fecha introducida no son correctas.',
				mode: 'pester'
			});
			toastEvent.fire();
		}

	}

	//

});