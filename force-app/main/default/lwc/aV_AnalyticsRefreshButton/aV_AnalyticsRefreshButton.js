import { LightningElement, api } from 'lwc';

export default class BotonRefresh extends LightningElement {

    @api refresh;
    @api getState;
    @api setState;
    @api originalPage;

    formattedDate;
    formattedTime;

    renderedCallback() {
        this.formattedDate = this.getFormattedDate();
        this.formattedTime = this.getFormattedTime();

        
    }

    onClickBoton() {
        this.formattedDate = this.getFormattedDate();
        this.formattedTime = this.getFormattedTime();
        this.navigateOriginalPage();
        this.refresh();
    }

    getFormattedTime() {
        const now = new Date();
        const options = {
            hour: 'numeric',
            minute: 'numeric'
            //, second: 'numeric' 
        };
        return now.toLocaleTimeString('es-ES', options);
    }
    

    getFormattedDate() {
        const now = new Date();
        const options = {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric'
        };
        return now.toLocaleDateString('es-ES', options);
    }

    navigateOriginalPage() {
        this.setState({ ...this.getState(), pageId: this.originalPage });
        return;
      }
}