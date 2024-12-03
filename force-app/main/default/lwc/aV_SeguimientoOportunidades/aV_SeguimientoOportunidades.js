import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs2 from '@salesforce/resourceUrl/AV_ChartJS';

export default class AV_SeguimientoOportunidades extends LightningElement {
  //@api selection;
  @api measureColumn;
  @api labelColumn;
  @api targetPage;
  @api previousPage;
  @api metadata;
  @api setSelection;
  @api selectMode;
  @api getState;
  @api setState;

  selectedBar = false;

  chart;
  chartjsInitialized = false;

  @api
  get selection() {
    return this._selection;
  }

  set selection(selection) {
    this._selection = selection;
  }

  @api
  get results() {
    return this._results;
  }

  set results(results) {

    /*
    if(this._results !== results && this.chartjsInitialized){
      console.log('generateCanvas results');
      this.generateCanvas();
      console.log('this.results');
    }
    */
    this._results = results;
    if (this.chartjsInitialized) {
      this.generateCanvas();
    }
  }


  renderedCallback() {

    if (this.getState().pageId == this.previousPage) {
      this.setSelection([]);
    }
    this.generateCanvas();
    this.chartjsInitialized = true;
    
  }

  makeConfig() {
    let config = {
      type: 'horizontalBar',
      data: this.createDataChart(),
      options: {
        layout: {
          padding: {
            right: 40
          }

        },
        maintainAspectRatio: false,
        tooltips: {
          enabled: false
        },
        legend: {
          display: false
        },
        hover: {
          enabled: false,
          animationDuration: 0
        },
        scales: {
          xAxes: [{
            display: false,
            gridLines: {
              display: false
            },
            ticks: {
              min: 0
            }
          }],
          yAxes: [{
            gridLines: {
              display: false
            }

          }]
        },

        animation: {

          duration: 0,

          onComplete: function () {

            var chartInstance = this.chart,
              ctx = chartInstance.ctx;
            ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);


            var meta;
            var data;
            this.data.datasets.forEach(function (dataset, i) {
              meta = chartInstance.controller.getDatasetMeta(i);

              meta.data.forEach(function (bar, index) {
                data = dataset.data[index];

                if (data != 0) {

                  if (dataset.label === 'Oportunidades') {
                    data = data.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
                  }
                  else {
                    data = Math.round((dataset.data[index].toFixed(3) * 100) * 10) / 10;
                    data = data.toString().replace('.', ',') + '%';
                  }
                  ctx.textAlign = 'left';
                  ctx.textBaseline = 'center';
                  ctx.fillStyle = '#000000';
                  ctx.fillText(data, bar._model.x + 3, bar._model.y + 5);
                }
              });
            });
          }

        },
        onClick: (event, elements) => {
          if (this.selectedBar) {
            this.navigateOriginalPage();

          }
          else {
            this.selectedBar = true;
            this.setSelection(elements.map((element) => this.results[element._index]));
            this.navigatePage();

          }
          this.generateCanvas();
        }
      }
    };
    return config;
  }

  hashRow(row) {
    return this.metadata.groups.map((group) => row[group]).join('|^|');
  }

  makeColor(index, isFaded) {

    return `rgba(0, 126, 174, ${isFaded ? '0.2' : '1'})`;
  }

  navigatePage() {
    if (this._selection == null || this._selection.length == 0) {
      return [];
    }
    this.setState({ ...this.getState(), pageId: this.targetPage });
  }

  navigateOriginalPage() {
    this.selectedBar = false;
    this.setSelection([]);
    this.setState({ ...this.getState(), pageId: this.previousPage });
    return;
  }

  combine(row) {
    return this.metadata.groups.map((group) => row[group]).join(' - ');
  }

  generateCanvas() {
    loadScript(this, chartjs2 + '/Chart.min.js').then(
      () => {

        let canvas = document.createElement('canvas');
        // disable Chart.js CSS injection
        window.Chart.platform.disableCSSInjection = true;

        const divPrincipal = this.template.querySelector('div.divContainer');
        const divScroll = document.createElement('div');
        divScroll.setAttribute('class', 'divScroll');

        while (divPrincipal.firstChild) {
          divPrincipal.firstChild.remove();
        }


        if (this.results.length > 7) {
          const newHeight = 250 + ((this.results.length - 7) * 20);
          divScroll.style.height = `${newHeight}px`;
        }
        else {
          divScroll.style.height = '300px';
        }

        divPrincipal.appendChild(divScroll).appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this.chart = new window.Chart(ctx, this.makeConfig());

      }).catch((error) => {
        this.showNotification(this.errorTitle, error.body.message, this.errorVariant);
      });

  }

  createDataChart() {
    const selectedRowHashes = new Set(this._selection.map(this.hashRow.bind(this)));
    let labels = [];
    let measures = [];

    if (this.results) {
      this.results.forEach((row) => {
        measures.push(row[this.measureColumn]);
        labels.push(row[this.labelColumn]);
      });
    }

    let datasets = {
      datasets: [
        {
          data: measures,
          backgroundColor: this.results.map((row, i) =>
            this.makeColor(i, selectedRowHashes.size > 0 && !selectedRowHashes.has(this.hashRow(row)))
          ),
          label: this.measureColumn
        }
      ],
      labels: labels
    }
    return datasets;
  }
}