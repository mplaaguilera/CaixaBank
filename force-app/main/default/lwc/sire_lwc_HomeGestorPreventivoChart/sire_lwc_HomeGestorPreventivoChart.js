import {LightningElement,wire,track,api} from 'lwc';
import getProcesos from '@salesforce/apex/SIRE_LCMP_HomeGestorPreventivo.getQueryProcesos';

export default class Sire_lwc_HomeGestorPreventivoChart extends LightningElement {

    @api informeProcesosEstrategias;
    @track chartConfiguration;
    @track showChart = false;

    @wire(getProcesos, {})
    getProcesos({error,data}) {
        if (error) {
            this.error = error;
            this.chartConfiguration = undefined;
        } else if (data) {
            if (data.length > 0) {
                this.showChart = true;
            }

            let totalEstrategias = [];
            let totalSituaciones = [];
            let numProcesosArray = [];
            let procesosChart = [];

            data.forEach(proceso => {
                if((proceso.SIR_agrupacionSituacion__c === 'Pendiente' || proceso.SIR_agrupacionSituacion__c === 'Pendiente Riesgos' || proceso.SIR_agrupacionSituacion__c === 'Pendiente Consenso') || (proceso.SIR_fld_Situacion_SF__c === 'SF_PVCAP5' || proceso.SIR_fld_Situacion_SF__c === 'SF_PVACA3' || proceso.SIR_fld_Situacion_SF__c === 'SF_PVINRI')){
                    totalEstrategias.push(proceso.estrategia);
                    totalSituaciones.push(proceso.situacion);
                    procesosChart.push(proceso);
                }
            });

            
            procesosChart.forEach(proceso => {
                let numProcesos = 0;
                for (let i = 0; i < totalEstrategias.length; i++) {
                    if (proceso.estrategia === totalEstrategias[i] && proceso.situacion === totalSituaciones[i]) {
                        numProcesos++;
                    }
                }
                numProcesosArray.push(numProcesos);
            });

      /*      let chartData = [];
			let chartLabels = [];
			var i = 0;

			data.forEach(proceso => {
				chartData.push(numProcesosArray[i]);
				i++;
				chartLabels.push(proceso.estrategia + ' - ' + proceso.situacion);
			});
*/
            let mapSituaciones = new Map();
            let mapEstrategias = new Map();
            let i = 0;
            let e = 0;

            procesosChart.forEach(proceso => {
                if(numProcesosArray[e] !== 0){
                    if(!mapSituaciones.has(proceso.situacion)){
                    mapSituaciones.set(proceso.situacion, i);
                    i++;  
                    }
                }
                e++;
            });

  
            e = 0;
            procesosChart.forEach(proceso => {
                if(numProcesosArray[e] !== 0){
                    if(!mapEstrategias.has(proceso.estrategia)){
                        let longitud = [];
                        for (let n = 0; n < i; n++) {
                            longitud.push(0);
                        }
                        mapEstrategias.set(proceso.estrategia, longitud);
                    }
                }
                e++;
            });

            i = 0;
            procesosChart.forEach(proceso => {
                if(numProcesosArray[i] !== 0){
                    mapEstrategias.get(proceso.estrategia)[mapSituaciones.get(proceso.situacion)] = numProcesosArray[i];
                }
                i++;
            });

            let arrayEstrategias = Array.from(mapEstrategias.keys());
            let arrayDS = [];
            let color = ['#C6D2E1', '#064F70', '#007EAE', '#2BC0ED', '#A5EAFD', '#8775C9', '#884C93', '#13B8A0', '#38767E', '#FF5200', '#FF8D00', '#F5C78F', '#000000'];
            let j = 0;

            for (let posicion of arrayEstrategias) {
                arrayDS.push({
                    axis: 'x',
                    label: posicion,
                    backgroundColor: color[j],
                    data: mapEstrategias.get(posicion)
                });
                j++;
            }

            this.chartConfiguration = {
                type: 'horizontalBar',
                data: {
                    labels: Array.from(mapSituaciones.keys()),
                    datasets: arrayDS
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: {
                        position: 'right'
                    },
                    scales: {
                        xAxes: [{
                            stacked: true,
                            scaleLabel: {
                                display: true,
                                labelString: "# Procesos"
                            },
                            position: 'top',
                            gridLines: {
                                display: true
                            }
                        }],
                        yAxes: [{
                            stacked: true,
                            scaleLabel: {
                                display: true,
                                labelString: "Situaciones"
                            },
                            gridLines: {
                                display: false
                            },
                            maxBarThickness: 28,
                            barPercentage: 0.8,
                            categoryPercentage: 1.0
                        }]
                    }
                }
            }
        }
    }
}