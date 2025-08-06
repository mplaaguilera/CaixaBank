import { LightningElement, wire, api, track  } from 'lwc';
import getCargasFormulario from '@salesforce/apex/SIR_LCMP_GetCargasFinancieras.getCargasFormulario';
import updateFormulario    from '@salesforce/apex/SIR_LCMP_GetCargasFinancieras.guardarFormulario';
import getCalculadorLink    from '@salesforce/apex/SIR_LCMP_GetCargasFinancieras.getCaluladoraLink';
import { ShowToastEvent }  from 'lightning/platformShowToastEvent';
import {loadStyle } from 'lightning/platformResourceLoader';
import recurso from '@salesforce/resourceUrl/SIR_Formulario';
import SIR_CMP_ErrorMessage 		from '@salesforce/label/c.SIR_CMP_ErrorMessage';
import resource from '@salesforce/resourceUrl/SIR_Icons';

import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class Sir_lwc_CargasFinancieras extends LightningElement {
   
    @api recordId;
    wrapper;
    @api importeTotalFinanciacion;
    //  Préstamos y créditos con garantía Real
    @track deudaPrestamoRealCaixa;
    @track cuotaPrestamoRealCaixa;
    @track deudaPrestamoRealNoCaixa = 0;
    @track cuotaPrestamoRealNoCaixa = 0;
    //  Préstamos y créditos con garantía Personal
    @track deudaPrestamoPersonalCaixa;
    @track cuotaPrestamoPersonalCaixa;
    @track deudaPrestamoPersonalNoCaixa = 0;
    @track cuotaPrestamoPersonalNoCaixa = 0;
    //  Tarjetas
    @track deudaTarjetaCaixa;
    @track cuotaTarjetaCaixa;
    @track deudaTarjetaNoCaixa = 0;
    @track cuotaTarjetaNoCaixa = 0;
    //  Operaciones con empresas del Grupo
    @track deudaOperacionesCaixa;
    @track cuotaOperacionesCaixa;
    @track deudaOperacionesNoCaixa = 0;
    @track cuotaOperacionesNoCaixa = 0;
    //  Otros
    @track deudaOtrosCaixa;
    @track cuotaOtrosCaixa;
    @track deudaOtrosNoCaixa = 0;
    @track cuotaOtrosNoCaixa = 0;
    // Total Caixa Y Otras Entidades    
    @track totalDeudaCargasCaixa;
    @track totalCuotaCargasCaixa;
    @track totalDeudaCargasNoCaixa;
    @track totalCuotaCargasNoCaixa;
    // Préstamo/s a cancelar/reducir
    @track deudaPrestamosCaixa;
    @track cuotaPrestamosCaixa;
    @track deudaPrestamosNoCaixa;
    @track CuotaPrestamosNoCaixa;
    // Operación de refinanciación 
    @track deudaOperacionRefCaixa;
    @track cuotaOperacionRefCaixa;
    @track deudaOperacionRefNoCaixa;
    @track cuotaOperacionRefNoCaixa;
    // Total Refinanciado
    @track deudaTotalRefCaixa;
    @track cuotaTotalRefCaixa;
    @track deudaTotalRefNoCaixa;
    @track cuotaTotalRefNoCaixa;
    // Otros Datos de Interés
    @track otrosDatosCargas = '';
    @track form = [];
    @track calculadora;
    @track calculadoraIcon = resource + '/SIR_Icons/Calculadora_30.png';

    @track changeFieldTotalCuotaCargasNoCaixa = false;
    @track changeFieldTotalDeudaCargasNoCaixa = false;
    @track changeFieldTotalCuotaCargasCaixa = false;
    @track changeFieldTotalDeudaCargasCaixa = false;
	  @track changeFieldDeudaTotalRefCaixa = false;
    @track changeFieldCuotaTotalRefCaixa = false;
	  @track changeFieldDeudaTotalRefNoCaixa = false;
	  @track changeFieldCuotaTotalRefNoCaixa = false;

    // cargamos con el recurso estatico los estilos
    connectedCallback(){
      loadStyle(this, recurso);
      this.setCalculadoraLink();      
    }

    @wire(getCargasFormulario, { idFormulario: '$recordId'})
    getFormulario({ error, data }) {           
        if(data){
			this.wrapper                          = data;
			//  Préstamos y créditos con garantía Real
			this.deudaPrestamoRealCaixa           = (this.wrapper[0].SIR_deudaTotalGarantiaReal__c != null) ? this.wrapper[0].SIR_deudaTotalGarantiaReal__c : 0;
			this.cuotaPrestamoRealCaixa           = (this.wrapper[0].SIR_cuotaGarantiaReal__c != null ) ? this.wrapper[0].SIR_cuotaGarantiaReal__c : 0;
			this.deudaPrestamoRealNoCaixa         = (this.wrapper[0].SIR_deudaTotalGarantiaRealEnt__c != null) ? this.wrapper[0].SIR_deudaTotalGarantiaRealEnt__c : 0;
			this.cuotaPrestamoRealNoCaixa         = (this.wrapper[0].SIR_cuotaGarantiaRealEnt__c != null) ? this.wrapper[0].SIR_cuotaGarantiaRealEnt__c : 0 ;
			//  Préstamos y créditos con garantía Personal
			this.deudaPrestamoPersonalCaixa       = (this.wrapper[0].SIR_deudaTotalGarantiaPersonal__c != null ) ? this.wrapper[0].SIR_deudaTotalGarantiaPersonal__c : 0;
			this.cuotaPrestamoPersonalCaixa       = (this.wrapper[0].SIR_CuotaGarantiaPersonal__c != null) ? this.wrapper[0].SIR_CuotaGarantiaPersonal__c : 0;
			this.deudaPrestamoPersonalNoCaixa     = (this.wrapper[0].SIR_deudaTotalGarantiaPersonalEnt__c != null) ? this.wrapper[0].SIR_deudaTotalGarantiaPersonalEnt__c : 0;
			this.cuotaPrestamoPersonalNoCaixa     = (this.wrapper[0].SIR_CuotaGarantiaPersonalEnt__c != null) ? this.wrapper[0].SIR_CuotaGarantiaPersonalEnt__c : 0;
			//  Tarjetas
			this.deudaTarjetaCaixa               = (this.wrapper[0].SIR_deudaTotalTarjeta__c != null ) ? this.wrapper[0].SIR_deudaTotalTarjeta__c : 0 ;
			this.cuotaTarjetaCaixa               = (this.wrapper[0].SIR_CuotaMensualTarjetas__c != null) ? this.wrapper[0].SIR_CuotaMensualTarjetas__c : 0;
			this.deudaTarjetaNoCaixa             = (this.wrapper[0].SIR_deudaTotalTarjetaEnt__c != null) ? this.wrapper[0].SIR_deudaTotalTarjetaEnt__c : 0;
			this.cuotaTarjetaNoCaixa             = (this.wrapper[0].SIR_CuotaMensualTarjetasEnt__c != null) ? this.wrapper[0].SIR_CuotaMensualTarjetasEnt__c : 0;
			//  Operaciones con empresas del Grupo
			this.deudaOperacionesCaixa          = (this.wrapper[0].SIR_deudaTotalEmpresasGrupo__c != null) ? this.wrapper[0].SIR_deudaTotalEmpresasGrupo__c : 0;
			this.cuotaOperacionesCaixa          = (this.wrapper[0].SIR_CuotaMensualEmpresasGrupo__c != null) ? this.wrapper[0].SIR_CuotaMensualEmpresasGrupo__c : 0;
			this.deudaOperacionesNoCaixa        = (this.wrapper[0].SIR_deudaTotalEmpresasGrupoEnt__c != null) ? this.wrapper[0].SIR_deudaTotalEmpresasGrupoEnt__c : 0;
			this.cuotaOperacionesNoCaixa        = (this.wrapper[0].SIR_CuotaMensualEmpresasGrupoEnt__c != null) ? this.wrapper[0].SIR_CuotaMensualEmpresasGrupoEnt__c : 0;
			//  Otros
			this.deudaOtrosCaixa                = (this.wrapper[0].SIR_deudaTotalOtros__c != null) ?  this.wrapper[0].SIR_deudaTotalOtros__c : 0;
			this.cuotaOtrosCaixa                = (this.wrapper[0].SIR_CuotaMensualOtros__c != null) ?  this.wrapper[0].SIR_CuotaMensualOtros__c : 0;
			this.deudaOtrosNoCaixa              = (this.wrapper[0].SIR_deudaTotalOtrosEnt__c != null ) ?  this.wrapper[0].SIR_deudaTotalOtrosEnt__c : 0;
			this.cuotaOtrosNoCaixa              = (this.wrapper[0].SIR_CuotaMensualOtrosEnt__c != null) ? this.wrapper[0].SIR_CuotaMensualOtrosEnt__c : 0;
			// Total Caixa Y Otras Entidades
			this.totalDeudaCargasCaixa          = (this.wrapper[0].SIR_TotalDeudaCaixabank__c != null) ? this.wrapper[0].SIR_TotalDeudaCaixabank__c :  0; 
			this.totalCuotaCargasCaixa          = (this.wrapper[0].SIR_TotalCuotaCaixabank__c != null) ? this.wrapper[0].SIR_TotalCuotaCaixabank__c :  0;
			this.totalDeudaCargasNoCaixa        = (this.wrapper[0].SIR_TotalDeudaOtraEntidad__c != null) ? this.wrapper[0].SIR_TotalDeudaOtraEntidad__c :  0;
			this.totalCuotaCargasNoCaixa        = (this.wrapper[0].SIR_TotalCuotaOtraEntidad__c != null) ? this.wrapper[0].SIR_TotalCuotaOtraEntidad__c :  0;
			// variable api para capacidad y solucion 
			this.importeTotalFinanciacion       = this.totalCuotaCargasCaixa + this.totalCuotaCargasNoCaixa;
			// Préstamo/s a cancelar/reducir
			//this.deudaPrestamosCaixa            = (this.wrapper[0].SIR_prestamoDeudaCaixa__c != null) ? this.wrapper[0].SIR_prestamoDeudaCaixa__c :  this.totalDeudaCargasCaixa; 
			this.deudaPrestamosCaixa            = (this.wrapper[0].SIR_prestamoDeudaCaixa__c != null) ? this.wrapper[0].SIR_prestamoDeudaCaixa__c :  0;          
			//this.cuotaPrestamosCaixa            = (this.wrapper[0].SIR_prestamoCuotaCaixa__c != null) ? this.wrapper[0].SIR_prestamoCuotaCaixa__c :  this.totalCuotaCargasCaixa;
			this.cuotaPrestamosCaixa            = (this.wrapper[0].SIR_prestamoCuotaCaixa__c != null) ? this.wrapper[0].SIR_prestamoCuotaCaixa__c :  0;
			this.deudaPrestamosNoCaixa          = (this.wrapper[0].SIR_prestamoDeudaNoCaixa__c != null) ? this.wrapper[0].SIR_prestamoDeudaNoCaixa__c :0;
			this.CuotaPrestamosNoCaixa          = (this.wrapper[0].SIR_prestamoCuotaNoCaixa__c != null) ? this.wrapper[0].SIR_prestamoCuotaNoCaixa__c :0;
			// Operación de refinanciación 
			this.deudaOperacionRefCaixa         = (this.wrapper[0].SIR_DeudaOperacionRefCaixa__c != null ) ? this.wrapper[0].SIR_DeudaOperacionRefCaixa__c : 0;
			this.cuotaOperacionRefCaixa         = (this.wrapper[0].SIR_CuotaOperacionRefCaixa__c != null ) ? this.wrapper[0].SIR_CuotaOperacionRefCaixa__c : 0;
			this.deudaOperacionRefNoCaixa       = (this.wrapper[0].SIR_DeudaOperacionRefNoCaixa__c != null) ? this.wrapper[0].SIR_DeudaOperacionRefNoCaixa__c : 0;
			this.cuotaOperacionRefNoCaixa       = (this.wrapper[0].SIR_CuotaOperacionRefNoCaixa__c != null) ?  this.wrapper[0].SIR_CuotaOperacionRefNoCaixa__c : 0;
			// Total Refinanciado
			this.deudaTotalRefCaixa             = (this.wrapper[0].SIR_TotalDeudaRefCaixa__c != null) ? this.wrapper[0].SIR_TotalDeudaRefCaixa__c : 0 ;
			this.cuotaTotalRefCaixa             = (this.wrapper[0].SIR_TotalCuotaRefCaixa__c != null) ? this.wrapper[0].SIR_TotalCuotaRefCaixa__c : 0 ; 
			this.deudaTotalRefNoCaixa           = (this.wrapper[0].SIR_TotalDeudaRefNoCaixa__c != null) ? this.wrapper[0].SIR_TotalDeudaRefNoCaixa__c : 0 ;
			this.cuotaTotalRefNoCaixa           = (this.wrapper[0].SIR_TotalCuotaRefNoCaixa__c != null) ? this.wrapper[0].SIR_TotalCuotaRefNoCaixa__c : 0 ;
			// Otros Datos de Interés
			this.otrosDatosCargas               = (this.wrapper[0].SIR_OtrosDatosInteresCargas__c != null) ? this.wrapper[0].SIR_OtrosDatosInteresCargas__c : '';
			// Calculos Totales        
      //this.changeTotalesRefi();
      this.changeTotalRefiDeudaCaixa();
      this.handleChnage();

        }
    }
    changeDeudaPrestamoRealNoCaixa(event){ 
      this.deudaPrestamoRealNoCaixa = event.target.value;
      if(this.deudaPrestamoRealNoCaixa === ''){
        this.deudaPrestamoRealNoCaixa = 0;
      }
      this.changeTotalesDeudaOtrasEnt();
    }
    changeCuotaPrestamoRealNoCaixa(event){ 
      this.cuotaPrestamoRealNoCaixa = event.target.value;
      if(this.cuotaPrestamoRealNoCaixa === ''){
        this.cuotaPrestamoRealNoCaixa = 0;
      }
      this.changeTotalesCuotaOtrasEnt();
    }
    changeDeudaPrestamoPersonalNoCaixa(event){ 
      this.deudaPrestamoPersonalNoCaixa = event.target.value;
      if(this.deudaPrestamoPersonalNoCaixa === ''){
        this.deudaPrestamoPersonalNoCaixa = 0;
      }
      this.changeTotalesDeudaOtrasEnt();
    }
    changeCuotaPrestamoPersonalNoCaixa(event){ 
      this.cuotaPrestamoPersonalNoCaixa = event.target.value;
      if(this.cuotaPrestamoPersonalNoCaixa === ''){
        this.cuotaPrestamoPersonalNoCaixa = 0;
      }
      this.changeTotalesCuotaOtrasEnt();
    }
    changeDeudaTarjetaNoCaixa(event){ 
      this.deudaTarjetaNoCaixa = event.target.value;
      if(this.deudaTarjetaNoCaixa === ''){
        this.deudaTarjetaNoCaixa = 0;
      }
      this.changeTotalesDeudaOtrasEnt();
    }
    changeCuotaTarjetaNoCaixa(event){ 
      this.cuotaTarjetaNoCaixa = event.target.value;
      if(this.cuotaTarjetaNoCaixa === ''){
        this.cuotaTarjetaNoCaixa = 0;
      }
      this.changeTotalesCuotaOtrasEnt();
    }
    changeDeudaOperacionesNoCaixa(event){ 
      this.deudaOperacionesNoCaixa = event.target.value;
      if(this.deudaOperacionesNoCaixa === ''){
        this.deudaOperacionesNoCaixa = 0;
      }
      this.changeTotalesDeudaOtrasEnt();
    }
    changeOperacionDeudaCaixa(event){ 
      this.deudaOperacionRefCaixa = event.target.value;
      if(this.deudaOperacionRefCaixa === ''){
        this.deudaOperacionRefCaixa = 0;
      }
      this.changeTotalRefiDeudaCaixa();
    }
    changeOperacionCuotaCaixa(event){ 
      this.cuotaOperacionRefCaixa = event.target.value;
      if(this.cuotaOperacionRefCaixa === ''){
        this.cuotaOperacionRefCaixa = 0;
      }
      this.changeTotalRefiCuotaCaixa();
    }
    changeCuotaOperacionesNoCaixa(event){ 
      this.cuotaOperacionesNoCaixa = event.target.value;
      if(this.cuotaOperacionesNoCaixa === ''){
        this.cuotaOperacionesNoCaixa = 0;
      }
	  this.changeTotalesCuotaOtrasEnt();
    }
    changeDeudaOtrosNoCaixa(event){ 
      this.deudaOtrosNoCaixa = event.target.value;
      if(this.deudaOtrosNoCaixa === ''){
        this.deudaOtrosNoCaixa = 0;
      }
      this.changeTotalesDeudaOtrasEnt();
    }
    changeCuotaOtrosNoCaixa(event){ 
      this.cuotaOtrosNoCaixa = event.target.value;
      if(this.cuotaOtrosNoCaixa === ''){
        this.cuotaOtrosNoCaixa = 0;
      }
	  this.changeTotalesCuotaOtrasEnt();
    }
    changeDeudaPrestamos(event){ 
      this.deudaPrestamosNoCaixa = event.target.value;
      if(this.deudaPrestamosNoCaixa === ''){
        this.deudaPrestamosNoCaixa = 0;
      }
      this.changeTotalRefiDeudaOtrasEnt();
    }
    changeCuotaPrestamos(event){ 
      this.CuotaPrestamosNoCaixa = event.target.value;
      if(this.CuotaPrestamosNoCaixa === ''){
        this.CuotaPrestamosNoCaixa = 0;
      }
      this.changeTotalRefiCuotaOtrasEnt();
    }
    changeDeudaOperacion(event){ 
      this.deudaOperacionRefNoCaixa = event.target.value;
      if(this.deudaOperacionRefNoCaixa === ''){
        this.deudaOperacionRefNoCaixa = 0;
      }
      this.changeTotalRefiDeudaOtrasEnt();
    }
    changeCuotaOperacion(event){ 
      this.cuotaOperacionRefNoCaixa = event.target.value;
      if(this.cuotaOperacionRefNoCaixa === ''){
        this.cuotaOperacionRefNoCaixa = 0;
      }
      this.changeTotalRefiCuotaOtrasEnt();
    }

    // 10/02/23 - Se añaden los change de los campos que antes estaban disabled
    changeDeudaPrestamoRealCaixa(event){ 
      this.deudaPrestamoRealCaixa = event.target.value;
      if(this.deudaPrestamoRealCaixa === ''){
        this.deudaPrestamoRealCaixa = 0;
      }
      this.changeTotalesDeudaCaixa();
    }
    changeCuotaPrestamoRealCaixa(event){ 
      this.cuotaPrestamoRealCaixa = event.target.value;
      if(this.cuotaPrestamoRealCaixa === ''){
        this.cuotaPrestamoRealCaixa = 0;
      }
      this.changeTotalesCuotaCaixa();
    }
    changeDeudaPrestamoPersonalCaixa(event){ 
      this.deudaPrestamoPersonalCaixa = event.target.value;
      if(this.deudaPrestamoPersonalCaixa === ''){
        this.deudaPrestamoPersonalCaixa = 0;
      }
      this.changeTotalesDeudaCaixa();
    }
    changeCuotaPrestamoPersonalCaixa(event){ 
      this.cuotaPrestamoPersonalCaixa = event.target.value;
      if(this.cuotaPrestamoPersonalCaixa === ''){
        this.cuotaPrestamoPersonalCaixa = 0;
      }
      this.changeTotalesCuotaCaixa();
    }
    changeDeudaTarjetaCaixa(event){ 
      this.deudaTarjetaCaixa = event.target.value;
      if(this.deudaTarjetaCaixa === ''){
        this.deudaTarjetaCaixa = 0;
      }
      this.changeTotalesDeudaCaixa();
    }
    changeCuotaTarjetaCaixa(event){ 
      this.cuotaTarjetaCaixa = event.target.value;
      if(this.cuotaTarjetaCaixa === ''){
        this.cuotaTarjetaCaixa = 0;
      }
      this.changeTotalesCuotaCaixa();
    }
    changeDeudaOperacionesCaixa(event){ 
      this.deudaOperacionesCaixa = event.target.value;
      if(this.deudaOperacionesCaixa === ''){
        this.deudaOperacionesCaixa = 0;
      }
      this.changeTotalesDeudaCaixa();
    }
    changeCuotaOperacionesCaixa(event){ 
      this.cuotaOperacionesCaixa = event.target.value;
      if(this.cuotaOperacionesCaixa === ''){
        this.cuotaOperacionesCaixa = 0;
      }
      this.changeTotalesCuotaCaixa();
    }
    changeDeudaOtrosCaixa(event){ 
      this.deudaOtrosCaixa = event.target.value;
      if(this.deudaOtrosCaixa === ''){
        this.deudaOtrosCaixa = 0;
      }
      this.changeTotalesDeudaCaixa();
    }
    changeCuotaOtrosCaixa(event){ 
      this.cuotaOtrosCaixa = event.target.value;
      if(this.cuotaOtrosCaixa === ''){
        this.cuotaOtrosCaixa = 0;
      }
      this.changeTotalesCuotaCaixa();
    }
    changeTotalDeudaCargasCaixa(event){ 
      this.totalDeudaCargasCaixa = event.target.value;
      if(this.totalDeudaCargasCaixa === ''){
        this.totalDeudaCargasCaixa = 0;
      }
      this.changeFieldTotalDeudaCargasCaixa = true;
      this.changeTotalesDeudaCaixa();
    }   
    changeTotalCuotaCargasCaixa(event){ 
      this.totalCuotaCargasCaixa = event.target.value;
      if(this.totalCuotaCargasCaixa === ''){
        this.totalCuotaCargasCaixa = 0;
      }    
      this.changeFieldTotalCuotaCargasCaixa = true;
      this.changeTotalesCuotaCaixa();
    }
    changeTotalDeudaCargasNoCaixa(event){ 
      this.totalDeudaCargasNoCaixa = event.target.value;
      if(this.totalDeudaCargasNoCaixa === ''){
        this.totalDeudaCargasNoCaixa = 0;
      }
      this.changeFieldTotalDeudaCargasNoCaixa = true;
      this.changeTotalesDeudaOtrasEnt();
    }
    changeTotalCuotaCargasNoCaixa(event){ 
      this.totalCuotaCargasNoCaixa = event.target.value;
      if(this.totalCuotaCargasNoCaixa === ''){
        this.totalCuotaCargasNoCaixa = 0;
      }
      this.changeFieldTotalCuotaCargasNoCaixa = true;
      this.changeTotalesCuotaOtrasEnt();
    }
    changeDeudaPrestamosCaixa(event){ 
      this.deudaPrestamosCaixa = event.target.value;
      if(this.deudaPrestamosCaixa === ''){
        this.deudaPrestamosCaixa = 0;
      }
      this.changeTotalRefiDeudaCaixa();
    }
    changeCuotaPrestamosCaixa(event){ 
      this.cuotaPrestamosCaixa = event.target.value;
      if(this.cuotaPrestamosCaixa === ''){
        this.cuotaPrestamosCaixa = 0;
      }
      this.changeTotalRefiCuotaCaixa();
    }
    changeDeudaTotalRefCaixa(event){ 
      this.deudaTotalRefCaixa = event.target.value;
      if(this.deudaTotalRefCaixa === ''){
        this.deudaTotalRefCaixa = 0;
      }
	  this.changeFieldDeudaTotalRefCaixa = true;
      this.changeTotalRefiDeudaCaixa();
    }
    changeCuotaTotalRefCaixa(event){ 
      this.cuotaTotalRefCaixa = event.target.value;
      if(this.cuotaTotalRefCaixa === ''){
        this.cuotaTotalRefCaixa = 0;
      }
	  this.changeFieldCuotaTotalRefCaixa = true;
      this.changeTotalRefiCuotaCaixa();
    }
    changeDeudaTotalRefNoCaixa(event){ 
      this.deudaTotalRefNoCaixa = event.target.value;
      if(this.deudaTotalRefNoCaixa === ''){
        this.deudaTotalRefNoCaixa = 0;
      }
	  this.changeFieldDeudaTotalRefNoCaixa = true;
      this.changeTotalRefiDeudaOtrasEnt();
    }
    changeCuotaTotalRefNoCaixa(event){ 
      this.cuotaTotalRefNoCaixa = event.target.value;
      if(this.cuotaTotalRefNoCaixa === ''){
        this.cuotaTotalRefNoCaixa = 0;
      }
	  this.changeFieldCuotaTotalRefNoCaixa = true;
      this.changeTotalRefiCuotaOtrasEnt();
    }

	// Calcula columa deuda caixa 1r columna
	changeTotalesDeudaCaixa(){   
		if(this.changeFieldTotalDeudaCargasCaixa == true){
			this.changeFieldTotalDeudaCargasCaixa = false;
      	} else {
        	this.totalDeudaCargasCaixa = parseFloat(this.deudaPrestamoRealCaixa) + parseFloat(this.deudaPrestamoPersonalCaixa) + parseFloat(this.deudaTarjetaCaixa ) + parseFloat(this.deudaOperacionesCaixa) + parseFloat(this.deudaOtrosCaixa); 
		} 
        this.changeTotalRefiDeudaCaixa();
    }
	// Calcula columa cuota caixa 2n columna
	changeTotalesCuotaCaixa(){   
		if(this.changeFieldTotalCuotaCargasCaixa == true){
			this.changeFieldTotalCuotaCargasCaixa = false;
      	} else {
        	this.totalCuotaCargasCaixa = parseFloat(this.cuotaPrestamoRealCaixa) + parseFloat(this.cuotaPrestamoPersonalCaixa) + parseFloat(this.cuotaTarjetaCaixa ) + parseFloat(this.cuotaOperacionesCaixa) + parseFloat(this.cuotaOtrosCaixa); 
		}
		this.importeTotalFinanciacion    = parseFloat(this.totalCuotaCargasCaixa) + parseFloat(this.totalCuotaCargasNoCaixa);
		this.changeTotalRefiCuotaCaixa();
    }
	// Calcula columa deuda otras entidades 3a columna
	changeTotalesDeudaOtrasEnt(){   
		if(this.changeFieldTotalDeudaCargasNoCaixa == true){
			this.changeFieldTotalDeudaCargasNoCaixa = false;
      	} else {
			this.totalDeudaCargasNoCaixa = parseFloat(this.deudaPrestamoRealNoCaixa) + parseFloat(this.deudaPrestamoPersonalNoCaixa) + parseFloat(this.deudaTarjetaNoCaixa ) + parseFloat(this.deudaOperacionesNoCaixa) + parseFloat(this.deudaOtrosNoCaixa); 
		} 
		this.changeTotalRefiDeudaOtrasEnt();
    }
	// Calcula columa cuota otras entidades 4a columna
	changeTotalesCuotaOtrasEnt(){  
		if(this.changeFieldTotalCuotaCargasNoCaixa == true){
			this.changeFieldTotalCuotaCargasNoCaixa = false;
      	} else {
        	this.totalCuotaCargasNoCaixa = parseFloat(this.cuotaPrestamoRealNoCaixa) + parseFloat(this.cuotaPrestamoPersonalNoCaixa) + parseFloat(this.cuotaTarjetaNoCaixa ) + parseFloat(this.cuotaOperacionesNoCaixa) + parseFloat(this.cuotaOtrosNoCaixa); 
		}	 
		this.importeTotalFinanciacion    = parseFloat(this.totalCuotaCargasCaixa) + parseFloat(this.totalCuotaCargasNoCaixa);
        this.changeTotalRefiCuotaOtrasEnt();
    }
	
	// Calcula columa TOTAL REFI deuda caixa 1r columna
	changeTotalRefiDeudaCaixa(){  
		if(this.changeFieldDeudaTotalRefCaixa == true){
			this.changeFieldDeudaTotalRefCaixa = false;
      	} else {
        	this.deudaTotalRefCaixa = parseFloat(this.totalDeudaCargasCaixa) - parseFloat(this.deudaPrestamosCaixa) + parseFloat(this.deudaOperacionRefCaixa);
		} 		
        // Enviamos los cambios a los otros componentes   
      	this.handleChnage();
    }
	// Calcula columa TOTAL REFI cuota caixa 2n columna
	changeTotalRefiCuotaCaixa(){  
		if(this.changeFieldCuotaTotalRefCaixa == true){
			this.changeFieldCuotaTotalRefCaixa = false;
      	} else {
        	this.cuotaTotalRefCaixa = parseFloat(this.totalCuotaCargasCaixa) - parseFloat(this.cuotaPrestamosCaixa) + parseFloat(this.cuotaOperacionRefCaixa);
		} 		
        // Enviamos los cambios a los otros componentes   
      	this.handleChnage();
    }
	// Calcula columa TOTAL REFI deuda otras entidades 3a columna
	changeTotalRefiDeudaOtrasEnt(){  
		if(this.changeFieldDeudaTotalRefNoCaixa == true){
			this.changeFieldDeudaTotalRefNoCaixa = false;
      	} else {
        	this.deudaTotalRefNoCaixa = parseFloat(this.totalDeudaCargasNoCaixa) - parseFloat(this.deudaPrestamosNoCaixa) + parseFloat(this.deudaOperacionRefNoCaixa);
		} 		
        // Enviamos los cambios a los otros componentes   
      	this.handleChnage();
    }
	// Calcula columa TOTAL REFI cuota otras entidades 4a columna
	changeTotalRefiCuotaOtrasEnt(){  
		if(this.changeFieldCuotaTotalRefNoCaixa == true){
			this.changeFieldCuotaTotalRefNoCaixa = false;
      	} else {
        	this.cuotaTotalRefNoCaixa = parseFloat(this.totalCuotaCargasNoCaixa) - parseFloat(this.CuotaPrestamosNoCaixa) + parseFloat(this.cuotaOperacionRefNoCaixa);
		} 		
        // Enviamos los cambios a los otros componentes   
      	this.handleChnage();
    }
    // Otros Datos Interes
    changeOtrosDatosCargas(event){ 
      	this.otrosDatosCargas = event.target.value;
    }
    // Guardamos el Formulario
    guardar(){
		this.form = [];
		this.form.push(this.comprobarValor(this.deudaPrestamoRealNoCaixa));   
		this.form.push(this.comprobarValor(this.cuotaPrestamoRealNoCaixa));
		this.form.push(this.comprobarValor(this.deudaPrestamoPersonalNoCaixa));
		this.form.push(this.comprobarValor(this.cuotaPrestamoPersonalNoCaixa));
		this.form.push(this.comprobarValor(this.deudaTarjetaNoCaixa));
		this.form.push(this.comprobarValor(this.cuotaTarjetaNoCaixa));
		this.form.push(this.comprobarValor(this.deudaOperacionesNoCaixa));
		this.form.push(this.comprobarValor(this.cuotaOperacionesNoCaixa));
		this.form.push(this.comprobarValor(this.deudaOtrosNoCaixa));
		this.form.push(this.comprobarValor(this.cuotaOtrosNoCaixa));
		this.form.push(this.comprobarValor(this.totalDeudaCargasNoCaixa));
		this.form.push(this.comprobarValor(this.totalCuotaCargasNoCaixa));
		this.form.push(this.comprobarValor(this.otrosDatosCargas));
		this.form.push(this.comprobarValor(this.deudaOperacionRefCaixa));
		this.form.push(this.comprobarValor(this.cuotaOperacionRefCaixa));
		this.form.push(this.comprobarValor(this.deudaPrestamosNoCaixa));
		this.form.push(this.comprobarValor(this.deudaOperacionRefNoCaixa));
		this.form.push(this.comprobarValor(this.CuotaPrestamosNoCaixa));
		this.form.push(this.comprobarValor(this.cuotaOperacionRefNoCaixa));
		this.form.push(this.comprobarValor(this.deudaTotalRefNoCaixa));
		this.form.push(this.comprobarValor(this.cuotaTotalRefNoCaixa));
		this.form.push(this.comprobarValor(this.deudaTotalRefCaixa));
		this.form.push(this.comprobarValor(this.cuotaTotalRefCaixa));
		// 10/02/2023 - Se añaden los nuevos campos editables
		this.form.push(this.comprobarValor(this.deudaPrestamoRealCaixa));
		this.form.push(this.comprobarValor(this.cuotaPrestamoRealCaixa));
		this.form.push(this.comprobarValor(this.deudaPrestamoPersonalCaixa));
		this.form.push(this.comprobarValor(this.cuotaPrestamoPersonalCaixa));
		this.form.push(this.comprobarValor(this.deudaTarjetaCaixa));
		this.form.push(this.comprobarValor(this.cuotaTarjetaCaixa));
		this.form.push(this.comprobarValor(this.deudaOperacionesCaixa));
		this.form.push(this.comprobarValor(this.cuotaOperacionesCaixa));
		this.form.push(this.comprobarValor(this.deudaOtrosCaixa));
		this.form.push(this.comprobarValor(this.cuotaOtrosCaixa));
		this.form.push(this.comprobarValor(this.totalDeudaCargasCaixa));
		this.form.push(this.comprobarValor(this.totalCuotaCargasCaixa));
		this.form.push(this.comprobarValor(this.deudaPrestamosCaixa));
		this.form.push(this.comprobarValor(this.cuotaPrestamosCaixa));

		updateFormulario({idFormulario: this.recordId, data: this.form})
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
			}
		});      
	}
	comprobarValor(valor){
		valor = valor.toString();
		return valor;
	}
    // mandamos evento
    handleChnage() {
      // Creates the event with the data.
      const selectedEvent = new CustomEvent("cargasfinancieras", {
          	detail: {
				valorcargas:  this.importeTotalFinanciacion ,
				totalCuota :  this.cuotaTotalRefCaixa,
				importeCuotaActual : this.totalCuotaCargasCaixa         
          } 
      });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
  }

  setCalculadoraLink(){
    getCalculadorLink()
	.then(result => {
		this.calculadora = result;
	})
	.catch(error => {
		const evt = new ShowToastEvent({
		title: SIR_CMP_ErrorMessage,
		message: JSON.stringify(error),
		variant: 'error'
				});
				this.dispatchEvent(evt);
	});
  }
}