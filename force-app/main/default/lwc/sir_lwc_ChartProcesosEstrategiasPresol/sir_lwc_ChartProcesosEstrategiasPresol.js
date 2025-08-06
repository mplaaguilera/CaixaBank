import {LightningElement, wire, track, api} from 'lwc';
import getProcesos from '@salesforce/apex/SIR_LCMP_HomePresolAutoRefresh.getQueryProcesos';

export default class Sir_lwc_ChartProcesosEstrategiasPresol extends LightningElement {

	@api informeProcesosEstrategias;
	@track chartConfiguration;
	@track showChart = false;
 
 	@wire(getProcesos, {})
	 getProcesos({error, data}) {
		var i = 0;
		if (error) {
			this.error = error;
			this.chartConfiguration = undefined;
		} else if (data) {
			if(data.length > 0){
				this.showChart = true;
			}		

			let totalEstrategias = [];
			let totalSituaciones = [];
			let numProcesosArray = [];
			let procesosChart = [];
			let numProcesos = 0;
			let mapEstrategias = new Map();
			let mapSituaciones = new Map();

			data.forEach(proceso => {
				if((proceso.SIR_agrupacionSituacion__c === 'Pendiente' || proceso.SIR_agrupacionSituacion__c === 'En Gestión')){				
				//if((proceso.SIR_fld_Situacion_SF__c === 'SF_REPLANCNT' || proceso.SIR_fld_Situacion_SF__c === 'SF_INIGEST' || proceso.SIR_fld_Situacion_SF__c === 'SF_ANALISPRE' || proceso.SIR_fld_Situacion_SF__c === 'SF_CLINOLOC' || proceso.SIR_fld_Situacion_SF__c === 'SF_PTECONTAC')){
					totalEstrategias.push(proceso.estrategia);
					totalSituaciones.push(proceso.situacion);
					procesosChart.push(proceso);
				}	
			});

            procesosChart.forEach(proceso => {
                numProcesos = 0;
                for (i = 0; i < totalEstrategias.length; i++) {
                    if (proceso.estrategia === totalEstrategias[i] && proceso.situacion === totalSituaciones[i]) {
                        numProcesos++;
                    }
                }
                numProcesosArray.push(numProcesos);
            });

			/*let chartData = [];
			let chartLabels = [];
			var i = 0;
			data.forEach(proceso => {
				chartData.push(numProcesosArray[i]);
				i++;
				chartLabels.push(proceso.estrategia + ' - ' +proceso.situacion);
			});
			*/
			
			i = 0;
			procesosChart.forEach(proceso => {
				if(!mapEstrategias.has(proceso.estrategia)){
					mapEstrategias.set(proceso.estrategia, i);
					i++;
				}
			});
			
			procesosChart.forEach(proceso => {
				let longitud = [];
				for (let n = 0; n < i; n++) {
					longitud.push(0);
				}
				mapSituaciones.set(proceso.situacion, longitud);
			});

			i = 0;
			procesosChart.forEach(proceso => {
				mapSituaciones.get(proceso.situacion)[mapEstrategias.get(proceso.estrategia)] = numProcesosArray[i];
				i++;
			});
			
			let arraySituaciones = Array.from( mapSituaciones.keys() );
			let arrayDS = [];
			let color = ['#C6D2E1', '#064F70', '#007EAE', '#2BC0ED', '#A5EAFD', '#8775C9', '#884C93', '#13B8A0', '#38767E', '#FF5200', '#FF8D00', '#F5C78F', '#000000'];
			let j = 0;
			for(let posicion of arraySituaciones){
				arrayDS.push({
					axis: 'x',
					label: posicion,
					backgroundColor: color[j],
					data: mapSituaciones.get(posicion)
				});
				j ++;
			}
			this.chartConfiguration = {
				type: 'horizontalBar',
				data: {
					labels: Array.from( mapEstrategias.keys() ),
					datasets: arrayDS
				},
				options: {
					responsive: true,
					maintainAspectRatio: false,
					legend: {
						position: 'right'
					},
					scales: {
						xAxes: [
						{
							stacked: true,
							scaleLabel: { display: true, labelString: "# Procesos" },
							position: 'top',
							gridLines: {
								display: true
							}
						}
						],
						yAxes: [
							{
								stacked: true,
								scaleLabel: { display: true, labelString: "Estrategias" },
								gridLines: {
									display: false
								},
								maxBarThickness: 28,
								barPercentage: 0.8,
								categoryPercentage: 1.0
							}
						]
					}
				}		
			}
		}
	}
}