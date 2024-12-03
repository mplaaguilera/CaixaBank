import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getData from '@salesforce/apex/CIBE_MetricChart_Controller.getData';
import userHasPermissionSet from '@salesforce/apex/CIBE_MetricChart_Controller.userHasPermissionSet';

import USER_ID from '@salesforce/user/Id';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import { getRecord } from 'lightning/uiRecordApi';

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/AV_ChartJsV391';

//Labels

import alertaComercial from '@salesforce/label/c.CIBE_Alerta_Comercial';
import avisos from '@salesforce/label/c.CIBE_Avisos';
import expCli from '@salesforce/label/c.CIBE_Experiencia_Cliente';
import gestionarPri from '@salesforce/label/c.CIBE_Gestionar_Priorizados';
import iniciativaGes from '@salesforce/label/c.CIBE_Iniciativa_Ges';
import onboarding from '@salesforce/label/c.CIBE_Onboarding';
import llamadas from '@salesforce/label/c.CIBE_Llamadas';
import muro from '@salesforce/label/c.CIBE_Muro';
import stopandgo from '@salesforce/label/c.CIBE_Stop_Go';
import opPendFir from '@salesforce/label/c.CIBE_OperacionesPendFirma';
import origenCli from '@salesforce/label/c.CIBE_OrigenCliente';
import origenGes from '@salesforce/label/c.CIBE_OrigenGestor';
import buscador from '@salesforce/label/c.CIBE_Buscador';
import tareas from '@salesforce/label/c.CIBE_Tareas';
import opPendFirmaLargo from '@salesforce/label/c.CIBE_OpPendFirmaLargo';


const AVISOS = avisos;
const TAREAS = tareas;

//CUSTOM METADATA
const GESTIONAR_PRIORIZADOS_CIB = 'CIBE_PriorManageClients';
const GESTIONAR_PRIORIZADOS_EMP = 'CIBE_PriorManageClientsEMP';
const TASK_NEXT_7_DAYS_CIB = 'CIBE_TareasProximos7Dias_CIB';
const TASK_NEXT_7_DAYS_EMP = 'CIBE_TareasProximos7Dias_EMP';
const EVENTS_TODAY = 'CIBE_TodaysAppointments';
const NOTIFICACIONES = 'CIBE_PendingConversation';
const AVISOS_CIB = 'CIBE_WarningsToManage';
const AVISOS_EMP = 'CIBE_WarningsToManageEMP';

//TAREAS RECORDTYPE CIB
const RT_GESTIONAR_PRI_CIB 		= gestionarPri + ' CIB';
const RT_CLIENTE_EXP_CIB 		= expCli +' CIB';
const RT_ALERTA_COMERCIAL_CIB 	= alertaComercial + ' CIB';
const RT_ONBOARDING_CIB 		= onboarding + ' CIB';
const RT_INICIATIVA_GESTOR_CIB 	= iniciativaGes + ' CIB';
const RT_AVISOS_CIB 			= avisos + ' CIB';

//TAREAS RECORDTYPE DEVELOPERNAME CIB
const RT_GESTIONAR_PRI_DN_CIB = 'CIBE_GestionarPriorizadosCIB';
const RT_CLIENTE_EXP_DN_CIB = 'CIBE_ExperienciaClienteCIB';
const RT_ALERTA_COMERCIAL_DN_CIB = 'CIBE_AlertaComercialCIB';
const RT_ONBOARDING_DN_CIB = 'CIBE_OnboardingCIB';
const RT_INICIATIVA_GESTOR_DN_CIB = 'CIBE_OtrosCIB';
const RT_AVISOS_DN_CIB ='CIBE_AvisosCIB';

//TAREAS RECORDTYPE EMP
const RT_GESTIONAR_PRI_EMP 		= gestionarPri + ' EMP';
const RT_CLIENTE_EXP_EMP 		= expCli +' EMP';
const RT_ALERTA_COMERCIAL_EMP 	= alertaComercial + ' EMP';
const RT_ONBOARDING_EMP 		= onboarding + ' EMP';
const RT_INICIATIVA_GESTOR_EMP 	= iniciativaGes + ' EMP';
const RT_AVISOS_EMP 			= avisos + ' EMP';

//TAREAS RECORDTYPE DEVELOPERNAME EMP
const RT_GESTIONAR_PRI_DN_EMP = 'CIBE_GestionarPriorizadosEMP';
const RT_CLIENTE_EXP_DN_EMP = 'CIBE_ExperienciaClienteEMP';
const RT_ALERTA_COMERCIAL_DN_EMP = 'CIBE_AlertaComercialEMP';
const RT_ONBOARDING_DN_EMP = 'CIBE_OnboardingEMP';
const RT_INICIATIVA_GESTOR_DN_EMP = 'CIBE_OtrosEMP';
const RT_AVISOS_DN_EMP = 'CIBE_AvisosEMP';

//EVENTOS
//Evento -> Activity -> Campo 'Iniciador' --> AV_InOutbound__c
const ORIGEN_CLIENTE = origenCli;
const ORIGEN_GESTOR = origenGes;
const ENTRADA = "Entrada','002";
const SALIDA = "Salida','001";

//AV_NotifyMe
const MURO = muro;
const STOPGO = stopandgo;
const LLAMADAS = llamadas;
const PENDIENTE_FIRMA_LABEL = opPendFir;
const PENDIENTE_FIRMA = opPendFirmaLargo;



export default class cibe_MetricChart extends NavigationMixin(LightningElement) {

	labels = {
        alertaComercial,
        avisos,
        expCli,
        gestionarPri,
        iniciativaGes,
		onboarding,
		llamadas,
		muro,
		stopandgo,
		opPendFir,
		origenCli,
		origenGes,
		buscador,
		tareas,
		opPendFirmaLargo
    };

	@api metadataChartName;

	@track title;
	@track reportId;
	@track numRecords;
	@track loading = false;

	@track showDonutCharts;
	@track chart;
	@track config;
	@track dataset;
	@track coloursList;
	@track office;
	@track offficeShort;
	@track filterValue;
	@track showLegendClientsCIB;
	@track showLegendClientsEMP;
	@track showLegendNotify;
	@track showLegendAppointments;
	@track showLegendTasks7daysCIB;
	@track showLegendTasks7daysEMP
	@track showLegendWarningsCIB;
	@track showLegendWarningsEMP;
	@track showNumbers;
	@track error;
	@track wiredData;
	@track showTableGroupedByCliente;

	@track filtersValuesMap = new Map([
		[RT_GESTIONAR_PRI_CIB, RT_GESTIONAR_PRI_DN_CIB],
		[RT_CLIENTE_EXP_CIB, RT_CLIENTE_EXP_DN_CIB],
		[RT_INICIATIVA_GESTOR_CIB, RT_INICIATIVA_GESTOR_DN_CIB],
		[RT_ALERTA_COMERCIAL_CIB, RT_ALERTA_COMERCIAL_DN_CIB],
		[RT_ONBOARDING_CIB, RT_ONBOARDING_DN_CIB],
		[RT_AVISOS_CIB, RT_AVISOS_DN_CIB],

		[RT_GESTIONAR_PRI_EMP, RT_GESTIONAR_PRI_DN_EMP],
		[RT_CLIENTE_EXP_EMP, RT_CLIENTE_EXP_DN_EMP],
		[RT_INICIATIVA_GESTOR_EMP, RT_INICIATIVA_GESTOR_DN_EMP],
		[RT_ALERTA_COMERCIAL_EMP, RT_ALERTA_COMERCIAL_DN_EMP],
		[RT_ONBOARDING_EMP, RT_ONBOARDING_DN_EMP],
		[RT_AVISOS_EMP, RT_AVISOS_DN_EMP],

		[LLAMADAS, LLAMADAS],
		[MURO, MURO],
		[STOPGO, STOPGO],
		[PENDIENTE_FIRMA_LABEL, PENDIENTE_FIRMA],
		//[PENDIENTE_FIRMA_LABEL, PENDIENTE_FIRMA_LABEL],


		[ORIGEN_CLIENTE, SALIDA],
		[ORIGEN_GESTOR, ENTRADA],
	]);
	connectedCallback(){
	}
	@wire(userHasPermissionSet)
	checkVisibilityHomeV4(data) {
		if (data) {
			this.showTableGroupedByCliente = data.data;
		}
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

			if (this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB
				|| this.metadataChartName == GESTIONAR_PRIORIZADOS_EMP
				|| this.metadataChartName == TASK_NEXT_7_DAYS_CIB
				|| this.metadataChartName == TASK_NEXT_7_DAYS_EMP
				|| this.metadataChartName == AVISOS_CIB
				|| this.metadataChartName == AVISOS_EMP
				|| this.metadataChartName == NOTIFICACIONES
				|| this.metadataChartName == EVENTS_TODAY
				) {
				this.showDonutCharts = true;
				this.loading = true;
				if (this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB) {
					this.showLegendClientsCIB = true;
				} else if (this.metadataChartName == GESTIONAR_PRIORIZADOS_EMP) {
					this.showLegendClientsEMP = true;
				}else if (this.metadataChartName == NOTIFICACIONES) {
					this.showLegendNotify = true;
				} else if (this.metadataChartName == EVENTS_TODAY) {
					this.showLegendAppointments = true;
				} else if (this.metadataChartName == TASK_NEXT_7_DAYS_CIB) {
					this.showLegendTasks7daysCIB = true;
				} else if (this.metadataChartName == TASK_NEXT_7_DAYS_EMP) {
					this.showLegendTasks7daysEMP = false;
				} else if (this.metadataChartName == AVISOS_CIB) {
					this.showLegendWarningsCIB = true;
				} else if (this.metadataChartName == AVISOS_EMP) {
					this.showLegendWarningsEMP = false;
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

				if (data.numRecordsList !== undefined 
				&& (this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB
					|| this.metadataChartName == GESTIONAR_PRIORIZADOS_EMP
					|| this.metadataChartName == TASK_NEXT_7_DAYS_CIB
					|| this.metadataChartName == TASK_NEXT_7_DAYS_EMP
					|| this.metadataChartName == EVENTS_TODAY 
					|| this.metadataChartName == NOTIFICACIONES 
					|| this.metadataChartName == AVISOS_CIB 
					|| this.metadataChartName == AVISOS_EMP 
				))		
				{
					this.dataset = data.numRecordsList;

				} else {
					let datasetList = [];
					datasetList.push(this.numRecords);
					this.dataset = datasetList;

				}
				this.getColours(this.metadataChartName);
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
		if (chartName == GESTIONAR_PRIORIZADOS_CIB ) {
			labelList = [RT_GESTIONAR_PRI_CIB, RT_CLIENTE_EXP_CIB, RT_INICIATIVA_GESTOR_CIB, RT_ALERTA_COMERCIAL_CIB, RT_ONBOARDING_CIB];
		} else if ( chartName == GESTIONAR_PRIORIZADOS_EMP ) {
			labelList = [RT_GESTIONAR_PRI_EMP, RT_CLIENTE_EXP_EMP, RT_ALERTA_COMERCIAL_EMP, RT_ONBOARDING_EMP];
		}else if (chartName == NOTIFICACIONES ) {
			labelList = [LLAMADAS, MURO, STOPGO, PENDIENTE_FIRMA_LABEL];
		} else if (chartName == EVENTS_TODAY) {
			labelList = [ORIGEN_CLIENTE, ORIGEN_GESTOR];
		} else if (chartName == TASK_NEXT_7_DAYS_CIB || chartName == TASK_NEXT_7_DAYS_EMP) {
			labelList = [TAREAS];
		} else if (chartName == AVISOS_CIB || chartName == AVISOS_EMP) {
			labelList = [AVISOS];
		}
		return labelList;
	}

	getColours(chartName) {
		if (chartName == GESTIONAR_PRIORIZADOS_CIB) {
			this.coloursList = ['rgb(6,79,112)', 'rgb(0,126,174)', 'rgb(43,192,237)', 'rgb(165,234,253)', 'rgb(165, 234, 233)'];
		}else if (chartName == GESTIONAR_PRIORIZADOS_EMP ) {
			this.coloursList = ['rgb(6,79,112)', 'rgb(0,126,174)', 'rgb(43,192,237)', 'rgb(165, 234, 233)'];
		} else if (chartName == NOTIFICACIONES) {
			this.coloursList = ['rgb(6,79,112)', 'rgb(0,126,174)', 'rgb(43,192,237)', 'rgb(165,234,253)'];
		} else if (chartName == EVENTS_TODAY) {
			this.coloursList = ['rgb(6,79,112)', 'rgb(0,126,174)'];
		} else if (chartName == TASK_NEXT_7_DAYS_CIB || chartName == TASK_NEXT_7_DAYS_EMP) {
			this.coloursList = ['rgb(6,79,112)'];
		} else if (chartName == AVISOS_CIB || chartName == AVISOS_EMP) {
			this.coloursList = ['rgb(6,79,112)'];
		}
	}
	// Sin rosco
	navigateToReportWithoutFilter(event) {
		if (this.reportId !== undefined) {

			if (this.metadataChartName !== GESTIONAR_PRIORIZADOS_CIB 
				&& this.metadataChartName !== GESTIONAR_PRIORIZADOS_EMP) {

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
			}else {
				this[NavigationMixin.Navigate]({
					type: 'standard__component',
					attributes: {
						componentName: "c__cibe_NavigateTableGroupedByClient"
					}, 
					state: {
						c__rtName: null,
						c__isCIB: this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB ? true : false
					}
				});
			}
		}
	}

	// Vacio 	
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

	// Rosco
	navigateToReportWithFilter(metaChart) {
		if (this.reportId !== undefined) {
			var valueToFilterReport = "'" + this.filtersValuesMap.get(this.filterValue) + "'";
			var valueToFilter =  this.filtersValuesMap.get(this.filterValue) ;
			if (metaChart == GESTIONAR_PRIORIZADOS_CIB 
				|| metaChart == GESTIONAR_PRIORIZADOS_EMP) {
				if (!this.showTableGroupedByCliente) {
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: this.reportId,
							objectApiName: 'Report',
							actionName: 'view'
						},
						state: {
							fv8: valueToFilterReport
						}
					});
				} 
				else {
					this[NavigationMixin.Navigate]({
						type: 'standard__component',
						attributes: {
							componentName: "c__CIBE_NavigateTableGroupedByClient"
						},
						state: {
							c__rtName: valueToFilter,
							c__isCIB: this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB ? true : false
						}
					});
					
				}
			} else if (metaChart == EVENTS_TODAY ) {
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: this.reportId,
							objectApiName: 'Report',
							actionName: 'view'
						},
						state: {
							fv2: valueToFilterReport
						}
				});
			
			} else if (metaChart == NOTIFICACIONES) {
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.reportId,
						objectApiName: 'Report',
						actionName: 'view'
					},
					state: {
						fv1: valueToFilterReport
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

	// Leyenda
	navigateToReportWithFilterLegend(event) {

		var filterValueLegend = event.target.dataset.id ;
		if (this.reportId !== undefined) {
			var valueToFilterReport = "'" + this.filtersValuesMap.get(filterValueLegend) + "'";
			var valueToFilter =  this.filtersValuesMap.get(filterValueLegend) ;
			if (this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB 
				|| this.metadataChartName == GESTIONAR_PRIORIZADOS_EMP) {					
					var word =  this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB ?  ' CIB' : ' EMP';
					valueToFilterReport = "'" + this.filtersValuesMap.get(filterValueLegend + word) + "'";
					valueToFilter =  this.filtersValuesMap.has(filterValueLegend + word) ? this.filtersValuesMap.get(filterValueLegend + word) : 'no tiene' ;
					if (!this.showTableGroupedByCliente) {
					this[NavigationMixin.Navigate]({
						type: 'standard__recordPage',
						attributes: {
							recordId: this.reportId,
							objectApiName: 'Report',
							actionName: 'view'
						},
						state: {
							fv9: valueToFilterReport
						}
						
					});

				} else {
					this[NavigationMixin.Navigate]({
						type: 'standard__component',
						attributes: {
							componentName: "c__cibe_NavigateTableGroupedByClient"
						},
						state: {
							c__rtName: valueToFilter,
							c__isCIB: this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB ? true : false
						}
					});
				}
			} else if (this.metadataChartName == NOTIFICACIONES ) {
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.reportId,
						objectApiName: 'Report',
						actionName: 'view'
					},
					state: {
						fv1: valueToFilterReport
					}
				});
			} else if ( this.metadataChartName == EVENTS_TODAY 
					|| this.metadataChartName == AVISOS_CIB 
					|| this.metadataChartName == AVISOS_EMP) {
				this[NavigationMixin.Navigate]({
					type: 'standard__recordPage',
					attributes: {
						recordId: this.reportId,
						objectApiName: 'Report',
						actionName: 'view'
					},
					state: {
						fv2: valueToFilterReport
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

	// Buscador de tareas
	goMassReassign(event) {
		
		this[NavigationMixin.Navigate]({
			type: 'standard__navItemPage',
			attributes: {
				apiName: this.metadataChartName == GESTIONAR_PRIORIZADOS_CIB ? 'Tarea_CIB' : 'CIBE_TareasEMP'
			}
		})
	}
}