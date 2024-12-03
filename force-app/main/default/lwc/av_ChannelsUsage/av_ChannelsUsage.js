import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } 		from 'lightning/platformShowToastEvent';

import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';

import getData 			from '@salesforce/apex/AV_ChannelsUsage_Controller.getChannels';

import Iconos from '@salesforce/resourceUrl/AV_IconChannels';

export default class Av_ChannelsUsage extends LightningElement {

    @api recordId;
    @track viewSpinner = true;
    @track listData;
    @track noDataFound;
	//iconos
	iconVideollamada=Iconos+'/videollamada.svg';
	iconPay=Iconos+'/App_pay.svg';
	iconCita=Iconos+'/cita_previa_cliente.svg';
	iconMuro=Iconos+'/Muro.svg';
	iconNowApp=Iconos+'/now_imagin_app.svg';
	iconNowWeb=Iconos+'/now_imagin_web.svg';
	iconR2B=Iconos+'/ready2buy.svg';
	iconSign=Iconos+'/Sign_IOS.svg';
	iconVisitasOficina=Iconos+'/visitas_oficina.svg';
	iconCajero=Iconos+'/Cajero.svg';
	//fechas
	@track webLastVisit;
	@track lastOfficeVisit;
	@track lastAppointment;
	@track lastVideoConference;
	@track nowLastVisit;
	@track atmLastVisit;
	//accesos
	@track webNumberDays;
	@track officeAccessNumberDays;
	@track atmNumberDays;
	@track wallMessagesFromClient;
	@track cxbPayLogins;
	@track imaginNowNumberDays;
	@track appointmentNumerDays;
	@track signLogins;
	@track videoConferenceNumberDays;
	@track signedR2B;
	//view accesos
	@track accesosWeb=true;
	@track accesosVisitaOficina=true;
	@track accesosMuro=true;
	@track accesosNowApp=true;
	@track accesosPay=true;
	@track accesosCajero=true;
	@track accesosVideollamada=true;
	@track accesosR2B=true;
	@track accesosCitas=true;
	@track accesosSignApp=true;

	@track prefiere="";
	@track tipoCliente;
	@track acciones="";
	@track viewNoDataFound = false;
	@track viewAcciones=true;

    connectedCallback() {
		this.getData();
	}

	changeDate(date) {
		if (date=='') {
			return 'No aplica';
		}
		var year = date.substring(0,4);
		var month = date.substring(4,6);
		var day = date.substring(6,8);
		var dateF = day+"/"+month+"/"+year;
		return dateF;
	}

    getData() {
		getData({recordId: this.recordId})
			.then(result => {
				if(result.severity === 'ok') {
					this.listData = result.nameValueMap;
					//Consulta/Opera/Contrata
					var cont=0;
					if (this.listData.nowUseIndicator[0]=='1') {
						this.acciones='Consulta';
						cont++;
					}
					if (this.listData.nowRegistryIndicator[0]=='1') {
						if (cont>=1) {
							this.acciones=this.acciones.concat(' | Opera');
						} else {
							this.acciones='Opera';
							cont++;
						}
					}
					if (this.listData.nowSalesIndicator[0]=='1') {
						if (cont>=1) {
							this.acciones=this.acciones.concat(' | Contrata');
						} else {
							this.acciones='Contrata';
							cont++;
						}
					}
					if(cont==0) {
						this.viewAcciones=false;
					}
                    //accesos
					this.webNumberDays=this.listData.webNumberDays[0];
					if (this.webNumberDays=='1') {
						this.accesosWeb=false;
					} else if (this.webNumberDays=='') {
						this.webNumberDays='0';
					}
					this.officeAccessNumberDays=this.listData.officeAccessNumberDays[0];
					if (this.officeAccessNumberDays=='1') {
						this.accesosVisitaOficina=false;
					} else if (this.officeAccessNumberDays=='') {
						this.officeAccessNumberDays='0';
					}
					this.wallMessagesFromClient=this.listData.wallMessagesFromClient[0];
					if (this.wallMessagesFromClient=='1') {
						this.accesosMuro=false;
					} else if (this.wallMessagesFromClient=='') {
						this.wallMessagesFromClient='0';
					}
					var nowNumberDays=this.listData.nowNumberDays[0];
					if (nowNumberDays=='') {
						nowNumberDays='0';
					}
					var imaginbankNumberDays=this.listData.imaginbankNumberDays[0];
					if (imaginbankNumberDays='') {
						imaginbankNumberDays='0';
					}
					if (imaginbankNumberDays==0 && nowNumberDays==0) {
						this.imaginNowNumberDays=0;
					}else {
						this.imaginNowNumberDays=nowNumberDays+imaginbankNumberDays;
					}
					if (this.imaginNowNumberDays>200) {
						this.imaginNowNumberDays=200;
					}
					if (this.imaginNowNumberDays=='1') {
						this.accesosNowApp=false;
					}
					this.cxbPayLogins=this.listData.cxbPayLogins[0];
					if (this.cxbPayLogins=='1') {
						this.accesosPay=false;
					} else if (this.cxbPayLogins=='') {
						this.cxbPayLogins='0';
					}
					this.atmNumberDays=this.listData.atmNumberDays[0];
					if (this.atmNumberDays=='1') {
						this.accesosCajero=false;
					} else if (this.atmNumberDays=='') {
						this.atmNumberDays='0';
					}
					this.videoConferenceNumberDays=this.listData.videoConferenceNumberDays[0];
					if (this.videoConferenceNumberDays=='1') {
						this.accesosVideollamada=false;
					} else if (this.videoConferenceNumberDays=='') {
						this.videoConferenceNumberDays='0';
					}
					this.signedR2B=this.listData.signedR2B[0];
					if (this.signedR2B=='1') {
						this.accesosR2B=false;
					} else if (this.signedR2B=='') {
						this.signedR2B='0';
					}
					this.appointmentNumberDays=this.listData.appointmentNumberDays[0];
					if (this.appointmentNumberDays=='1') {
						this.accesosCitas=false;
					} else if (this.appointmentNumberDays=='') {
						this.appointmentNumberDays='0';
					}
					this.signLogins=this.listData.signLogins[0];
					if (this.signLogins=='1') {
						this.accesosSignApp=false;
					} else if (this.signLogins=='') {
						this.signLogins='0';
					}
					//fechas
					if (this.listData.nowLastVisit[0]<this.listData.imaginbankLastVisit[0]) {
						this.nowLastVisit=this.changeDate(this.listData.imaginbankLastVisit[0]);
					}else {
						this.nowLastVisit=this.changeDate(this.listData.nowLastVisit[0]);
					}
					this.webLastVisit=this.changeDate(this.listData.webLastVisit[0]);
					this.lastOfficeVisit=this.changeDate(this.listData.lastOfficeVisit[0]);
					this.lastAppointment=this.changeDate(this.listData.lastAppointment[0]);
					this.lastVideoConference=this.changeDate(this.listData.lastVideoConference[0]);
					this.atmLastVisit=this.changeDate(this.listData.atmLastVisit[0]);
					//prefiere
					var nowIosNumberDays=this.listData.nowIosNumberDays[0];
					if (nowIosNumberDays=='') {
						nowIosNumberDays='0';
					}
					var imaginbankIosNumberDays=this.listData.imaginbankIosNumberDays[0];
					if (imaginbankIosNumberDays='') {
						imaginbankIosNumberDays='0';
					}
					var ios=nowIosNumberDays+imaginbankIosNumberDays;
					if (nowIosNumberDays=='0' && imaginbankIosNumberDays=='0') {
						ios=0;
					}
					var nowAndroidNumberDays=this.listData.nowAndroidNumberDays[0];
					if (nowAndroidNumberDays=='') {
						nowAndroidNumberDays='0';
					}
					var imaginbankAndroidNumberDays=this.listData.imaginbankAndroidNumberDays[0];
					if (imaginbankAndroidNumberDays='') {
						imaginbankAndroidNumberDays='0';
					}
					var android=nowAndroidNumberDays+imaginbankAndroidNumberDays;
					if (nowAndroidNumberDays=='0' && imaginbankAndroidNumberDays=='0') {
						android=0;
					}
					if (ios>android) {
						this.prefiere="IOS";
					}else if (ios<android) {
						this.prefiere="Android";
					} else {
						this.prefiere="IOS/Android";
					}
					var cont2=0;
					if (ios>0) {
						this.usaIosAndroid="IOS";
						cont2++;
					}
					if (android>0) {
						if (cont2>0) {
							this.usaIosAndroid=this.usaIosAndroid.concat('/Android');
						}else {
							this.usaIosAndroid="Android";
						}
					}
					//tipo de cliente
					if (this.listData.visitorTag[0]=='3. SIN_CONTACTOS') {
						this.tipoCliente="Desvinculado";
					}else if (this.listData.visitorTag[0]=='1. 100% FÍSICO' || this.listData.visitorTag[0]=='1. 100% FÍSICO - CAJERO') {
						this.tipoCliente="Físico";
					}else if (this.listData.visitorTag[0]=='4. 100% DIGITAL') {
						this.tipoCliente="Digital";
					}else if (this.listData.visitorTag[0]=='2. OMNICANAL') {
						this.tipoCliente="Omnicanal";
					}
					this.viewSpinner = false;
				} else if(result.severity === 'error') {
					console.log('Display ShowToastEvent error: ' + result.descError);
					this.dispatchEvent(new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: result.descError,
						variant: result.severity
					}));
                    this.noDataFound = result.descError;
					this.viewNoDataFound = true;
					this.viewSpinner = false;
				} else {
					console.log('Option invalid: ' + JSON.stringify(result));
					this.noDataFound = JSON.stringify(result);
					this.viewNoDataFound = true;
					this.viewSpinner = false;
				}
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ' + JSON.stringify(error));
                this.dispatchEvent(new ShowToastEvent({
					title: AV_CMP_ErrorMessage,
					message: JSON.stringify(error),
					variant: 'error'
				}));
				this.noDataFound = JSON.stringify(error);
				this.viewNoDataFound = true;
				this.viewSpinner = false;
			});
	}
}