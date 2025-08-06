public with sharing class OS_CaseTriggerHelper {
   
    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void personAccountBI(List<Case> lstCasos) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null) {
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
    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
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
    
    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void identificarClienteAlfBI(List<Case> lstCasos) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.CC_IdentCliente__c != '0') {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            alfAux(casosAlf, setIdCuentas, true);
        }
    }

    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void identificarClienteAlfBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosAlf = new List<Case>();
        for (Case caso : lstCasos) {
            //caso.CC_IdentCliente__c != '0' no existe en el PB, añadido para contuniar la lógica del BI
            if (caso.AccountId != null && mapOldObj.get(caso.Id).CC_IdentCliente__c != caso.CC_IdentCliente__c && caso.CC_IdentCliente__c != '0') {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosAlf.add(caso);
            }
        }

        if(!setIdCuentas.isEmpty()){
            alfAux(casosAlf, setIdCuentas, true);
        }
    }

    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    public static void identificarCambioClienteAlfBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
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
            alfAux(casosAlf, setIdCuentas, false);
        }
    }
    
    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
    private static void alfAux(List<Case> lstCasos, Set<Id> setIdCuentas, Boolean cambioDocumen) {
        Map<Id,Account> mapAccount = new Map<Id, Account>([SELECT Id, CC_Email__c, CC_NumPerso__c, CC_Numero_Documento__c, CC_OficinaGestoraId__c, CC_OficinaGestoraId__r.CC_Gerencia_Comercial__c,
        CC_OficinaGestoraId__r.CC_Gerencia_Comercial__r.ParentId FROM Account WHERE Id IN :setIdCuentas]);
        
        for (Case caso : lstCasos) {
            if (mapAccount.containsKey(caso.AccountId)) {
                if(cambioDocumen || (!cambioDocumen && caso.CC_Canal_Procedencia__c != 'Formulario web')){
                    caso.CC_MailTelfNotif__c = mapAccount.get(caso.AccountId).CC_Email__c;
                    caso.CC_Numero_Documento__c = mapAccount.get(caso.AccountId).CC_Numero_Documento__c;
                    if(!cambioDocumen && caso.CC_Canal_Procedencia__c != 'Formulario web'){
                        caso.CC_NumPerso__c = mapAccount.get(caso.AccountId).CC_Numero_Documento__c;
                    }
                }
 
            }
        }
    }       


    // Metodo creado por traspaso de process builder cc_Case_Modificar_Account a trigger
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

    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
    public static void creacionCaso_BI(List<Case> lstCasos) {

        Set<Id> setIdsGrupos = new Set<Id>();
        Map<Id,Group> mapaGruposCasos = new Map<Id, Group>();
        for (Case caso : lstCasos) {
            if (caso.OwnerId != null && String.valueOf(caso.OwnerId).startsWith('00G')) {
                setIdsGrupos.add(caso.OwnerId);
            }
        }

        if (!setIdsGrupos.isEmpty()) {
            List<Group> lstGruposCasos = [SELECT Id, DeveloperName FROM Group WHERE Id IN :setIdsGrupos];
            if(!lstGruposCasos.isEmpty()){
                for (Group grupo : lstGruposCasos) {
                    mapaGruposCasos.put(grupo.Id, grupo);
                }
            }
        }

        for (Case caso : lstCasos) {
            caso.CC_Admin__c = true;
            caso.CC_Tramo_TRZ__c = 'Recibida - En evaluacion';
            caso.CC_CanalNotifCli__c = 'Email';
            caso.CC_Canal_Respuesta__c = caso.Origin;
            
            if (caso.Origin == 'Twitter') {
                caso.CC_CanalNotifCli__c = 'Twitter';
            }
            if (caso.Origin == null) {
                caso.CC_Canal_Respuesta__c = 'Email';
            } 
            else if (caso.Origin == 'Comentarios Stores') {
                caso.CC_Canal_Respuesta__c = 'Comentarios APPs';
            }
            if (mapaGruposCasos.containsKey(caso.OwnerId)) {
                caso.CC_Cola_Procedencia__c = mapaGruposCasos.get(caso.OwnerId).DeveloperName;
            }
        }
    }

    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
    public static void creacionCasoPropuestasBI(List<Case> lstCasos) {
        for (Case caso : lstCasos) {
            if (caso.Origin == 'Propuestas de mejora') {
                caso.CC_Descripcion_Problematica__c = caso.Description;
                caso.CC_Titulo_Propuesta__c = caso.Subject;
            }
        }
    }

    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
    public static void seInformaCanalRespuestaBI(List<Case> lstCasos) {
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Respuesta_Modificar__c != null && caso.Status != 'Cerrado' && caso.Status != 'Rechazado') {
                caso.CC_Canal_Respuesta__c = caso.CC_Canal_Respuesta_Modificar__c;
            }
        }
    }

    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
    public static void seInformaCanalRespuestaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        for (Case caso : lstCasos) {
            if (caso.CC_Canal_Respuesta_Modificar__c != null && caso.CC_Canal_Respuesta_Modificar__c != mapOldObj.get(caso.Id).CC_Canal_Respuesta_Modificar__c && caso.Status != 'Cerrado' && caso.Status != 'Rechazado') {
                caso.CC_Canal_Respuesta__c = caso.CC_Canal_Respuesta_Modificar__c;
            }
        }
    }

    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
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

    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
    public static void empleadoCuentaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
        List<Case> casosCuentaRellenada = new List<Case>();
        Set<Id> setCuentasCasos = new Set<Id>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.RecordtypeId == rtEmpleado) {
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

                if(mapCuentasCasos.containsKey(caso.AccountId)){
                    caso.CC_Oficina_afectada__c = mapCuentasCasos.get(caso.AccountId).CC_Numero_Oficina__c;
                }
            
            }
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


    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
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

  
    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
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

    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
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

    // Metodo creado por traspaso de process builder CC_Gestion_Caso a trigger
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
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    public static void informarOficinaAfectadaDetalleBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        for (Case caso : lstCasos) {
            if (caso.CC_Oficina__c != mapOldObj.get(caso.Id).CC_Oficina__c && caso.CC_Oficina__c != null && caso.AccountId == null && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia) {
                caso.CC_Oficina_Afectada_Lookup__c = caso.CC_Oficina__c;
            }
        }
    }

    public static void informarOficinaAfectadaBI(List<Case> lstCasos) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosOficina = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia ) {
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


    public static void informarOficinaAfectadaBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Set<Id> setIdCuentas = new Set<Id>();
        List<Case> casosOficina = new List<Case>();
        for (Case caso : lstCasos) {
            if (caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia && Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName().startsWith('OS_')) {
                if(!setIdCuentas.contains(caso.AccountId)){
                    setIdCuentas.add(caso.AccountId);
                }
                casosOficina.add(caso);
            }
        }
        if(!casosOficina.isEmpty()){
            Map<Id,Account> mapCuentas = new Map<Id,Account>([SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Id IN :setIdCuentas AND CC_OficinaGestoraId__c != null]);
            for (Case caso : casosOficina) {
                if (mapCuentas.containsKey(caso.AccountId)) {
                    caso.CC_Oficina_Afectada_Lookup__c = mapCuentas.get(caso.AccountId).CC_OficinaGestoraId__c;
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

            for (Case caso : lstCasosComprobar) {
                if(mapColas.containsKey(caso.OwnerId) && caso.CC_Cola_Procedencia__c != mapColas.get(caso.OwnerId).DeveloperName){
                    caso.CC_Cola_Procedencia__c = mapColas.get(caso.OwnerId).DeveloperName;
                }
            }
        }
    }

    public static void eliminarSituacion(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        Set<Id> casoIds = new Set<Id>();
        for(Case caso: listNewObj) {
            if(caso.CC_Ultima_Interaccion__c != 'Nuevo' && caso.OS_Eliminar_Situacion__c && caso.OS_Situacion_SR__c != null && (Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Cliente' || Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Empleado')){
                casoIds.add(caso.Id);
            }
        }
        List<Case> casosFiltrados = [SELECT CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, OS_Eliminar_Situacion__c FROM Case WHERE Id IN :casoIds];
        if (!casosFiltrados.isEmpty()){
            for (Case cadaCasoFiltrado : casosFiltrados) {
                cadaCasoFiltrado.CC_Ultima_Interaccion__c = 'Nuevo';
                cadaCasoFiltrado.CC_Fecha_Ultima_Interaccion__c = System.now();
                cadaCasoFiltrado.OS_Eliminar_Situacion__c = false;
            }
        }
        update casosFiltrados;
    }

    public static void reasignacionDelCaso(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        Set<Id> casoIds = new Set<Id>();
        String viejoOwnerId;
        String nuevoOwnerId;
        for(Case caso: listNewObj) {
            viejoOwnerId = mapOldObj.get(caso.Id).OwnerId;
            nuevoOwnerId = caso.OwnerId;
            if(nuevoOwnerId != System.UserInfo.getUserId() && nuevoOwnerId != viejoOwnerId && viejoOwnerId.startsWith('005') && nuevoOwnerId.startsWith('005') && (Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Cliente' || Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Empleado')) {
                casoIds.add(caso.Id);
            }
        }
        List<Case> casosFiltrados = [SELECT CC_Ultima_Interaccion__c, CC_Fecha_Ultima_Interaccion__c, OwnerId FROM Case WHERE Id IN :casoIds];
        if (!casosFiltrados.isEmpty()){
            for (Case cadaCasoFiltrado : casosFiltrados) {
                cadaCasoFiltrado.CC_Ultima_Interaccion__c = 'Reasignación del caso';
                cadaCasoFiltrado.CC_Fecha_Ultima_Interaccion__c = System.now();
            }
        }
        update casosFiltrados;
    }

    public static void avisoPropietarioNuevoCorreo(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        Set<Id> casoIds = new Set<Id>();
        for(Case caso: listNewObj) {
            if(caso.OS_Aviso_Propietario__c && (Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Cliente' || Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Empleado')){
                casoIds.add(caso.Id);
            }
        }
        if(!casoIds.isEmpty()) {
        List<Case> casosFiltrados = [SELECT Id, CaseNumber, OS_Aviso_Propietario__c, OwnerId FROM Case WHERE Id IN :casoIds];
        if (!casosFiltrados.isEmpty()){
                CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'OS_Notificacion_Nuevo_Correo'];
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody('Tiene nuevos correos pendientes.');
                notification.setNotificationTypeId(type.Id);
                for (Case cadaCasoFiltrado : casosFiltrados) {
                    if(String.valueOf(cadaCasoFiltrado.OwnerId).startsWith('005')) {
                        cadaCasoFiltrado.OS_Aviso_Propietario__c = false;
                        notification.setSenderId(cadaCasoFiltrado.OwnerId);
                        notification.setTitle('Aviso sobre el caso ' + cadaCasoFiltrado.CaseNumber);
                        notification.setTargetId(cadaCasoFiltrado.Id);
                        notification.send(new Set<String> { cadaCasoFiltrado.OwnerId });
                    }
                }
            }
            update casosFiltrados;
        }
    }

    public static void enviarEncuestaCierre(List<Case> listNewObj, Map<Id, Case> mapOldObj) {
        List<Id> casoIds = new List<Id>();
        for(Case caso: listNewObj) {
            if(caso.Status == 'Cerrado' && caso.Status != mapOldObj.get(caso.Id).Status && Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Empleado' && (caso.CC_Canal_Procedencia__c == 'Buzón Comercio Exterior' || caso.CC_Canal_Procedencia__c == 'Buzón Contact Center International' || caso.CC_Canal_Procedencia__c == 'Buzón International Support' || caso.CC_Canal_Procedencia__c == 'Buzón KYC Renewal' || caso.CC_Canal_Procedencia__c == 'Buzón Service Desk' || caso.CC_Canal_Procedencia__c == 'Buzón Export Online' || caso.CC_Canal_Procedencia__c == 'Teléfono COPS atención empleados')) {
                casoIds.add(caso.Id);
            }
        }
        OS_Encuesta.enviarEncuesta(casoIds);
    }

    public static void scheduleProgramarAlerta(List<Case> listNewObj, Map<Id, Case> mapOldObj){
        
        List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c>();
        
        List<CBK_SCH_PendingProcess__c> procesosAnteriores = new List<CBK_SCH_PendingProcess__c>();
        List <Id> idCasos = new List<Id>();
        
        for (Case caso: listNewObj){
            idCasos.add(caso.Id);
        }
        //Consultar si queued tiene que ser true o false
        procesosAnteriores= [SELECT Id, ClassName__c, Queued__c FROM CBK_SCH_PendingProcess__c where RecordId__c IN :idCasos AND Queued__c = false AND Schedule_Time__c >= TODAY];

        if(!procesosAnteriores.isEmpty()){
            for(CBK_SCH_PendingProcess__c proceso: procesosAnteriores){
                proceso.Queued__c = true;
            }
        }
        update procesosAnteriores;

        for (Case caso: listNewObj){
            if(mapOldObj.get(caso.Id).Status == 'Activo' && caso.Status == 'Pendiente Alerta' && caso.OS_Alerta_Fecha__c != null && (Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Empleado' || Schema.SObjectType.Case.getRecordTypeInfosById().get(caso.RecordTypeId).getDeveloperName() == 'OS_Cliente')){
                CBK_SCH_PendingProcess__c pendingProcessAlerta = new CBK_SCH_PendingProcess__c();
                pendingProcessAlerta.RecordId__c = caso.Id;
                pendingProcessAlerta.Schedule_Time__c = caso.OS_Alerta_Fecha__c;
                pendingProcessAlerta.ClassName__c = 'CBK_SCH_OS_ScheduleProgramarAlerta';
                pendingProcessInsertList.add(pendingProcessAlerta);
            }
        }
        Insert pendingProcessInsertList;
    }

    public static void actualizarOwnerBackup(Set<Id> setIdUser, List<Case> listCases) {
        List<Case> listCases2 = new List<Case>();
        Map<Id, User> mapUser = new Map<Id, User>();
        Set<String> stringColas = new Set<String>();
        Map<String, Id> mapColas = new Map<String, Id>();

        List<User> listUser = [SELECT OS_Inicio_Vigencia_Agente_Backup__c, OS_Fin_Vigencia_Agente_Backup__c, OS_Agente_Backup__c, OS_Cola_Backup__c 
                                FROM User WHERE Id IN :setIdUser AND OS_Inicio_Vigencia_Agente_Backup__c <= TODAY AND OS_Fin_Vigencia_Agente_Backup__c >= TODAY 
                                AND (OS_Agente_Backup__c != null OR OS_Cola_Backup__c != null)];
        
        if (!listUser.isEmpty()){
            for (User newUser: listUser){ 
                mapUser.put(newUser.Id, newUser);
            }
            for (Case newCase: listCases){  
                if(mapuser.containskey(newCase.ownerId)){
                    User propietario = mapUser.get(newCase.OwnerId);
                    if(propietario.OS_Agente_Backup__c != null){
                        newCase.OwnerId = propietario.OS_Agente_Backup__c;
                    }
                    else if(propietario.OS_Cola_Backup__c != null){
                        stringColas.add(propietario.OS_Cola_Backup__c); 
                        listCases2.add(newCase);
                    }
                }
            }
            if (!stringColas.isEmpty()){
                List<Group> listColas = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :stringColas];
                if(!listColas.isEmpty()){
                    for (Group cola: listColas){
                        mapColas.put(cola.Name, cola.Id);
                    }
                }
                for (Case newCase2: listCases2){ 
                    if(mapuser.containskey(newCase2.ownerId)){   
                        String nombreCola = mapUser.get(newCase2.OwnerId).OS_Cola_Backup__c;
                        if(mapColas.containsKey(nombreCola)) {
                            newCase2.OwnerId = mapColas.get(nombreCola);
                        }
                    }
                } 
            }  
        }
    }

    /*public static void filtroAcuseReciboValija_AI(List<Case> listNewObj) {
        List<Case> casesToSend = new List<Case>();
        for(Case cs : listNewObj){
            if(cs.CC_Canal_Procedencia__c == 'Valija digital'){
                casesToSend.add(cs);
            }
        }

        if(!casesToSend.isEmpty()){
            envioAcuseReciboValija(casesToSend);
        }
    }

    public static void filtroAcuseReciboValija_BI(List<Case> listNewObj) {
        List<Case> casesToSend = new List<Case>();
        for(Case cs : listNewObj){
            if(cs.CC_Canal_Procedencia__c == 'Valija digital'){
                casesToSend.add(cs);
            }
        }

        if(!casesToSend.isEmpty()){
            generarSemillaCasos(casesToSend);
        }
    }

    public static void generarSemillaCasos(List<Case> casesToSend) {
        for(Case caso : casesToSend){
            if(String.isBlank(caso.CC_Referencia_Correo_Saliente__c)){ 
                String nuevaReferencia = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.CaseNumber);
                caso.CC_Referencia_Correo_Saliente__c = nuevaReferencia;
            }
        }
    } */

    


}