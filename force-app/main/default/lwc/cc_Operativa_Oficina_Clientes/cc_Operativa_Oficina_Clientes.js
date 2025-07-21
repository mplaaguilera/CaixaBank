import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";


export default class Cc_Operativa_Oficina_Clientes extends LightningElement {
    @api recordId;
    @api oportunidadCreadaAPI;
    @api otpDerivar = null;;
    derivar = true;

    handleModalOficinaCerrado(event) {
        this.template.querySelector('.backdrop')?.classList.remove('slds-backdrop--open');
        this.template.querySelector('.modal')?.classList.remove('slds-fade-in-open');
        this.dispatchEvent(new CloseActionScreenEvent());
        // Reemitir el evento hacia el componente Aura
        const customEvent = new CustomEvent('modalcerrado', {
            detail: event.detail
        });
        this.dispatchEvent(customEvent);
    }
    realizarTrasladoDesdeDerivar(event) {
        // Reemitir el evento hacia el componente Aura
        const customEvent = new CustomEvent('realizartrasladocolaborador', {
            detail: event.detail
        });
        this.dispatchEvent(customEvent);
    }
    abrirModalTrasladarColaborador(event) {
        // Reemitir el evento hacia el componente Aura
        const customEvent = new CustomEvent('realizarremitido', {
            detail: event.detail
        });
        this.dispatchEvent(customEvent);
    }
    abrirModalSolicitarInfo(event) {
        // Reemitir el evento hacia el componente Aura
        const customEvent = new CustomEvent('solicitarinfo', {
            detail: event.detail
        });
        this.dispatchEvent(customEvent);
    }
    refreshTab(event) {
        // Reemitir el evento hacia el componente Aura
        const customEvent = new CustomEvent('refrescartab', {
            detail: event.detail
        });
        this.dispatchEvent(customEvent);
    }
    desactivarSpinnerDerivar(event) {
        // Reemitir el evento hacia el componente Aura
        const customEvent = new CustomEvent('desactivarspinner', {
            detail: event.detail
        });
        this.dispatchEvent(customEvent);
    }

    // onmodalcerrado="{!c.handleModalOficinaCerrado}" 
    // onrealizartrasladocolaborador="{!c.realizarTrasladoDesdeDerivar}" 
    // onrealizarremitido="{!c.abrirModalTrasladarColaborador}" 
    // onsolicitarinfo="{!c.abrirModalSolicitarInfo}" 
    // onrefrescartab="{!c.refreshTab}" 
    // ondesactivarspinner="{!c.desactivarSpinnerDerivar}"-->
       
}