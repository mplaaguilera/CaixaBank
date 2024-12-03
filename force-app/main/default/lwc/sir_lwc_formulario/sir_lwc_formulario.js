import { LightningElement , api , track, wire } from 'lwc';
import getValoresForm from '@salesforce/apex/SIR_LCMP_IngresosIntervinientes.getValoresForm';
import getCapacidadFormulario from '@salesforce/apex/SIR_LCMP_GetCapacidadYsolucion.getCapacidadFormulario';
//import {loadStyle } from 'lightning/platformResourceLoader';
//import recurso from '@salesforce/resourceUrl/SIR_formularioTabs';

export default class Sir_lwc_formulario extends LightningElement {
    @api recordId;
    wrapper;
    // Determinación de la capacidad de pago actual
    @api ingresosDisponibles        = 0;
    @api valorTotalGastos           = 0;
    @api ratioEndeudamiento         = 0;
    @api importeCuotaActual       = 0;
   // @track importeCuotaActual       = 0;
    @api importeTotalFinanciacion   = 0;
    @api ratioTotal                 = 0;
    @api capacidadPagoCliente;
    @api capacidadDevolucion;
    @api tipoSolucion;

    @api checkFinalista = false;
    @api value;
    @api IngresosFuturo;
    @api ratioFuturo;
    @api ratioAdmision;
    @api solucionAplicar;
    @api tipoDificultad;
    @api checkCortoPlazo;
    @api checkLargoPlazo;
    @api cargaFinacieraCaixa;
    @api ratioActual;

    @api solucionDeuda;

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
            lightning-tabset.tab-active > div > lightning-tab-bar {
                --backgroundColorActive: #359CD5;
                --lwc-colorBackgroundAlt: var(--backgroundColorActive);
                --lwc-colorTextActionLabelActive: white;
            }
        `;
        
        const style2 = document.createElement('style');
        style2.innerText = `.slds-tabs_scoped__nav {
            border-bottom-color: #359CD5;
            border-bottom-width: 0.15rem;
        }`;

        this.template.querySelector('lightning-tabset').appendChild(style);
        this.template.querySelector('lightning-tabset').appendChild(style2);   
    }


    @wire(getValoresForm, { idFormulario: '$recordId'})
    getValoresForm({ error, data }) {           
        if(data){          
            if(data[0].SIR_TotalGastos__c == null){
                this.valorTotalGastos = 0;
            } else {
                this.valorTotalGastos = data[0].SIR_TotalGastos__c;
            } 
            if(data[0].SIR_capActualRatioEndeudamiento__c == null){
                this.ratioEndeudamiento = 0;
            } else {
                this.ratioEndeudamiento = data[0].SIR_capActualRatioEndeudamiento__c;
            }            
            this.importeCuotaActual = data[0].SIR_importeCuotaActual__c;
            this.importeTotalFinanciacion = data[0].SIR_capActualImporteFinanciacion__c;            
            if(data[0].SIR_capActualRatioTotal__c == null){
                this.ratioTotal = 0;
            } else {
                this.ratioTotal = data[0].SIR_capActualRatioTotal__c;
            } 
            this.capacidadPagoCliente = data[0].SIR_capActualPagoCliente__c;
            this.capacidadDevolucion = data[0].SIR_capacidadDevolucion__c;
            this.tipoSolucion = data[0].SIR_capActualTipoSolucion__c;
            if(this.tipoSolucion == 'Solución finalista'){
                this.checkFinalista = true;
            } else {
                this.checkFinalista = false;
                this.value = '';
            }                
            this.IngresosFuturo = data[0].SIR_ingresosFuturo__c;
            this.ratioFuturo = data[0].SIR_ratioFuturo__c;
            this.ratioAdmision = data[0].SIR_ratioAdmision__c;
            this.solucionAplicar = data[0].SIR_solucionAplicar__c;
            this.tipoDificultad = data[0].SIR_tipoDificultad__c;
            if(data[0].SIR_solucionAplicar__c != null && data[0].SIR_solucionAplicar__c != ''){
                if(data[0].SIR_solucionAplicar__c == 'Corto Plazo'){
                    this.checkCortoPlazo = true;
                    this.checkLargoPlazo = false;
                } else {
                    this.checkCortoPlazo = false;
                    this.checkLargoPlazo = true;
                } 
            }                           
            this.cargaFinacieraCaixa = data[0].SIR_TotalCuotaRefCaixa__c;
            if(data[0].SIR_ratioActual__c == null){
                this.ratioActual = 0;
            } else {
                this.ratioActual = data[0].SIR_ratioActual__c;
            } 
            
        }
    }
      

    
    // Evento que manda el total de ingresos desde el componente hijo Ingresos Intervinientes al componente padre para actualizar el valor en el componente capacidad y solución
    hanldeValoresIngresos(event) {
        this.ingresosDisponibles = event.detail.valorTrabajo +  event.detail.valorBienes;
        // calculo del radio de endeudamiento total que es dependiente de los ingresos y el importe total de cuota de financiación
        this.ratioTotal                     = ( this.importeTotalFinanciacion /this.ingresosDisponibles) * 100;
        // Función para calcular la Capacidad de pago del cliente y Tipo de solución que se muestra en el componente Hijo Capacidad y Solución
        this.calculalosIngresosYgastos();
        // Realizamos llamada a este metodo para recuperar valores de la base de datos cuando cambian los ingresosDisponibles
        this.calculateFormula(); 
    }
    // Evento que manda el total de gastos desde el componente Hijos Gastos Intervinientes al componente padre para actualizar el valor en componente capacidad y solución
    hanldeValoresGastos(event) {
        this.valorTotalGastos = event.detail.valorGastos;
        // Función para calcular la Capacidad de pago del cliente y Tipo de solución que se muestra en el componente Hijo Capacidad y Solución
        this.calculalosIngresosYgastos();
    }
    // Realizamos llamada para reuperar datos de la base de datos 
    calculateFormula() {
        getCapacidadFormulario({idFormulario: this.recordId})
        .then(result => {           
            this.wrapper                          = result;
            // Necesitamos importe de cuota Actual para sacar el valor del ratio de endeudamiento    
            // this.importeCuotaActual             = (this.wrapper[0].SIR_capActualImporteCuota__c != null) ? this.wrapper[0].SIR_capActualImporteCuota__c : 0;
            this.importeCuotaActual             = (this.importeCuotaActual != null) ? this.importeCuotaActual : 0;
            this.ratioEndeudamiento             =  (this.importeCuotaActual / this.ingresosDisponibles) * 100;
            this.ratioActual = this.ratioEndeudamiento;
            // this.importeCuotaActualFuturo       = (this.wrapper[0].SIR_importeCuotaActual__c != null) ? this.wrapper[0].SIR_importeCuotaActual__c : 0;
            this.importeCuotaActualFuturo       = this.importeCuotaActual;
            this.ratioFuturo                    =  (this.IngresosFuturo != null )? (this.importeCuotaActualFuturo / this.IngresosFuturo) *100 : 0;
            if(this.ratioFuturo > 0 && this.ratioEndeudamiento > 0){
                if(this.ratioFuturo >= 45 && this.ratioEndeudamiento >= 45){
                    this.tipoDificultad  = 'Estructural';
                    this.solucionAplicar = 'Largo Plazo';
                    this.checkCortoPlazo = false;
                    this.checkLargoPlazo = true;
                }else if((this.ratioFuturo < 45 && this.ratioEndeudamiento >= 45 ) ||  this.ratioEndeudamiento <= this.ratioAdmision ){
                    this.tipoDificultad  = 'Coyuntural';
                    this.solucionAplicar = 'Corto Plazo';
                    this.checkCortoPlazo = true;
                    this.checkLargoPlazo = false;
                }else{
                    this.tipoDificultad  = '';
                    this.solucionAplicar = '';
                    this.checkCortoPlazo = false;
                    this.checkLargoPlazo = false;
                }
            }
        })
       .catch(error => { this.error = error })
    }
    // Función para calcular la Capacidad de pago del cliente y Tipo de solución que se muestra en el componente Hijo Capacidad y Solución
    calculalosIngresosYgastos() {
        // capacidad de pago del cliente
        if( (this.ingresosDisponibles* 0.55) > this.valorTotalGastos ){
            this.capacidadPagoCliente = this.ingresosDisponibles* 0.45;
        }else{
          this.capacidadPagoCliente = this.ingresosDisponibles -this.valorTotalGastos;
        }
        this.capacidadDevolucion = this.capacidadPagoCliente;
        // Tipo de solución 
        if(this.ingresosDisponibles < this.valorTotalGastos){
            this.tipoSolucion = 'Solución finalista';
            this.checkFinalista = true;
   
        }else{
            this.tipoSolucion = 'Búsqueda solución';
            this.checkFinalista = false;
            this.value          = '';
        }
        // calculo de la solucion
        if(this.capacidadDevolucion > this.cargaFinacieraCaixa ){
            this.solucionDeuda = 'Sostenible';
        } else {
            this.solucionDeuda = 'No sostenible';
        }
    }
    // Evento desde el componente Hijo Cargas Financieras para calcular el importe total de cuota de financiación en el componente capacidad y solución
    hanldeCargasFinancieras(event) {
        this.importeTotalFinanciacion = event.detail.valorcargas;
        this.cargaFinacieraCaixa = event.detail.totalCuota;
        this.importeCuotaActual = event.detail.importeCuotaActual;
        this.importeCuotaActualFuturo = this.importeCuotaActual
        // calculo del radio de endeudamiento total que es dependiente de los ingresos y el importe total de cuota de financiación
        this.ratioTotal                     = ( this.importeTotalFinanciacion /this.ingresosDisponibles) * 100;
        this.ratioEndeudamiento             =  (this.importeCuotaActual / this.ingresosDisponibles) * 100;
        // calculo de la solucion
        if(this.capacidadDevolucion > this.cargaFinacieraCaixa ){
            this.solucionDeuda = 'Sostenible';
        } else {
            this.solucionDeuda = 'No sostenible';
        }
    }
    // cargamos con el recurso estatico los estilos
    /*connectedCallback(){
        loadStyle(this, recurso);
    }*/
}