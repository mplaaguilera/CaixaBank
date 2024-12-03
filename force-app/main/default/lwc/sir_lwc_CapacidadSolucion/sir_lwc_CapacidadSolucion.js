import { LightningElement, wire, api, track } from 'lwc';
import getCapacidadFormulario from '@salesforce/apex/SIR_LCMP_GetCapacidadYsolucion.getCapacidadFormulario';
import guardarFormulario from '@salesforce/apex/SIR_LCMP_GetCapacidadYsolucion.guardarFormulario';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {loadStyle } from 'lightning/platformResourceLoader';
import recurso from '@salesforce/resourceUrl/SIR_Formulario';
import { NavigationMixin } from 'lightning/navigation';
export default class Sir_lwc_CapacidadSolucion extends LightningElement {
    @api recordId;
    @track mas = '<';
    @track menos ='>';
    @track error;
    // Determinación de la capacidad de pago actual
    @api ingresosDisponibles = 0;               // SIR_capActualIngresosDisponibles__c  
    @api gastosNecesarios = 0;                  // SIR_capActualGastosNecesarios__c
    @api importeCuotaActual = 0;              // SIR_capActualImporteCuota__c             campo Formula que se calcula cuando se crea el formulario
    @api ratioEndeudamiento = 0;                // SIR_capActualRatioEndeudamiento__c
    @api importeTotalFinanciacion = 0;          // SIR_capActualImporteFinanciacion__c
    @api ratioTotal = 0;                        // SIR_capActualRatioTotal__c
    @api capacidadPagoCliente = 0;              // SIR_capActualPagoCliente__C
    @api capacidadDevolucion = 0;               // SIR_capacidadDevolucion__c
    @api tipoSolucion;                          // SIR_capActualTipoSolucion__c
    @api checkFinalista = false;                // Check para mostar los opciones Solucion Finalista
    @api value ;                                // SIR_SolucionFinalista__c
   
    // Determinación del endeudamiento futuro
    @track IngresosFuturo = 0;                  // SIR_ingresosFuturo__c                    Data Entry  publico para recuperar ratio futuro        
    @api importeCuotaActualFuturo = 0;        // SIR_importeCuotaActual__c                Campo Formula que se calcula al crear el formulario
    @api ratioFuturo = 0;                     // SIR_ratioEndeudamientoFuturo__c
    @track textIngresoFuturos = '';             // SIR_textIngresosFuturo__c

    //Determinación de la solución a aplicar
    @api ratioAdmision = 0;                     // SIR_ratioAdmision__c              
    @api ratioActual  = 0;                    // SIR_ratioActual__c
    //@track ratioFuturo = 0;                   // SIR_ratioFuturo__c
    @api checkCortoPlazo = false;             // Check para mostar los opciones Solucion Corto Plazo
    @api checkLargoPlazo = false;             // Check para mostar los opciones Solucion Largo Plazo
    @track valueCortoPlazo =  '';               // SIR_solucionCortoPlazo__c
    @track valueLargoPlazo = '';                // SIR_solucionLargoPlazo__c
    @api tipoDificultad  = '';                // SIR_tipoDificultad__c
    @api solucionAplicar = '';                // SIR_solucionAplicar__c
   // @track capacidadDevolucion = 0;             // SIR_capacidadDevolucion__c
    @api cargaFinacieraCaixa  = 0;            // SIR_cargaFinancieraCaixa__c
    @api solucionDeuda    = '';               // SIR_solucionDeuda__c
    @track solucionDeudaAplicar = '';           // SIR_solucionDeudaAplicar__c
    @track datosInteresSolucion = '';           // SIR_textSolucionAplicar__c
    
    // Track para calculos
    @track totalIngresosTrabajo = 0;        // SIR_TotalIngresosTrabajo__c
    @track totalIngresosVienes = 0;         // SIR_TotalIngresosBienes__c

    
    // cargamos con el recurso estatico los estilos
    connectedCallback(){
        loadStyle(this, recurso);
    }
  
    @wire(getCapacidadFormulario, { idFormulario: '$recordId'})
    getCapacidadFormulario({ error, data }) {          
        if(data){
            this.wrapper                          = data;
                       
          //  this.importeCuotaActual             = (this.wrapper[0].SIR_capActualImporteCuota__c != null) ? this.wrapper[0].SIR_capActualImporteCuota__c : 0;
            //if(this.value != ''){
                this.value                      = (this.wrapper[0].SIR_SolucionFinalista__c != null) ? this.wrapper[0].SIR_SolucionFinalista__c : '';
            //}
            this.IngresosFuturo                 = (this.wrapper[0].SIR_ingresosFuturo__c   != null) ? this.wrapper[0].SIR_ingresosFuturo__c : 0;
           // this.importeCuotaActualFuturo       = (this.wrapper[0].SIR_importeCuotaActual__c != null ) ? this.wrapper[0].SIR_importeCuotaActual__c : 0;
            this.ratioFuturo                    = (this.importeCuotaActualFuturo != null && this.wrapper[0].SIR_ingresosFuturo__c != 0) ? (this.importeCuotaActualFuturo / this.IngresosFuturo)*100 : 0;  
            this.textIngresoFuturos             = (this.wrapper[0].SIR_textIngresosFuturo__c != null ) ? this.wrapper[0].SIR_textIngresosFuturo__c : '';
            this.ratioAdmision                  = (this.wrapper[0].SIR_ratioAdmision__c != null ) ? this.wrapper[0].SIR_ratioAdmision__c : 0;
            this.ratioActual                    =  (this.ratioEndeudamiento != 0 || this.ratioEndeudamiento != null) ? this.ratioEndeudamiento :0;
            this.cargaFinacieraCaixa            = (this.wrapper[0].SIR_cargaFinancieraCaixa__c != null) ? this.wrapper[0].SIR_cargaFinancieraCaixa__c : 0;
            this.solucionDeudaAplicar           = (this.wrapper[0].SIR_solucionDeudaAplicar__c != null) ? this.wrapper[0].SIR_solucionDeudaAplicar__c : '';
            this.datosInteresSolucion           = (this.wrapper[0].SIR_textSolucionAplicar__c != null) ? this.wrapper[0].SIR_textSolucionAplicar__c : '';

            this.tipoDificultad                 = (this.wrapper[0].SIR_tipoDificultad__c != null) ? this.wrapper[0].SIR_tipoDificultad__c : '';
            this.solucionAplicar                = (this.wrapper[0].SIR_solucionAplicar__c != null) ? this.wrapper[0].SIR_solucionAplicar__c : '';           
            this.valueCortoPlazo                = (this.wrapper[0].SIR_solucionCortoPlazo__c != null) ? this.wrapper[0].SIR_solucionCortoPlazo__c : '';
            this.valueLargoPlazo                = (this.wrapper[0].SIR_solucionLargoPlazo__c != null) ? this.wrapper[0].SIR_solucionLargoPlazo__c : '';
        //    this.capacidadDevolucion            = (this.wrapper[0].SIR_capacidadDevolucion__c != null)? this.wrapper[0].SIR_capacidadDevolucion__c : 0;
            this.solucionDeuda                  = (this.wrapper[0].SIR_solucionDeuda__c != null) ? this.wrapper[0].SIR_solucionDeuda__c : '';
            this.calculos();
            // Comprobamos las Soluciones que tenemos que mostrar*/
            
            if(this.solucionAplicar === 'Corto Plazo'){
                this.checkCortoPlazo = true;
            }else{
                this.checkCortoPlazo = false;
            }
            if(this.solucionAplicar === 'Largo Plazo'){
                this.checkLargoPlazo = true;
            }else{
                this.checkLargoPlazo = false;
            }
        }
    }
    // Valor seleccionado en la Solución a aplicar
    handleSolucionDeuda(event) {
        this.solucionDeudaAplicar = event.target.value;
    }
     //Texto Otros datos interes Solución deuda
     handleTextoSolucion(event) {
        this.datosInteresSolucion = event.target.value;
    }

    // Valor seleccionado en la Solución Finalista
    handleOnChange(event) {
        this.value = event.target.value;
    }
     // Valor seleccionado en la Solución Corto plazo
     handleCorto(event) {
        this.valueCortoPlazo = event.target.value;
    }
    // Valor seleccionado en la Solución Largo plazo
    handleLargo(event) {
        this.valueLargoPlazo = event.target.value;
    }
     // Valor seleccionado en la Solución Finalista
     handleIngresosFuturo(event) {
        this.IngresosFuturo = event.target.value;
        this.valuerg = this.IngresosFuturo ;
        // Si ingresos futuro no tiene valor ponemos un 0
        if(this.IngresosFuturo === null || this.IngresosFuturo === undefined || this.IngresosFuturo === ''){
            this.IngresosFuturo = 0;
            this.ratioFuturo    = 0;
        }else{
            this.ratioFuturo    = (this.importeCuotaActualFuturo / this.IngresosFuturo)*100 ;
        }
        // Calculamos el ratio de endeudamiento futuro dinamicamente al cambiar el valor de Ingresos Futuro
        if(this.ratioFuturo != null || this.ratioFuturo != '' || this.ratioFuturo > 0){
            this.calculos();
        }
    }
     // Valor seleccionado Texto Desglose futuros
     handleTextoIngresos(event) {
        this.textIngresoFuturos = event.target.value;
    }
    // Valor seleccionado Ratio Admisión
    handleRatioAdmision(event) {
        this.ratioAdmision = event.target.value;
        this.calculos();
        
    }
    get options() {
        return [
            { label: 'Cancelación de la deuda con condonación y/o quita', value: '9' },
            { label: 'Venta de patrimonio adicional si hay patrimonio disponible', value: '10' },
            { label: 'Venta de la finca hipotecada a tercero no vinculado / Venta asistida', value: '11' },
            { label: 'Compra del activo / Dación en alquiler', value: '12' }
        ];
    }
    get optionsCortoPlazo() {
        return [
            { label: 'Carencia', value: '1' },
            { label: 'Amortización parcial de capital, carencia parcial', value: '2' },
            { label: 'Moratoria de cuotas', value: '3'},
            { label: 'Refinanciación de los saldos vencidos e impagados', value: '4' }
        ];
    }
    get optionsLargoPlazo() {
        return [
            { label: 'Reducción del tipo de interés', value: '5' },
            { label: 'Novación de plazo', value: '6' },
            { label: 'Modificación del calendario de amortización', value: '7'},
            { label: 'Consolidación de deudas', value: '8' }
        ];
    }
    // Guardamos el Formulario
    guardar(){
        // Determinación de la capacidad de pago actual
        this.form = [];
        this.form.push(this.comprobarValor(this.value)); 
        this.form.push(this.comprobarValor(this.IngresosFuturo));
        this.form.push(this.comprobarValor(this.textIngresoFuturos));  
        this.form.push(this.comprobarValor(this.ratioAdmision));
        this.form.push(this.comprobarValor(this.valueCortoPlazo));
        this.form.push(this.comprobarValor(this.valueLargoPlazo)); 
        this.form.push(this.comprobarValor(this.tipoDificultad));
        this.form.push(this.comprobarValor(this.solucionAplicar));
        this.form.push(this.comprobarValor(this.solucionDeudaAplicar));
        this.form.push(this.comprobarValor(this.datosInteresSolucion));      
  
        guardarFormulario({idFormulario: this.recordId, data: this.form})
         .then(result => {           
            if(result == 'OK'){
                // Muestro mensaje de OK
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Guardado',
                        message: 'Se ha guardado los cambios correctamente',
                        variant: 'success'
                    })
                );
              /*  this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Recordatorio',
                        message: 'Recuerde enviar el Formulario a SIREC con el Botón correspondiente de la cabecera del Formulario',
                        variant: 'warning'
                    })
                );*/
                 eval("$A.get('e.force:refreshView').fire();");
                window.location.reload();
               
            }
        })
        .catch(error => { this.error = error })
    }

   
    comprobarValor(valor){
      valor = valor.toString();
      return valor;
    }
    // Metodo para calcular tipo dificultad solucion aplicar y los boolean para controlar la visibilidad de los tipos de soluciones
    calculos(){
       
        if(this.ratioFuturo > 0 && this.ratioEndeudamiento > 0){
            if(this.ratioFuturo >= 45 && this.ratioEndeudamiento >= 45){
                this.tipoDificultad  = 'Estructural';
                this.solucionAplicar = 'Largo Plazo';
                this.checkCortoPlazo = false;
                this.checkLargoPlazo = true;
                this.valueCortoPlazo = '';
            }else if((this.ratioFuturo < 45 && this.ratioEndeudamiento >= 45 ) ||  this.ratioEndeudamiento <= this.ratioAdmision ){
                this.tipoDificultad  = 'Coyuntural';
                this.solucionAplicar = 'Corto Plazo';
                this.checkCortoPlazo = true;
                this.checkLargoPlazo = false;
                this.valueLargoPlazo = '';
            }else{
                this.tipoDificultad  = '';
                this.solucionAplicar = '';
                this.checkCortoPlazo = false;
                this.checkLargoPlazo = false;
                this.valueCortoPlazo = '';
                this.valueLargoPlazo = '';
            }
        }
    }
}