import {LightningElement, wire, track, api} from 'lwc';
import getProcesos from '@salesforce/apex/SIR_LCMP_HomeImpaAutoRefresh.getQueryProcesos';
export default class ProcesosEstrategiasChart extends LightningElement {

	@api informeProcesosEstrategias;
	@track chartConfiguration;
	@track showChart = false;
 
 	@wire(getProcesos, {})
	 getProcesos({error, data}) {
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

			data.forEach(proceso => {
				totalEstrategias.push(proceso.estrategia);
				totalSituaciones.push(proceso.situacion);
			});

            var numProcesos = 0;
            data.forEach(proceso => {
                numProcesos = 0;
                for (var i = 0; i < totalEstrategias.length; i++) {
                    if (proceso.estrategia === totalEstrategias[i] && proceso.situacion === totalSituaciones[i]) {
                        if((proceso.SIR_fld_Situacion_SF__c !== 'SF_ILOCALI' || proceso.SIR_fld_Situacion_SF__c !== 'SF_NORECOBRO' || proceso.SIR_fld_Situacion_SF__c !== 'SF_FINALIZ')){
                            numProcesos++;
                        }
                    }
                }
                numProcesosArray.push(numProcesos);
            });
			

			let chartData = [];
			let chartLabels = [];
			var i = 0;
			data.forEach(proceso => {
				chartData.push(numProcesosArray[i]);
				i++;
				chartLabels.push(proceso.estrategia + ' - ' +proceso.situacion);
			});

			let mapEstrategias = new Map();
			var i = 0;
			data.forEach(proceso => {
				if(!mapEstrategias.has(proceso.estrategia)){
					mapEstrategias.set(proceso.estrategia, i);
					i++;
				}
			});

			var mapSituaciones = new Map();
			data.forEach(proceso => {
				var longitud = [];
				for (var n = 0; n < i; n++) {
					longitud.push(0);
				}
				mapSituaciones.set(proceso.situacion, longitud);
			});

			var i = 0;
			data.forEach(proceso => {
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