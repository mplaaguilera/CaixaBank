import { LightningElement,api,track,wire } from 'lwc';

import { ShowToastEvent }  from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

import  actualizarPermiso  from '@salesforce/apex/AV_CesionPermisos_Controller.actualizarPermiso';

export default class Av_updatePermiso extends NavigationMixin(LightningElement) {

    @api permiso;
    @track fechaInicio;
    @track fechaFinal;
    @track formedPer= true;
    @track showSpinner = false;
    @track formatedOffice = '';
    @api recordId;
    MAX_PERMISOS = 3;
    ONEUNIXYEAR = 365*24*60*60*1000;
    ONEUNIXDAY = 24*60*60*1000;
    currentPageReference = null;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          this.recordId = currentPageReference.attributes.recordId || null;
       }
    }

connectedCallback(){
    this.formatedOffice = (this.permiso.AV_UsuarioCedido__r.AV_NumeroOficinaEmpresa__c).substring(4)
    
}
getContactRecord(){
    let recordId = this.permiso.AV_ContactoUsuarioCedido__c 
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            objectApiName:'Contact',
            recordId:recordId,
            actionName:'view'
        },

    })
}

exitModal(){
    this.dispatchEvent(new CustomEvent('refresh'))
    window.location.href = '#';
    
}

cancelModal(){
    window.location.href = '#';

}
handleDates(e){
    let startInput = this.template.querySelector('[data-id="startDate"]').value;
    let finalInput = this.template.querySelector('[data-id="endDate"]').value;
    let type;
    if(e.target.name == 'startDateInterval'){
        type = 'inicio';
    }else if(e.target.name == 'endDateInterval'){
        type = 'cese';
    }
    this.fechaInicio = ( startInput != ''  && startInput !== null) ? this.formatDate(startInput) : null;
    this.fechaFinal = ( finalInput != '' && finalInput !== null) ? this.formatDate(finalInput) : null;
    let isPostToday = (new Date(e.target.value).getTime()) >= (new Date().getTime()-this.ONEUNIXDAY)
    if(isPostToday){
        if(startInput != '' && finalInput != ''){
            let msegundosUnix =  (new Date(finalInput).getTime()) - (new Date(startInput).getTime()); //Diferencia de milisegundos entre las dos fechas
            let validarFecha = (msegundosUnix >= 0);
            if( !(validarFecha && (msegundosUnix <= this.ONEUNIXYEAR) && isPostToday)){
                this.displayDateErrors(validarFecha,'periodo',type); 
            }
        }
    }else{
        if(typeof e.target.value  !== 'object'){
            this.displayDateErrors(isPostToday,'yesterday',type)
        }
    }
    this.enableCeder();
}
enableCeder(){        
     this.formedPer =  (this.fechaFinal == null || this.fechaInicio == null  );
}
formatDate(fecha){
    let fdt = new Date(Date.parse(fecha)); //fdt stand for fechaDateTime
    return fdt.getDate() + '/' + (fdt.getMonth()+1) + '/' + fdt.getFullYear();
     
}
displayDateErrors(condition,type,endOrStart){
    let label ;//= (endOrStart === 'inicio')?'cese':'inicio';
    if(endOrStart === 'inicio'){
        label = 'cese;'
        this.fechaInicio = null;
    }else{
        label = 'inicio';
        this.fechaFinal = null;

    }
    let title = ' ';
    let msg = '';
    if(type === 'periodo' ){
        msg= (!condition) 
        ?'La fecha de '+endOrStart+' no puede ser posterior a la fecha de '+ label
        :'Los permisos no se pueden otorgar por más de un año';
        title = (!condition) 
        ? 'Fechas incorrectas'
        : 'Periodo invalido';
    }else if(type === 'yesterday'){
        title = 'Fechas incorrecta';
        msg = 'Introduce una fecha posterior a la actual'
    }
    this.dispatchEvent(new ShowToastEvent({
        title: title,
        message: msg,
        variant: 'error',
    }));
    
}
switchSpinner(){
    this.showSpinner = !this.showSpinner;
}
executeUpdt(event){
    let permisoId = this.permiso.Id;
    this.switchSpinner();
    let startToSend = (this.fechaInicio != null)?this.fechaInicio:this.formatDate(this.initPermToUpdtInicio);
    let endToSend = (this.fechaFinal != null)?this.fechaFinal:this.formatDate(this.initPermToUpdtFinal);
    let jsonPermisos = {
        "Id":permisoId,
        "Inicio":startToSend,
        "Final":endToSend
    }

    
    actualizarPermiso({permisos:jsonPermisos})
    .then(res => {
        if(res === 'OK'){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Permiso actualizado',
                message: '',
                variant: 'success',          
            }));
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'No se ha podido actualizar el permiso ',
                message: 'Contacta con tu administrador',
                variant: 'error',          
            }));
        }
        this.switchSpinner();
        this.exitModal();
    })
}
}