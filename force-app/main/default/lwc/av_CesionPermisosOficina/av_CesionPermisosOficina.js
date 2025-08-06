import { LightningElement,track ,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


// import lookupSearchEmployees    from '@salesforce/apex/AV_CesionPermisos_Controller.searchEmployees';
// import givePermisos             from '@salesforce/apex/AV_CesionPermisos_Controller.givePermission';
import retrievePermisos         from '@salesforce/apex/AV_CesionPermisos_Controller.checkForPermissionGivenToUsers';
import retrivePermisosGiven     from '@salesforce/apex/AV_CesionPermisos_Controller.checkForPermissionGivenToMe';
import borrarPermiso            from '@salesforce/apex/AV_CesionPermisos_Controller.deletePermiso';

import USER_ID from '@salesforce/user/Id';



export default class Av_CesionPermisosOficina extends NavigationMixin(LightningElement) {

    recordId;

    @track selectedEmployees = [];
    @track permisosDisponibles;
    @track MAX_PERMISOS = 3;
    @track formedPer = true
    @track givedPermision;
    @track givenPermision;
    @track showSpinner = true;
    @track emptyGiven= false;
    @track emptyGived = false;

    connectedCallback(){            
        this.checkForPermissionsGivenToUsers();
        this.checkForPermissionsGivenToMe();
    }

    @api
    switchSpinner(){ this.showSpinner = !this.showSpinner}
   
	updatePermiso(event){
        this.dispatchEvent(new CustomEvent('update',{
            detail:{
                info:event.target.name
            }
        }))
    }
    handleSelectionOffice(event){
        var targetId = event.target.dataset.id;
        const input =this.template.querySelector(`[data-id="${targetId}"]`); 
        const selection = input.getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
                    if (targetId === 'clookup1' || targetId === 'clookup2'){
                        this.getMultiselectionDiv({'label':sel.title,'value':sel.id})
                    }else if (targetId === 'clookup3' || targetId === 'clookup4'){
                        this.getMultiselectionDivUpdt({'label':sel.title,'value':sel.id})
                    }
				}
                input.handleClearSelection();
			} 
    }

    sendPermiso(){
        this.dispatchEvent(new CustomEvent('nuevopermiso'))
    }

    deletePermiso(event){
        this.switchSpinner();
        borrarPermiso({recordId:event.target.name})
        .then( res => {
            if(res === 'OK'){
                this.checkForPermissionsGivenToUsers();
                  this.dispatchEvent(new ShowToastEvent({
                    title: 'Permiso eliminado',
                    message: 'El permiso ya no es válido',
                    variant: 'success'          
                }));
            }else{
                  this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Ha habido algún fallo eliminando el permiso.',
                    variant: 'error'
                    
                }));
            }
        });

    }

    formatDate(fecha){
        var fdt = new Date(Date.parse(fecha)); //fdt stand for fechaDateTime
        return fdt.getDate() + '/' + (fdt.getMonth()+1) + '/' + fdt.getFullYear();
         
    }

@api
checkForPermissionsGivenToUsers(){
    retrievePermisos({userId:USER_ID}).then(res=>{
        this.emptyGived = (res.length === 0);
        if (res!=null){
            this.permisosDisponibles = this.MAX_PERMISOS-res.length
            this.dispatchEvent (new CustomEvent('numeropermisos',{
                detail:{
                    numPerm:this.permisosDisponibles
                }
            }))
            res.forEach(perm => {
                perm['AV_InicioPermisoFormat__c'] = this.formatDate(perm['AV_InicioPermiso__c']);
                perm['AV_FinalPermisoFormat__c'] = this.formatDate(perm['AV_FinalPermiso__c']);
                if (perm['AV_ContactoUsuarioCedido__c'] != null) {
                    perm['link'] = true;
                } else {
                    perm['link'] = false;
                }
            })
            this.givedPermision = res;
            this.switchSpinner();
        }
    })
}
getContactRecord(event){
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            objectApiName:'Contact',
            recordId:event.target.name,
            actionName:'view'
        }

    })
}

getOfficeRecord(event){
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            objectApiName:'Account',
            recordId:event.target.name,
            actionName:'view'
        }

    })
}

@api
checkForPermissionsGivenToMe(){
    retrivePermisosGiven({userId:USER_ID}).then(res => {
        res.forEach(perm => {
            perm['AV_InicioPermisoFormat__c'] = this.formatDate(perm['AV_InicioPermiso__c']);
            perm['AV_FinalPermisoFormat__c'] = this.formatDate(perm['AV_FinalPermiso__c']);
            if (perm['AV_GestorPermiso__c'] != null) {
                perm['link'] = true;
            } else {
                perm['link'] = false;
            }
        })
        this.givenPermision = res;
        this.emptyGiven = this.givenPermision.length === 0;
    })
}
}