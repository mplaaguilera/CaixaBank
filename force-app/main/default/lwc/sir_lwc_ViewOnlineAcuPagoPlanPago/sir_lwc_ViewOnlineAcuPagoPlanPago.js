/* eslint-disable vars-on-top */
import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import obtenerDatos from '@salesforce/apex/SIR_LCMP_ViewOnlineAcuPagoPlanPago.obtenerDatos';
import callWsInfoApPp from '@salesforce/apex/SIR_LCMP_ViewOnlineAcuPagoPlanPago.callWsInfoApPp';

import {loadStyle } from 'lightning/platformResourceLoader';
import SIR_ModalMasAncho from '@salesforce/resourceUrl/SIR_ModalMasAncho';
import {loadScript} from 'lightning/platformResourceLoader';
import removeStylesheet from "@salesforce/resourceUrl/SIR_removeStylesheet";

const columns = [
    { label: 'Fecha prevista pago', fieldName: 'fechaPago', type: 'text', initialWidth: 162},
    { label: 'Fecha límite', fieldName: 'fechaLimite', type: 'text', initialWidth: 162},
    { label: 'Importe pactado', fieldName: 'importePactado', type: 'text', initialWidth: 170},
    { label: 'Cumplido', fieldName: 'cunplido', type: 'text', initialWidth: 162},
    { label: 'Importe pago', fieldName: 'importePago', type: 'text', initialWidth: 170},
    { label: 'Fecha realización', fieldName: 'fechaRealizacion', type: 'text', initialWidth: 162},
    { label: 'Comentario', fieldName: 'comentario', type: 'text'}
];

export default class Sir_lwc_ViewOnlineAcuPagoPlanPago extends LightningElement {
    histPagos = [];
    columns = columns;
    
    @api recordId;
    @api idPropuesta;
	@api cerrarComponente;

    @track camposVisible = false;
    @track tituloFormulario = 'Prueba';
    @track mensajeKO = false;
    @track mensajeError = '';
    @track codigoError = '';
    @track disabledCerrar = true;
	@track loadingVisible = true;

    @track acuerdoPago = false;
    @track planPago = false;    
    // Campos comunes cabecera
    @track nombreCliente = '';
    @track dniCif = '';
    @track gestorProceso = '';
    @track fechaSituacion = '';
    @track fechaAlta = '';
    @track totalDeudaExigible = '';
    // Campos comunes Plan Pago y Acuerdo de Pago
    @track diasGracia = '';
    @track porcentajeMinPago = '';
    @track fechaInicio;
    @track importeTotal = '';
    @track importePendiente = '';
    // Campos comunes Pago Ciclo Actual
    @track fechaVencimiento = '';
    @track fechaLimite = '';
    @track importeAcordado = '';
    // Campos exclusivos Plan Pago 
    @track importeCuota = '';
    @track numCuotas = '';
    @track periodicidad = '';
    @track dias = '';
    @track comentario = '';  
    // Historico
    @track historicoPagos = ''; 
    
    connectedCallback(){ 
		this.loadingVisible = true;
        loadStyle(this, SIR_ModalMasAncho); 
        if(this.idPropuesta == null || this.idPropuesta === undefined){
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => { 
                // Hacemos query para traer el idPropuesta y otros datos del cliente/proceso
                obtenerDatos({idTarea: this.recordId}).then(result => {                         
                    if(result !== undefined){                        
                        this.idPropuesta = result;
                        this.callWS();
                    } else if(result.error){
                        this.mensajeError = result.body.message;
                        this.codigoError = result.body.stackTrace;

                        this.acuerdoPago = false;
                        this.planPago = false;
                        this.camposVisible = false;
                        this.loadingVisible = false;
                        this.mensajeOKVisible = false;    
                        this.mensajeKO = true;
                        this.disabledCerrar = false;      
                    }
                })
                .catch(error => {
                    console.log('Error');
                    console.log(error);            
                }); 
            }, 100);   
        } else {          
            this.callWS();
        } 
    }

    callWS(){
        callWsInfoApPp({idPropuesta: this.idPropuesta}).then(result => {  			
			if(result !== undefined && result.length >= 0){ 			
				//Si el resultado del WS es OK 
				if(result[0] === 'OK'){ 
					// Constantes para transformar los importes al formato deseado
					const options = { style: 'currency', currency: 'EUR' };
					const numberFormat = new Intl.NumberFormat('es-ES', options);
					// Info del WS para la cabecera
					this.nombreCliente = result[1].cabecera.nombreCompleto;
					this.dniCif = result[1].cabecera.documento;
					this.gestorProceso = result[1].cabecera.gestorResponsable;
					this.fechaSituacion = result[1].cabecera.fechaSituacion;
					this.fechaAlta = result[1].cabecera.fechaAlta;
					if(result[1].cabecera.importeDeudaTotal != null && result[1].cabecera.importeDeudaTotal !== undefined && result[1].cabecera.importeDeudaTotal !== ''){
						this.totalDeudaExigible = numberFormat.format(result[1].cabecera.importeDeudaTotal);
					}
					var tipoInfo = result[1].cabecera.tipoDetallePago;
					// Campos comunes                      
					this.diasGracia = result[1].seccionPago.numDiasGraciaVto;
					if(result[1].seccionPago.porcenMinimoAceptado != null && result[1].seccionPago.porcenMinimoAceptado !== undefined && result[1].seccionPago.porcenMinimoAceptado !== ''){
						this.porcentajeMinPago = result[1].seccionPago.porcenMinimoAceptado + ' %';
					}
					this.fechaInicio = result[1].seccionPago.fechaInicioVenc;
					if(result[1].seccionPago.importePago != null && result[1].seccionPago.importePago !== undefined && result[1].seccionPago.importePago !== ''){
						this.importeTotal = numberFormat.format(result[1].seccionPago.importePago);
					}
					if(result[1].seccionPago.importePendiente != null && result[1].seccionPago.importePendiente !== undefined && result[1].seccionPago.importePendiente !== ''){
						this.importePendiente = numberFormat.format(result[1].seccionPago.importePendiente);
					}
					// Campos comunes Pago Ciclo Actual
					this.fechaVencimiento = result[1].pagoCicloActual.fechaPago;
					this.fechaLimite = result[1].pagoCicloActual.fechaLimite;
					if(result[1].pagoCicloActual.importeAcordado != null && result[1].pagoCicloActual.importeAcordado !== undefined && result[1].pagoCicloActual.importeAcordado !== ''){
						this.importeAcordado = numberFormat.format(result[1].pagoCicloActual.importeAcordado);
					}

					if(tipoInfo === 'PLAN PAGO'){                        
						this.tituloFormulario = 'Plan de Pago - Situación: ' + result[1].seccionPago.descripcionCodEstado;
						// Campos exclusivos Plan Pago
						if(result[1].seccionPago.importeCuotas != null && result[1].seccionPago.importeCuotas !== undefined && result[1].seccionPago.importeCuotas !== ''){
							this.importeCuota = numberFormat.format(result[1].seccionPago.importeCuotas);
						}
						this.numCuotas = result[1].seccionPago.numeroCuotas;
						if(result[1].seccionPago.periodicidad != null && result[1].seccionPago.periodicidad !== undefined && result[1].seccionPago.periodicidad !== '' && result[1].seccionPago.periodicidad === '0'){
							this.periodicidad = 'Diario';
						} else {
							this.periodicidad = result[1].seccionPago.periodicidad;
						}
						this.dias = result[1].seccionPago.unidadTiempo;
						this.comentario = result[1].seccionPago.comentario;
						// Booleanos para visualizar en front
						this.acuerdoPago = false;
						this.planPago = true;
					} else {
						this.tituloFormulario = 'Acuerdo de Pago - Situación: ' + result[1].seccionPago.descripcionCodEstado;
						// Booleanos para visualizar en front
						this.acuerdoPago = true;
						this.planPago = false;
					}   
					// Historico 
					let currentData = [];
					for (var i = 0; i < result[1].historicoPagos.length; i++) {
						let rowData = {};  
						rowData.fechaPago = result[1].historicoPagos[i].fechaPagoHis;  
						rowData.fechaLimite = result[1].historicoPagos[i].fechaLimiteHis;    
						if(result[1].historicoPagos[i].importePactadoHis != null && result[1].historicoPagos[i].importePactadoHis !== undefined && result[1].historicoPagos[i].importePactadoHis !== ''){
							this.importePactado = numberFormat.format(result[1].historicoPagos[i].importePactadoHis);
						}  
						rowData.cunplido = result[1].historicoPagos[i].cumplidosHis;
						if(result[1].historicoPagos[i].importePagoHis != null && result[1].historicoPagos[i].importePagoHis !== undefined && result[1].historicoPagos[i].importePagoHis !== ''){
							this.importePago = numberFormat.format(result[1].historicoPagos[i].importePagoHis);
						}
						rowData.fechaRealizacion = result[1].historicoPagos[i].fechaRealizHis; 
						rowData.comentario = result[1].historicoPagos[i].comentarioHis;                      
						currentData.push(rowData);
					}                     
					this.histPagos = currentData;
					this.historicoPagos = 'Histórico de pagos (' + result[1].historicoPagos.length + ')';

					this.camposVisible = true;            
					this.loadingVisible = false;   
					this.mensajeKO = false;
					this.disabledCerrar = false;              
				} else { //Si el resultado del WS es KO se muestra el error
					this.mensajeError = result[1];
					this.codigoError = result[2];    
					
					this.acuerdoPago = false;
					this.planPago = false;
					this.camposVisible = false;
					this.loadingVisible = false;
					this.mensajeOKVisible = false;    
					this.mensajeKO = true;
					this.disabledCerrar = false;
				}           
			} else if(result.error){
				this.mensajeError = result.body.message;
				this.codigoError = result.body.stackTrace;
	
				this.acuerdoPago = false;
				this.planPago = false;
				this.camposVisible = false;
				this.loadingVisible = false;
				this.mensajeOKVisible = false;    
				this.mensajeKO = true;
				this.disabledCerrar = false;      
			}
		})
		.catch(error => {
			console.log('Error');
			console.log(error);            
		});
    }

    cerrar() {	
		loadScript(this, removeStylesheet);
		this.dispatchEvent(new CustomEvent('siguiente'));		
        this.dispatchEvent(new CloseActionScreenEvent());       
    }

}