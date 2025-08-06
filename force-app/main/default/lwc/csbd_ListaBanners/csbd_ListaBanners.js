import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import csbdOpportunityMessageChannel from '@salesforce/messageChannel/CSBD_Opportunity_MessageChannel__c';
import LightningConfirm from 'lightning/confirm';
import { logoFaciliteaCasa, textoBannerSeparador } from './utils';
import { errorApex, toast, formatearIsoDate } from 'c/csbd_lwcUtils';

import usuarioDesarrolladorApex from '@salesforce/apex/CSBD_Utils.usuarioDesarrollador';

import OPP_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPP_CONTACT_ID from '@salesforce/schema/Opportunity.CSBD_Contact__c';
import OPP_NO_IDENTIFICADO from '@salesforce/schema/Opportunity.CSBD_No_Identificado__c';
import OPP_RECORD_TYPE_DEVELOPER_NAME from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import OPP_NOW_ORIGEN from '@salesforce/schema/Opportunity.CSBD_Now_Origen__c';
import OPP_ESTADO from '@salesforce/schema/Opportunity.CSBD_Estado__c';
import OPP_ETAPA from '@salesforce/schema/Opportunity.StageName';
import OPP_FECHA_CITA from '@salesforce/schema/Opportunity.CSBD_Fecha_Cita__c';
import OPP_URGENTE from '@salesforce/schema/Opportunity.CSBD_Urgencia__c';
import OPP_ORIGEN_LEAD_EXISTENTE from '@salesforce/schema/Opportunity.CSBD_OrigenLeadExistente__c';
import OPP_FECHA_ENTRADA_ULTIMO_LEAD from '@salesforce/schema/Opportunity.CSBD_FechaEntradaUltimoLead__c';
import OPP_MOSTRAR_AVISO from '@salesforce/schema/Opportunity.CSBD_MostrarAviso__c';
import OPP_ALTA_OMNICHANNEL from '@salesforce/schema/Opportunity.CSBD_Alta_omnichannel__c';
import OPP_PRODUCTO_MIFID from '@salesforce/schema/Opportunity.CSBD_Producto_MIFID__c';
import OPP_TELEFONO from '@salesforce/schema/Opportunity.CSBD_Telefono_Solicitud__c';
import OPP_TIPO_BONIFICADO from '@salesforce/schema/Opportunity.CSBD_TipoBonificado__c';
import OPP_CANAL from '@salesforce/schema/Opportunity.CSBD_Canal__c';
import OPP_CLIENTE_PORTAL_IDENTIFICADO from '@salesforce/schema/Opportunity.CSBD_Cliente_Portal_Identificado__c';

const OPPTY_FIELDS = [
	OPP_IDENTIFICADOR, OPP_NOW_ORIGEN, OPP_RECORD_TYPE_DEVELOPER_NAME, OPP_MOSTRAR_AVISO, OPP_CONTACT_ID,
	OPP_NO_IDENTIFICADO, OPP_ALTA_OMNICHANNEL, OPP_ESTADO, OPP_ETAPA, OPP_PRODUCTO_MIFID, OPP_TELEFONO,
	OPP_TIPO_BONIFICADO, OPP_URGENTE, OPP_FECHA_CITA, OPP_ORIGEN_LEAD_EXISTENTE, OPP_FECHA_ENTRADA_ULTIMO_LEAD,
	OPP_CANAL, OPP_CLIENTE_PORTAL_IDENTIFICADO
];

export default class csbdListaBanners extends LightningElement {
	@api recordId;

	usuarioDesarrollador = null;
	intersectionObserver = null;
	_verBanners = true;
	_lastRecordId = null;
	_lastBannerData = null;

	get verBanners() {
		return this._verBanners;
	}

	set verBanners(verBanners) {
		//this._verBanners = verBanners;
		if (!verBanners) {

			//Banners --> Pills
			const cardBanners = this.refs.cardBanners;
			if (cardBanners) {
				cardBanners.addEventListener('transitionend', () => {
					this._verBanners = false;
					setTimeout(() => {
						this.refs.pillContainer.classList.remove('oculto');
						if (!this.intersectionObserver) {
							this.intersectionObserver = new IntersectionObserver(this.handleIntersect.bind(this), { root: null, rootMargin: '0px', threshold: 1.0 });
						}
						this.observarPopovers();
						this.setNubbinColor();
						this.refs.pillContainer.offsetTop; //Forzar render
					}, 80);
				});
				cardBanners.classList.add('oculto');
			} else {
				this._verBanners = false;
				setTimeout(() => this.refs.pillContainer.classList.remove('oculto'), 80);
			}
		} else {
			//Pills --> Banners
			this.intersectionObserver && this.intersectionObserver.disconnect();
			const pillContainer = this.refs.pillContainer;
			if (pillContainer && !pillContainer.classList.contains('oculto')) {
				pillContainer.addEventListener('transitionend', () => {
					this._verBanners = true;
					setTimeout(() => this.refs.cardBanners.classList.remove('oculto'), 80);
				});
				pillContainer.classList.add('oculto');
			} else {
				this._verBanners = true;
				setTimeout(() => {
					if (this.refs.cardBanners) {
						this.refs.cardBanners.classList.remove('oculto');
					}
				}, 80);
			}
		}
	}

	record;

	banners = [];

	idTimeouts = { abrirPillPopover: {}, cerrarPillPopover: {} };

	@wire(MessageContext) messageContext;
	subscription;

	connectedCallback() {
		setTimeout(() => this.verBanners = true, 500);
		// Inicializar IntersectionObserver una sola vez
		if (!this.intersectionObserver) {
			this.intersectionObserver = new IntersectionObserver(this.handleIntersect.bind(this), { root: null, rootMargin: '0px', threshold: 1.0 });
		}
		// Obtener usuario desarrollador solo una vez
		usuarioDesarrolladorApex().then(result => {
			this.usuarioDesarrollador = result;
		});
		// Suscribirse al canal de mensajes para manejar eventos externos
		/*
		if (!this.subscription && this.messageContext) {
			this.subscription = subscribe(
				this.messageContext,
				csbdOpportunityMessageChannel,
				(message) => this.handleMessage(message)
			);
		}
		*/
	}

	disconnectedCallback() {
		if (this.intersectionObserver) {
			this.intersectionObserver.disconnect();
		}
		this.subscription = null;
	}

	@wire(getRecord, { recordId: '$recordId', fields: OPPTY_FIELDS })
	async wiredRecord({ data: record, error: errorGetRecord }) {
		if (record) {
			// Comprobar si los datos clave han cambiado
			const bannerData = {
				urgente: getFieldValue(record, OPP_URGENTE),
				estado: getFieldValue(record, OPP_ESTADO),
				canal: getFieldValue(record, OPP_CANAL),
				contactoId: getFieldValue(record, OPP_CONTACT_ID),
				noIdentificado: getFieldValue(record, OPP_NO_IDENTIFICADO),
				clientePortalIdentificado: getFieldValue(record, OPP_CLIENTE_PORTAL_IDENTIFICADO),
				altaOmnichannel: getFieldValue(record, OPP_ALTA_OMNICHANNEL),
				productoMifid: getFieldValue(record, OPP_PRODUCTO_MIFID),
				telefono: getFieldValue(record, OPP_TELEFONO),
				tipoBonificado: getFieldValue(record, OPP_TIPO_BONIFICADO),
				nowOrigen: getFieldValue(record, OPP_NOW_ORIGEN),
				fechaCita: getFieldValue(record, OPP_FECHA_CITA),
				recordType: getFieldValue(record, OPP_RECORD_TYPE_DEVELOPER_NAME),
				fechaUltimoLead: getFieldValue(record, OPP_FECHA_ENTRADA_ULTIMO_LEAD),
				mostrarAviso: getFieldValue(record, OPP_MOSTRAR_AVISO),
				origenLeadExistente: getFieldValue(record, OPP_ORIGEN_LEAD_EXISTENTE)
			};
			if (this._lastRecordId === this.recordId && JSON.stringify(this._lastBannerData) === JSON.stringify(bannerData)) {
				return; // No recalcular banners
			}
			this._lastRecordId = this.recordId;
			this._lastBannerData = bannerData;

			this.record = record;
			let banners = [...this.banners];
			let bannersNew = [];
			/*
			if (getFieldValue(record, OPP_ETAPA) === 'Formalizada') {
				bannersNew.push({
					idBanner: 'formalizada', orden: 1,
					pillLabel: 'Formalizada',
					iconName: 'utility:opportunity',
					texto: 'Oportunidad <span style="font-weight: 500;">formalizada</span>.',
					backgroundColor: '#f0fff5', color: 'rgb(47, 50, 50)', descartable: true
				});
			} else if (getFieldValue(record, OPP_ETAPA) === 'Rechazada') {
				bannersNew.push({
					idBanner: 'rechazada', orden: 1,
					pillLabel: 'Rechazada',
					iconName: 'utility:close',
					texto: 'Oportunidad <span style="font-weight: 500;">rechazada</span>.',
					backgroundColor: '#fff2ec', color: 'rgb(47, 50, 50)', descartable: true
				});
			} else if (getFieldValue(record, OPP_ETAPA) === 'Perdida') {
				bannersNew.push({
					idBanner: 'perdida', orden: 1,
					pillLabel: 'Perdida',
					iconName: 'utility:clear',
					texto: 'Oportunidad <span style="font-weight: 500;">perdida</span>.',
					backgroundColor: '#ffefee', color: 'rgb(47, 50, 50)', descartable: true
				});
			}
			*/
			//Urgente
			if (bannerData.urgente === 'Si') {
				bannersNew.push({
					idBanner: 'urgente', orden: 20,
					iconName: 'utility:priority', pillIconName: 'custom:custom26',
					pillLabel: 'Urgente',
					texto: '<span style="font-weight: 500;">Esta oportunidad se ha marcado como <span style="font-weight: 600;">urgente</span>.</span>',
					backgroundColor: '#fdfbf3', color: 'rgb(47, 50, 50)', descartable: true
				});
			}
			//No identificado Canal Portal
			if (!bannerData.contactoId && !bannerData.noIdentificado && bannerData.canal === 'portal' && !bannerData.clientePortalIdentificado) {
				bannersNew.push({
					idBanner: 'noIdentificado', orden: 25,
					iconName: 'utility:resource_absence', pillIconName: 'standard:resource_absence',
					pillLabel: 'Cliente no identificado',
					texto: 'Esta es una oportunidad de canal portal. Recuerda identificar correctamente al cliente.',
					enlace: { label: 'Identificado', idEnlace: 'identificarFocusCliente' },
					backgroundColor: '##c4c4c4', color: 'rgb(50, 53, 53)', descartable: true
				});
			} /*else if (this.usuarioDesarrollador && !bannerData.contactoId && !bannerData.noIdentificado && bannerData.canal !== 'portal') {
				//No identificado
				bannersNew.push({
					idBanner: 'noIdentificado', orden: 25,
					iconName: 'utility:resource_absence', pillIconName: 'standard:resource_absence',
					pillLabel: 'Cliente no identificado',
					texto: 'Cliente no identificado.',
					enlace: { label: 'Identificar', idEnlace: 'identificarFocus' },
					backgroundColor: '##c4c4c4', color: 'rgb(50, 53, 53)', descartable: true
				});
			}*/
			//Pendiente de cita
			if (bannerData.estado === 'Pendiente Cita') {
				bannersNew.push({
					idBanner: 'pendienteCita', orden: 30,
					iconName: 'utility:event', pillIconName: 'standard:event',
					pillLabel: `Cita el ${formatearIsoDate(bannerData.fechaCita, true, false)}`,
					texto: `Esta oportunidad está <span style="font-weight: 500;">pendiente de cita</span> con el cliente el <span style="font-weight: 500;">${formatearIsoDate(bannerData.fechaCita)}</span>.`,
					enlace: { label: 'Desprogramar', idEnlace: 'desprogramarCita' },
					backgroundColor: '#f1eefd', color: 'rgb(50, 53, 53)', descartable: true
				});
			}
			//Asignación manual
			if (!bannerData.altaOmnichannel) {
				bannersNew.push({
					idBanner: 'asignacionManual', orden: 40,
					iconName: 'utility:groups', pillIconName: 'standard:groups',
					pillLabel: 'Asignación manual',
					texto: 'La propiedad de esta oportunidad se gestiona manualmente.',
					backgroundColor: '#f7f7f7', color: 'rgb(47, 50, 50)', descartable: true
				});
			}
			//Producto MiFID
			if (bannerData.productoMifid) {
				bannersNew.push({
					idBanner: 'productoMifid', orden: 50,
					iconName: 'utility:call', pillIconName: 'standard:call',
					pillLabel: 'Producto MiFID',
					texto: 'Producto <span style="font-weight: 500;">MiFID</span>. Recuerda llamar mediante el widget de telefonía para que la conversación quede grabada.',
					clickToDialNumTelefono: bannerData.telefono?.replace(/\s/g, '').replace(/^\+34/, ''),
					backgroundColor: '#fef4ea', color: 'rgb(47, 50, 50)', descartable: true
				});
			}
			//Tipo bonificado
			if (bannerData.tipoBonificado) {
				bannersNew.push({
					idBanner: 'tipoBonificado', orden: 60,
					iconName: 'utility:promotions', pillIconName: 'standard:promotions',
					pillLabel: `Ofrecido tipo bonificado del ${bannerData.tipoBonificado}%`,
					texto: `Se ha ofrecido previamente al cliente un interés bonificado del <span style="font-weight: 500;">${bannerData.tipoBonificado}%</span>.`,
					backgroundColor: '#ecf5ff', color: 'rgb(47, 50, 50)', descartable: true
				});
			}
			//Hipoteca con origen Facilitea/Hipoteca con nueva búsqueda en plataformas digitales
			const origenFacilitea = bannerData.nowOrigen === 'faciliteacasa';
			const fechaNuevaBusquedaEnPhd = bannerData.fechaUltimoLead;
			if (bannerData.recordType === 'CSBD_Hipoteca' && (origenFacilitea || fechaNuevaBusquedaEnPhd)) {
				let texto = '';
				if (origenFacilitea) {
					texto = `<span>Oportunidad originada en${logoFaciliteaCasa}</span>`;
				}
				if (fechaNuevaBusquedaEnPhd) {
					texto && (texto += textoBannerSeparador); //Añadir separador si hace falta
					const fechaUltimoLeadIso = new Date(fechaNuevaBusquedaEnPhd).toISOString();
					const origenLeadExistenteFormat = bannerData.origenLeadExistente === 'faciliteacasa' ? logoFaciliteaCasa : ' plataformas digitales';
					texto += `<span><span style="font-weight: 500;">Nueva búsqueda</span> del cliente en${origenLeadExistenteFormat} el ${formatearIsoDate(fechaUltimoLeadIso, true, false)}.</span>`;
				}

				let enlace = null;
				if (origenFacilitea && fechaNuevaBusquedaEnPhd
					&& bannerData.mostrarAviso === 'Nueva búsqueda en facilitea casa') {
					enlace = { idEnlace: 'noAvisarNuevamente', helptext: 'Dejar de incluir esta oportunidad en el recuento de los futuros avisos automáticos.', label: 'No avisar de nuevo' };
				}
				bannersNew.push({
					idBanner: 'hipotecaFaciliteaOrNuevaBusquedaPhd', orden: 70,
					iconName: 'utility:screen', pillIconName: 'standard:screen',
					pillLabel: 'Nueva búsqueda en plataformas',
					texto,
					enlace,
					backgroundColor: '#f0faf7', color: 'rgb(47, 50, 50)', descartable: true
				});
			}

			bannersNew.forEach(bannerNew => {
				let bannerOld = banners.find(b => b.idBanner === bannerNew.idBanner);
				if (bannerOld) {
					banners[banners.findIndex(b => b.idBanner === bannerNew.idBanner)] = { ...bannerNew };
				} else {
					banners.push(bannerNew);
				}
			});
			banners = banners.filter(banner => bannersNew.some(bannerNew => bannerNew.idBanner === banner.idBanner));
			banners = banners.sort((a, b) => a.orden - b.orden);
			this.banners = [...banners];

		} else if (errorGetRecord) {
			errorApex(this, errorGetRecord, 'Problema recuperando los datos de la oportunidad');
		}
	}

	cerrarBanner({ detail: { idBanner } }) {
		this.banners.splice(this.banners.findIndex(b => b.idBanner === idBanner), 1);
		this.banners = [...this.banners];
	}

	async bannerEnlaceOnclick({ detail: { idBanner, idEnlace } }) {
		if (idBanner) {
			if (idEnlace === 'abrirModalAsignacionAutomatica') {
				this.publicarEvento('abrirModalAsignacionAutomatica');
			} else if (idEnlace === 'cerrarOportunidad') {
				this.publicarEvento('cerrarOportunidad');
			} else if (idEnlace === 'programarCita') {
				this.publicarEvento('programarCita');
			} else if (idEnlace === 'desprogramarCita') {
				this.publicarEvento('desprogramarCita');
			} else if (idEnlace === 'identificarFocus') {
				this.publicarEvento('identificarFocus');
			} else if (idEnlace === 'identificarFocusCliente') {
				this.handleClientePortalIdentificado();
			} else if (idBanner === 'hipotecaFaciliteaOrNuevaBusquedaPhd' && idEnlace === 'noAvisarNuevamente') {
				if (await LightningConfirm.open({
					variant: 'header', theme: 'alt-inverse', label: 'No incluir en avisos automáticos',
					message: '¿Quieres que el recuento de los futuros avisos automáticos deje de incluir esta hipoteca?'
				})) {
					const campos = {};
					campos.Id = this.recordId;
					campos[OPP_MOSTRAR_AVISO.fieldApiName] = null;
					updateRecord({ fields: campos })
						.then(() => toast('success', 'Se actualizó correctamente la oportunidad', 'Se actualizó correctamente la oportunidad ' + getFieldValue(this.record, OPP_IDENTIFICADOR)))
						.catch(error => errorApex(this, error, 'Problema actualizando Oportunidad'));
				}
			}
		}
	}

	async publicarEvento(type) {
		if (!this.messageContext || !csbdOpportunityMessageChannel) {
			console.error('Error publicando el evento');
			return;
		}
		publish(this.messageContext, csbdOpportunityMessageChannel, {
			source: 'csbd_ListaBanners', recordId: this.recordId, type
		});
	}

	cambiarTipoVista() {
		this.verBanners = !this._verBanners;
	}

	async setNubbinColor() {
		this.template.querySelectorAll('.pillContainerItem').forEach(
			i => i.style.setProperty('--pill-color', i.dataset.backgroundColor)
		);
	}

	handleIntersect(entries) {
		requestAnimationFrame(() => {
			const viewportWidth = window.innerWidth || document.documentElement.clientWidth;

			entries.forEach(entry => {
				const pillPopover = entry.target;
				const pillContainerItem = pillPopover.closest('.pillContainerItem');

				this.intersectionObserver.unobserve(pillPopover);

				if (pillPopover.classList.contains('pillPopoverOculto')) {
					pillPopover.style.transform = 'translateX(-50%) translateY(0.5rem)';
				} else {
					pillPopover.style.transform = 'translateX(-50%) translateY(0)';
				}
				pillPopover.style.left = '50%';
				const rect = pillPopover.getBoundingClientRect();
				const pillContainerItemRect = pillContainerItem.getBoundingClientRect();
				if (rect.right > viewportWidth) {
					pillPopover.style.left = `calc(50% - ${rect.right - viewportWidth + 14}px)`;
				} else if (rect.left < 0) {
					pillPopover.style.left = `calc(50% + ${Math.abs(rect.left) + 14}px)`;
				}
				const nubbinOffset = pillContainerItemRect.left + pillContainerItemRect.width / 2 - pillPopover.getBoundingClientRect().left;
				pillPopover.style.setProperty('--nubbin-offset', `${nubbinOffset}px`);

				this.intersectionObserver.observe(pillPopover);
			});
		});
	}

	observarPopovers() {
		const pillPopovers = this.template.querySelectorAll('.pillPopover:not(.pillPopoverOculto)');
		pillPopovers.forEach(popover => this.intersectionObserver.observe(popover));
	}

	pillContainerItemOnmouseenter({ currentTarget: pillContainerItem, currentTarget: { dataset: { idBanner } } }) {
		this.idTimeouts.abrirPillPopover[idBanner] = setTimeout(() => {
			clearTimeout(this.idTimeouts.cerrarPillPopover[idBanner]);
			this.idTimeouts.cerrarPillPopover[idBanner] = null;
			this.template.querySelectorAll('.pillPopover').forEach(popover => {
				popover.classList.add('pillPopoverOculto');
			});
			pillContainerItem.querySelector('.pillPopover').classList.remove('pillPopoverOculto');
		}, 290);
	}

	pillContainerItemOnmouseleave({ currentTarget: pillContainerItem, currentTarget: { dataset: { idBanner } } }) {
		clearTimeout(this.idTimeouts.abrirPillPopover[idBanner]);
		this.idTimeouts.abrirPillPopover[idBanner] = null;
		this.idTimeouts.cerrarPillPopover[idBanner] = setTimeout(() => {
			pillContainerItem.querySelector('.pillPopover').classList.add('pillPopoverOculto');
		}, 530);
	}

	get verIcono() {
		return getFieldValue(this.record, OPP_CLIENTE_PORTAL_IDENTIFICADO) ? 'utility:success' : '';
	}

	handleClientePortalIdentificado(){
		const campos = {
			Id: this.recordId,
			[OPP_NO_IDENTIFICADO.fieldApiName]: true,
			[OPP_CLIENTE_PORTAL_IDENTIFICADO.fieldApiName]: true
		};

		updateRecord({ fields: campos })
			.then(() => toast('success', 'Se ha identificado correctamente la oportunidad de canal Portal', 'Se ha identificado correctamente la oportunidad de canal Portal'))
			.catch(error => errorApex(this, error, 'Problema actualizando la Oportunidad de canal Portal'));
	}
}