/*eslint-disable dot-notation */
import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue, updateRecord, getRecordNotifyChange} from 'lightning/uiRecordApi';
import getRegistroRelacionado from '@salesforce/apex/CSBD_EnlacesOperativasController.getRegistroRelacionado';
import informarSLA from '@salesforce/apex/CSBD_EnlacesOperativasController.informarSLA';

import OPP_ACCOUNT_ID from '@salesforce/schema/Opportunity.AccountId';
import OPP_ACCOUNT_NUMPERSO from '@salesforce/schema/Opportunity.Account.CC_NumPerso__c';
import OPP_ACCOUNT_NUMDOC from '@salesforce/schema/Opportunity.Account.CC_Numero_Documento__c';
import OPP_ACCOUNT_FIRSTNAME from '@salesforce/schema/Opportunity.Account.FirstName';
import OPP_ACCOUNT_LASTNAME from '@salesforce/schema/Opportunity.Account.LastName';
import OPP_NUMSIA from '@salesforce/schema/Opportunity.CSBD_NumSia__c';
import OPP_NUMEXPSIA from '@salesforce/schema/Opportunity.CSBD_NumeroExpedienteSIA__c';
import OPP_RECORDTYPE_DEVNAME from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import OPP_ID from '@salesforce/schema/Opportunity.Id';
import OPP_CREATED_DATE from '@salesforce/schema/Opportunity.CreatedDate';
import OPP_PRIMER_SLA from '@salesforce/schema/Opportunity.CSBD_PrimerContactoSLA__c';
import OPP_PRIMERA_RESPUESTA_SLA from '@salesforce/schema/Opportunity.CSBD_SLA_Primera_Respuesta__c';
import OPP_ANONIMIZADA from '@salesforce/schema/Opportunity.CSBD_Anonimizada__c';

const OPP_FIELDS_GETRECORD = [
	OPP_ACCOUNT_ID,
	OPP_ACCOUNT_NUMPERSO,
	OPP_ACCOUNT_NUMDOC,
	OPP_ACCOUNT_FIRSTNAME,
	OPP_ACCOUNT_LASTNAME,
	OPP_NUMSIA,
	OPP_NUMEXPSIA,
	OPP_RECORDTYPE_DEVNAME,
	OPP_CREATED_DATE,
	OPP_PRIMER_SLA,
	OPP_PRIMERA_RESPUESTA_SLA,
	OPP_ANONIMIZADA
];

const URL_ENLACES = [
	{label: 'Lista operativa', url: 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.FichaClientePosicionCliente.PEListaCont&origen=salesforce&_vmcNewTab=true&params=numper%3D@@@numperso@@@%26nif%3D@@@nif@@@'},
	{label: 'Opendesk', url: 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.MuroConMiGestorMensajes.muro&origen=salesforce&_vmcNewTab=true&params=idCliente%3D@@@numperso@@@%26nombre%3D@@@firstName@@@%20@@@lastName@@@%26nif%3D@@@nif@@@'},
	{label: 'CaixaBankNow', url: 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.MenusTFGestion.accesoNOWGenerico&origen=salesforce&_vmcNewTab=true&params=numeroPersona%3D@@@numperso@@@%26tipoPersona%3DF'},
	//{label: 'Carterización', url: 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CAI.FichaComercial.CA.OFI.Carterizacion&origen=salesforce&_vmcNewTab=true&params=numper%3D@@@numperso@@@%26nif%3D@@@nif@@@%26nombre%3D@@@firstName@@@%20@@@lastName@@@'},
	//{label: 'Enviar comunicado', url: 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.AsesorVentasComunicado.petiCom&origen=salesforce&_vmcNewTab=true&_flowId=petiCom-flow&params=listaClientes%3D@@@numperso@@@'},
	//{label: 'Remediación RGPD', url: 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.GdprConsentimientos.consentimientosLOPD&origen=salesforce&_vmcNewTab=true&params=numper%3D@@@numperso@@@%26empresa%3D001'},
	{label: 'Documentación PHD', url: 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.ExpedienteRiesgoGesDocumental.conExpedX&origen=salesforce&_vmcNewTab=true&params=aplicacion%3DSIA%26ref_ext%3D@@@numSia@@@'},
	{label: 'SIA', url: 'https://pro14.tf7.lacaixa.es/CA.OFI/ContrataActivoConSol/resumenSolicitud.tf7?_flowId=resumenSolicitud-flow&tid=ResumenAdmisionActivo&_tabGroupId=ResumenSolicitud&menuSolicitudOffice=4223&menuSolicitudContract=@@@numExpSia@@@&menuSolicitudModality=01'},
	//{label: 'Crear Acta Mifid', url: 'https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/peaRedirect.tf7?pea=CA.OFI.CoordinaGobiernoActas.actaMifid&origen=salesforce&_vmcNewTab=true&params=titularPrincipal%3D@@@numperso@@@%26empContacto%3D@@@empContacto@@@%26medio%3D002%26usr%3D002'}
	{label: 'CIRBE', url: 'https://pro05.tf7.lacaixa.es/CA.OFI/RiesgosBEConPersonas/consultaRiesgo.tf7?_flowId=datosRiesgoCirbe-flow'},
	{label: 'Nota simple', url: 'https://pro05.tf7.lacaixa.es/CA.OFI/InfSolvRegPropGestionInformes/busPeticionesFlow.tf7?_flowId=busPeticiones-flow&_flowRType=FR'},
	{label: 'Tasaciones', url: 'https://pro05.tf7.lacaixa.es/CA.OFI/TasacionesInmuebles/flows/tasacionesHipotecarias.tf7?_flowId=tasacionesHipotecarias-flow'},
	{label: 'Simulador de seguros', url: 'https://pro05.tf7.lacaixa.es/absis3/PortalesProductos?idPortal=11007&absis_esc=PRO&escenari=PRO'}
];

export default class csbdEnalacesOperativas extends LightningElement {

    @api recordId;

    @api objectApiName;

	@api campoBusqueda;

	oportunidad;

	links = [];

	linksPares = [];

	linksImpares = [];

	linkListVisible = true;

	recordIdCalculado;

	connectedCallback() {
		if (this.objectApiName !== 'Opportunity') {
			getRegistroRelacionado({recordId: this.recordId, campoLookup: this.campoBusqueda, nombreObjeto: this.objectApiName})
				.then(result => {
					this.recordIdCalculado = result[this.campoBusqueda];
				})
				.catch(error => {
					console.error(error);
				});
		} else {
			this.recordIdCalculado = this.recordId;
		}
	}

    @wire(getRecord, {recordId: '$recordIdCalculado', fields: OPP_FIELDS_GETRECORD})
	wiredRecord({error, data}) {
    	if (data) {
			this.oportunidad = data;
            let links = [];
			URL_ENLACES.forEach((enlace, id) => {
				const url = this.substituirParametros(enlace.url);
				if (!url.includes('@@@')) {
					const recordType = getFieldValue(this.oportunidad, OPP_RECORDTYPE_DEVNAME);
					const anonimizada = getFieldValue(this.oportunidad, OPP_ANONIMIZADA);
					//CIRBE solo aparece en Préstamo e Hipoteca. Nota simple y Tasaciones solo aparecen en Hipoteca
					if (enlace.label !== 'CIRBE' && enlace.label !== 'Nota simple' && enlace.label !== 'Tasaciones' && enlace.label !== 'Documentación PHD'
						|| enlace.label === 'CIRBE' && (recordType === 'CSBD_Prestamo' || recordType === 'CSBD_Hipoteca')
						|| (enlace.label === 'Nota simple' || enlace.label === 'Tasaciones') && recordType === 'CSBD_Hipoteca'
						|| enlace.label === 'Documentación PHD' && anonimizada === false) {
						links.push({id, label: enlace.label, url});
					}
				}
			});
			this.links = links;
			this.linksPares = links.filter((_, index) => index % 2 === 0);
			this.linksImpares = links.filter((_, index) => index % 2 !== 0);
    	} else if (error) {
    		console.error(error);
        }
    }

    substituirParametros(url) {
    	return url
			.replace('@@@numperso@@@', getFieldValue(this.oportunidad, OPP_ACCOUNT_NUMPERSO) ?? '@@@ERROR@@@')
			.replace('@@@nif@@@', getFieldValue(this.oportunidad, OPP_ACCOUNT_NUMDOC) ?? '@@@ERROR@@@')
			.replace('@@@firstName@@@', getFieldValue(this.oportunidad, OPP_ACCOUNT_FIRSTNAME) ?? '@@@ERROR@@@')
			.replace('@@@lastName@@@', getFieldValue(this.oportunidad, OPP_ACCOUNT_LASTNAME) ?? '@@@ERROR@@@')
			.replace('@@@numSia@@@', getFieldValue(this.oportunidad, OPP_NUMSIA) ?? '@@@ERROR@@@')
			.replace('@@@numExpSia@@@', getFieldValue(this.oportunidad, OPP_NUMEXPSIA) ?? '@@@ERROR@@@');
    	    //.replace('@@@empContacto@@@', this.empContacto ?? '@@@ERROR@@@');
    }

    toggleLinkList() {
    	this.linkListVisible = !this.linkListVisible;
    	const botonExpandirContraer = this.template.querySelector('.botonExpandirContraer');
    	if (this.linkListVisible) {
    		botonExpandirContraer.classList.add('expandido');
    		botonExpandirContraer.querySelector('lightning-button-icon').title = 'Cerrar';
    	} else {
    		botonExpandirContraer.classList.remove('expandido');
    		botonExpandirContraer.querySelector('lightning-button-icon').title = 'Abrir';
    	}
    }

    abrirEnlace(event) {
        // Abrir enlace en nueva ventana
        let url = event.currentTarget.dataset.url;
        window.open(url, '_blank', 'width=' + window.screen.availWidth, 'height=' + window.screen.availHeight);

        // En caso de acceder al enlace de OpenDesk, en Hipotecas o préstamos, se calcula el SLA en Apex
        let label = event.currentTarget.dataset.label;
        const recordType = getFieldValue(this.oportunidad, OPP_RECORDTYPE_DEVNAME);
        const primerSlaString = getFieldValue(this.oportunidad, OPP_PRIMERA_RESPUESTA_SLA);

        if (label === 'Opendesk' && !primerSlaString && (recordType === 'CSBD_Prestamo' || recordType === 'CSBD_Hipoteca')) {

			informarSLA({ oportunidadId: this.recordIdCalculado })
                .then(() => {
                    // Aquí refresca el registro para ver los cambios en pantalla
					getRecordNotifyChange([{recordId: this.recordIdCalculado}]);
                })
                .catch(error => console.error(error));
        }
    }
}