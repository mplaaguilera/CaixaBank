({
    consultarCotitulares : function (component, event, helper) {
        var action1=component.get('c.getReclamacionesAnterioresToShow');
        action1.setParams({
            "recId": component.get('v.recordId')
        });
        action1.setCallback(this,function(response){
            component.set('v.spinner', true);
            var state1=response.getState();
            if(state1==="SUCCESS"){
                var response = response.getReturnValue();
                var reclamantes = response['reclamante'];
                var cotitulares = response['cotitular'];
                if(reclamantes != null && reclamantes != '' && reclamantes != 'undefined'){
                    component.set('v.reclAntExist', true);
                    component.set('v.reclAntReclamanteExist', true);
                    component.set('v.reclAntReclamanteList', reclamantes);
                }
                if(cotitulares != null && cotitulares != '' && cotitulares != 'undefined'){
                    component.set('v.reclAntExist', true);
                    component.set('v.reclAntCotitularExist', true);
                    component.set('v.reclAntCotitularList', cotitulares);
                }
            }
            var action2=component.get('c.getAntecedentesToShow');
            var antecedentes=[];
            action2.setParams({
                "recId": component.get('v.recordId')
            });
            action2.setCallback(this,function(response){
                var state2=response.getState();
                if(state2==="SUCCESS"){
                    var response = response.getReturnValue();
                    var reclamantes = response['reclamante'];
                    var cotitulares = response['cotitular'];
                    var listadoSACRec;
                    var listadoCBPORec;
                    var listadoSACCot;
                    var listadoCBPOCot;
                    if(reclamantes != null && reclamantes != '' && reclamantes != 'undefined'){ 
                        listadoSACRec = reclamantes['SAC'];
                        listadoCBPORec = reclamantes['CBPO'];
                    }
                    if(cotitulares != null && cotitulares != '' && cotitulares != 'undefined'){ 
                        listadoSACCot = cotitulares['SAC'];
                        listadoCBPOCot = cotitulares['CBPO'];
                    }
                    if(listadoSACRec != null && listadoSACRec != '' && listadoSACRec != 'undefined'){
                        component.set('v.antHistExist', true);
                        component.set('v.antHistReclamanteExist', true);
                        component.set('v.antHistReclamanteList', listadoSACRec);
                    }
                    if(listadoCBPORec != null && listadoCBPORec != '' && listadoCBPORec != 'undefined'){
                        component.set('v.antCBPOExist', true);
                        component.set('v.antCBPOReclamanteExist', true);
                        component.set('v.antCBPOReclamanteList', listadoCBPORec);
                    }
                    if(listadoSACCot != null && listadoSACCot != '' && listadoSACCot != 'undefined'){
                        component.set('v.antHistExist', true);
                        component.set('v.antHistCotitularExist', true);
                        component.set('v.antHistCotitularList', listadoSACCot);
                    }
                    if(listadoCBPOCot != null && listadoCBPOCot != '' && listadoCBPOCot != 'undefined'){
                        component.set('v.antCBPOExist', true);
                        component.set('v.antCBPOCotitularExist', true);
                        component.set('v.antCBPOCotitularList', listadoCBPOCot);
                    }
                }
                var action3=component.get('c.getDemandasEntidadToShow');
                action3.setParams({
                    "recId": component.get('v.recordId')
                });
                action3.setCallback(this,function(response){
                    var state3=response.getState();
                    var responseLength=response.getReturnValue().length;
                    if(state3==="SUCCESS"){
                        var response = response.getReturnValue();
                        var reclamantes = response['reclamante'];
                        var cotitulares = response['cotitular'];
                        if(reclamantes != null && reclamantes != '' && reclamantes != 'undefined'){
                            component.set('v.demEntExist', true);
                            component.set('v.demEntReclamanteExist', true);
                            component.set('v.demEntReclamanteList', reclamantes);
                        }
                        if(cotitulares != null && cotitulares != '' && cotitulares != 'undefined'){
                            component.set('v.demEntExist', true);
                            component.set('v.demEntCotitularExist', true);
                            component.set('v.demEntCotitularList', cotitulares);
                        }
                    }
                    var action4=component.get('c.getDemandasMorosidadToShow');
                    action4.setParams({
                        "recId": component.get('v.recordId')
                    });
                    action4.setCallback(this,function(response){
                        var state4=response.getState();
                        var responseLength=response.getReturnValue().length;
                        if(state4==="SUCCESS"){
                            var response = response.getReturnValue();
                            var reclamantes = response['reclamante'];
                            var cotitulares = response['cotitular'];
                            if(reclamantes != null && reclamantes != '' && reclamantes != 'undefined'){
                                component.set('v.demMorExist', true);
                                component.set('v.demMorReclamanteExist', true);
                                component.set('v.demMorReclamanteList', reclamantes);
                            }
                            if(cotitulares != null && cotitulares != '' && cotitulares != 'undefined'){
                                component.set('v.demMorExist', true);
                                component.set('v.demMorCotitularExist', true);
                                component.set('v.demMorCotitularList', cotitulares);
                            }
                        }
                        var action5=component.get('c.getConcursosToShow');
                        action5.setParams({
                            "recId": component.get('v.recordId')
                        });
                        action5.setCallback(this,function(response){
                            var state5=response.getState();
                            var responseLength=response.getReturnValue().length;
                            if(state5==="SUCCESS"){
                                var response = response.getReturnValue();
                                var reclamantes = response['reclamante'];
                                var cotitulares = response['cotitular'];
                                if(reclamantes != null && reclamantes != '' && reclamantes != 'undefined'){
                                    component.set('v.concursosExist', true);
                                    component.set('v.concursosReclamanteExist', true);
                                    component.set('v.concursosReclamanteList', reclamantes);
                                }
                                if(cotitulares != null && cotitulares != '' && cotitulares != 'undefined'){
                                    component.set('v.concursosExist', true);
                                    component.set('v.concursosCotitularExist', true);
                                    component.set('v.concursosCotitularList', cotitulares);
                                }
                            }
                        });
                        component.set('v.spinner', false);
                        if(!component.get('v.reclAntExist') && !component.get('v.antHistExist') && !component.get('v.antCBPOExist') && !component.get('v.demEntExist') && !component.get('v.demMorExist') && !component.get('v.concursosExist')){
                            component.set('v.showEmptyMessage', true);
                        }
                        $A.enqueueAction(action5);
                    });
                    $A.enqueueAction(action4);
                });
                $A.enqueueAction(action3);
            });
            $A.enqueueAction(action2);
        });
        $A.enqueueAction(action1);
    }
})