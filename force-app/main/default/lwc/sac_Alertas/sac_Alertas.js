import { LightningElement, api, wire, track } from 'lwc';
import getAlertasList from '@salesforce/apex/SAC_LCMP_Alertas.getAlertasByCaseId';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: 'Fecha creación', fieldName: 'CreatedDate', type: 'date', 
    typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    },
    sortable: true },
    { label: 'Alerta', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Leído', fieldName: 'SAC_Leido__c', type: 'boolean', sortable: true },
    { label: 'Fecha lectura', fieldName: 'SAC_FechaLectura__c', type: 'date',
    typeAttributes: {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    }, 
    sortable: true },
    { label: 'Leído por', fieldName: 'SAC_LeidoPorNombre__c', type: 'text', sortable: true },
    {
        type: "button", initialWidth: 120, typeAttributes: {
            label: 'Ver detalles',
            name: 'Ver detalles',
            title: 'Ver detalles',
            disabled: false,
            value: 'Ver detalles'
        }
    }
];

export default class Sac_Alertas extends NavigationMixin(LightningElement) {
    @api recordId;
    @track tituloTabla;
    @track isDatePickerEnabled = true;
    @track isDatePickerEnabledLectura = true;
    @track isLeidoPickerEnabled = true;
    @track isLeidoPorPickerEnabled = true;
    @track isNamePickerEnabled = true;
    error;
    @track alertas;
    @track wiredAlertasResult;
    sortedBy;
    sortedDirection;
    recordPageUrl;
     showFilters = false;

    @wire(getAlertasList, { recordId: '$recordId' })
    wiredAlertas(result) {
        this.wiredAlertasResult = result;
        if (result.data) {
            this.alertas = result.data;
            this.error = undefined;
            this.tituloTabla = 'Alertas (' +  this.alertas.length + ')';
        } else if (result.error) {
            this.error = result.error;
            this.alertas = undefined;
        }
    }

    handleSortData(event) {
        // const { fieldName, sortDirection } = event.detail;
        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection
        const cloneData = [...this.alertas];

        cloneData.sort(this.sortBy(fieldName, sortDirection === 'asc' ? 1 : -1));
        this.alertas = cloneData;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };
    
        return function (a, b) {
            const valueA = key(a);
            const valueB = key(b);
    
            if (typeof valueA === 'boolean' && typeof valueB === 'boolean') {
                return reverse * (valueA === valueB ? 0 : (valueA ? -1 : 1));
            }
    
            const A = valueA ? valueA.toString().toUpperCase() : '';
            const B = valueB ? valueB.toString().toUpperCase() : '';
            let comparison = 0;
    
            if (A > B) {
                comparison = 1;
            } else if (A < B) {
                comparison = -1;
            }
            return reverse * comparison;
        };
    }

    handleRefreshClick() {
        //this.alertas = wiredAlertasResult;
        return refreshApex(this.wiredAlertasResult);
    }

    handleRowAction(event) {
        let alertId = event.detail.row.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: alertId,
                objectApiName: 'SAC_Alerta__c',
                actionName: 'view'
            }
        });
    }

    handleFiltro(event) {
        this.showFilters = !this.showFilters;
    }

    handlePicklistChange(event) {
        const selectedComparison = event.target.value;
        
        this.isDatePickerEnabled = !(selectedComparison === 'opcion1' || selectedComparison === 'opcion2' || selectedComparison === 'opcion3');
    }

    handlePicklistChangeLectura(event) {
        const selectedComparisonLectura = event.target.value;
        
        this.isDatePickerEnabledLectura = !(selectedComparisonLectura === 'opcion1' || selectedComparisonLectura === 'opcion2' || selectedComparisonLectura === 'opcion3');
    }

    handlePicklistChangeLeido(event) {
        const selectedComparisonLeido = event.target.value;
        
        this.isLeidoPickerEnabled = !(selectedComparisonLeido === 'opcionSI' || selectedComparisonLeido === 'opcionNO');
    }

    handlePicklistChangeLeidoPor(event) {
        const selectedComparisonLeidoPor = event.target.value;
        
        this.isLeidoPorPickerEnabled = !(selectedComparisonLeidoPor === 'opcion1' || selectedComparisonLeidoPor === 'opcion2');
    }

    handlePicklistChangeName(event) {
        const selectedComparisonName = event.target.value;
        
        this.isNamePickerEnabled = !(selectedComparisonName === 'opcion1' || selectedComparisonName === 'opcion2');
    }
    

    handleFiltrar(event) {

        const selectedDateValueLectura = this.template.querySelector('.date-picker_lectura').value;     //Fecha de lectura
        const selectedComparisonLectura = this.template.querySelector('.picklist_fechaLectura').value;

        const selectedDateValue = this.template.querySelector('.date-picker_creacion').value; //fecha creacion
        const selectedComparison = this.template.querySelector('.picklist_fechaCreacion').value;

        const selectedComparisonLeido = this.template.querySelector('.picklist_leido').value;
        const selectedComparisonLeidoPor = this.template.querySelector('.picklist_leidoPor').value;
        const selectedComparisonName = this.template.querySelector('.picklist_alertaName').value;

        var inp1 = this.template.querySelector('.text-input-leido').value;
        var inp2 = this.template.querySelector('.text-input-alerta').value;
        
        let filteredAlertas = this.wiredAlertasResult.data;
          
        
          // NOMBRE ALERTA
          if (selectedComparisonName === "opcion1") { // Igual
             filteredAlertas = filteredAlertas.filter(alerta => 
                alerta.Name === inp2
            );
        } else if (selectedComparisonName === "opcion2") { // Diferente
            filteredAlertas = filteredAlertas.filter(alerta => 
                alerta.Name !== inp2
            );
        } else if (selectedComparisonName === "opcion3") { // Empieza con
            filteredAlertas = filteredAlertas.filter(alerta => 
                alerta.Name.startsWith(inp2)
            );
        } else if (selectedComparisonName === "opcion4") { // Acaba en
            filteredAlertas = filteredAlertas.filter(alerta => 
                alerta.Name.endsWith(inp2)
            );
        } else if (selectedComparisonName === "opcion5") { // Contiene
            filteredAlertas = filteredAlertas.filter(alerta => 
                alerta.Name.includes(inp2)
            );
        } else if (selectedComparisonName === "opcion6") { // No contiene
            filteredAlertas = filteredAlertas.filter(alerta => 
                !alerta.Name.includes(inp2)
            );
        }


        // NOMBRE Leido Por
        if (selectedComparisonLeidoPor === "opcion1") { // Igual
            filteredAlertas = filteredAlertas.filter(alerta => 
                alerta.SAC_LeidoPorNombre__c === inp1
            );
        } else if (selectedComparisonLeidoPor === "opcion2") { // Diferente
            filteredAlertas = filteredAlertas.filter(alerta => 
                alerta.SAC_LeidoPorNombre__c !== inp1
            );
        } else if (selectedComparisonLeidoPor === "opcion3") { // Empieza con
            filteredAlertas = filteredAlertas.filter(alerta => {
                if (alerta.SAC_LeidoPorNombre__c != null) {
                    return alerta.SAC_LeidoPorNombre__c.startsWith(inp1);
                }
                return false;
            });
        } else if (selectedComparisonLeidoPor === "opcion4") { // Termina en
            filteredAlertas = filteredAlertas.filter(alerta => {
                if (alerta.SAC_LeidoPorNombre__c != null) {
                    return alerta.SAC_LeidoPorNombre__c.endsWith(inp1);
                }
                return false;
            });
        } else if (selectedComparisonLeidoPor === "opcion5") { // Contiene
            filteredAlertas = filteredAlertas.filter(alerta => {
                if (alerta.SAC_LeidoPorNombre__c != null) {
                    return alerta.SAC_LeidoPorNombre__c.includes(inp1);
                }
                return false;
            });
        } else if (selectedComparisonLeidoPor === "opcion6") { // No contiene
            filteredAlertas = filteredAlertas.filter(alerta => {
                if (alerta.SAC_LeidoPorNombre__c != null) {
                    return !alerta.SAC_LeidoPorNombre__c.includes(inp1);
                }
                return false;
            });
        }
        
        

        // LEIDO SI O NO
        if(selectedComparisonLeido === "opcionSI"){
            filteredAlertas = filteredAlertas.filter(alerta =>
                alerta.SAC_Leido__c === true
            );
        }                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
       else if (selectedComparisonLeido === "opcionNO"){
            filteredAlertas = filteredAlertas.filter(alerta =>
                alerta.SAC_Leido__c === false
            );
        }

        //FECHA CREACION 
         if (selectedComparison === "opcion1") { // Igual a
             filteredAlertas = filteredAlertas.filter(alerta =>
                 new Date(alerta.CreatedDate).toISOString().split('T')[0] === selectedDateValue
             );
         } else if (selectedComparison === "opcion2") { // Después de
             filteredAlertas= filteredAlertas.filter(alerta =>
                 new Date(alerta.CreatedDate).toISOString().split('T')[0] > selectedDateValue
             );
         } else if (selectedComparison === "opcion3") { // Antes de
             filteredAlertas = filteredAlertas.filter(alerta =>
                 new Date(alerta.CreatedDate).toISOString().split('T')[0] < selectedDateValue
             );
         } else if (selectedComparison === 'opcion4') { // Mañana
            const today = new Date();
            const tomorrowStart = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
            const tomorrowEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 2);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= tomorrowStart && alertaDate < tomorrowEnd;
            });
        } else if (selectedComparison === 'opcion5') { // Hoy
              const today = new Date();
              const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
              const todayEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);

              filteredAlertas = filteredAlertas.filter(alerta => {
                  const alertaDate = new Date(alerta.CreatedDate);
                  return alertaDate >= todayStart && alertaDate < todayEnd;
              });
          } else if (selectedComparison === 'opcion6') { // Ayer
              const today = new Date();
              const yesterdayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 1);
              const yesterdayEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate());

              filteredAlertas = filteredAlertas.filter(alerta => {
                  const alertaDate = new Date(alerta.CreatedDate);
                  return alertaDate >= yesterdayStart && alertaDate < yesterdayEnd;
              });
          } else if (selectedComparison === 'opcion7') { // La semana siguiente
            const today = new Date();
            const nextWeekStart = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7);
            const nextWeekEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 14);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= nextWeekStart && alertaDate < nextWeekEnd;
            });
        }else if (selectedComparison === 'opcion8') { // Esta semana
            const today = new Date();
            const firstDayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay());
            const lastDayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() + (6 - today.getDay()));
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfWeek && alertaDate <= lastDayOfWeek;
            });
        }else if (selectedComparison === 'opcion9') { // Semana pasada
            const today = new Date();
            const firstDayOfLastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() - 7);
            const lastDayOfLastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() - 1);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfLastWeek && alertaDate <= lastDayOfLastWeek;
            });
        } else if (selectedComparison === 'opcion10') { // Mes siguiente
            const today = new Date();
            const firstDayOfNextMonth = new Date(today.getFullYear(), today.getMonth() + 1, 1);
            const lastDayOfNextMonth = new Date(today.getFullYear(), today.getMonth() + 2, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfNextMonth && alertaDate <= lastDayOfNextMonth;
            });
        }
        else if (selectedComparison === 'opcion11') { // Este mes
            const today = new Date();
            const firstDayOfCurrentMonth = new Date(today.getFullYear(), today.getMonth(), 1);
            const lastDayOfCurrentMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfCurrentMonth && alertaDate <= lastDayOfCurrentMonth;
            });
        } else if (selectedComparison === 'opcion12') { // Mes pasado
            const today = new Date();
            const firstDayOfLastMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1);
            const lastDayOfLastMonth = new Date(today.getFullYear(), today.getMonth(), 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfLastMonth && alertaDate <= lastDayOfLastMonth;
            });
        }else if(selectedComparison === 'opcion13') { // Trimestre siguiente
            const today = new Date();
            const currentMonth = today.getMonth();
            const firstDayOfNextQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3 + 3, 1);
            const lastDayOfNextQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3 + 6, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfNextQuarter && alertaDate <= lastDayOfNextQuarter;
            });
        }
        else if (selectedComparison === 'opcion14') { // Este trimestre
            const today = new Date();
            const currentMonth = today.getMonth();
            const firstDayOfCurrentQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3, 1);
            const lastDayOfCurrentQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3 + 3, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfCurrentQuarter && alertaDate <= lastDayOfCurrentQuarter;
            });
        } else if (selectedComparison === 'opcion15') { // Trimestre pasado
            const today = new Date();
            const currentMonth = today.getMonth();
            const firstDayOfLastQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3 - 3, 1);
            const lastDayOfLastQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfLastQuarter && alertaDate <= lastDayOfLastQuarter;
            });
        }else if (selectedComparison === 'opcion16') { // Año siguiente
            const today = new Date();
            const nextYear = today.getFullYear() + 1;
            const firstDayOfNextYear = new Date(nextYear, 0, 1);
            const lastDayOfNextYear = new Date(nextYear, 11, 31);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfNextYear && alertaDate <= lastDayOfNextYear;
            });
        }else if (selectedComparison === 'opcion17') { // Este año
            const today = new Date();
            const currentYear = today.getFullYear();
            const firstDayOfCurrentYear = new Date(currentYear, 0, 1);
            const lastDayOfCurrentYear = new Date(currentYear, 11, 31);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfCurrentYear && alertaDate <= lastDayOfCurrentYear;
            });
        } else if (selectedComparison === 'opcion18') { // Año pasado
            const today = new Date();
            const currentYear = today.getFullYear();
            const firstDayOfLastYear = new Date(currentYear - 1, 0, 1);
            const lastDayOfLastYear = new Date(currentYear - 1, 11, 31);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.CreatedDate);
                return alertaDate >= firstDayOfLastYear && alertaDate <= lastDayOfLastYear;
            });
        }
        
        
        //FECHA LECTURA

        if (selectedComparisonLectura === "opcion1") { //Igual a 
             filteredAlertas = filteredAlertas.filter(alerta =>{
                if(alerta.SAC_FechaLectura__c != null){
                return new Date(alerta.SAC_FechaLectura__c).toISOString().split('T')[0] === selectedDateValueLectura;
                }
                return false
        });         
         } else if (selectedComparisonLectura === "opcion2") { // Después de
                filteredAlertas = filteredAlertas.filter(alerta =>{
                if(alerta.SAC_FechaLectura__c != null){
                    return new Date(alerta.SAC_FechaLectura__c).toISOString().split('T')[0] > selectedDateValueLectura;
                    }
                    return false
            });
          } else if (selectedComparisonLectura === "opcion3") { // Antes de
            filteredAlertas = filteredAlertas.filter(alerta =>{
            if(alerta.SAC_FechaLectura__c != null){
                return new Date(alerta.SAC_FechaLectura__c).toISOString().split('T')[0] < selectedDateValueLectura;
                }
                return false
        });
          }else if (selectedComparisonLectura === 'opcion4') { // Mañana
            const today = new Date();
            const tomorrowStart = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
            const tomorrowEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 2);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= tomorrowStart && alertaDate < tomorrowEnd;
            });
        } else if (selectedComparisonLectura === 'opcion5') { // Hoy
              const today = new Date();
              const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
              const todayEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);

              filteredAlertas = filteredAlertas.filter(alerta => {
                  const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                  return alertaDate >= todayStart && alertaDate < todayEnd;
              });
          } else if (selectedComparisonLectura === 'opcion6') { // Ayer
              const today = new Date();
              const yesterdayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 1);
              const yesterdayEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate());

              filteredAlertas = filteredAlertas.filter(alerta => {
                  const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                  return alertaDate >= yesterdayStart && alertaDate < yesterdayEnd;
              });
          } else if (selectedComparisonLectura === 'opcion7') { // La semana siguiente
            const today = new Date();
            const nextWeekStart = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7);
            const nextWeekEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 14);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= nextWeekStart && alertaDate < nextWeekEnd;
            });
        }else if (selectedComparisonLectura === 'opcion8') { // Esta semana
            const today = new Date();
            const firstDayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay());
            const lastDayOfWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() + (6 - today.getDay()));
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfWeek && alertaDate <= lastDayOfWeek;
            });
        }else if (selectedComparisonLectura === 'opcion9') { // Semana pasada
            const today = new Date();
            const firstDayOfLastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() - 7);
            const lastDayOfLastWeek = new Date(today.getFullYear(), today.getMonth(), today.getDate() - today.getDay() - 1);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfLastWeek && alertaDate <= lastDayOfLastWeek;
            });
        } else if (selectedComparisonLectura === 'opcion10') { // Mes siguiente
            const today = new Date();
            const firstDayOfNextMonth = new Date(today.getFullYear(), today.getMonth() + 1, 1);
            const lastDayOfNextMonth = new Date(today.getFullYear(), today.getMonth() + 2, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfNextMonth && alertaDate <= lastDayOfNextMonth;
            });
        }
        else if (selectedComparisonLectura === 'opcion11') { // Este mes
            const today = new Date();
            const firstDayOfCurrentMonth = new Date(today.getFullYear(), today.getMonth(), 1);
            const lastDayOfCurrentMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfCurrentMonth && alertaDate <= lastDayOfCurrentMonth;
            });
        } else if (selectedComparisonLectura === 'opcion12') { // Mes pasado
            const today = new Date();
            const firstDayOfLastMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1);
            const lastDayOfLastMonth = new Date(today.getFullYear(), today.getMonth(), 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfLastMonth && alertaDate <= lastDayOfLastMonth;
            });
        }else if(selectedComparisonLectura === 'opcion13') { // Trimestre siguiente
            const today = new Date();
            const currentMonth = today.getMonth();
            const firstDayOfNextQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3 + 3, 1);
            const lastDayOfNextQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3 + 6, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfNextQuarter && alertaDate <= lastDayOfNextQuarter;
            });
        }
        else if (selectedComparisonLectura === 'opcion14') { // Este trimestre
            const today = new Date();
            const currentMonth = today.getMonth();
            const firstDayOfCurrentQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3, 1);
            const lastDayOfCurrentQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3 + 3, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfCurrentQuarter && alertaDate <= lastDayOfCurrentQuarter;
            });
        } else if (selectedComparisonLectura === 'opcion15') { // Trimestre pasado
            const today = new Date();
            const currentMonth = today.getMonth();
            const firstDayOfLastQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3 - 3, 1);
            const lastDayOfLastQuarter = new Date(today.getFullYear(), Math.floor(currentMonth / 3) * 3, 0);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfLastQuarter && alertaDate <= lastDayOfLastQuarter;
            });
        }else if (selectedComparisonLectura === 'opcion16') { // Año siguiente
            const today = new Date();
            const nextYear = today.getFullYear() + 1;
            const firstDayOfNextYear = new Date(nextYear, 0, 1);
            const lastDayOfNextYear = new Date(nextYear, 11, 31);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfNextYear && alertaDate <= lastDayOfNextYear;
            });
        }else if (selectedComparisonLectura === 'opcion17') { // Este año
            const today = new Date();
            const currentYear = today.getFullYear();
            const firstDayOfCurrentYear = new Date(currentYear, 0, 1);
            const lastDayOfCurrentYear = new Date(currentYear, 11, 31);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfCurrentYear && alertaDate <= lastDayOfCurrentYear;
            });
        } else if (selectedComparisonLectura === 'opcion18') { // Año pasado
            const today = new Date();
            const currentYear = today.getFullYear();
            const firstDayOfLastYear = new Date(currentYear - 1, 0, 1);
            const lastDayOfLastYear = new Date(currentYear - 1, 11, 31);
        
            filteredAlertas = filteredAlertas.filter(alerta => {
                const alertaDate = new Date(alerta.SAC_FechaLectura__c);
                return alertaDate >= firstDayOfLastYear && alertaDate <= lastDayOfLastYear;
            });
        }


        this.tituloTabla = 'Alertas (' + filteredAlertas.length + ')';
        this.alertas = filteredAlertas;
        
    }
    
    get columns() {
        return columns;
    }
}