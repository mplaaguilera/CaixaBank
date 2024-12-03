public with sharing class HDT_CaseTriggerHelper {

    public static void accionesBeforeUpdate(List<Case> listNewObjCC, Map<Id, Case> mapNewObjCC, Map<Id, Case> mapOldObjCC) {
        cambiosEstadoPendiente(listNewObjCC, mapOldObjCC);
        desvinculacionAgrupadorBU(listNewObjCC, mapOldObjCC);
        cambioPropietarioBU(listNewObjCC, mapOldObjCC);
        cambioPropietarioOriginal(listNewObjCC, mapOldObjCC);
        permiteCambioOwnerCC(listNewObjCC, mapOldObjCC);
        personAccountBU(listNewObjCC, mapOldObjCC);
        identificarCambioOficinaAfectadaBU(listNewObjCC, mapOldObjCC);
        cambioContactoEmpleadoBU(listNewObjCC, mapOldObjCC);
        blanqueoAccountBU(listNewObjCC, mapOldObjCC);
        contactoIncoherenteBU(listNewObjCC, mapOldObjCC);
        informarOficinaAfectadaBU(listNewObjCC, mapOldObjCC);
        seAsignaPropietario3NBU(listNewObjCC, mapOldObjCC);
        cuentaDesasociadaBU(listNewObjCC, mapOldObjCC);
        seInformaCanalRespuestaBU(listNewObjCC, mapOldObjCC);
        empleadoCuentaBU(listNewObjCC, mapOldObjCC);
        tematicaInformadoBU(listNewObjCC, mapOldObjCC);
        productoInformadoBU(listNewObjCC, mapOldObjCC);
        motivoInformadoBU(listNewObjCC, mapOldObjCC);
        actualizarColaProcedenciaBU(listNewObjCC, mapOldObjCC);
        asociaActivoBU(listNewObjCC, mapOldObjCC);
        causaInformadoBU(listNewObjCC, mapOldObjCC);
        solucionInformadoBU(listNewObjCC, mapOldObjCC);
        informarOficinaAfectadaDetalleBU(listNewObjCC, mapOldObjCC);
        generarEncuestaHDT1N(mapOldObjCC, mapNewObjCC);
        informarDetallesConsulta(listNewObjCC, mapOldObjCC, false);
    }

    public static void caseGestionado(List<Case> lstCasos, Map<Id, Case> mapOldObj) {

        for(Case caso : lstCasos){

                //CONDICIONAL ANTIGUO, SOLO SE QUIERE MARCAR EL CHECK A TRUE CUANDO EL CASO PASA DE PROPIETARIO DE COLA A AGENTE
                //if(String.valueOf(caso.OwnerId).left(3) == '005' && (mapOldObj == null || (mapOldObj != null && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId)) && !caso.CC_Gestionado_Agente__c)
                if(mapOldObj != null && String.valueOf(mapOldObj.get(caso.Id).OwnerId).left(3) == '00G' && String.valueOf(caso.OwnerId).left(3) == '005' &&  !caso.CC_Gestionado_Agente__c)
                {
                    caso.CC_Gestionado_Agente__c = true;
                }

        }
    }

    public static void calcularNumAgrupadores(List<Case> lstCasesCC, Map<Id, Case> mapOldObj) {

        List<Id> lstIdsAgrupador = new List<Id>();
        Map<Id, List<Case>> mapaCasosAgrupados = new Map<Id, List<Case>>();
        List<CC_Agrupador__c> agrupadores = new List<CC_Agrupador__c>();

        for(Case caso : lstCasesCC){
            if(caso.CC_Agrupador_Id__c != mapOldObj.get(caso.Id).CC_Agrupador_Id__c){
                if(caso.CC_Agrupador_Id__c != null){
                    lstIdsAgrupador.add(caso.CC_Agrupador_Id__c);
                }
                if(mapOldObj.get(caso.Id).CC_Agrupador_Id__c != null){
                    lstIdsAgrupador.add(mapOldObj.get(caso.Id).CC_Agrupador_Id__c);
                }
            }
        }

        if(!lstIdsAgrupador.isEmpty()){
            List<Case> lstCasos = [SELECT Id, CC_Agrupador_Id__c FROM Case WHERE CC_Agrupador_Id__c IN :lstIdsAgrupador ORDER BY CC_Agrupador_Id__c ];
            if (!lstCasos.isEmpty()) {
                for (Case casoAgrupado : lstCasos) {
                    if(mapaCasosAgrupados.containsKey(casoAgrupado.CC_Agrupador_Id__c)) {
                        List<Case> lstCasosAgrupados = mapaCasosAgrupados.get(casoAgrupado.CC_Agrupador_Id__c);
                        lstCasosAgrupados.add(casoAgrupado);
                        mapaCasosAgrupados.put(casoAgrupado.CC_Agrupador_Id__c,lstCasosAgrupados);
                    } else {
                        mapaCasosAgrupados.put(casoAgrupado.CC_Agrupador_Id__c, new List<Case> {casoAgrupado});
                    }
                }
            }
            for (Id idAgrupador : lstIdsAgrupador) {
                CC_Agrupador__c agrupador = new CC_Agrupador__c(Id = idAgrupador);
                if(mapaCasosAgrupados.containsKey(idAgrupador)){
                    agrupador.CC_Numero_Casos__c = mapaCasosAgrupados.get(idAgrupador).size();
                }else{
                    agrupador.CC_Numero_Casos__c = 0;
                }

                if(!agrupadores.contains(agrupador)){
                agrupadores.add(agrupador);
            }

            }
            if (!agrupadores.isEmpty()) {
                String jsonAgrupadores = JSON.serialize(agrupadores);
                actualizarAgrupador(jsonAgrupadores);
            }
        }
    }

     //Método creado a partir del traspaso de PB (cc_Gestion_Caso) a Trigger
     public static void estadoCerradoAux(Set<Id> setIdCasos, Map<Id, Case> mapaCasosCerrados) {
        List<Task> lstTareas = [SELECT Id, WhatId FROM Task WHERE Status = 'Pendiente' AND Type = 'Traslado Tercer Nivel' AND WhatId IN :setIdCasos];

        for (Task tarea : lstTareas) {
            tarea.Status = 'Completed';
            tarea.CC_Tipo_Cierre__c = 'Cierre Tercer Nivel';

            tarea.CC_Fecha_Fin__c = Datetime.now();
            if(mapaCasosCerrados.containsKey(tarea.WhatId) && mapaCasosCerrados.get(tarea.WhatId).CC_Resolucion__c != null){
                tarea.Description = mapaCasosCerrados.get(tarea.WhatId).CC_Resolucion__c;
            }
        }
        if (!lstTareas.isEmpty()) {
            Database.update(lstTareas,false);
        }
    }

    //MLA - Posible borrado
    public static void contactoIncoherenteBI(List<Case> lstCasos) {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        //Id rtEmpleadoCSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado_CSI').getRecordTypeId();

        Set<Id> idCuentas = new Set<Id>();
        Set<Id> idContactos = new Set<Id>();
        List<Case> casosComprobar = new List<Case>();

        for (Case caso : lstCasos) {
            if (caso.ContactId != null && caso.AccountId != null && caso.RecordTypeId != null) {
                if(!idCuentas.contains(caso.AccountId)){
                    idCuentas.add(caso.AccountId);
                }
                if(!idContactos.contains(caso.ContactId)){
                    idContactos.add(caso.ContactId);
                }
                casosComprobar.add(caso);
            }
        }

        if(!idCuentas.isEmpty() || !idContactos.isEmpty()){
            Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, RecordType.DeveloperName FROM Account WHERE Id IN :idCuentas]);
            Map<Id,Contact> mapContactos = new Map<Id,Contact>([SELECT Id, RecordType.DeveloperName FROM Contact WHERE Id IN :idContactos]);
            for (Case caso : casosComprobar) {
                if ((!mapCuentas.isEmpty() && mapCuentas.containsKey(caso.AccountId) && (caso.recordTypeId == rtEmpleado && mapCuentas.get(caso.AccountId).RecordType.DeveloperName == 'CC_ClientePA'
                || caso.recordTypeId == rtCliente && mapCuentas.get(caso.AccountId).RecordType.DeveloperName == 'HDT_Empleado'))
                || (!mapContactos.isEmpty() && mapContactos.containsKey(caso.ContactId) && (caso.recordTypeId == rtEmpleado && mapContactos.get(caso.ContactId).RecordType.DeveloperName == 'CC_ClientePA'
                || caso.recordTypeId == rtCliente && mapContactos.get(caso.ContactId).RecordType.DeveloperName == 'HDT_Empleado'))) {
                    caso.AccountId = null;
                    caso.ContactId = null;
                }
            }
        }
    }

    public static void mccInformadoAux( List<Case> lstCasosMCC , Set<Id> setIdMCC, String tipoMCC) {
        Map<Id,CC_MCC__c> mapMCCs = new Map<Id,CC_MCC__c>();
        mapMCCs = new Map<Id,CC_MCC__c>([SELECT Id, Name, CC_Codigo_Externo__c FROM CC_MCC__c WHERE Id IN :setIdMCC]);

        if (!mapMCCs.isEmpty()) {
            for (Case caso : lstCasosMCC) {
                switch on tipoMCC {
                    when 'tematica' {
                        if(mapMCCs.containsKey(caso.CC_MCC_Tematica__c)){
                            caso.CC_Codigo_Externo_Tematica__c = mapMCCs.get(caso.CC_MCC_Tematica__c).CC_Codigo_Externo__c;
                            caso.CC_Tematica__c = mapMCCs.get(caso.CC_MCC_Tematica__c).Name;
                        }
                        break;
                    }
                    when 'producto' {
                        if(mapMCCs.containsKey(caso.CC_MCC_ProdServ__c)){
                            caso.CC_Codigo_Externo_Producto__c = mapMCCs.get(caso.CC_MCC_ProdServ__c).CC_Codigo_Externo__c;
                            caso.CC_Producto_Servicio__c = mapMCCs.get(caso.CC_MCC_ProdServ__c).Name;
                        }
                        break;
                    }
                    when 'motivo' {
                        if(mapMCCs.containsKey(caso.CC_MCC_Motivo__c)){
                            caso.CC_Codigo_Externo_Motivo__c = mapMCCs.get(caso.CC_MCC_Motivo__c).CC_Codigo_Externo__c;
                            caso.CC_Motivo__c = mapMCCs.get(caso.CC_MCC_Motivo__c).Name;
                        }
                        break;
                    }
                    when 'causa' {
                        if(mapMCCs.containsKey(caso.CC_MCC_Causa__c)){
                            caso.CC_Codigo_Externo_Causa__c = mapMCCs.get(caso.CC_MCC_Causa__c).CC_Codigo_Externo__c;
                            caso.CC_Causa__c = mapMCCs.get(caso.CC_MCC_Causa__c).Name;
                        }
                        break;
                    }
                    when 'solucion' {
                        if(mapMCCs.containsKey(caso.CC_MCC_Solucion__c)){
                            caso.CC_Solucion__c = mapMCCs.get(caso.CC_MCC_Solucion__c).Name;
                        }
                        break;
                    }
                }
            }
        }
    }

    /*
     //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
     @TestVisible
     private static void AlfAux(List<Case> lstCasos, Set<Id> setIdCuentas, Boolean cambioDocumen) {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, CC_Email__c, CC_NumPerso__c, CC_Numero_Documento__c, CC_OficinaGestoraId__c, CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c,
        CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId FROM Account WHERE Id IN :setIdCuentas]);


        for (Case caso : lstCasos) {
            if (mapAccount.containsKey(caso.AccountId)) {
                if(cambioDocumen || (!cambioDocumen && caso.CC_Canal_Procedencia__c != 'Formulario web')){

                    caso.CC_MailTelfNotif__c = mapAccount.get(caso.AccountId).CC_NumPerso__c;
                    caso.CC_Numero_Documento__c = mapAccount.get(caso.AccountId).CC_Numero_Documento__c;
                    if(!cambioDocumen && caso.CC_Canal_Procedencia__c != 'Formulario web'){
                        caso.CC_NumPerso__c = mapAccount.get(caso.AccountId).CC_Numero_Documento__c;
                    }
                }
                if (caso.RecordTypeId == rtCliente && mapAccount.get(caso.AccountId).CC_OficinaGestoraId__c != null) {
                    if (mapAccount.get(caso.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c != null){
                        caso.CC_DAN__c = mapAccount.get(caso.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c;
                    }
                    if (mapAccount.get(caso.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId != null){
                        caso.CC_DG__c = mapAccount.get(caso.AccountId).CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId;
                    }
                }
            }
        }
    }
    */


    public static void tematicaInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Tematica__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_Tematica__c)){
                    setIdMCC.add(caso.CC_MCC_Tematica__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'tematica');
        }
    }

    //********************************************************************************************************************** */
    //********************************************************************************************************************** */
     //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
     public static void identificarCambioOficinaAfectadaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.recordTypeId == rtCliente && caso.CC_Oficina_Afectada_Lookup__c != null && mapOldObj.get(caso.Id).CC_Oficina_Afectada_Lookup__c != caso.CC_Oficina_Afectada_Lookup__c) {
                if(!setIdCuentas.contains(caso.CC_Oficina_Afectada_Lookup__c)){
                    setIdCuentas.add(caso.CC_Oficina_Afectada_Lookup__c);
                }
                casosAlf.add(caso);
            }
        }
    }

     //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
     public static void blanqueoAccountBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId == null && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                caso.CC_MailTelfNotif__c = null;
                caso.CC_Numero_Documento__c = null;
                caso.CC_NumPerso__c = null;
            }
        }
    }

    public static void contactoIncoherenteBU(List<Case> lstCasos ,Map<Id, Case> mapOldObj) {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        //Id rtEmpleadoCSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado_CSI').getRecordTypeId();

        Set<Id> idCuentas = new Set<Id>();
        Set<Id> idContactos = new Set<Id>();
        List<Case> casosComprobar = new List<Case>();

        for (Case caso : lstCasos) {
            if (caso.ContactId != null && caso.AccountId != null && caso.RecordTypeId != null && caso.ContactId != mapOldObj.get(caso.Id).ContactId) {
                if(!idCuentas.contains(caso.AccountId)){
                    idCuentas.add(caso.AccountId);
                }
                if(!idContactos.contains(caso.ContactId)){
                    idContactos.add(caso.ContactId);
                }
                casosComprobar.add(caso);
            }
        }
    }


     //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
     public static void cambioContactoEmpleadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.ContactId != null && mapOldObj.get(caso.Id).ContactId != caso.ContactId && (caso.RecordTypeId == rtEmpleado || caso.RecordTypeId == rtBankia)) {
                if(!setIdContacto.contains(caso.ContactId)){
                    setIdContacto.add(caso.ContactId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdContacto.isEmpty()){
            Map<Id,Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id IN :setIdContacto]);

            for (Case caso : casosAlf) {
                if (mapContacts.containsKey(caso.ContactId) && mapContacts.get(caso.ContactId).Email != null) {
                    caso.CC_MailTelfNotif__c = mapContacts.get(caso.ContactId).Email;
                }
            }
        }
    }

     //Método creado a partir del traspaso de PB (cc_Case_Modificar_Account) a Trigger
     public static void personAccountBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && mapOldObj.get(caso.Id).AccountId != caso.AccountId) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :setIdCuentas AND RecordType.DeveloperName = 'CC_ClientePA']);

            for (Case caso : casosAlf) {
                if (mapAccount.containsKey(caso.AccountId)) {
                    caso.ContactId = mapAccount.get(caso.AccountId).PersonContactId;
                }
            }
        }
    }

    public static void seAsignaPropietario3NBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
                if (caso.Status == 'Pendiente Interno' && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('00G') && String.valueOf(caso.OwnerId).startsWith('005')) {
                    caso.Status = 'Activo';
                }
            }
    }

    public static void empleadoCuentaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        List<Case> casosCuentaRellenada = new List<Case>();
        Set<Id> setCuentasCasos = new Set<Id>();
        for (Case caso : lstCasos) {
                        //if (caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId) {

            if (caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId && (caso.RecordtypeId == rtEmpleado || caso.RecordtypeId == rtBankia)) {
                casosCuentaRellenada.add(caso);
                if(!setCuentasCasos.contains(caso.AccountId)){
                    setCuentasCasos.add(caso.AccountId);
                }
            }
        }

        if (!casosCuentaRellenada.isEmpty()) {

            Map<Id, Account> mapCuentasCasos = new Map<Id, Account>([SELECT Id, CC_Numero_Oficina__c FROM Account WHERE Id IN :setCuentasCasos]);

            for (Case caso : casosCuentaRellenada) {
                    caso.CC_Oficina_Afectada_Lookup__c = caso.AccountId;
                    caso.CC_Oficina__c = caso.AccountId;
                    caso.CC_Oficina_afectada__c = mapCuentasCasos.get(caso.AccountId).CC_Numero_Oficina__c;
            }
        }
    }

    public static void tematicaInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Tematica__c != null && caso.CC_MCC_Tematica__c != mapOldObj.get(caso.Id).CC_MCC_Tematica__c) {
                if(!setIdMCC.contains(caso.CC_MCC_Tematica__c)){
                    setIdMCC.add(caso.CC_MCC_Tematica__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'tematica');
        }
    }

    public static void motivoInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Motivo__c != null && caso.CC_MCC_Motivo__c != mapOldObj.get(caso.Id).CC_MCC_Motivo__c) {
                if(!setIdMCC.contains(caso.CC_MCC_Motivo__c)){
                    setIdMCC.add(caso.CC_MCC_Motivo__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'motivo');
        }
    }

    public static void productoInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_ProdServ__c != null && caso.CC_MCC_ProdServ__c != mapOldObj.get(caso.Id).CC_MCC_ProdServ__c) {
                if(!setIdMCC.contains(caso.CC_MCC_ProdServ__c)){
                    setIdMCC.add(caso.CC_MCC_ProdServ__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'producto');
        }
    }

    public static void seInformaCanalRespuestaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Respuesta_Modificar__c != null && caso.CC_Canal_Respuesta_Modificar__c != mapOldObj.get(caso.Id).CC_Canal_Respuesta_Modificar__c && caso.Status != 'Cerrado' && caso.Status != 'Rechazado') {
                caso.CC_Canal_Respuesta__c = caso.CC_Canal_Respuesta_Modificar__c;
            }
        }
    }


    public static void informarOficinaAfectadaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosOficina = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosOficina.add(caso);
            }
        }
        Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Id IN :setIdCuentas AND CC_OficinaGestoraId__c != null]);

        for (Case caso : casosOficina) {
            if (mapCuentas.containsKey(caso.AccountId)) {
                //caso.CC_Oficina_afectada__c = mapCuentas.get(caso.AccountId).CC_OficinaGestoraId__c;
                caso.CC_Oficina_Afectada_Lookup__c = mapCuentas.get(caso.AccountId).CC_OficinaGestoraId__c;
            }
        }
    }

    public static void informarDireccionTerritorialBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Id> listIdCasos = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.CC_Oficina_Afectada_Lookup__c != null && caso.AccountId != null && (mapOldObj.get(caso.Id).AccountId != caso.AccountId || mapOldObj.get(caso.Id).CC_Oficina_Afectada_Lookup__c != caso.CC_Oficina_Afectada_Lookup__c)) {
                listIdCasos.add(caso.id);
            }
        }

        if (!listIdCasos.isEmpty()) {
            CC_Trazabilidad_Methods.altaPeticion(listIdCasos);
        }
    }

    public static void causaInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Causa__c != null && caso.CC_MCC_Causa__c != mapOldObj.get(caso.Id).CC_MCC_Causa__c) {
                if(!setIdMCC.contains(caso.CC_MCC_Causa__c)){
                    setIdMCC.add(caso.CC_MCC_Causa__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'causa');
        }
    }

    public static void informarOficinaAfectadaDetalleBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        for (Case caso : lstCasos) {
            if (caso.CC_Oficina__c != mapOldObj.get(caso.Id).CC_Oficina__c && caso.CC_Oficina__c != null && caso.AccountId == null && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia ) {
                caso.CC_Oficina_Afectada_Lookup__c = caso.CC_Oficina__c;
            }
        }
    }


    public static void solucionInformadoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Solucion__c != null && caso.CC_MCC_Solucion__c != mapOldObj.get(caso.Id).CC_MCC_Solucion__c) {
                if(!setIdMCC.contains(caso.CC_MCC_Solucion__c)){
                    setIdMCC.add(caso.CC_MCC_Solucion__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'solucion');
        }
    }


    public static void asociaActivoBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {

        Set<Id> setIdAssets = new Set<Id>();
        List<Case> lstCasosAsociados = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AssetId != mapOldObj.get(caso.Id).AssetId && caso.AssetId != null) {
                if(!setIdAssets.contains(caso.AccountId)){
                    setIdAssets.add(caso.AssetId);
                }
                lstCasosAsociados.add(caso);
            }
        }
        if(!setIdAssets.isEmpty()){
            Map<Id,Asset> mapAsset = new Map<Id, Asset>([SELECT Id, AccountId FROM Asset WHERE Id IN :setIdAssets AND AccountId != null]);

            for (Case caso : lstCasosAsociados) {
                if (mapAsset.containsKey(caso.AssetId) && caso.CC_Oficina__c != mapAsset.get(caso.AssetId).AccountId) {
                    caso.CC_Oficina__c = mapAsset.get(caso.AssetId).AccountId;
                }
            }
        }
    }

    public static void actualizarColaProcedenciaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Case> lstCasosComprobar = new List<Case>();
        Set<Id> setIdGrupos = new Set<Id>();
        for (Case caso : lstCasos) {
            if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueOf(caso.OwnerId).startsWith('00G') && caso.Origin == 'Email') {
                if(!setIdGrupos.contains(caso.OwnerId)){
                    setIdGrupos.add(caso.OwnerId);
                }
                lstCasosComprobar.add(caso);
            }
        }

        if(!lstCasosComprobar.isEmpty()){
            Map<Id, Group> mapColas = new Map<Id, Group>([SELECT Id, DeveloperName FROM Group WHERE Id IN: setIdGrupos]);
            /*
            for (Case caso : lstCasosComprobar) {
                if(caso.CC_Canal_procedencia__c != 'Formulario Consultas Operativas')
                {
                    if(mapColas.containsKey(caso.OwnerId) && caso.CC_Cola_Procedencia__c != mapColas.get(caso.OwnerId).DeveloperName){
                        caso.CC_Cola_Procedencia__c = mapColas.get(caso.OwnerId).DeveloperName;
                    }
                }
            }*/
        }
    }

    public static void cuentaDesasociadaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if (caso.AccountId == null && caso.AccountId != mapOldObj.get(caso.Id).AccountId) {
                caso.CC_Oficina_Afectada_Lookup__c = null;
                caso.CC_Oficina__c = null;
                caso.CC_Oficina_afectada__c = null;
            }
        }
    }

    public static void permiteCambioOwnerCC(List<Case> listNewCases, Map<Id, Case> mapOldObj) {
        List<Id> usuarioNuevo = new List<Id>();
        Map<Id, Case> usuarioNuevoPorCase = new Map<Id, Case>();
        for (Case caso : listNewCases){
            if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueof(caso.OwnerId).startsWith('005')) {
                usuarioNuevo.add(caso.OwnerId);
                usuarioNuevoPorCase.put(caso.OwnerId, caso);
            }
        }

        if (!usuarioNuevo.isEmpty()) {
            UserRole rol = [SELECT Id FROM UserRole WHERE DeveloperName = 'HDT'];
                List<User> usuarios = [SELECT Id, Name, UserRoleId FROM User WHERE Id IN :usuarioNuevo];
                List<PermissionSetAssignment> userPermissionSets = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE AssigneeId IN : usuarioNuevo AND PermissionSet.Name = 'HDT_Tercer_Nivel'];
                List<Id> usuariosPermitidos = new List<Id>();
                for (PermissionSetAssignment userPermission : userPermissionSets) {
                    usuariosPermitidos.add(userPermission.AssigneeId);
                }

            for (User usuario : usuarios) {

                    if (usuario.UserRoleId != rol.Id && (usuario.Name != 'System' && usuario.Name != 'Automated Process' && usuario.Name != 'Administrador de sistema') && !usuariosPermitidos.contains(usuario.Id)){
                    usuarioNuevoPorCase.get(usuario.Id).addError('Únicamente se pueden vincular a trabajadores del Help Desk Tecnico');
                }
            }
        }
    }

    public static void informarOficinaAfectadaBI(List<Case> lstCasos) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        //Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosOficina = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.RecordTypeId != rtEmpleado) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosOficina.add(caso);
            }
        }
        Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Id IN :setIdCuentas AND CC_OficinaGestoraId__c != null]);
        for (Case caso : casosOficina) {
            if (mapCuentas.containsKey(caso.AccountId)) {
                caso.CC_Oficina_Afectada_Lookup__c = mapCuentas.get(caso.AccountId).CC_OficinaGestoraId__c;
            }
        }
    }


    public static void motivoInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Motivo__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_Motivo__c)){
                    setIdMCC.add(caso.CC_MCC_Motivo__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'motivo');
        }
    }

    public static void productoInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_ProdServ__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_ProdServ__c)){
                    setIdMCC.add(caso.CC_MCC_ProdServ__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'producto');
        }
    }



    public static void solucionInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Solucion__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_Solucion__c)){
                    setIdMCC.add(caso.CC_MCC_Solucion__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'solucion');
        }
    }

    public static void causaInformadoBI(List<Case> lstCasos) {
        Set<Id> setIdMCC = new Set<Id>();
        List<Case> lstCasosMCC = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.Status != 'Cerrado' && caso.Status != 'Rechazado' && caso.CC_MCC_Causa__c != null) {
                if(!setIdMCC.contains(caso.CC_MCC_Causa__c)){
                    setIdMCC.add(caso.CC_MCC_Causa__c);
                }
                lstCasosMCC.add(caso);
            }
        }

        if(!lstCasosMCC.isEmpty()){
            mccInformadoAux(lstCasosMCC, setIdMCC, 'causa');
        }
    }

    public static void seInformaCanalRespuestaBI(List<Case> lstCasos) {
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Respuesta_Modificar__c != null && caso.Status != 'Cerrado' && caso.Status != 'Rechazado') {
                caso.CC_Canal_Respuesta__c = caso.CC_Canal_Respuesta_Modificar__c;
            }
        }
    }

    @future
	public static void actualizarAgrupador(String jsonString){

		List<CC_Agrupador__c> lstAgrupador = (List<CC_Agrupador__c>)Json.deserialize(jsonString,List<CC_Agrupador__c>.class);
        Database.update(lstAgrupador);
    }


    public static void cambiosEstadoPendiente(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && (caso.Status == 'Pendiente Colaborador' || caso.Status == 'Pendiente Cliente'  || caso.Status == 'Pendiente Incidencia'  || caso.Status == 'Pendiente Interno'  || caso.Status == 'Pendiente Revisión')){
                caso.CC_Cambio_Estado_Pendiente__c = Date.today();
                if (caso.Status == 'Pendiente Interno') {
                    caso.CC_Fecha_Traslado_3N__c = DateTime.now();
                }
            }
        }
    }

    public static void crearActividadCierreCC(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.Status == 'Cerrado' && caso.OwnerId != null){
                String detallesConsulta = null;
                String detallesSolucion = null;

                if (caso.CC_Detalles_Consulta__c != null && caso.CC_Detalles_Consulta__c.length() > 254) {
                    detallesConsulta = caso.CC_Detalles_Consulta__c.substring(0,255);
                } else {
                    detallesConsulta = caso.CC_Detalles_Consulta__c;
                }

                if (caso.CC_Detalles_Solucion__c != null && caso.CC_Detalles_Solucion__c.length() > 254) {
                    detallesSolucion = caso.CC_Detalles_Solucion__c.substring(0,255);
                } else {
                    detallesConsulta = caso.CC_Detalles_Solucion__c;
                }

                Task createTask = new Task( Type = 'Cerrado' ,Subject = 'Cerrado' ,ActivityDate = System.today() ,Status = 'Completed' ,WhatId = caso.Id ,CC_Detalles_Consulta__c = detallesConsulta ,CC_Detalles_Solucion__c = detallesSolucion ,CC_Fecha_Inicio__c = Datetime.now() ,Priority = 'Normal');
                lstTareas.add(createTask);
            }
        }

        if(!lstTareas.isEmpty()){
            HDT_Activity.crearActividades(lstTareas);
        }
    }

    public static void crearActividadReactivacionCC(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.Status != mapOldObj.get(caso.Id).Status && caso.CC_Reactivado_Operativa__c != mapOldObj.get(caso.Id).CC_Reactivado_Operativa__c && caso.CC_Reactivado_Operativa__c != null){
                Task createTask = new Task( Type = 'Reactivación' ,Subject = 'Reactivación'  ,Description = caso.CC_Motivo_Reactivacion__c ,Status = 'Completed' ,WhatId = caso.Id ,CC_Fecha_Inicio__c = Datetime.now() ,Priority = 'Normal');
                lstTareas.add(createTask);
            }
        }

        if(!lstTareas.isEmpty()){
            HDT_Activity.crearActividades(lstTareas);
        }
    }

    public static void crearActividadTraslado(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        List<Case> casosTrasladados = new List<Case>();
        Set<Id> setAgrupadores = new Set<Id>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.CC_Agrupador_Id__c  != mapOldObj.get(caso.Id).CC_Agrupador_Id__c && caso.CC_Agrupador_Id__c  != null){
                casosTrasladados.add(caso);
                setAgrupadores.add(caso.CC_Agrupador_Id__c);
            }
        }

        if(!casosTrasladados.isEmpty() && !setAgrupadores.IsEmpty()){
            Map<ID, CC_Agrupador__c> mapAgrupadores = new Map<ID, CC_Agrupador__c>([SELECT Id, Name FROM CC_Agrupador__c WHERE Id IN :setAgrupadores]);

            for (Case casoTrasladado : casosTrasladados) {
                String titulo = 'Traslado a Incidencia';
                if(mapAgrupadores.containsKey(casoTrasladado.CC_Agrupador_Id__c)){
                    titulo = 'Traslado a ' + mapAgrupadores.get(casoTrasladado.CC_Agrupador_Id__c).Name + ' de Incidencia';
                }
                Task createTask = new Task( Type = 'Traslado Incidencia' , Subject = titulo, Status = 'Pendiente' ,Agrupador__c = casoTrasladado.CC_Agrupador_Id__c, WhatId = casoTrasladado.Id ,CC_Fecha_Inicio__c = Datetime.now() ,Priority = 'Normal');
                lstTareas.add(createTask);
            }
        }

        if(!lstTareas.isEmpty()){
            HDT_Activity.crearActividades(lstTareas);
        }
    }

    public static void desvinculacionAgrupadorBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.CC_Agrupador_Id__c  != mapOldObj.get(caso.Id).CC_Agrupador_Id__c && caso.CC_Agrupador_Id__c  == null){
                caso.Status = mapOldObj.get(caso.Id).Status;
            }
        }
    }

    public static void desvinculacionAgrupadorAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Case> lstCasosDesvinculados = new List<Case>();
        List<Task> lstTareasRechazables = new List<Task>();
        Map<Id, Case> mapIdCasosDesvinculados = new Map<Id, Case>();
        Set<Id> setIdAgrupadores = new Set<Id>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.CC_Agrupador_Id__c  != mapOldObj.get(caso.Id).CC_Agrupador_Id__c && caso.CC_Agrupador_Id__c  == null){
                lstCasosDesvinculados.add(caso);
                mapIdCasosDesvinculados.put(caso.Id, mapOldObj.get(caso.Id));
                setIdAgrupadores.add(mapOldObj.get(caso.Id).CC_Agrupador_Id__c);
            }
        }

        if(!lstCasosDesvinculados.isEmpty() && !mapIdCasosDesvinculados.isEmpty() && !setIdAgrupadores.isEmpty()){
            List<Task> lstTraslados = [SELECT Id, Status, WhatId, Agrupador__c FROM Task WHERE Type = 'Traslado Incidencia' AND WhatId IN :mapIdCasosDesvinculados.keySet() AND Agrupador__c IN :setIdAgrupadores];
            if (!lstTraslados.isEmpty()) {
                for(Task tareaTraslado : lstTraslados) {
                    if(mapIdCasosDesvinculados.containsKey(tareaTraslado.WhatId) && mapIdCasosDesvinculados.get(tareaTraslado.WhatId).CC_Agrupador_Id__c == tareaTraslado.Agrupador__c){
                        tareaTraslado.Status = 'Rechazada';
                        lstTareasRechazables.add(tareaTraslado);
                    }
                }
            }
        }

        if(!lstTareasRechazables.isEmpty()){
            Database.update(lstTareasRechazables, false);
        }
    }

    public static void cambioPropietarioBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.OwnerId != null && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('005')){
                caso.CC_Autoasignado_Coordinador__c = false;
            }
        }
    }

    public static void cambioPropietarioAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        List<Case> casosTraspasados = new List<Case>();
        Set<Id> setIdCasos = new Set<Id>();

        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.OwnerId != null && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('005')){
                casosTraspasados.add(caso);
                setIdCasos.add(caso.Id);
            }
        }

        if(!casosTraspasados.isEmpty()){
            Map<ID, Case> mapCasos = new Map<ID, Case>([SELECT Id, Owner.Name FROM Case WHERE Id IN :setIdCasos]);
            for (Case casoTrasladado : casosTraspasados) {
                String titulo = 'Reasignación del caso';
                if((String.valueOf(casoTrasladado.OwnerId).startsWith('005') || String.valueOf(casoTrasladado.OwnerId).startsWith('00G')) && mapCasos.containsKey(casoTrasladado.Id)){
                    titulo = 'Reasignación del caso a ' + mapCasos.get(casoTrasladado.Id).Owner.Name;
                }
                Task createTask = new Task(Type = 'Reasignación ' , Subject = titulo, ActivityDate = System.today(), Status = 'Completed', WhatId = casoTrasladado.Id ,Priority = 'Normal');
                lstTareas.add(createTask);
            }
        }

        if(!lstTareas.isEmpty()){
            HDT_Activity.crearActividades(lstTareas);
        }
    }

    public static void cambioPropietarioOriginal(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.OwnerId != null && String.valueOf(mapOldObj.get(caso.Id).OwnerId).startsWith('005') && !(caso.CC_En_Tercer_Nivel__c && mapOldObj.get(caso.Id).CC_En_Tercer_Nivel__c)){
                caso.CC_Owner_Anterior__c = mapOldObj.get(caso.Id).OwnerId;
            }
        }
    }

    public static void cambioPropietarioActividades(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCaso = new Set<Id>();
        Map<Id, Case> mapIdCaso = new Map<Id, Case>();

        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && String.valueOf(caso.OwnerId).startsWith('005')){
                setIdCaso.add(caso.Id);
                mapIdCaso.put(caso.Id,caso);
            }
        }
        if(!setIdCaso.isEmpty()){
            List<Task> lstTareas = [SELECT Id, WhatId FROM Task WHERE WhatId IN :setIdCaso AND IsClosed = FALSE];
            if(!lstTareas.isEmpty()){
                for (Task tarea : lstTareas) {
                    if( mapIdCaso.containsKey(tarea.WhatId)){
                        tarea.OwnerId = mapIdCaso.get(tarea.WhatId).OwnerId;
                    }
                }
                Database.update(lstTareas);
            }
        }
    }

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //+++++++++++ Migración de Process Builder ++++++++++++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    public static Map<Id, CC_MCC__c> obtencionMCCAplicacionesYServicios() {
        Map<Id, CC_MCC__c> mapMCC = new Map<Id, CC_MCC__c>([SELECT Id, Name FROM CC_MCC__c WHERE Name IN ('Aplicaciones y servicios oficina','Protección de datos','LOPD')]);
        return mapMCC;
    }

    //Método creado a partir del traspaso de PB (cc_Creacion_Caso) a Trigger
    public static void comprobacionContactoAI(List<Case> lstCasos) {
        List<Id> casosConContacto = new List<Id>();
        for (Case caso : lstCasos) {
            if(caso.ContactId != null){
                casosConContacto.add(caso.Id);
            }
        }

        if (!casosConContacto.isEmpty()) {
            HDT_Caracteristica.RelacionarCaso(casosConContacto);
        }
    }

    //Método creado a partir del traspaso de PB (cc_Gestion_Caso) a Trigger
    public static void estadoCerradoAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCasos = new Set<Id>();
        Map<Id, Case> casosCerrados = new Map<Id,Case>();
        for (Case caso : lstCasos) {
            if (caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(caso.Id).Status && caso.CC_Resolucion__c != null && caso.OwnerId != null) {
                setIdCasos.add(caso.Id);
                casosCerrados.put(caso.Id, caso);
            }
        }

        if (!setIdCasos.isEmpty()) {
            estadoCerradoAux(setIdCasos, casosCerrados);
        }
    }


    //Método creado a partir del traspaso de PB (cc_Gestion_Caso) a Trigger
    public static void estadoCerradoAI(List<Case> lstCasos) {
        Set<Id> setIdCasos = new Set<Id>();
        Map<Id, Case> casosCerrados = new Map<Id,Case>();
        for (Case caso : lstCasos) {
            if (caso.Status == 'Cerrado' && caso.CC_Resolucion__c != null && caso.OwnerId != null) {
                setIdCasos.add(caso.Id);
                casosCerrados.put(caso.Id, caso);
            }
        }

        if (!setIdCasos.isEmpty()) {
            estadoCerradoAux(setIdCasos, casosCerrados);
        }
    }

    public static void modificaCausaDeCasoAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Id> idsCasos = new List<Id>();
        Date hoy = Date.today();
        Integer d = hoy.day();
        Integer mo = hoy.month();
        Integer yr = hoy.year();

        DateTime fechaHoraActual = DateTime.newInstance(yr, mo, d);
        for (Case caso : lstCasos) {
            if ((caso.CC_Campana__c != mapOldObj.get(caso.Id).CC_Campana__c && caso.CC_Campana__c != null || caso.CC_MCC_Causa__c != mapOldObj.get(caso.Id).CC_MCC_Causa__c && caso.CC_MCC_Causa__c != null) && caso.CreatedDate >= fechaHoraActual && caso.Status != 'Rechazado' && caso.CC_Tipo_Contacto__c != 'Incidencia' && caso.CC_Agrupador_Id__c == null) {
                idsCasos.add(caso.Id);
            }
        }

        if (!idsCasos.isEmpty()) {
            CC_Agrupador_CIC_Asignacion_Casos.asociarCasosAComunicacionInformativa(idsCasos);
        }
    }

    public static void enviarEncuestaAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdContacto = new Set<Id>();
        List<Case> casosEncuesta = new List<Case>();
        List<Id> idsCasos = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(caso.Id).Status) {
                if(!setIdContacto.contains(caso.CC_Agrupador_Id__c)){
                    setIdContacto.add(caso.CC_Agrupador_Id__c);
                }
                casosEncuesta.add(caso);
            }
        }

        if(!casosEncuesta.isEmpty() && !setIdContacto.IsEmpty()){
            Map<Id,CC_Agrupador__c> mapAgrupador = new Map<Id,CC_Agrupador__c>([SELECT Id FROM CC_Agrupador__c WHERE Id IN :setIdContacto AND CC_Record_Type_Name__c != 'Incidencia']);

            for (Case caso : casosEncuesta) {
                if (mapAgrupador.containsKey(caso.CC_Agrupador_Id__c) || caso.CC_Agrupador_Id__c == null) {
                    idsCasos.add(caso.Id);
                }
            }

            if (!idsCasos.isEmpty()) {
                HDT_Envio_Encuestas_3N.enviarEncuesta(idsCasos);
            }
        }
    }

    public static void asociaActivoAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {

        Set<Id> setIdAssets = new Set<Id>();
        List<Case> lstCasosAsociados = new List<Case>();
        List<Id> idsCasos = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.AssetId != mapOldObj.get(caso.Id).AssetId && caso.AssetId != null) {
                if(!setIdAssets.contains(caso.AccountId)){
                    setIdAssets.add(caso.AssetId);
                }
                lstCasosAsociados.add(caso);
            }
        }

        if(!setIdAssets.isEmpty()){
            Map<Id,Asset> mapAsset = new Map<Id, Asset>([SELECT Id, AccountId FROM Asset WHERE Id IN :setIdAssets AND AccountId != null]);

            for (Case caso : lstCasosAsociados) {
                if (mapAsset.containsKey(caso.AssetId) && caso.CC_Oficina__c != mapAsset.get(caso.AssetId).AccountId) {
                    //caso.CC_Oficina__c = mapAsset.get(caso.AssetId).AccountId;
                    idsCasos.add(caso.Id);
                }
            }
        }

        if (!idsCasos.isEmpty()) {
            CC_Avisos_Activo.avisoActivos(idsCasos);
        }
    }

    public static void actualizarAgrupadorAU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Id> agrupadoresId = new List<Id>();

        for (Case caso : lstCasos) {
            if (caso.CC_Agrupador_Id__c != mapOldObj.get(caso.Id).CC_Agrupador_Id__c && caso.CC_Agrupador_Id__c != null) {
                agrupadoresId.add(caso.CC_Agrupador_Id__c);
            }
        }

        if(!agrupadoresId.isEmpty()){
            CC_Agrupador_Controller.actualizarAgrupador(agrupadoresId);
        }
    }

    public static void informarDireccionTerritorialAI(List<Case> lstCasos) {
        List<Id> listIdCasos = new List<Id>();
        for (Case caso : lstCasos) {
            if (caso.CC_Oficina_Afectada_Lookup__c != null && caso.AccountId != null) {
                listIdCasos.add(caso.Id);
            }
        }
        if (!listIdCasos.isEmpty()) {
            CC_Trazabilidad_Methods.altaPeticion(listIdCasos);
        }
    }

    // Función para calcular si han pasado más de 3 dás desde el cierre de un caso para reabrirlo.
    // Esta funcionalidad impide que se pueda Reabrir un Caso que lleve cerrado más de 3 dias hábiles.
    // Solo Aplica para HDT.

    public static Boolean hanPasadoTresDiasDesdeCierre(Case caso) {

        // Verificar si el caso está cerrado y tiene una fecha ClosedDate válida
        if (caso.Status != 'Cerrado' || caso.ClosedDate == null) {
            return false;
        }else{

            DateTime fechaCierre = caso.ClosedDate;

            // Obtener el business hour "CC_Empleado"
            BusinessHours businessHour = [SELECT Id FROM BusinessHours WHERE Name = 'HDT_Empleados' LIMIT 1];

            Long ms3Dias = 3 * 86400000;
            // Calcular la fecha límite tomando en cuenta los días laborables
            DateTime fechaLimite = BusinessHours.add(businessHour.Id, fechaCierre, Integer.valueof(3) * 60 * 60 * 1000);

            // Obtener la diferencia en días hábiles entre la fecha límite y ahora
            Long diasHabilesenmsg = BusinessHours.diff(businessHour.Id, fechaLimite, DateTime.now());
                        Long diasTranscurridos = diasHabilesenmsg / 86400000;


            // Verificar si han pasado 3 días hábiles
            if (diasTranscurridos >= 3) {
                return true;
            } else {
                return false;
            }
        }
    }

    //Envío de correo Acuse de Recibo
    public static void envioCorreoAcuseRecibo(List<Case> casos) {

        if (!casos.isEmpty()) {
            //Recogemos las plantillas de correo ordenadas alfabeticamente (0: Catalan, 1: Castellano)
            List<EmailTemplate> plantillas = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'HDT_Acuse_Recibo_Empleado_%' ORDER BY DeveloperName];
            //Recogemos el Custom Setting para obtener las direcciones de correo de respuesta (Configuracion_1 : Castellano, Configuracion_2 : Catalan)
            HDT_Parametros__c emailRespuesta = HDT_Parametros__c.getInstance('HDT_Email_Respuesta_Empleados_New');

            //HDT_Parametros__c emailRespuesta = [SELECT HDT_Configuracion_1__c FROM HDT_Parametros__c WHERE Name = 'HDT_Email_Respuesta_Empleados_New'];
            //Recogemos los Ids del remitente ordenadas alfabeticamente por la direccion (0: Catalan, 1 Castellano) en el caso de que existan los 2
            List<OrgWideEmailAddress> buzones = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (:emailrespuesta.HDT_Configuracion_1__c) ORDER BY Address];

            //Buscamos si ya hay tareas de acuse de recibo para esos casos
            List<Task> tareasAcuse = [SELECT WhatId, WhoId FROM Task WHERE RecordType.DeveloperName = 'HDT_Task'
                                        AND Type = 'Acuse de recibo' AND WhatId IN :casos AND WhoId IN :CC_MetodosUtiles.listaCampo(casos, 'ContactId')];

            List<Messaging.SingleEmailMessage> acuses = new List<Messaging.SingleEmailMessage>();
			
			if (!plantillas.isEmpty() && !buzones.isEmpty()){
							
            for (Case caso : casos) {
                //Se envía acuse si no existe ya uno para ese caso y contacto
                if (!acusePrevio(tareasAcuse, caso.Id, caso.ContactId)) {
                    Messaging.SingleEmailMessage acuse = new Messaging.SingleEmailMessage();
                    if (buzones.size() == 2) {
                        if (caso.CC_Idioma__c == 'ca') {
                            acuse.setTemplateId(plantillas[0].Id);
                            acuse.setOrgWideEmailAddressId(buzones[0].Id);
                        }else{
                            acuse.setTemplateId(plantillas[1].Id);
                            acuse.setOrgWideEmailAddressId(buzones[1].Id);
                        }
                    } else {
                        if (caso.CC_Idioma__c == 'ca') {
                            acuse.setTemplateId(plantillas[0].Id);
                        } else {
                            acuse.setTemplateId(plantillas[1].Id);
                        }
                        acuse.setOrgWideEmailAddressId(buzones[0].Id);
                    }
                    acuse.setSaveAsActivity(true);
                    acuse.setWhatId(caso.Id);
                    acuse.setTargetObjectId(caso.ContactId);
                    acuse.setTreatTargetObjectAsRecipient(false);
                    acuse.setToAddresses(new List<String>{caso.ContactEmail});

                    acuses.add(acuse);
					}
				}
			} 

            //Envío de los correos de acuse
            if (!acuses.isEmpty()) {
                List<Task> tareasAcuseInsert = new List<Task>();
                Map<String, String> logsEnviosKo = new Map<String, String>();

                List<Messaging.SendEmailResult> resultadosEnvioAcuses = Messaging.sendEmail(acuses, false);
                for (Integer i = 0; i < resultadosEnvioAcuses.size(); i++) {
                    Messaging.SendEmailResult resultadoEnvioAcuse = resultadosEnvioAcuses[i];
                    if (resultadoEnvioAcuse.isSuccess()) { //Envío OK
                        Task nuevaTareaAcuse = new Task();
                        nuevaTareaAcuse.ActivityDate = System.today();
                        nuevaTareaAcuse.Subject = 'Acuse de recibo';
                        nuevaTareaAcuse.Type = 'Acuse de recibo';
                        nuevaTareaAcuse.Status = 'Completed';
                        nuevaTareaAcuse.WhatId = acuses[i].getWhatId();
                        nuevaTareaAcuse.WhoId = acuses[i].getTargetObjectId();
                        tareasAcuseInsert.add(nuevaTareaAcuse);
                    } else { //Envío KO
                        logsEnviosKo.put(resultadoEnvioAcuse.getErrors()[0].getMessage(), acuses[i].getWhatId());
                    }
                }
                HDT_Activity.crearActividades(tareasAcuseInsert);

                if (!logsEnviosKo.isEmpty()) {
                    CBK_Log.error(logsEnviosKo);
                }
            }
        }
    }

    private static Boolean acusePrevio(List<Task> tareasAcuse, Id idCaso, Id idContacto) {
        for (Task tareaAcuse : tareasAcuse) {
            if (tareaAcuse.WhatId == idCaso && tareaAcuse.WhoId == idContacto) {
                return true;
            }
        }
        return false;
    }
    

    public static void generarEncuestaHDT1N(Map<Id, Case> mapOldObj, Map<Id, Case> mapNewObj) {

        List<CC_Lista_Valores__c> listaCanalResolucion = [SELECT Name,CC_Activa__c,CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución'];

		Set<String> canalesResolucion = new Set<String>();
        for (CC_Lista_Valores__c resolucion : listaCanalResolucion) {
            if(resolucion.CC_Activa__c){
                canalesResolucion.add(resolucion.Name);
            }
        }

        List<Case> casos = new List<Case>();
        for (Case casoNew : mapNewObj.values()) {
            if (casoNew.HDT_Resuelto_Primera_Llamada__c && casoNew.Origin == 'Phone'
            && casoNew.Status == 'Cerrado'
            && mapOldObj.get(casoNew.Id).Status != 'Cerrado'
            && canalesResolucion.contains(casoNew.CC_Canal_Resolucion__c)) {
                casos.add(casoNew);
            }
        }
        if (!casos.isEmpty()) {
            //Obtenemos el custom setting de HDT Parametros para obtener el Id y la URL de la encuesta (Configuracion_1: Id Encuesta, Configuracion_2: URL)
            List<HDT_Parametros__c> linkEncuestaEmpleado = [SELECT HDT_Configuracion_1__c, HDT_Configuracion_2__c
                                                            FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta'];

            //Obtenemos el custom setting de HDT Parametros EdG para obtener el Id y la URL de la encuesta (Configuracion_1: Id Encuesta, Configuracion_2: URL)
            List<HDT_Parametros__c> linkEncuestaEmpleadoEdG = [SELECT HDT_Configuracion_1__c, HDT_Configuracion_2__c
                                                            FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta_EdG'];

            if (!linkEncuestaEmpleado.isEmpty() || !linkEncuestaEmpleadoEdG.isEmpty()) {
                Map<Id, CC_MCC__c> tematicas = new Map<Id, CC_MCC__c>(
                    [SELECT Name FROM CC_MCC__c WHERE Id IN :CC_MetodosUtiles.listaCampo(casos, 'CC_MCC_Tematica__c')]
                );

                for (Case caso : casos) {
                    Case casoNew = mapNewObj.get(caso.Id);
                    String urlEncuesta3N;

                    //Difernciamos entre EdG y no Edgs
                    //Comprobamos que no se EdG
                    if (caso.CC_Canal_Resolucion__c == 'Incidencias Técnicas' || caso.CC_Canal_Resolucion__c == 'Servicios Centrales' || caso.CC_Canal_Resolucion__c == 'SmartPhones'){
                        urlEncuesta3N = linkEncuestaEmpleado[0].HDT_Configuracion_2__c;
                        urlEncuesta3N += 'sid=' + linkEncuestaEmpleado[0].HDT_Configuracion_1__c;
                    }else{
                        urlEncuesta3N = linkEncuestaEmpleadoEdG[0].HDT_Configuracion_2__c;
                        urlEncuesta3N += 'sid=' + linkEncuestaEmpleadoEdG[0].HDT_Configuracion_1__c; 
                        urlEncuesta3N += '&empresa=' + casoNew.CC_Canal_Resolucion__c;
                    }

                    urlEncuesta3N += '&lang=' + casoNew.CC_Idioma__c;
                    urlEncuesta3N += '&userid=' + casoNew.CC_Matricula_Empleado__c;
                    urlEncuesta3N += '&ticketid=' + casoNew.CaseNumber;
                    urlEncuesta3N += '&idet=' + casoNew.CC_MCC_Tematica__c;
                    //Si hay temática se quitan los espacios de su nombre
                    String tematicaName = tematicas.get(casoNew.CC_MCC_Tematica__c).Name;
                    urlEncuesta3N += '&et=' + (tematicaName == null ? '' : tematicaName.replace(' ', '_'));
                    urlEncuesta3N += '&newtest=Y';
                    casoNew.CC_URL_Encuesta_3N__c = urlEncuesta3N;
                }
            }
        }
    }

    public static void cierreCasoHDT1N(List<Case> lstCasos, Map<Id, Case> oldMap) {
        List<CC_Lista_Valores__c> listaCanalResolucion = [SELECT Name,CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Valor__c = 'EDG' AND CC_Lista__r.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución'];
        List<CC_Lista_Valores__c> listaCanalResolucion2 = [SELECT Name,CC_Valor__c, CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Valor__c = 'No EDG' AND CC_Lista__r.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución'];
    
		Set<String> canalesResolucionEdG = new Set<String>();
        for (CC_Lista_Valores__c resolucion : listaCanalResolucion) {
            if(resolucion.CC_Activa__c){
                canalesResolucionEDG.add(resolucion.Name);
            }
        }

        Set<String> canalesResolucionPrimeros = new Set<String>();
        for (CC_Lista_Valores__c resolucion : listaCanalResolucion2) {
            if(resolucion.CC_Activa__c){
                canalesResolucionPrimeros.add(resolucion.Name);
            }
        }

        String apiNamePlantillas = 'HDT_Encuesta_1N_%';
        String apiNamePlantillasEdG = 'HDT_Encuesta_EdG_1N_%';
        
        List<Case> lstCasosHDT = new List<Case>();

        for (Case caso : lstCasos) {
            if(oldMap.containsKey(caso.Id)){
                if (caso.HDT_Resuelto_Primera_Llamada__c && caso.Origin == 'Phone' && caso.Status =='Cerrado' 
                    && oldMap.get(caso.Id).Status != 'Cerrado' 
                    && (canalesResolucionPrimeros.contains(caso.CC_Canal_Resolucion__c) || canalesResolucionEdG.contains(caso.CC_Canal_Resolucion__c))) {
                    lstCasosHDT.add(caso);
                }
            }
        }

        if(!lstCasosHDT.isEmpty()){
            //Obtenemos el custom setting de HDT Parametros para obtener el Id y la URL de la encuesta (Configuracion_1: Id Encuesta, Configuracion_2: URL)
            List<HDT_Parametros__c> linkEncuestaEmpleado =[SELECT  HDT_Configuracion_1__c, HDT_Configuracion_2__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta' LIMIT 1];
            List<HDT_Parametros__c> linkEncuestaEmpleadoEdG =[SELECT  HDT_Configuracion_1__c, HDT_Configuracion_2__c,HDT_Activo__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta_EdG' LIMIT 1];
            
            if(!linkEncuestaEmpleado.isEmpty() || !linkEncuestaEmpleadoEdG.isEmpty()){
                Map<Id, Case> mapInfoCasos = new Map<Id, Case>([SELECT Origin, CaseNumber, Contact.Email, CC_Idioma__c, CC_URL_Encuesta_3N__c,CC_Matricula_Empleado__c, CC_MCC_Tematica__r.name, CC_MCC_Tematica__r.CC_idCognitivo__c, CC_MCC_Tematica__c FROM Case WHERE Id IN :lstCasosHDT]);
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

                //Recogemos el Custom Setting para obtener las direcciones de correo de respuesta
                HDT_Parametros__c emailRespuesta = HDT_Parametros__c.getInstance('HDT_Email_Respuesta_Empleados_New');

                //Recogemos los Ids del remitente ordenadas alfabeticamente por la direccion (0: Catalan, 1 Castellano) en el caso de que existan los 2
                List <OrgWideEmailAddress> remitentesId = [SELECT Id FROM OrgWideEmailAddress WHERE Address IN (: emailrespuesta.HDT_Configuracion_1__c, : emailrespuesta.HDT_Configuracion_2__c) ORDER BY Address];

                List <EmailTemplate> plantillasNoEdG = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE : apiNamePlantillas ORDER BY DeveloperName];
                List <EmailTemplate> plantillasEdG =  [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE : apiNamePlantillasEdG ORDER BY DeveloperName];
                


                for(Case casoFiltrado : lstCasosHDT){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List <EmailTemplate> plantillas;

                    //Comprobamos que plantillas tenemos que recoger. Si es EdG o no.
                    if (canalesResolucionPrimeros.contains(casoFiltrado.CC_Canal_Resolucion__c)) {
                        //Utiilzamos las plantillas para no EdG
                        plantillas = plantillasNoEdG;
                    }else{
                        // Comprobamos si se trata de una plantilla de EdG si está activa para usarla o no.
                        // Debe estar activa el 1 de Enero de 2025.
                        if (linkEncuestaEmpleadoEdG[0].HDT_Activo__c) {
                             //Utilizamos plantillas para EdG
                            plantillas = plantillasEdG;
                        }else{
                            return;
                        }
                    }

                    if(remitentesId.size() == 2){
                        if(casoFiltrado.CC_Idioma__c == 'ca'){
                            mail.setTemplateId(plantillas[0].Id);
                            mail.setOrgWideEmailAddressId(remitentesId[0].Id);
                        }else if(casoFiltrado.CC_Idioma__c == 'en'){
                            mail.setTemplateId(plantillas[2].Id);
                            mail.setOrgWideEmailAddressId(remitentesId[1].Id);
                        }else{
                            mail.setTemplateId(plantillas[1].Id);
                            mail.setOrgWideEmailAddressId(remitentesId[1].Id);
                        }
                    }else{
                        if(casoFiltrado.CC_Idioma__c == 'ca'){
                            mail.setTemplateId(plantillas[0].Id);
                        }else if(casoFiltrado.CC_Idioma__c == 'en'){
                            mail.setTemplateId(plantillas[2].Id);
                        }else{
                            mail.setTemplateId(plantillas[1].Id);
                        }
                        mail.setOrgWideEmailAddressId(remitentesId[0].Id);
                    }

                    mail.setSaveAsActivity(true);
                    mail.setWhatId(casoFiltrado.Id);
                    mail.setTargetObjectId(casoFiltrado.ContactId);
                    mail.setTreatTargetObjectAsRecipient(false);
                    String[] toAddresses = new String[] {mapInfoCasos.get(casoFiltrado.Id).Contact.Email};
                    mail.setToAddresses(toAddresses);
                    allmsg.add(mail);

                }

                //Recogida de errores en caso de fallo de email
                //Modificado por Moisés Cano - 18102023
                try {
                    // Enviar el correo electrónico y manejar errores si los hay
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
                } catch (Exception e) {
                    CBK_Log.error(e, 'Error en el envio de email');
                }


            }
        }
    }

    //Rellena el campo Detalles Consulta con información del caso, contacto y activo al updatear el caso
    public static void informarDetallesConsulta(List<Case> lstCasos, Map<Id, Case> mapOldObj, Boolean isInsert){
        Map <Id, Case> casosMap = new Map <Id, Case>();
        List <Id> contactList = new List <Id>();
        List <Id> assetList = new List <Id>();
        Map <Id, Contact> caseContactMap;
        Map <Id, Asset> caseAssetMap;


        if(isInsert){
            for (Case caso : lstCasos){
                casosMap.put(caso.Id, caso);
                if(caso.ContactId != null){
                    contactList.add(caso.ContactId);
                }
                if(caso.AssetId != null){
                    assetList.add(caso.AssetId);
                }
            }
        }else{
            //Recogemos solo los casos en los que se ha updateado el Contact, el activo o la cuenta para actualizar el Detalles Consulta
            for (Case caso : lstCasos){
                if (mapOldObj.get(caso.Id).ContactId != caso.ContactId || mapOldObj.get(caso.Id).AssetId != caso.AssetId){
                    casosMap.put(caso.Id, caso);
                    if(caso.ContactId != null){
                        contactList.add(caso.ContactId);
                    }
                    if(caso.AssetId != null){
                        assetList.add(caso.AssetId);
                    }
                }
            }
        }

        if(!casosMap.isEmpty()){
            if(!contactList.isEmpty()){
                caseContactMap = new Map <Id, Contact>([SELECT Id, Account.Name, Name, CC_Matricula__c, Email, MobilePhone, CC_Cargo__c FROM Contact WHERE Id IN :contactList]);
            }
            if(!assetList.isEmpty()){
                caseAssetMap = new Map <Id, Asset>([SELECT Id, Name FROM Asset WHERE Id IN : assetList]);
            }

            for(Case caso : casosMap.values()){
                String detalles = '#\n';
                detalles += caso.CaseNumber + '\n';

                if(caso.ContactId != null){
                    detalles += caseContactMap.get(caso.ContactId).Account.Name+'\n' + '\n' + caseContactMap.get(caso.ContactId).Name + '\n' + caseContactMap.get(caso.ContactId).CC_Matricula__c +
                    '\n' + caseContactMap.get(caso.ContactId).Email + '\n' + caseContactMap.get(caso.ContactId).MobilePhone +
                    '\n' + caseContactMap.get(caso.ContactId).CC_Cargo__c + '\n';
                }
                if(caso.AssetId != null){
                    detalles += '\n' + caseAssetMap.get(caso.AssetId).Name + '\n';
                }
                detalles += '#';
                if(caso.CC_Detalles_Consulta__c == null){
                    caso.CC_Detalles_Consulta__c = detalles;
                }else{
                    if(caso.CC_Detalles_Consulta__c.startsWith('#')){
                        String [] infoDetalles = caso.CC_Detalles_Consulta__c.split('#');
                        if(infoDetalles.size() == 2){
                            caso.CC_Detalles_Consulta__c = detalles;
                        }else if(infoDetalles.size() > 2){
                            caso.CC_Detalles_Consulta__c = detalles + '\n' + infoDetalles[2];
                        }
                    }
                }
            }
        }
    }

    public static String generarUrlEncuesta(String configuracion2, String configuracion1, String idioma, String canalResolucion, String matriculaEmpleado, String caseNumber, String tematicaId, String tematicaName) {
        return configuracion2 +
               'sid=' + configuracion1 +
               '&lang=' + idioma +
               '&empresa=' + canalResolucion +
               '&userid=' + matriculaEmpleado +
               '&ticketid=' + caseNumber +
               '&idet=' + tematicaId +
               '&et=' + tematicaName.replace(' ', '_') +
               '&newtest=Y';
    }
}