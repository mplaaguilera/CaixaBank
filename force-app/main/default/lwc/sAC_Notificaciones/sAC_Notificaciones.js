import { LightningElement, api} from 'lwc';
import desmarcarNotificacion from '@salesforce/apex/SAC_LCMP_DesmarcarNotificacion.desmarcarNotificacion';
import userId from '@salesforce/user/Id';
import { updateRecord } from 'lightning/uiRecordApi';

export default class SAC_Notificaciones extends LightningElement {
    @api recordId;
    renderedCallback(){     
        desmarcarNotificacion({ idUsuario: userId, idCasoDisparador: this.recordId });
    }
}