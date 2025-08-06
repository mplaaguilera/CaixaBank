({
    
    selectColumns: function(component, event){
    
        component.set('v.mycolumns', [

            {label: 'Oficina', fieldName: 'SAC_Oficina__rName', type: 'text', wrapText: true, sortable: true, cellAttributes:{class:{fieldName:'colorRow'}, style: "color: black !important;"}},
            {label: 'Gestor Centro', fieldName: 'ownerName', type: 'text', wrapText: true, sortable: true, cellAttributes:{class:{fieldName:'colorRow'}, style: "color: black !important;"}},
            {label: 'Reclamante', fieldName: 'SAC_Reclamacion__rAccountName', type: 'text', wrapText: true, sortable: true, cellAttributes:{class:{fieldName:'colorRow'}, style: "color: black !important;"}},
            {label: 'Numero documento', fieldName: 'SAC_Reclamacion__rAccountCC_Numero_Documento__c', type: 'text', sortable: true, cellAttributes:{class:{fieldName:'colorRow'}, style: "color: black !important;"}},
            {label: 'Estado', fieldName: 'SAC_Estado__c', type: 'text', wrapText: true, sortable: "true", cellAttributes:{class:{fieldName:'colorRow'}, style: "color: black !important;"}},        
            {label: 'Fecha vencimiento', fieldName: 'SAC_FechaLimite__c', type: 'date', sortable: true, cellAttributes:{class:{fieldName:'colorRow' }, style: "color: black !important;"}},
            {label: 'View', type: 'button', initialWidth: 135, typeAttributes: { label: 'Ver detalles', name: 'view_details', title: 'Click para ver los detalles'},
            cellAttributes:{
                class:{fieldName:'colorRow'}
            }}
        ]);

    },
    
    getActionOffice: function(component, event) {

        var sTipoBusqueda = component.get("v.sTipoBusqueda");
        let busquedaPorDefecto = component.get("v.porDefecto");
        let sBusqueda = component.get("v.sBusqueda");
        let sBusquedaDesde = component.get("v.sBusquedaDesde");
        let sBusquedaHasta = component.get("v.sBusquedaHasta");

       let getTareas = component.get("c.getActionOffice");

       if(busquedaPorDefecto === true){
            sTipoBusqueda = 'porDefecto';
            getTareas.setParams({
                'tipoBusqueda': sTipoBusqueda
            });
        }
        else if(busquedaPorDefecto === false){
            if(sTipoBusqueda == 'idTarea' || sTipoBusqueda == 'asunto' || sTipoBusqueda == 'estado'){
                getTareas.setParams({
                    'tipoBusqueda': sTipoBusqueda,
                    'valorBuscado': sBusqueda
                });
            }
            else if(sTipoBusqueda == 'fechaCreacion'){
                getTareas.setParams({
                    'tipoBusqueda': sTipoBusqueda,
                    'valorBuscadoDesde': sBusquedaDesde,
                    'valorBuscadoHasta': sBusquedaHasta
                });
            }
        }
        getTareas.setCallback(this, function(response){
            
            let rightNow = new Date();
                rightNow.setMinutes(
                    new Date().getMinutes() - new Date().getTimezoneOffset()
                );
            let yyyyMmDd = rightNow.toISOString().slice(0,10);

            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading' , false);
                let rows = response.getReturnValue();

                if(rows == '' || rows == null || rows == undefined){ /*&& sBusqueda != ''*/
                    component.set('v.bError', true);
                    component.set('v.sMensErr', 'No se ha identificado ninguna consulta que coincida con su búsqueda.');
                }else{
                    component.set('v.bError', false);
                }
                
                for ( let i = 0; i < rows.length; i++ ) {
                    let row = rows[i];
                    if ( row.SAC_Oficina__r ) {
                        row.SAC_Oficina__rName = row.SAC_Oficina__r.Name;
                    }
                    if ( row.SAC_Reclamacion__r ) {
                        row.SAC_Reclamacion__rCaseNumber = row.SAC_Reclamacion__r.CaseNumber;
                    
                        if ( row.SAC_Reclamacion__r.Account ) {

                            if ( row.SAC_Reclamacion__r.Account.Name ) {
                                row.SAC_Reclamacion__rAccountName = row.SAC_Reclamacion__r.Account.Name;
                            }
                            if ( row.SAC_Reclamacion__r.Account.CC_Numero_Documento__c ) {
                                row.SAC_Reclamacion__rAccountCC_Numero_Documento__c = row.SAC_Reclamacion__r.Account.CC_Numero_Documento__c;
                            }
                        }
                    
                    }
                    if(row.SAC_FechaVencimientoProrroga__c != undefined && row.SAC_FechaVencimientoProrroga__c != null){
                        row.SAC_FechaLimite__c = row.SAC_FechaVencimientoProrroga__c;
                    }
                    else if(row.SAC_FechaVencimientoInicial__c != undefined && row.SAC_FechaVencimientoInicial__c != null){
                        row.SAC_FechaLimite__c = row.SAC_FechaVencimientoInicial__c;
                    }

                    if(row.SAC_FechaLimite__c == yyyyMmDd){
                        row.colorRow = "slds-theme_warning";
                    }else if(row.SAC_FechaLimite__c < yyyyMmDd){
                        row.colorRow = "slds-theme_error";
                    }
                    
                    if(row.Owner) {
                        row.ownerName = row.Owner.Name;
                    }

                    if(row.SAC_Estado__c){
                        row.SAC_Estado__c = row.SAC_Estado__c;
                    }

                }

                component.set("v.TareasList", rows);
                this.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
                component.set("v.cargando", false);
                 
            } else {
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
           }
        });
        $A.enqueueAction(getTareas);
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.TareasList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse));
        component.set("v.TareasList", data);
    },
    
    sortByfield: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            a = key(a); 
            b = key(b);
            if(!a) {
                return 1;
            }
            if(!b) {
                return -1;
            }
            return reverse * ((a > b) - (b > a));
        }
    },

    buscarTarea : function(component, event){
        
        if(component.get("v.selectedSearch") === true){
            component.set("v.selectedSearch", false);
        }else if(component.get("v.selectedSearch") === false){
            component.set("v.selectedSearch", true);
        }
    },

    getEstados: function(component, event){
    
        let getEstados = component.get("c.getEstados");
        getEstados.setParams({
            'objectName': 'tarea'
        });
        getEstados.setCallback(this, function(response){
            let state = response.getState();

            if (state === "SUCCESS") {
                let estados = response.getReturnValue();
                component.set('v.optionsEstado' , estados);
            }
        });
        $A.enqueueAction(getEstados);
    }
})