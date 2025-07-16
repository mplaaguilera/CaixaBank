import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

export default class Cc_Operativa_Oficina_Popup extends LightningElement {

@api recordId;
@api oportunidadCreadaAPI;
@api derivar;
@api otpDerivar = null;

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

  modalTeclaPulsada(event) {
      if (event.keyCode === 27) { //ESC
          this.cerrarModal();
      }
  }

  cerrarModal() {
      this.template.querySelector('.backdrop')?.classList.remove('slds-backdrop--open');
      this.template.querySelector('.modal')?.classList.remove('slds-fade-in-open');
      this.dispatchEvent(new CloseActionScreenEvent());
      const customEvent = new CustomEvent('modalcerrado', {
          detail: event.detail
      });
      this.dispatchEvent(customEvent);
  }

  abrirModal() {
      if (this.documentacionCaseExtension) {
          this.toast('error', 'No se puede derivar este caso', this.toastDocumentacionCasoYaCreado);
          this.cerrarModal();
      } else {
          this.template.querySelector('.modal')?.classList.add('slds-fade-in-open');
          this.template.querySelector('.backdrop')?.classList.add('slds-backdrop--open');
      }
  }
}