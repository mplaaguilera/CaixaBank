import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';


export default class Cc_Operativa_Oficina_ModalFinal extends LightningElement {
    @api mensajeMostrarModalToast;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state && currentPageReference.state.c__mensajeMostrarModalToast) {
            this.mensajeMostrarModalToast = currentPageReference.state.c__mensajeMostrarModalToast;
        }
    }

    cerrarModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}