({
	reinit: function(component) {
		//component.find('caseData').reloadRecord(true);
		$A.get('e.force:refreshView').fire();
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		let duracionToast = 4000;
		if (tipo != 'success')
		{
			duracionToast = 10000;
		}
		toastEvent.setParams({ 'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': duracionToast });
		toastEvent.fire();
	},

	/**
	 * @description       : Limpia las letras, espacios, comas y decimales de un campo de entrada, dejando solo números Enteros.
	 * 					 	Invocable tanto desde Controller como desde cmp
	 * @author            : Jaime Villarón
	 * @group             : 
	 * @last modified on  : 2025-07-22
	 * @last modified by  : Jaime Villarón
	 * Modifications Log 
	 * Ver   Date         Author             Modification
	 * 1.0   2025-07-22  Jaime Villarón   Initial Version
	 */
	limpiarLetras: function(component, event, helper) {
        let inputCmp = event.getSource(); // El componente que disparó el evento
        let inputValue = inputCmp.get("v.value") || ''; // Valor actual
		//let newInputValue = inputValue.replace(/\D/g, '').substring(0, 15).replace(/\s/g, '');
		let newInputValue = inputValue.replace(/\D/g, '').replace(/\s/g, '');

        inputCmp.set("v.value", newInputValue); // Actualiza el mismo campo
    },

	/**
	 * @description       : Valida los campos de un formulario dado un array de IDs.
	 *                      Devuelve true si todos los campos son válidos, false si alguno es inválido.
	 *                      Utiliza el método checkValidity() de los componentes de Lightning.
	 *                      Si un campo es inválido, llama a reportValidity() para mostrar el mensaje de error.
	 * @author            : Jaime Villarón
	 * @group             : 
	 * @last modified on  : 2025-07-23
	 * @last modified by  : Jaime Villarón
	 * Modifications Log 
	 * Ver   Date         Author             Modification
	 * 1.0   2025-07-23  Jaime Villarón   Initial Version
	 */
	validarCamposFormulario: function(component, ids) {
        let algunInvalido = false;

        ids.forEach(id => {
            let cmp = component.find(id);
            if (cmp) {
                // Por si hay múltiples elementos con el mismo aura:id (devuelve array)
                let elementos = Array.isArray(cmp) ? cmp : [cmp];
                elementos.forEach(el => {
                    if (el.checkValidity && !el.checkValidity()) {
                        el.reportValidity();
                        algunInvalido = true;
                    }
                });
            }
        });

        return !algunInvalido; // Devuelve true si todos son válidos
    },

	/**
	 * @description       : Validación de NIF por letra de control.
	 * @author            : Jaime Villarón
	 * @group             : 
	 * @last modified on  : 2025-07-22
	 * @last modified by  : Jaime Villarón
	 * Modifications Log 
	 * Ver   Date         Author             Modification
	 * 1.0   2025-07-22  Jaime Villarón   Initial Version
	 */
	esNIFValidoPorControl: function(nif) {
		const letras = 'TRWAGMYFPDXBNJZSQVHLCKE';
		nif = nif.toUpperCase();

		// NIE: X -> 0, Y -> 1, Z -> 2
		let numero = nif;
		if (nif.charAt(0) === 'X') numero = '0' + nif.slice(1);
		else if (nif.charAt(0) === 'Y') numero = '1' + nif.slice(1);
		else if (nif.charAt(0) === 'Z') numero = '2' + nif.slice(1);

		const numeroNumerico = parseInt(numero.slice(0, 8), 10);
		const letraEsperada = letras[numeroNumerico % 23];
		const letraReal = nif.charAt(8);
		return letraEsperada === letraReal;
	},

	/**
	 * @description       : Validación de CIF por letra de control.
	 * @author            : Jaime Villarón
	 * @group             : 
	 * @last modified on  : 2025-07-22
	 * @last modified by  : Jaime Villarón
	 * Modifications Log 
	 * Ver   Date         Author             Modification
	 * 1.0   2025-07-22  Jaime Villarón   Initial Version
	 */
	esCIFValidoPorControl: function(cif) {
		let letrasControl = "JABCDEFGHI";
		let sumaPar = 0;
		let sumaImpar = 0;

		for (let i = 1; i < 8; i += 2) {
			let n = parseInt(cif.charAt(i)) * 2;
			if (n > 9) n = Math.floor(n / 10) + (n % 10);
			sumaImpar += n;
		}

		for (let i = 2; i < 8; i += 2) {
			sumaPar += parseInt(cif.charAt(i));
		}

		let sumaTotal = sumaPar + sumaImpar;
		let control = (10 - (sumaTotal % 10)) % 10;

		let tipo = cif.charAt(0);
		let digitoControl = cif.charAt(8);

		if ("KPQRSNW".includes(tipo)) {
			// debe ser letra
			return digitoControl === letrasControl[control];
		} else if ("ABEH".includes(tipo)) {
			// debe ser número
			return digitoControl === control.toString();
		} else {
			// puede ser ambos
			return digitoControl === control.toString() || digitoControl === letrasControl[control];
		}
	},

	setDataAnexos: function(component) {
		let getAnexos = component.get('c.getFilesCase');
		getAnexos.setParam('casoId', component.get('v.recordId'));
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.dataAnexos', response.getReturnValue());
			}
		});
		$A.enqueueAction(getAnexos);
	},

	fetchCRSeguimiento: function(component) {
		let action = component.get('c.fetchCRSeguimientoController');
		action.setCallback(this, function (response) {
			let values = [];
			let result = response.getReturnValue();
			for (let key in result) {
				values.push({
					label: result[key],
					value: key
				});
			}
			component.set('v.CRs', values);
		});
		$A.enqueueAction(action);
		window.setTimeout($A.getCallback(() => component.find('inputNombresContratos').focus()), 400);
	},

	fetchEmail: function(component) {
		let actionEm = component.get('c.fetchEmailsCaso');
		actionEm.setParam('caseId', component.get('v.recordId'));
		actionEm.setCallback(this, function (response) {
			let values = [];
			let result = response.getReturnValue();
			for (let key in result) {
				values.push({
					label: result[key],
					value: key
				});
			}
			component.set('v.Emailcaso', values);
		});
		$A.enqueueAction(actionEm);
	},

	fetchEmailcaso: function(component) {
		let actionEm = component.get('c.fetchEmailsCaso');
		actionEm.setParam('caseId', component.get('v.caseId'));
		actionEm.setCallback(this, function (response) {
			let values = [];
			let result = response.getReturnValue();
			for (let key in result) {
				values.push({
					label: result[key],
					value: key
				});
			}
			component.set('v.Emailcaso', values);
		});
		$A.enqueueAction(actionEm);
	},

	abrirTab: function(component, idCaso) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openTab({recordId: idCaso, focus: true})
		.then(tab => workspaceAPI.getTabInfo({tabId: tab}))
		.catch(error => {
			console.error(error);
		});
	},

	postChatter: function(component, idCaso, operativa, notaTipificada, observaciones) {
		let publicar = component.get('c.postOnChatter');
		publicar.setParams({
			caseId: idCaso,
			operativa: operativa,
			notaTipificada: notaTipificada,
			observaciones: observaciones
		});
		publicar.setCallback(this, response => {
			var helper = this;
			helper.reinit(component);
		});
		$A.enqueueAction(publicar);
	},

	formatBytes:function(bytes,decimals) {
		if (bytes === 0) {
			return '0 Bytes';
		}
		var k = 1024,
			dm = decimals || 2,
			sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
			i = Math.floor(Math.log(bytes) / Math.log(k));
		return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
	}
});