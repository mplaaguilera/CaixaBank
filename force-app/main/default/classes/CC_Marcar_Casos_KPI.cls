public with sharing class CC_Marcar_Casos_KPI {

    public static List<Case> calcularRepetitividad(List<Case> lstCasos) {

        List<Case> listReturn = new List<Case>();
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Map<String, List<Case>> casosPorCuentaYTematica = new Map<String, List<Case>>();
        Map<Id, Integer> casoActualizarFuture = new Map<Id, Integer>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> tematicaId = new Set<Id>();
        Set<Id> tematicaIdOld = new Set<Id>();
        //Map<Id,Id> tematicaIdOld = new Map<Id,Id>();
        Set<Case> casoIdSet = new  Set<Case>();
        Set<Case> listaCasosAux = new Set<Case>();
        // Recopilar IDs de cuentas relevantes
        for (Case caso : lstCasos) {
            if (caso.recordTypeId == rtCliente && caso.AccountId != null && caso.CC_MCC_Tematica__c != null  && caso.Origin == 'Phone'&& caso.Status != 'Rechazado' && caso.CC_MCC_Tematica__r.Name != 'Contactos erróneos' && (String.isEmpty(caso.CC_Detalles_Consulta__c)  || (!String.isEmpty(caso.CC_Detalles_Consulta__c) && !caso.CC_Detalles_Consulta__c.containsIgnoreCase('cort'))) && (String.isEmpty(caso.CC_Detalles_Solucion__c)  || (!String.isEmpty(caso.CC_Detalles_Solucion__c) &&  !caso.CC_Detalles_Solucion__c.containsIgnoreCase('cort')))){
                        accountIds.add(caso.AccountId);
                        tematicaId.add(caso.CC_MCC_Tematica__c);
                        casoIdSet.add(caso);
                    }
                }
        //Solo hay que ejecutar cuando los casos a actualizar estan OK.
        if(!casoIdSet.isEmpty()){
        List<Case> listaCasos = new List<Case>();
        Set<Case> casoIdSetAux = new Set<Case>();
        // Actualizar y contar casos repetidos 
        if (!accountIds.isEmpty()) {
            // Consultar casos repetidos por cuenta y temática
            if (Test.isRunningTest()){
                listaCasos = [SELECT Id, CaseNumber, AccountId, CC_MCC_Tematica__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c,CC_NumeroCasoOrigenRep__c, CC_Repetitivo__c FROM Case WHERE RecordTypeId = :rtCliente AND Origin = 'Phone' AND Status != 'Rechazado' AND AccountId IN :accountIds AND CreatedDate = TODAY  AND CC_MCC_Tematica__c IN :tematicaId AND CC_MCC_Tematica__r.Name != 'Contactos erróneos' ORDER BY CreatedDate ASC];
             } else {
                listaCasos = [SELECT Id, CaseNumber, AccountId, CC_MCC_Tematica__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c,CC_NumeroCasoOrigenRep__c, CC_Repetitivo__c FROM Case WHERE RecordTypeId = :rtCliente AND Origin = 'Phone' AND Status != 'Rechazado' AND AccountId IN :accountIds AND CreatedDate = YESTERDAY  AND CC_MCC_Tematica__c IN :tematicaId AND CC_MCC_Tematica__r.Name != 'Contactos erróneos' ORDER BY CreatedDate ASC];
             }
    
            if(!listaCasos.isEmpty()){
                for (Case caso :listaCasos) {
                    if((String.isEmpty(caso.CC_Detalles_Consulta__c)  || (!String.isEmpty(caso.CC_Detalles_Consulta__c) && !caso.CC_Detalles_Consulta__c.containsIgnoreCase('cort'))) && (String.isEmpty(caso.CC_Detalles_Solucion__c)  || (!String.isEmpty(caso.CC_Detalles_Solucion__c) &&  !caso.CC_Detalles_Solucion__c.containsIgnoreCase('cort')))){
                        String key = caso.AccountId + '_' + caso.CC_MCC_Tematica__c;
                        if (!casosPorCuentaYTematica.containsKey(key)) {
                            casosPorCuentaYTematica.put(key, new List<Case>());
                        }
                        casosPorCuentaYTematica.get(key).add(caso);
                    }
                }
            }
    //Recorro el mapa de cuenta_tematica
        if(!casosPorCuentaYTematica.isEmpty()){
            for (String key :casosPorCuentaYTematica.keySet()) {
                Case casoUno = casosPorCuentaYTematica.get(key)[0];
                //recorro los casos con esa key, lo que dice que esa cuenta y esa tematica tienen X cantodad de casosç
                for (Case c : casoIdSet) {
                    //Si el caso es uno que genera repetitividad, lo marco con el campo CC_NumeroCasoOrigenRep__c
                    if(c.AccountId == casoUno.AccountId && c.CC_MCC_Tematica__c == casoUno.CC_MCC_Tematica__c && c.CaseNumber != casoUno.CaseNumber){
                        //Actualizamos solo los casos que entran por el trigger,no todos los de la lista. No comprobamos que este vacia, ya que al principio lo hicimos. 
                                        c.CC_NumeroCasoOrigenRep__c = casoUno.CaseNumber;
                                        casoIdSetAux.add(c);
                                        if(c.CaseNumber != casoUno.CaseNumber){
                                            listReturn.add(c);
                                        }
                            }
                        }
                 }
            }       
        }
    }
    
        return listReturn;
    }
    
    public static List<Case> calcularDerivacionOficina(List<Case> lstCasos) {
        List<Case> listReturn = new List<Case>();
        Id rtTarea = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        Set<Case> setCasosDepurado = new Set<Case>();
        Set<Id> prueba = new Set<Id>();
        List<Case> lstCasosTask = new List<Case>();
        if(!lstCasos.isEmpty()){
            for (Case c : lstCasos) {
                if(c.CC_MCC_Motivo__r.CC_Excluir_Registro__c == false && c.CC_MCC_Tematica__r.CC_Excluir_Registro__c == false){
                    lstCasosTask.add(c);
                    prueba.add(c.id);
                }
            }
        }
    
        Set<Case> casosLimProt= new Set<Case>();
        List<Task> lstTareasByCases = new List<Task>();
        if(!lstCasosTask.isEmpty()){
     
            if (Test.isRunningTest()){
                lstTareasByCases = [SELECT Type, Subject, WhatId, CC_Grupo_Colaborador_Id__r.CC_Cuenta__c FROM Task WHERE Subject != 'Traslado a 3N de CSBD de Tercer Nivel' AND ( (Type = 'Remitir Colaborador' AND CC_Grupo_Colaborador_Id__r.CC_Cuenta__c != null) OR (Type = 'Consulta externa a empleado' AND CC_Tipo_Cierre__c = 'Consulta transferida' ) OR ( Status IN ('Completada','Completed') AND Type = 'Cita gestor' AND Subject = 'Cita gestor solicitada correctamente') OR ((Type ='Tarea gestor' OR Type ='Tarea Oficina' OR Type ='Tarea Cambio Oficina' OR Type ='Tarea Cambio Gestor') AND Subject = 'Solicitud contacto gestor (Contact Center)')) AND RecordTypeId = :rtTarea AND WhatId IN :prueba AND CreatedDate = TODAY  order by WhatId desc];
             } else {
                lstTareasByCases = [SELECT Type, Subject, WhatId, CC_Grupo_Colaborador_Id__r.CC_Cuenta__c FROM Task WHERE Subject != 'Traslado a 3N de CSBD de Tercer Nivel' AND ( (Type = 'Remitir Colaborador' AND CC_Grupo_Colaborador_Id__r.CC_Cuenta__c != null) OR (Type = 'Consulta externa a empleado' AND CC_Tipo_Cierre__c = 'Consulta transferida' ) OR ( Status IN ('Completada','Completed') AND Type = 'Cita gestor' AND Subject = 'Cita gestor solicitada correctamente') OR ((Type ='Tarea gestor' OR Type ='Tarea Oficina' OR Type ='Tarea Cambio Oficina' OR Type ='Tarea Cambio Gestor') AND Subject = 'Solicitud contacto gestor (Contact Center)')) AND RecordTypeId = :rtTarea AND WhatId IN :prueba AND CreatedDate = YESTERDAY  order by WhatId desc];
             }
            for (Case caso : lstCasosTask) {
                if (caso.CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c  == 'Derivar a oficina: Limitación protocolo' || caso.CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c == 'Derivar a oficina') {
                        setCasosDepurado.add(caso);
                    } else{
                        if(!lstTareasByCases.isEmpty()){
                            for (Task tarea : lstTareasByCases) {
                                if (tarea.WhatId == caso.Id) {
                                    if(tarea.Type == 'Tarea Cambio Oficina' || tarea.Type == 'Tarea Cambio Gestor'){
                                        casosLimProt.add(caso);
                                    }else{
                                        setCasosDepurado.add(caso);
                                    }
                                }
                            }
                        }
                    }      
            }
            if(!casosLimProt.isEmpty()){
            for (Case caso : casosLimProt) {
                caso.CC_Motivo_Derivacion__c = 'Por limitación de protocolo';
                listReturn.add(caso);
            }
            }
            if(!setCasosDepurado.isEmpty()){
                for (Case caso : setCasosDepurado) {
                    if(!casosLimProt.contains(caso)){
                        if(((caso.CC_OTP_Nivel__c != null && caso.CC_OTP_Valido__c == true && caso.CC_Status_Autorizacion__c == 'APPROVED')||(caso.CC_OTP_Nivel__c == null )) && caso.CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c  == 'Derivar a oficina: Limitación protocolo'){
                            caso.CC_Motivo_Derivacion__c = 'Por limitación de protocolo';
                            listReturn.add(caso);
                        }else if(caso.CC_Status_Autorizacion__c != 'APPROVED' && caso.CC_OTP_Nivel__c != null && caso.CC_OTP_Valido__c == false){
                            caso.CC_Motivo_Derivacion__c = 'Por KO autenticación';
                            listReturn.add(caso);
                        }else{
                            caso.CC_Motivo_Derivacion__c = 'Resto derivación';
                            listReturn.add(caso);
                        }
                    }
                }
            }
        }
        
                return listReturn;
    }
    
    }