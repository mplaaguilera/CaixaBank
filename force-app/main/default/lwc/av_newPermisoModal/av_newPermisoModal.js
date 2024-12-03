import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import givePermisos             from '@salesforce/apex/AV_CesionPermisos_Controller.givePermission';
import lookupSearchEmployees    from '@salesforce/apex/AV_CesionPermisos_Controller.searchEmployees';



import USER_ID from '@salesforce/user/Id';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';


export default class Av_newPermisoModal extends LightningElement{

    @track employeesDiv = true;
    @api record;
    @track empleOfi;
    @track fechaInicio;
    @track fechaFinal;
    @track selectedEmployees = [];
    @track formedPer= true;
    @track showLabel = false;
    @track MAX_PERMISOS = 3;
    @track ONEUNIXYEAR = 365*24*60*60*1000;
    @track ONEUNIXDAY = 24*60*60*1000;
    @track multiSelectionE=0;
    @api permisosDisponibles;
    @track permisosDispoLabel ;
    @track showSpinner = false;
    
    connectedCallback(){
        this.permisosDispoLabel = 'Permisos disponibles: '+this.permisosDisponibles;

    }

    @wire(getRecord, {recordId:USER_ID,fields:[OFICINA]})
    wiredUser({error,data}){
        if(data){
            this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value;
        }else if(error){
            console.log(error);
        }
    }

    switchSpinner(){ this.showSpinner = !this.showSpinner}
    handleSearchOffice(event){
        lookupSearchEmployees(event.detail)
        .then((results) => {
                let length = results.length * 3;
                this.template.querySelector('[data-id="lookup1"]').style.paddingBottom = length+'rem' 
                this.template.querySelector('[data-id="lookup1"] > c-av_-lookup').setSearchResults(results);
        })
        .catch((error) => {
            this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });

    }
    handleSelectionOffice(event){
        let targetId = event.target.dataset.id;
        this.template.querySelector('[data-id="lookup1"]').style.paddingBottom = 0;
        const input =this.template.querySelector(`[data-id="${targetId}"]`); 
        const selection = input.getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
                        this.getMultiselectionDiv({'label':sel.title,'value':sel.id})
				}
                input.handleClearSelection();
			} 
    }
    getMultiselectionDiv(employee){
        if(this.selectedEmployees.length < this.permisosDisponibles){
            this.multiSelectionE++;
            let insert = true;
            if(this.selectedEmployees.length > 0 ){
                for (let i = 0; i < this.selectedEmployees.length; i++) {
                    if (this.selectedEmployees[i]['label']===employee.label) {
                        insert = false;
                        break;
                    }				
                }
            }			
            if (insert) {
                this.selectedEmployees.push({label:employee.label,id:employee.value,bucleId:this.multiSelectionE});	
            }
            this.visibilityVars();  
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Máximo de permisos',
                message: 'Elimina algún permiso o edita alguno ya existente',
                variant: 'error',
            }));
        }
        this.enableCeder();
    }
    unSelectEmployee(cmp){
		for(let i=0;i<this.selectedEmployees.length;i++){
            if(this.selectedEmployees[i].id === cmp.target.name){
				this.selectedEmployees.splice(i,1);
				// break;
			}
		}
        this.enableCeder();
        this.visibilityVars(); 
		cmp.target.remove();
}

    swapScreen(){
        this.dispatchEvent( new CustomEvent('cerrar'));

    }
    visibilityVars(){
        this.employeesDiv = this.selectedEmployees.length == 0;
        this.showLabel = !this.employeesDiv;
    }
    
    cederPermisos(){
        this.switchSpinner();
        let jsonPermisos = {
            "Cedente":USER_ID,
            "Oficinas":this.empleOfi,
            "Inicio":this.fechaInicio,
            "Final":this.fechaFinal
        }
        let selEmpIds=[];
        this.selectedEmployees.forEach(emp => {
            selEmpIds.push(emp.id);
        })
        givePermisos({permisoInfo:jsonPermisos , destinatario:selEmpIds})
        .then(res=>{
            if(res.includes('OK')){
                // this.checkForPermissionsGived();
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Permiso concedido',
                    message: 'Los usuarios indicados podrán acceder a tus oficinas',
                    variant: 'Success'
                    
                }));
            }else if(res.includes('NOKCNT')){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Permiso no concedido',
                    message: 'El usuario indicado no tiene contacto asociado',
                    variant: 'Error'
                    
                }));
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Permiso no concedido',
                    message: 'Consulta con el adminsitrador',
                    variant: 'Error'
                    
                }));
            }
            this.switchSpinner();
            this.exitModal();
        })
    }

    exitModal(){
        this.dispatchEvent(new CustomEvent('exitmodal'));
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
         this.formedPer =  (this.fechaFinal == null || this.fechaInicio == null || this.selectedEmployees.length === 0 );
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
        variant: 'error'
    }));
    
}
notifyUser(title, message, variant) {
    if (this.notifyViaAlerts) {
        alert(`${title}\n${message}`);
    } else {
        // Notify via toast
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
    }
  }
}