import { LightningElement, track, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } 		 from 'lightning/platformShowToastEvent';
import chartjs 					 from '@salesforce/resourceUrl/AV_ChartJS';
//Labels
import AV_ChartJSNotLoaded 		 from '@salesforce/label/c.AV_ChartJSNotLoaded';
import AV_ErrorLoadingChartJS 	 from '@salesforce/label/c.AV_ErrorLoadingChartJS';
import AV_ChartJSNoData 		 from '@salesforce/label/c.AV_ChartJSNoData';
//Methods
import getData 					 from '@salesforce/apex/AV_ChartGetData.getData';

export default class av_Chart extends LightningElement {
	chart;
	config;
	scale;

	label = {
		AV_ChartJSNotLoaded,
		AV_ErrorLoadingChartJS,
		AV_ChartJSNoData
	};

	@api title;
	@api subTitle;
	@api chartTitle;
	@api displayTitle;
	@api titlePosition;
	@api legendPosition;
	@api displayLegend;
	@api icono;
	@api typeChart;
	@api listDatasets;
	@api listLabels;
	@api labelField;
	@api chartWidth;
	@api chartHeight;

	@track isChartJsInitialized;
	@track noDataAvailable;
	@track listLabels;
	@track listDtsets;

	chartNotLoaded = AV_ChartJSNotLoaded;

	renderedCallback() {
		this.scale = this.getScale(this.typeChart);
		getData({queryData: this.listLabels, queryLabel: this.labelField, dtSetQuery: this.listDatasets})
			.then(result => {
				console.log('result: ' + JSON.stringify(result));
				if(result.severity === 'ok'){
					if (this.isChartJsInitialized) {
						return;
					}
					this.labelsList = result.listLabels;
					this.listDtsets = result.dtsetModel;
					this.isChartJsInitialized = true;
					this.noDataAvailable = false;
					
					this.config = {
						type: this.typeChart,
						data: {
							labels: this.labelsList
						},
						options: {
							title: {
								display: this.displayTitle,
								position: this.titlePosition,
								text: this.chartTitle
							},
							legend: {
								display: this.displayLegend,
								position: this.legendPosition
							},
							responsive: true,
							scales: this.scale,
							tooltips: {
								enabled: true,
								mode: 'label',
								callbacks: {
									title: function(tooltipItems, data) {
										var idx = tooltipItems[0].index;
										return data.labels[idx];
									}
								}
							}
						} 
					};

					//Load the library of the chartJS and the data retrieve from the server
					Promise.all([
						loadScript(this, chartjs + '/Chart.min.js'),
						loadStyle(this,  chartjs + '/Chart.min.css')
					]).then(() => {
						const ctx = this.template.querySelector('canvas.chartStacked').getContext('2d');
						this.chart = new window.Chart(ctx, this.config);
						
						for(let key in this.listDtsets){
							this.chart.data.datasets.push({
								//type: this.typeChart,
								type: this.listDtsets[key].type,
								label: this.listDtsets[key].label,
								data: this.listDtsets[key].data,
								backgroundColor: this.listDtsets[key].backgroundColor,
								borderColor: this.listDtsets[key].borderColor ,
								borderWidth: 1,
								fill: this.listDtsets[key].type != 'line'
							});
						}
						this.chart.canvas.parentNode.style.height = this.chartHeight + '%';
						this.chart.canvas.parentNode.style.width = this.chartWidth   + '%';
						this.chart.update();
						console.log('Chart loaded correctly.');
						
					}).catch(error => {
						console.log('Display ShowToastEvent error: ' + error.message);
						this.dispatchEvent(
							new ShowToastEvent({
								title: AV_ErrorLoadingChartJS,
								message: error.message,
								variant: 'error'
							}),
						);
					});
				} 
				else if(result.severity === 'error'){
					this.noDataAvailable = true;
					console.log('Display ShowToastEvent error: ' + result.descError);
					new ShowToastEvent({
						title: AV_ErrorLoadingChartJS,
						message: result.descError,
						variant: result.severity
					})
				} 
				else {
					console.log('Option invalid: ' + JSON.stringify(result));
				}
		
			})
			.catch(error => {
				console.log('Display ShowToastEvent error: ' + JSON.stringify(error));
				new ShowToastEvent({
					title: AV_ErrorLoadingChartJS,
					message: JSON.stringify(error),
					variant: 'error'
				})
			});
	}

	getScale(typeChart){
		var scaleHorizontal = {
			xAxes: [{
				type: 'linear',
				ticks: {
					beginAtZero: true								
				},
				tooltips: {
					mode: 'index',
					intersect: false
				}
			}]
		};
		var scaleVertical = {
			xAxes: [{
				ticks: {
					callback: function(value, index, values) {
						/* var separator = '-';
						if (value.indexOf(separator)!=-1){
							return value.substring(0, value.indexOf(separator));
						}else{
							return value;
						} */
                        return value;
                    }
				}
			}],
			yAxes: [{
				type: 'linear',
				ticks: {
					beginAtZero: true
				}
			}]			
		};
		
		if(typeChart === 'bar'){
			this.scale = scaleVertical;
		} else {
			this.scale = scaleHorizontal;
		}
		return this.scale;
	}

}