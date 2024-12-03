import { LightningElement, api, track } from 'lwc';
 
export default class sire_lwc_HomeSolutionsWrapper extends LightningElement {

    @api hasHeader;
    @api headerIcon;
    @api headerTitle;
    @api headerSubtitle;
    @api listDatasets;
    updateTime;

    @track listCharts;

    connectedCallback() {
        let chartArray = [];
        for(let chart of this.listDatasets.split(',')) {
            chartArray.push(chart);
        }
        this.listCharts = chartArray;

        /* Modificacion 18/10 HSC */
        this.chartRetrieve();
        /*setInterval(function (){
            for(let chart of this.template.querySelectorAll('c-sir_lwc_-home-solutions')) {
                chart.retrieveCharts();
            }
            this.updateLasRefreshInfo();
        }.bind(this),1800000);*/
        /* FIN -- Modificacion 18/10 HSC */
    }

    renderedCallback() {
        if(this.listCharts.length  < 6) {
            this.template.querySelector('lightning-layout').className += ' slds-grid_align-space';
        }
    }

    /**
     * Executed when Aura parent component detects its tab is focused.
     * INICIO -- Modificacion 18/10 HSC */
    @api
    refreshCmp() {
        this.chartRetrieve();
        this.updateLastRefreshInfo();
    }
    
    chartRetrieve() {
        for(let chart of this.template.querySelectorAll('c-sire_lwc_-home-solutions')) {
            chart.retrieveCharts();            
        }
        this.updateTime = Date.now();
    }
    /* FIN -- Modificacion 18/10 HSC */

    updateLastRefreshInfo() {
        var now = Date.now();
        this.template.querySelector('c-sire_-home-header').refreshDate(now);
    }
}