import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getData from '@salesforce/apex/AV_MetricChart_Controller.getData';

import USER_ID from '@salesforce/user/Id';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import { getRecord } from 'lightning/uiRecordApi';

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/AV_ChartJsV391';

import BPRPS from '@salesforce/customPermission/AV_PrivateBanking';


const PRIOR_MANAGE_CLIENTS = 'AV_PriorManageClients';
const WARNINGS_TO_MANAGE = 'AV_WarningsToManage';
const PENDING_CONVERSATION = 'AV_PendingConversation';
const TASK_FOR_TODAY = 'AV_TaskForToday';
const TODAYS_APPOINTMENT = 'AV_TodaysAppointments';
const PRIOR_MANAGE_CLIENTS_SD = 'AV_PriorManageClientsSensibleData';
const PRIOR_MANAGE_CLIENTS_SD_BP = 'AV_PriorManageClientsSensibleDataBancaPr';
const WARNINGS_TO_MANAGE_SD = 'AV_WarningsToManageSensibleData';
const WARNINGS_TO_MANAGE_SD_BP = 'AV_WarningsToManageSensibleDataBancaPriv';
const PENDING_CONVERSATION_SD = 'AV_PendingConversationBancaPrivada';
const TODAYS_APPOINTMENT_SD = 'AV_TodaysAppointmentsBancaPrivada';
const PRIORIZADOR = 'Priorizador';
const CLIENT_EXPERIENCE = 'Experiencia de Cliente';
const CLIENT__EXPERIENCE = 'Experiencia Cliente';
const INICIATIVA_GESTOR = 'Iniciativa gestor';
const ALERTAS_COMERCIALES = 'Alertas Comerciales';
const ONBOARDING_INTOUCH = 'Onboarding Intouch';
const MURO = 'Muro';
const STOPGO = 'Stop&Go';
const LLAMADAS = 'Llamadas';
const ORIGEN_CLIENTE = 'Origen Cliente';
const ORIGEN_GESTOR = 'Origen Gestor';
const TAREAS = 'Tareas';
const INICIATIVA_GESTOR_A = 'Iniciativa Gestor/a';
const ENTRADA = "Entrada','002";
const SALIDA = "Salida','001";
const AVISOS = 'Avisos';

export default class Av_MetricChart extends NavigationMixin(LightningElement) {

	@api metadataChartName;

	@track title;
	@track reportId;
	@track numRecords;
	@track loading = false;

	showDonutCharts;
	chart;
	config;
	dataset;
	coloursList;
	office;
	offficeShort;
	filterValue;
	showLegendClients;
	showLegendConversations;
	showLegendAppointments;
	showLegendTasks;
	showLegendWarnings;
	showNumbers;
	error;
	wiredData;
	showTableGroupedByCliente;

	@track filtersValuesMap = new Map([
		[PRIORIZADOR, PRIORIZADOR],
		[CLIENT_EXPERIENCE, CLIENT__EXPERIENCE],
		[INICIATIVA_GESTOR, INICIATIVA_GESTOR_A],
		[ALERTAS_COMERCIALES, ALERTAS_COMERCIALES],
		[LLAMADAS, LLAMADAS],
		[MURO, MURO],
		[STOPGO, STOPGO],
		[ORIGEN_CLIENTE, SALIDA],
		[ORIGEN_GESTOR, ENTRADA],
		[ONBOARDING_INTOUCH, ONBOARDING_INTOUCH]
	]);
	connectedCallback(){
	}

	@wire(getRecord, { recordId: USER_ID, fields: [OFICINA] })
	wiredUser(wireResult) {
		// const { data, error } = wireResult;
		let data = wireResult.data;
		let error = wireResult.error;
		if (data) {
			this.office = data.fields.AV_NumeroOficinaEmpresa__c.value;
			if (this.office != null) {
				this.offficeShort = data.fields.AV_NumeroOficinaEmpresa__c.value.substring(4);
			}
		} else if (error) {
			console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
		}
	}


	@wire(getData, { metadataChart: '$metadataChartName' })
	retrieveCharts(wireResult) {
		// const { data, error } = wireResult;
		let data = wireResult.data;
		let error = wireResult.error;
		this.wiredData = wireResult;
		if (data) {
			this.showButton = data.hasLinkPermission;
			if (this.metadataChartName == PRIOR_MANAGE_CLIENTS
				|| this.metadataChartName == PENDING_CONVERSATION
				|| this.metadataChartName == WARNINGS_TO_MANAGE
				|| this.metadataChartName == TASK_FOR_TODAY
				|| this.metadataChartName == TODAYS_APPOINTMENT
				|| this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD
				|| this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD_BP
				|| this.metadataChartName == WARNINGS_TO_MANAGE_SD
				|| this.metadataChartName == WARNINGS_TO_MANAGE_SD_BP
				|| this.metadataChartName == PENDING_CONVERSATION_SD
				|| this.metadataChartName == TODAYS_APPOINTMENT_SD
				) {
				this.showDonutCharts = true;
				this.loading = true;
				if (this.metadataChartName == PRIOR_MANAGE_CLIENTS) {
					this.showLegendClients = true;
				} else if (this.metadataChartName == PENDING_CONVERSATION || this.metadataChartName == PENDING_CONVERSATION_SD) {
					this.showLegendConversations = true;
				} else if (this.metadataChartName == TODAYS_APPOINTMENT ||this.metadataChartName == TODAYS_APPOINTMENT_SD) {
					this.showLegendAppointments = true;
				} else if (this.metadataChartName == TASK_FOR_TODAY ) {
					this.showLegendTasks = true;
				} else if (this.metadataChartName == WARNINGS_TO_MANAGE || this.metadataChartName == WARNINGS_TO_MANAGE_SD || this.metadataChartName == WARNINGS_TO_MANAGE_SD_BP) {
					this.showLegendWarnings = true;

				} else if (this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD || this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD_BP) {
					this.showLegendClients = true;
				}
				this.numRecords = data.numRecords;
				if (this.numRecords > 0) {
					this.showNumbers = false;
				} else {
					this.showNumbers = true;
				}
				this.title = data.title;
				if (data.reportId !== undefined) {
					this.reportId = data.reportId;
				}
				if (data.numRecordsList !== undefined && (this.metadataChartName == PRIOR_MANAGE_CLIENTS || 
					this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD || this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD_BP ||
					this.metadataChartName == TODAYS_APPOINTMENT || this.metadataChartName == PENDING_CONVERSATION ||
					this.metadataChartName == TODAYS_APPOINTMENT_SD || this.metadataChartName == PENDING_CONVERSATION_SD ))		
				 {
					this.dataset = data.numRecordsList;
				} else {
					let datasetList = [];
					datasetList.push(this.numRecords);
					this.dataset = datasetList;
				}
				this.getColours();
				var counter = {
					id: 'counter',
					afterDraw(chart, arg, options) {
						var { ctx, chartArea: { top, right, bottom, left, width, height } } = chart;
						var fontSize = (height / 50).toFixed(2);
						ctx.font = fontSize + "em sans-serif";
						ctx.textBaseline = "middle";
						ctx.textAlign = "center";
						ctx.fillStyle = 'rgb(0,151,212)';
						ctx.fillText(options.textNumber, width / 2, height / 2);
						ctx.save();
					}
				};

				this.config = {
					type: 'doughnut',
					data: {
						datasets: [{
							backgroundColor: this.coloursList,
							data: this.dataset
						}],
						labels: this.getLabels(this.metadataChartName)
					},
					options: {
						onClick: (event, elements, chart) => {
							if (elements[0] != null) {
								this.filterValue = this.getLabels(this.metadataChartName)[elements[0].index];
								this.navigateToReportWithFilter(this.metadataChartName);
							} else {
								this.navigateToReportWithoutFilter();
							}
						},
						cutout: 30,
						title: {
							text: this.title
						},
						plugins: {
							legend: {
								display: false
							},
							counter: {
								textNumber: this.numRecords
							},
							tooltip: {
								enabled: true
							}
						},
						responsive: false //Si no no funciona la version
					},
					plugins: [counter]
				};
				loadScript(this, (chartjs + '/chart.min.js')).then(() => {
					if (this.template.querySelector('[name="' + this.metadataChartName + '"]') != null) {
						const ctx = this.template.querySelector('[name="' + this.metadataChartName + '"]').getContext('2d');
						if (this.chart != null) {
							this.chart.data.datasets[0].data = this.dataset;
							this.chart.options.plugins.counter.textNumber = this.numRecords;
							this.chart.update();
						} else {
							this.chart = new window.Chart(ctx, this.config);
						}
					}
					this.loading = false;
				}).catch(error => {
					console.log(error);
					this.loading = false;
				});
			} else {
				this.showDonutCharts = false;
				this.numRecords = data.numRecords;
				this.title = data.title;
				if (data.reportId !== undefined) {
					this.reportId = data.reportId;
					this.template.querySelector('article').classList.add('cursor-link');
					this.template.querySelector('span').classList.remove('cursor-default');
				}
			}
		} else if (error) {
			console.log('Error loading: ', JSON.parse(JSON.stringify(error)));
		}
	}

	@api
	refreshChart() {
		this.loading = true;
		refreshApex(this.wiredData).then(result => {
			this.loading = false;
		});
	}

	getLabels(chartName) {
		var labelList;
		if (chartName == PRIOR_MANAGE_CLIENTS || chartName == PRIOR_MANAGE_CLIENTS_SD || chartName == PRIOR_MANAGE_CLIENTS_SD_BP ) {
			labelList = [PRIORIZADOR, CLIENT_EXPERIENCE, INICIATIVA_GESTOR, ALERTAS_COMERCIALES, ONBOARDING_INTOUCH];
		} else if (chartName == PENDING_CONVERSATION ||chartName == PENDING_CONVERSATION_SD) {
			labelList = [MURO, STOPGO, LLAMADAS];
		} else if (chartName == TODAYS_APPOINTMENT ||chartName == TODAYS_APPOINTMENT_SD) {
			labelList = [ORIGEN_GESTOR, ORIGEN_CLIENTE];
		} else if (chartName == TASK_FOR_TODAY ) {
			labelList = [TAREAS];
		} else if (chartName == WARNINGS_TO_MANAGE || chartName == WARNINGS_TO_MANAGE_SD || chartName == WARNINGS_TO_MANAGE_SD_BP) {

			labelList = [AVISOS];
		}
		return labelList;
	}

	getColours() {
		if (this.metadataChartName == PRIOR_MANAGE_CLIENTS || this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD || this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD_BP ) {
			this.coloursList = ['rgb(6,79,112)', 'rgb(0,126,174)', 'rgb(43,192,237)', 'rgb(165,234,253)', 'rgb(165, 234, 233)'];
		} else if (this.metadataChartName == PENDING_CONVERSATION ||this.metadataChartName == PENDING_CONVERSATION_SD) {
			this.coloursList = ['rgb(0,126,174)', 'rgb(43,192,237)', 'rgb(6,79,112)'];
		} else if (this.metadataChartName == TODAYS_APPOINTMENT ||this.metadataChartName == TODAYS_APPOINTMENT_SD ) {
			this.coloursList = ['rgb(0,126,174)','rgb(6,79,112)',];
		} else if (this.metadataChartName == TASK_FOR_TODAY ) {
			this.coloursList = ['rgb(6,79,112)'];
		} else if (this.metadataChartName == WARNINGS_TO_MANAGE || this.metadataChartName == WARNINGS_TO_MANAGE_SD || this.metadataChartName == WARNINGS_TO_MANAGE_SD_BP) {
			this.coloursList = ['rgb(6,79,112)'];
		}
	}

	navigateToReportWithoutFilter(event) {
		if (this.reportId !== undefined) {
			if ((this.metadataChartName !== PRIOR_MANAGE_CLIENTS && this.metadataChartName !== PRIOR_MANAGE_CLIENTS_SD && this.metadataChartName !== PRIOR_MANAGE_CLIENTS_SD_BP)) {
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.reportId,
						objectApiName: 'Report',
						actionName: 'view'
					}
					/*state: {
						fv9: valueToFilter  TEST
					}*/
				});
			} else {
				this[NavigationMixin.Navigate]({
					type: 'standard__component',
					attributes: {
						componentName: "c__AV_NavigateTableGroupedByClient"
					},
					state: {
						c__fv9: ''
					}
				});
			}
		}
	}


	navigateToReport(event) {
		if (this.reportId !== undefined) {
			event.preventDefault();
			event.stopPropagation();
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: this.reportId,
					objectApiName: 'Report',
					actionName: 'view'
				}
			});
		}
	}

	navigateToReportWithFilter(metaChart) {
		if (this.reportId !== undefined) {
			var valueToFilter = "'" + this.filtersValuesMap.get(this.filterValue) + "'";
			if (metaChart == PRIOR_MANAGE_CLIENTS || metaChart == PRIOR_MANAGE_CLIENTS_SD || metaChart == PRIOR_MANAGE_CLIENTS_SD_BP) {
					this[NavigationMixin.Navigate]({
						type: 'standard__component',
						attributes: {
							componentName: "c__AV_NavigateTableGroupedByClient"
						},
						state: {
							c__fv9: valueToFilter
						}
					});
				
			} else if (metaChart == PENDING_CONVERSATION || metaChart == TODAYS_APPOINTMENT || metaChart == PENDING_CONVERSATION_SD ||metaChart == TODAYS_APPOINTMENT_SD) {
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.reportId,
						objectApiName: 'Report',
						actionName: 'view'
					},
					state: {
						fv2: valueToFilter
					}
				});
			} else {
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.reportId,
						objectApiName: 'Report',
						actionName: 'view'
					}
				});
			}
		}
	}


	navigateToReportWithFilterLegend(event) {
		if (this.reportId !== undefined) {
			var valueToFilter = "'" + event.currentTarget.dataset.id + "'";
			if (this.metadataChartName == PRIOR_MANAGE_CLIENTS || this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD || this.metadataChartName == PRIOR_MANAGE_CLIENTS_SD_BP) {
					this[NavigationMixin.Navigate]({
						type: 'standard__component',
						attributes: {
							componentName: "c__AV_NavigateTableGroupedByClient"
						},
						state: {
							c__fv9: valueToFilter
						}
					});
				
			} else if (this.metadataChartName == PENDING_CONVERSATION || this.metadataChartName == TODAYS_APPOINTMENT || this.metadataChartName == PENDING_CONVERSATION_SD || this.metadataChartName == TODAYS_APPOINTMENT_SD) {
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.reportId,
						objectApiName: 'Report',
						actionName: 'view'
					},
					state: {
						fv2: valueToFilter
					}
				});
			} else {
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.reportId,
						objectApiName: 'Report',
						actionName: 'view'
					}
				});
			}
		}
	}

	goMassReassign(event) {
		this[NavigationMixin.Navigate]({
			type: 'standard__component',
			attributes: {
				componentName: "c__av_MassReassignOwnerContainer"
			},
			state: {
				c__fromHome: this.metadataChartName
			}
		})
	}
}