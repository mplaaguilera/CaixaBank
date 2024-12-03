import { LightningElement, api } from 'lwc';
 
export default class Av_CustomPath extends LightningElement {
    @api allStages;
    @api currentStage;
    @api editMode;

    renderedCallback(){
        this.updateCurrentStage(this.currentStage);
    }
    
    @api
    updateCurrentStage(stageName) {
        /* Get all the li elements */
        let liElements = this.template.querySelectorAll('li');
        /* Variable to store the index of active stage on path */
        let activeIndex;
        /* Get the index of the active stage on path */
        for (let i = 0; i < liElements.length; i++) {
            if (liElements[i].dataset.identifier === 'pathstage') {
                if (liElements[i].dataset.key === stageName) {
                    /* Index next to the last completed stage will mark the active stage */
                    activeIndex = i;
                    break;
                }
            }
        }

        if (activeIndex != null) {
            /* Mark all the stages prior to active index as completed */
            for (let i = 0; i < activeIndex; i++) {
                if (liElements[i].dataset.identifier === 'pathstage') {
                    //liElements[i].className = 'slds-path__item slds-is-complete';
                    liElements[i].className = 'slds-path__item slds-is-active';
                    this.template.querySelector(`[data-key="${liElements[i].dataset.key}"] > a > span`).style.color = '#FFFFFF';
                }   
            }

            for (let i = activeIndex + 1; i < liElements.length; i++) {
                if (liElements[i].dataset.identifier === 'pathstage' && this.editMode) {
                    this.template.querySelector(`[data-key="${liElements[i].dataset.key}"] > a > span`).style.color = '#006DCC';
                }
            }

            /* Update the class for active stage */
            if (activeIndex < liElements.length) {
                liElements[activeIndex].className = 'slds-path__item slds-is-current slds-is-active';
                this.template.querySelector(`[data-key="${liElements[activeIndex].dataset.key}"] > a > span`).style.color = '#FFFFFF';
            }
        }
    }

    changeStage(event) {
        if(this.editMode) {
            this.resetSelection();
            this.updateCurrentStage(event.currentTarget.name);
            const searchEvent = new CustomEvent('changenew', {
                detail: {
                    newValue: event.currentTarget.name
                }
            });
            this.dispatchEvent(searchEvent);
        }
    }

    @api
    resetSelection() {
        let liElements = this.template.querySelectorAll('li');
        for (let i = 0; i < liElements.length; i++) {
            liElements[i].className = 'slds-path__item slds-is-incomplete';
        }
    }
}