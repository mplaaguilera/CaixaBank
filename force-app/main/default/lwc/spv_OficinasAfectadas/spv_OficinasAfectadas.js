import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';

//Llamadas Apex
import getOficinasAfectadas from '@salesforce/apex/SPV_LCMP_OficinasAfectadas.getOficinasAfectadas';
import getOficinasActualizadas from '@salesforce/apex/SPV_LCMP_OficinasAfectadas.getOficinasActualizadas';
import eliminarOficinaAfectada from '@salesforce/apex/SPV_LCMP_OficinasAfectadas.eliminarOficinaAfectada';

//Campos Account
import NAME_FIELD from '@salesforce/schema/Account.Name';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import PERSONEMAIL_FIELD from '@salesforce/schema/Account.CC_Email__c';
import BILLINGADDRESS_FIELD from '@salesforce/schema/Account.BillingAddress';
import OFICINAPADRE_FIELD from '@salesforce/schema/Account.ParentId';
import MANAGER_FIELD from '@salesforce/schema/Account.AV_EAPGestor__c';


const FIELDS = ['Case.OwnerId', 'Case.Status',  'Case.RecordType.DeveloperName', 'Case.SEG_Subestado__c'];
const fields = [OWNERID_FIELD];


export default class Spv_OficinasAfectadas extends NavigationMixin(LightningElement) {


    //Campos Account
    nameField = NAME_FIELD;
    PhoneField = PHONE_FIELD;
    PersonEmailField = PERSONEMAIL_FIELD;
    BillingAddressField = BILLINGADDRESS_FIELD;
    OficinaPadreField = OFICINAPADRE_FIELD
    ManagerField = MANAGER_FIELD;


    @api recordId;
    @api objectApiName;

    @track oficinasAfectadas = [];
    @track oficinasNoVacias = [];
    @track mostrar = true;
    @track idAccountView;
    @track spinnerLoading = false;
    @track idPopUp = '';
    @track posicionCursor;
    @track mostrarPopUp = false;


    get ownerId() {
        return getFieldValue(this.case.data, OWNERID_FIELD);
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    oficinasWired;         //Aquí se almacenan las oficinas afectadas del caso que recoge al hacer el wire 

    @wire(getOficinasAfectadas, { casoId: '$recordId'})
    getOficinasAfectadas(result){
        this.oficinasWired = result;
        if(result.data){
            this.oficinasAfectadas = result.data.listOficinasActual;
        }
        
        /*if(data){
            console.log('result ' + JSON.stringify(data));
            this._wiredResult = data;
            data.forEach(dato => {
                //Se reocrren los objetos intermedios relacionados, si alguno no tiene oficina afectada informada, se habrá borrado su registro a continuación y no se muestra
                if(JSON.stringify(dato.SPV_OficinaAfectada_Lookup__c) != "" && JSON.stringify(dato.SPV_OficinaAfectada_Lookup__c) != null && JSON.stringify(dato.SPV_OficinaAfectada_Lookup__c) != undefined){
                    this.oficinasNoVacias.push(dato);
                }
            });
            this.oficinasAfectadas = this.oficinasNoVacias;

        }*/
    } 



    //Al pulsar sobre una oficina afectada, te lleva a ver su registro
    verOficinaAfectadaClick(event){
        this.idAccountView = event.currentTarget.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "objectApiName": "Account",
                "recordId": this.idAccountView,
                "actionName": "view"
            }
        });
    }

    //Botón de eliminar
    handleEliminarOficinaAfectada(event){
        var idObjIntermedio = event.currentTarget.name;             //El name del botón de cada oficina afectada es el id del objeto intermedio que la relaciona con el caso
        this.spinnerLoading = true;
        eliminarOficinaAfectada({objetoIntermedioId: idObjIntermedio, casoId: this.recordId, ownerIdReclamacion: this.ownerId}).then(result=> {
            
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Oficina Afectada eliminada',
                    message: 'Se ha eliminado la oficina afectada.',
                    variant: 'success'
                }),);
            refreshApex(this.oficinasWired);            //Actualiza el componente para quitar el eliminado de la lista en la pantalla

        }).catch(error=>{
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Oficina Afectada NO eliminada',
                    message: error.body.message,
                    variant: 'error'
                }),);
        });
    }


    //Al pulsar sobre el botón de refrescar, trae de nuevo las oficinas afectadas asociadas a la reclamación
    handleRecargarOficinas(){
        //this.oficinasNoVacias = [];         //Se vacía la lista de oficinas vacías para cogerlas de nuevo actualizadas
        this.spinnerLoading = true;
        getOficinasActualizadas({'casoId': this.recordId}).then(result =>{
            this.spinnerLoading = false;
            if(result){
                this.oficinasAfectadas = result.listOficinasActual;
                refreshApex(this.oficinasWired);        //Actualiza el componente para que se muestren las nuevas oficinas afectadas actualizadas
                
            }
        }).catch(error =>{
           
            this.spinnerLoading = false;
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error'
                }),);
            });
    }

    //Al poner el ratón sobre el botón que es el nombre de la oficina afectada
    handleMouseOver(event){
        this.mostrarPopUp = true;
        if(this.idPopUp != event.target.dataset.targetId){
            this.idPopUp = event.target.dataset.targetId;       //idPopUp almacena el id del registro que se quiere msotrar en el popup, que se corersponde con el targetId
            
        }
                //Se almacena en pY y PX la posición en la que se quiere el popup
                var pY = event.clientY - 165;     //135  o 20 si se pone la flecha arriba-derecha
                //var pX = event.clientX + 100;
                var pX = event.clientX - 450;           //ESTE SI EL COMPONENTE SE PONE EN LA COLUMNA DE LA DERECHA
                
                //En el String se indica la posición que tendrá el popover, se le aplica como style en el html
                this.posicionCursor = "top: "+pY+"px; left:"+pX+"px; position: fixed; height:350px; width:400px;";

    }

    //Al quitar el ratón de encima del botón
    handleMouseLeave(event) {
        this.mostrarPopUp = false;
        this.idPopUp = '';
    }


    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }


}