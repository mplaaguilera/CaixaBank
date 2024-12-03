import { LightningElement, api, track, wire } from 'lwc';

export default class cibe_MetricChartsWrapper extends LightningElement {

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
		console.log(' thischarts');
		console.log(this.listCharts);
		this.chartRetrieve();        
	}

	renderedCallback() {
		if(this.listCharts.length < 6) {
			this.template.querySelector('lightning-layout').className += ' slds-grid_align-space';
		}
	}
	
	/**
	 * Executed when Aura parent component detects its tab is focused.
	 */
	@api
	refreshCmp() {
		this.chartRetrieve();
		this.updateLasRefreshInfo();
	}

	chartRetrieve() {
		for(let chart of this.template.querySelectorAll('c-cibe_-metric-chart')) {
			chart.refreshChart();
		}
		//this.updateLasRefreshInfo();
		this.updateTime = Date.now();
	}

	updateLasRefreshInfo() {
		var now = Date.now();
		this.template.querySelector('c-av_-home-header').refreshDate(now);
	}
}