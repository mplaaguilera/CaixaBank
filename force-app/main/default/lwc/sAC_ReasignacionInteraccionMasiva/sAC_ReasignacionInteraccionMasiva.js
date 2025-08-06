import { LightningElement, api, track} from 'lwc';
import getUsuarios from '@salesforce/apex/SAC_ReasignacionInteraccionMasiva_LWC_VF.getUsuarios';
import setNewOwnerToEscalate from '@salesforce/apex/SAC_ReasignacionInteraccionMasiva_LWC_VF.setNewOwnerToEscalate';
import { NavigationMixin } from 'lightning/navigation';
import validationComponente from '@salesforce/apex/SAC_ReasignacionInteraccionMasiva_LWC_VF.validationComponente';
export default class SAC_ReasignacionInteraccionMasiva extends NavigationMixin(LightningElement) {
    @track COLUMNS = [
        {label: 'CaseNumber', fieldName: 'SAC_CasoEscalado__c', type: 'text', editable: false}
    ]

    @track cuerpo;
    @track value = '';
    @track valores = [];
    @track isError;
    @track success;
    @api registros;
    @track stopValidateCall;
    @track stopOptionsCall;

    get validate(){
        if(!this.stopValidateCall){
            this.stopValidateCall = true;
            validationComponente({lstIdInteraccionSelected: this.registros})
            .then(resultado => {
                if(resultado == 'RecordType'){
                    this.cuerpo = 'Se han seleccionado registros del objeto interacción de distinto tipo';
                    this.isError = true;
                }else if(resultado == 'Grupo'){
                    this.cuerpo = 'Se han seleccionado registros con diferentes grupos, solo se pueden seleccionar registros de un mismo grupo';
                    this.isError = true;
                }else if(resultado == 'Escalado'){
                    this.cuerpo = 'No se ha seleccionado ningún registro';
                    this.isError = true;
                }else if(resultado == 'NoPropietario'){
                    this.cuerpo = 'La asignación solo está disponible para consultas internas en las que el grupo tenga parametrizado el campo Propietario.';
                    this.isError = true;
                }else if(resultado == 'NoAdminGrupo'){
                    this.cuerpo = 'Debe ser supervisor o administrador del grupo para poder asignar propietario a los registros';
                    this.isError = true;
                }else if(resultado == 'No'){
                    this.isError = false;
                }
                const isAvaible = this.isError === false ? true : false;
                return isAvaible;
            })
            .catch(error => {
                this.cuerpo = error.message;
            })
        }
        
    }

    get userOptions() {
        if(this.stopOptionsCall != true ){
            this.stopOptionsCall = true;
            getUsuarios({lstIdInteraccionSelected: this.registros})
            .then(resultado => {
                resultado.forEach(item => this.valores = [...this.valores ,{label: item.CC_Nombre__c + ' ' + item.CC_Apellidos__c , value: item.CC_Usuario__c }]);             
                return this.valores;
            })
            .catch(error => {
                this.cuerpo = error.message;
            })
        }

        
    }

    changeHandler(event) {
        this.value = event.target.value;
    }
    
    handleGuardar(){
        setNewOwnerToEscalate({lstIdInteraccionSelected: this.registros, userId: this.value})
        .then((resultado) => {
            this.cuerpo = 'Se han actualizado todos los registros y cambiado de propietario';
            this.success = true;
            setTimeout(() => {
                this.success = false;
                window.history.back();
            }, 5000)
        })
        .catch((error) => {
            const mensaje = error;
        })
    }

    handleCancelar(){
        window.history.back();
    }
}