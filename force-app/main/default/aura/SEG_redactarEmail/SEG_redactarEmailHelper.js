({
	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'duration': 4000});
		toastEvent.fire();
	},

	setDataAnexos: function(component, idsFilesUpload) {
		//Guardar selección actual para restaurarla tras actualizar la tabla
		let selectedRowsOld;
		let currentSelectRowsInfo = [];
		if (!$A.util.isUndefinedOrNull(component.find('dataTb'))) {
			selectedRowsOld = component.find('dataTb').getSelectedRows();
		}
		
		let getAnexos = component.get('c.getFilesCase');
		getAnexos.setParam('casoId', component.get('v.caseId'));
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//wrapper para poder descargar el documento via hyperlink
				let records = response.getReturnValue();
				let urlpath = window.location.href.split('/lightning/')[0];
				records.forEach(record => {
					record.ContentUrl = urlpath + '/sfc/servlet.shepherd/version/download/' + record.Id + '?operationContext=S';
					record.ContentSize = this.formatBytes(record.ContentSize, 2);
				});
				component.set('v.dataAnexos', records);
				component.set('v.hasAnexos', response.getReturnValue().length !== 0);

				if (idsFilesUpload.length > 0) {
					let selectedRowIdsNew = [...idsFilesUpload];
					if (selectedRowsOld) {
						selectedRowsOld.forEach(registro => selectedRowIdsNew.push(registro.ContentDocumentId));
					}
					component.set('v.currentSelectedRowsAnexos', selectedRowIdsNew);

					records.forEach(record =>{
						if(selectedRowIdsNew.includes(record.ContentDocumentId)){
							currentSelectRowsInfo.push(record);
						}
					})
					console.log('selected data '+ currentSelectRowsInfo);
					component.set('v.hasAnexosSelected', true);
					component.set('v.dataAnexosMostrar', currentSelectRowsInfo);
				}
			}
		});
		$A.enqueueAction(getAnexos);
	},

	formatBytes: function(bytes, decimals) {
		if (bytes == 0) {return '0 Bytes';}
		let k = 1024,
			dm = decimals || 2,
			sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
			i = Math.floor(Math.log(bytes) / Math.log(k));
		return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
	},

	setRows: function(Component) {
		let selectedRows = component.get('v.currentSelectedRowsAnexos');
		component.set('v.currentSelectedRowsAnexos', selectedRows);
	},

	identificarDestino: function(component) {
		let para = component.get('v.aPara');

		let getIdentificar = component.get('c.identificarDestinatario');
		getIdentificar.setParams({
			caseId: component.get('v.caseId'),
			correo: para.length > 0 ? para[0].label : para
		});
		$A.enqueueAction(getIdentificar);
	},

	reinit: function(component) {
		component.find('caseData').reloadRecord(true);
	}
});