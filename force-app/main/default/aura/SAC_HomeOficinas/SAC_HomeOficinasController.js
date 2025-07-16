({
    changeColumns: function(component, event, helper){
        helper.changeColumns(component, event);
    },

    getData : function(component, event, helper) {

        component.set("v.caseList");
        component.set("v.atrList");

        let selectedSearch = component.get("v.selectedSearch");
        let sTipoBusqueda = component.get("v.sTipoBusqueda");
        let sBusqueda = component.get("v.sBusqueda");
        let sBusquedaDesde = component.get("v.sBusquedaDesde");
        let sBusquedaHasta = component.get("v.sBusquedaHasta");

        let getCases = component.get("c.getCases");
        if(selectedSearch == 'Cliente'){
            getCases.setParams({
                'accountId': component.get("v.accountId")
            });
        }
        else if(selectedSearch == 'Oficina'){
            getCases.setParams({
                'oficina': component.get("v.accountId"),
                'tipoBusquedaOficina' : component.get("v.sTipoBusquedaOficina")
                
            });
        }
        else if(selectedSearch == 'Reclamacion'){
            if(sTipoBusqueda == 'idCaso' || sTipoBusqueda == 'nif' || sTipoBusqueda == 'nombreCliente'){
                getCases.setParams({
                    'tipoBusqueda': sTipoBusqueda,
                    'valorBuscado': sBusqueda
                });
            }else if(sTipoBusqueda == 'fechaRecep'){
                getCases.setParams({
                    'tipoBusqueda': sTipoBusqueda,
                    'valorBuscadoDesde': sBusquedaDesde,
                    'valorBuscadoHasta': sBusquedaHasta
                });
            }
        }

        getCases.setCallback(this, function(response){
            
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading' , false);
                var records =response.getReturnValue();

                if(records == '' && selectedSearch == 'Reclamacion' ){
                    component.set('v.bError', true);
                    component.set('v.sMensErr', 'No se ha identificado ninguna reclamación que coincida con su búsqueda.');
                }else{
                    component.set('v.bError', false);
                }

                records.forEach(function(record){
                    record.reclamacionLink = "/"+record.Id;
                });
                let rows = response.getReturnValue();
                for ( let i = 0; i < rows.length; i++ ) {
                    let row = rows[i];
                    if ( row.Account ) {
                        row.AccountName = row.Account.Name;
                        row.AccountCC_Numero_Documento__c = row.Account.CC_NumeroDocumento__c;
                    }
                   
                    if ( row.SEG_Grupo__r ) {
                        row.SEG_Grupo__rName = row.SEG_Grupo__r.Name;
                    }

                    if ( row.Owner ) {
                        row.OwnerName = row.Owner.Name;
                    }

                    if ( row.CC_MCC_Tematica__r ) {
                        row.CC_MCC_Tematica__rName = row.CC_MCC_Tematica__r.Name;
                    }

                    if ( row.CC_MCC_ProdServ__r ) {
                        row.CC_MCC_ProdServ__rName = row.CC_MCC_ProdServ__r.Name;
                    }

                    if ( row.CC_MCC_Motivo__r ) {
                        row.CC_MCC_Motivo__rName = row.CC_MCC_Motivo__r.Name;
                    }

                    if ( row.SEG_Detalle__r ) {
                        row.SEG_Detalle__rName = row.SEG_Detalle__r.Name;
                    }
                   
                }
                component.set("v.caseList", rows);
            }
        });
        $A.enqueueAction(getCases);

        //Consulta reclamaciones históricas ATR
        if(selectedSearch == 'Cliente')
        {
            let getExternalCases = component.get("c.getExternalCases");
            getExternalCases.setParams({
                'accountId': component.get("v.accountId")
            });
            getExternalCases.setCallback(this, function(response){
                let state = response.getState();
                if (state === "SUCCESS") {
                    let rowsATR = response.getReturnValue();                    

                    if(rowsATR){
                        for ( let i = 0; i < rowsATR.length; i++ ) {
                            if (rowsATR[i].customerIds){
                                for ( let j = 0; j < rowsATR[i].customerIds.length; j++ ) {
                                    if (j!==0){
                                        rowsATR[i].customers= rowsATR[i].customers+"  /  ";
                                    }
                                    rowsATR[i].customers= rowsATR[i].customers+rowsATR[i].customerIds[j];
                                }
                            }
                        }
                        if(rowsATR[0].claimCode != null){
                            component.set("v.atrList", rowsATR);
                        }
                    }
                }
            });
            $A.enqueueAction(getExternalCases);
        }
    },

    buscarPorOficina: function(component, event, helper){
        component.set("v.accountId")
        component.set("v.caseList");
        component.set("v.atrList");
        helper.buscarPorOficina(component, event);
    },

    buscarPorCliente: function(component, event, helper){
        component.set("v.accountId")
        component.set("v.caseList");
        component.set("v.atrList");
        helper.buscarPorCliente(component, event);
    },

    buscarPorReclamacion: function(component, event, helper){
        component.set("v.accountId")
        component.set("v.caseList");
        component.set("v.atrList");
        component.set("v.sBusqueda");
        component.set('v.bError', false);
        helper.buscarPorReclamacion(component, event);
    },
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": row.Id,
                      "slideDevName": "detail"
                    });
                    navEvt.fire();
                break;
            default:
                alert(row.Id);
                break;
        }
    },

    handleError: function(component, event) {
        var errors = event.getParams();
    },


    buscarAlfabetico: function(component, event, helper) {
        component.set('v.isLoading' , true);

        var action = component.get('c.getData');
        $A.enqueueAction(action);
    },

    handleChange: function(component) {
        component.set("v.accountId")
        //component.set("v.caseList");
        component.set("v.atrList");
        component.set("v.sBusqueda");
        component.set('v.bError', false);
	},

    valorBusquedaTeclaPulsada: function(component, event) {
		if (event.which === 13) { //Intro
			$A.enqueueAction(component.get('c.buscarAlfabetico'));
		}
	}
})