({
    consultarCotitulares : function (component, event, helper) {
        var action=component.get('c.getAntecedentesCotitularesToShow');
        var antecedentes=[];
        action.setParams({
            "tf7Codigo" : component.get('v.codigoPrestamo'),
            "recId": component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            component.set('v.spinner', true);
            var state=response.getState();
            console.log('*state ' + state);
            if(state==="SUCCESS"){             
                var response = response.getReturnValue();
                var listadoSAC = response['SAC'];
                var listadoCBPO = response['CBPO'];
                if(listadoSAC.length > 0){
                    component.set("v.antecedentesHistoricosExist", true);
                    component.set("v.antecedentesList",listadoSAC);
                }
                if(listadoCBPO.length > 0){
                    component.set("v.antecedentesCBPOExist", true);
                    component.set("v.antecedentesCBPOList",listadoCBPO);
                }
            }
            var action2=component.get('c.getEntidadCotitularesToShow');
            action2.setParams({
                "tf7Codigo" : component.get('v.codigoPrestamo'),
                "recId": component.get('v.recordId')
            });
            action2.setCallback(this,function(response){
                var state2=response.getState();
                console.log('*state2 ' + state2);
                var responseLength=response.getReturnValue().length;
                if(state2==="SUCCESS"){             
                    var response = response.getReturnValue();
                    if(responseLength > 0){
                        component.set("v.demandasEntidadExist", true);
                        component.set("v.demandasEntidadList",response);
                    }
                }
                var action3=component.get('c.getMorosidadCotitularesToShow');
                action3.setParams({
                    "tf7Codigo" : component.get('v.codigoPrestamo'),
                    "recId": component.get('v.recordId')
                });
                action3.setCallback(this,function(response){
                    var state3=response.getState();
                    console.log('*state3 ' + state3);
                    var responseLength=response.getReturnValue().length;
                    if(state3==="SUCCESS"){             
                        var response = response.getReturnValue();
                        if(responseLength > 0){
                            component.set("v.demandasMorosidadExist", true);
                            component.set("v.demandasMorosidadList",response);
                        }
                    }
                    var action4=component.get('c.getConcursosToShow');
                    action4.setParams({
                        "tf7Codigo" : component.get('v.codigoPrestamo'),
                        "recId": component.get('v.recordId')
                    });
                    action4.setCallback(this,function(response){
                        var state4=response.getState();
                        console.log('*state4 ' + state4);
                        var responseLength=response.getReturnValue().length;
                        if(state4==="SUCCESS"){             
                            var response = response.getReturnValue();
                            if(responseLength > 0){
                                component.set("v.concursosExist", true);
                                component.set("v.concursosList",response);
                            }
                        }
                        var action5=component.get('c.getReclamacionesAnterioresToShow');
                        action5.setParams({
                            "tf7Codigo" : component.get('v.codigoPrestamo'),
                            "recId": component.get('v.recordId')
                        });
                        action5.setCallback(this,function(response){
                            var state5=response.getState();
                            console.log('*state5 ' + state5);
                            var responseLength=response.getReturnValue().length;
                            if(state5==="SUCCESS"){             
                                var response = response.getReturnValue();
                                if(responseLength > 0){
                                    component.set("v.reclamacionesAnterioresExist", true);
                                    component.set("v.reclamacionesAnterioresList",response);
                                }
                            }
                        });
                        component.set('v.spinner', false);
                        $A.enqueueAction(action5);
                    });
                    $A.enqueueAction(action4);
                });
                $A.enqueueAction(action3);
            });
            $A.enqueueAction(action2);
        });
        $A.enqueueAction(action);
    },
    navigateToRelatedList: function(component,event,helper){
        var rlEvent = $A.get("e.force:navigateToRelatedList");
        rlEvent.setParams({
            "relatedListId": "AntecedentesRecHistSAC__r",
            "parentRecordId": component.get("v.recordId")
        });
        rlEvent.fire();
    },
    navigateToRecord: function(component, event, helper) {
        var recordId = event.target.getAttribute("data-recordId");
        var navService = component.find("navService");
        
        var pageReference = {
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                objectApiName: "SAC_Antecedentes__c", 
                actionName: "view"
            }
        };
        
        // Navegar a la página del registro
        navService.navigate(pageReference);
    }
})