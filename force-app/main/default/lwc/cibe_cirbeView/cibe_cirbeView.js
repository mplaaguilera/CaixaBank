import { LightningElement, api, track, wire } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import getCirbeRisk from '@salesforce/apex/CIBE_cirbeIntegration.getCirbeRisk';
import getUrl from '@salesforce/apex/CIBE_cirbeIntegration.getUrl';
import directo from '@salesforce/label/c.CIBE_CirbeRiesgoDirecto';
import indirecto from '@salesforce/label/c.CIBE_CirbeRiesgoIndirecto';
import evolucionCirbe from '@salesforce/label/c.CIBE_CirbeEvolucion';
import morosidad from '@salesforce/label/c.CIBE_CirbeMorosidad';
import morosidadOtros from '@salesforce/label/c.CIBE_CirbeMorosidadOtros';
import otrasComp from '@salesforce/label/c.CIBE_CirbeOtrasComp';
import detalle from '@salesforce/label/c.CIBE_CirbeDetalle';
import porDispDirecto from '@salesforce/label/c.CIBE_CirbePorDispDirecto';
import porDispIndirecto from '@salesforce/label/c.CIBE_CirbePorDispInirecto';
import concepto from '@salesforce/label/c.CIBE_CirbeConcepto';
import posicionesCXB from '@salesforce/label/c.CIBE_CirbeposicionesCXB';
import posicionesOtros from '@salesforce/label/c.CIBE_CirbeposicionesOtros';
import dispuesto from '@salesforce/label/c.CIBE_CirbeDispuesto';
import disponible from '@salesforce/label/c.CIBE_CirbeDisponible';
import fechaDatos from '@salesforce/label/c.CIBE_CirbefechaDatos';
import dispCuota from '@salesforce/label/c.CIBE_CirbedispCuota';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';


export default class Cibe_cirbeView extends LightningElement {
    @api recordId;
    @track charging = true;
    @track directData = [];
    @track indirectData = [];
    @track cxbRefresh = '';
    @track otherRefresh = '';
    chartjsInitialized = false;
    label = {
        directo,
        indirecto,
        evolucionCirbe,
        morosidad,
        morosidadOtros,
        otrasComp,
        detalle,
        porDispDirecto,
        porDispIndirecto,
        concepto,
        posicionesCXB,
        posicionesOtros,
        dispuesto,
        disponible,
        fechaDatos,
        dispCuota
    };
    @track columnsDirecto =[{ label: '', fieldName: 'concepto', sortable: "true", type: "text"},
    { label: 'Dispuesto CXB', fieldName: 'dispuesto', sortable: "true", type: "text", cellAttributes: { alignment: 'right' }},
    { label: 'Disponible CXB', fieldName: 'disponible', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: 'Dispuesto otras entidades', fieldName: 'dispuestoEnt', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }}, 
    { label: 'Disponible otras entidades', fieldName: 'disponibleEnt', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }},
    { label: '% Dispuesto cuota CXB/otras entidades', fieldName: 'porcentaje', sortable: "true", type:"text", cellAttributes: { alignment: 'right' }}];
    @track datos = [];
    @track url = '';
    @track cargando = true;
    @track error = '';
    @track bError = false;


    @wire(getUrl, { recordId: '$recordId' })
    getUrlTF({ error, data }){
        if(data){
            this.url = data;
        } else if(error){
            console.log(error);
        }
    }

    connectedCallback() {
        
        getCirbeRisk({recordId: this.recordId})
        .then(result => {

            let data = [];

            let donnutValuesDir = [];
            this.cxbRefresh = result.GeneralData.statementDate;
            this.otherRefresh = result.GeneralData.returnDate;
            result.DirectRiskData.dataTableDirectRisk.forEach(concepto => {
                if(concepto.litDirectRisk !== 'Total directos') {
                    let oConcepto = {};
                    oConcepto.concepto = concepto.litDirectRisk;
                    oConcepto.dispuesto = concepto.amountArrangedCom;
                    oConcepto.disponible = concepto.amountAvailableCom;
                    oConcepto.dispuestoEnt = concepto.amountArrangedEntities;
                    oConcepto.disponibleEnt = concepto.amountAvailableEntities;
                    oConcepto.porcentaje = concepto.arrangedFeeCaixa;
                    data.push(oConcepto);
                } else {
                    donnutValuesDir.push(parseInt(concepto.amountArrangedCom.replace(/\./g, ''), 10));
                    donnutValuesDir.push(parseInt(concepto.amountArrangedEntities.replace(/\./g, ''), 10));
                }
               
            });
            this.directData = data;

            data = [];
            let donnutValuesIn = [];
            result.IndirectRiskData.DataTableIndirectRisk.forEach(concepto => {
                if(concepto.litIndirectRisk !== 'Total indirectos') {
                    let oConcepto = {};
                    oConcepto.concepto = concepto.litIndirectRisk;
                    oConcepto.dispuesto = concepto.amountArrangedIndirectRisk;
                    oConcepto.disponible = concepto.amountAvailableIndirectRisk;
                    oConcepto.dispuestoEnt = concepto.amountArrangedIndirectRiskOtherEnt;
                    oConcepto.disponibleEnt = concepto.amountAvailableIndirectRiskOtherEnt;
                    oConcepto.porcentaje = concepto.totalFee;
                    data.push(oConcepto);
                } else {
                    donnutValuesIn.push(parseInt(concepto.amountArrangedIndirectRisk.replace(/\./g, ''), 10));
                    donnutValuesIn.push(parseInt(concepto.amountArrangedIndirectRiskOtherEnt.replace(/\./g, ''), 10));
                }
            });
            this.indirectData = data;
            this.loadDonnut(donnutValuesDir, donnutValuesIn, result.EvolutionDataCLI.EvolutionDataTableDirectRisk);
            this.cargando = false;
            this.dispatchEvent(new RefreshEvent());
            
        })
        .catch(error => {
          
            this.error = error.body.message;
            this.bError = true;
            this.cargando = false;
        });
    }

    loadDonnut(values, values2, values3){
        loadScript(this, chartjs)
            .then(() => {
                Chart.pluginService.register({
                    beforeDraw: function(chart) {

                      if (chart.config.options.elements.center) {

                        var ctx = chart.chart.ctx;

                        var centerConfig = chart.config.options.elements.center;
                        var fontStyle = centerConfig.fontStyle || 'Arial';
                        var txt = centerConfig.text;
                        var color = centerConfig.color || '#000';
                        var maxFontSize = centerConfig.maxFontSize || 75;
                        var sidePadding = centerConfig.sidePadding || 20;
                        var sidePaddingCalculated = (sidePadding / 100) * (chart.innerRadius * 2)
                        ctx.font = "30px " + fontStyle;
              
                        // Get the width of the string and also the width of the element minus 10 to give it 5px side padding
                        var stringWidth = ctx.measureText(txt).width;
                        var elementWidth = (chart.innerRadius * 2) - sidePaddingCalculated;
              
                        // Find out how much the font can grow in width.
                        var widthRatio = elementWidth / stringWidth;
                        var newFontSize = Math.floor(30 * widthRatio);
                        var elementHeight = (chart.innerRadius * 2);
              
                        // Pick a new font size so it will not be larger than the height of label.
                        var fontSizeToUse = Math.min(newFontSize, elementHeight, maxFontSize);
                        var minFontSize = centerConfig.minFontSize;
                        var lineHeight = centerConfig.lineHeight || 25;
                        var wrapText = false;
              
                        if (minFontSize === undefined) {
                          minFontSize = 20;
                        }
              
                        if (minFontSize && fontSizeToUse < minFontSize) {
                          fontSizeToUse = minFontSize;
                          wrapText = true;
                        }
              
                        // Set font settings to draw it correctly.
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'middle';
                        var centerX = ((chart.chartArea.left + chart.chartArea.right) / 2);
                        var centerY = ((chart.chartArea.top + chart.chartArea.bottom) / 2);
                        ctx.font = fontSizeToUse + "px " + fontStyle;
                        ctx.fillStyle = color;
              
                        if (!wrapText) {
                          ctx.fillText(txt, centerX, centerY);
                          return;
                        }
              
                        var words = txt.split(' ');
                        var line = '';
                        var lines = [];
              
                        // Break words up into multiple lines if necessary
                        for (var n = 0; n < words.length; n++) {
                          var testLine = line + words[n] + ' ';
                          var metrics = ctx.measureText(testLine);
                          var testWidth = metrics.width;
                          if (testWidth > elementWidth && n > 0) {
                            lines.push(line);
                            line = words[n] + ' ';
                          } else {
                            line = testLine;
                          }
                        }
              
                        // Move the center up depending on line height and number of lines
                        centerY -= (lines.length / 2) * lineHeight;
              
                        for (var n = 0; n < lines.length; n++) {
                          ctx.fillText(lines[n], centerX, centerY);
                          centerY += lineHeight;
                        }
                        //Draw text in center
                        ctx.fillText(line, centerX, centerY);
                      }
                    }
                  });

                const canvas2 = document.createElement('canvas');
                this.template.querySelector('div.chart2').appendChild(canvas2);
                const ctx2 = canvas2.getContext('2d');
                
                this.chart2 = new window.Chart(ctx2, this.setConfig(values2));//this.config
                
                ctx2.save();

                const canvas = document.createElement('canvas');
                this.template.querySelector('div.chart').appendChild(canvas);
                const ctx = canvas.getContext('2d');
                this.chart = new window.Chart(ctx, this.setConfig(values));
                ctx.save();


                const canvas3 = document.createElement('canvas');
                this.template.querySelector('div.chart3').appendChild(canvas3);
                const ctx3 = canvas3.getContext('2d');
                this.chart3 = new window.Chart(ctx3, this.setConfigbar(this.setDatabar(values3)));
                ctx3.save();
            })
            .catch(error => {
                this.error = error;
                console.log('error ' + error);
            });
    }
    async renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;
    }
    setConfig(values) {

       let percent;
       if(values[1] === 0 || values[0] === 0){
            if(values[0] === 0){
                percent = 0;
            } else {
                percent = 100;
            }
        } else {
            percent = (values[0]/(values[1]+values[0])*100).toFixed(2);
        }
        let config = {
            type: 'doughnut',
            cutoutPercentage : 80,
            data: {
                datasets: [
                    {
                        data: values, //this.doughNutValues,//Object.values(this.doughtNutMap.data)
                        backgroundColor: [
                            '#007EAE',
                            '#333333'
                            //'rgb(54, 162, 235)'
                        ],
                        label: 'Dataset 1'
                    }
                ],
                labels: (['CXB', this.label.otrasComp])//this.doughNutLabels
                //['Red', 'Orange', 'Yellow', 'Green', 'Blue']//Object.keys(this.doughtNutMap.data)
            },
            options: {
                responsive: true,
                legend: {
                    position: 'right'
                },
                animation: {
                    animateScale: true,
                    animateRotate: true,
                    onComplete : function() {
                        var ctx = this.chart.ctx;
                        ctx.font = 
                            window.Chart.helpers.fontString(window.Chart.defaults.global.defaultFontFamily,
                                                             'normal', 
                                                             window.Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';
                        this.data.datasets.forEach(function (dataset) {
                            for (var i = 0; i < dataset.data.length; i++) {
                                var model = dataset._meta[Object.keys(dataset._meta)[0]].data[i]._model,
                                    //total = dataset._meta[Object.keys(dataset._meta)[0]].total,
                                    mid_radius = model.innerRadius + (model.outerRadius - model.innerRadius)/2,
                                    start_angle = model.startAngle,
                                    end_angle = model.endAngle,
                                    mid_angle = start_angle + (end_angle - start_angle)/2;
                                var x = mid_radius * Math.cos(mid_angle);
                                var y = mid_radius * Math.sin(mid_angle);
                                ctx.fillStyle = '#fff';
                                if (i === 3){ // Darker text color for lighter background
                                    ctx.fillStyle = '#444';
                                }

                                if(dataset.data[i] !== 0) {
                                    ctx.fillText(dataset.data[i].toLocaleString('de-DE'), model.x + x, model.y + y);
                                }
                            }
                        });
                    }
                },
                events : ['click'],
                elements: {
                    center: {
                        text: percent.toLocaleString('de-DE').replace(/\./g, ',') + '%',
                        color: '#000000', // Default is #000000
                        fontStyle: 'Arial', // Default is Arial
                        sidePadding: 20, // Default is 20 (as a percentage)
                        minFontSize: 10, // Default is 20 (in px), set to false and text will not wrap.
                        lineHeight: 25 // Default is 25 (in px), used for when text wraps
                    }
                }
            }

        };
        return config;
    }

    setConfigbar(data) {

        const config = {
            type: 'bar',
            legend: {
                enabled: true,
                floating: true,
                verticalAlign: 'bottom',
                align:'center'           
            },
            data: data,
            options: {
                /*animation: {
                    onComplete : function() {
                        var ctx = this.chart.ctx;
                        ctx.font = 
                            window.Chart.helpers.fontString(window.Chart.defaults.global.defaultFontFamily,
                                                             'normal', 
                                                             window.Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';

                        this.data.datasets.forEach(function (dataset) {
                            console.log(dataset);
                            for (var i = 0; i < dataset.data.length; i++) {
                                console.log('datasetdata ' + dataset.data[i]);
                                console.log('datasetbar ' + JSON.stringify());
                            }
                        })
                    }
                },*/
                plugins: {
                    title: {
                        display: true,
                        text: 'Chart.js Bar Chart - Stacked'
                    },
                    datalabels: {
                        anchor: 'end',
                        align: 'top',
                        formatter: (value) => value.toLocaleString('de-DE')
                    }       
                },
                responsive: true,
                scales: {
                    xAxes: [{
                    stacked: true
                    }],
                    yAxes: [{
                    stacked: true
                    }]
                }
                }
          };
          return config;
    }

    setDatabar(historyData) {

        let labels =[];
        let datasets = [
            {
                label: 'CXB',
                data: [],
                backgroundColor: '#007EAE'
            },
            {
                label: this.label.morosidad,
                data: [],
                backgroundColor: '#F4C95D'
            },
            {
                label: this.label.otrasComp,
                data: [],
                backgroundColor: '#333333'
            },
            {
                label: this.label.morosidadOtros,
                data: [],
                backgroundColor: '#FBDBA7'
            }
        ]
        historyData.forEach(month => {
            labels.push(month.declarationDate);
            datasets[0].data.push(parseInt(month.arrangedOwnRisk.replace(/\./g, ''), 10));
            datasets[1].data.push(parseInt(month.amountOwnDefaulter.replace(/\./g, ''), 10));
            datasets[2].data.push(parseInt(month.arrangedOtherEnt.replace(/\./g, ''), 10));
            datasets[3].data.push(parseInt(month.amountOwnDefaulterOtherEnt.replace(/\./g, ''), 10));
        });
        //const labels = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ags'];
        const data = {
        labels: labels,
        datasets: datasets
    };
    return data;
}

    
}