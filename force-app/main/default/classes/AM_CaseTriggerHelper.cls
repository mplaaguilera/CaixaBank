public with sharing class AM_CaseTriggerHelper {

    public static List<Case> filtrarCasosAM(List<Case> lstCasos) {

        List<Case> casosAM = new List<Case>();
        // Recuperar RT's con buen rendimiento.
        Map<String,Schema.RecordTypeInfo> mapRTsObjects = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        Id AMCaseTypeId = mapRTsObjects.get('AM_Cliente').getRecordTypeId();
        Id AMCaseTypeEmpleadoId = mapRTsObjects.get('AM_Empleado').getRecordTypeId();
        for (Case caso : lstCasos) {
            if (caso.recordTypeId == AMCaseTypeId || caso.recordTypeId == AMCaseTypeEmpleadoId) {
                casosAM.add(caso);
            }
        }
        
        return casosAM;
    }
   
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
                    caso.CC_MailTelfNotif__c = mapAccount.get(caso.AccountId).CC_NumPerso__c;
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
    @future
    public static void creacionCaso_AI(String jsonCasos) {
        List<Case> lstCasos = (List<Case>)JSON.deserialize(jsonCasos, List<Case>.class);
        for (Case caso : lstCasos) {
            if (caso.CC_Admin__c) {
                caso.CC_Admin__c = false;
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
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
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

    public static void informarOficinaAfectadaDetalleBU(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id rtBankia = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        for (Case caso : lstCasos) {
            if (caso.CC_Oficina__c != mapOldObj.get(caso.Id).CC_Oficina__c && caso.CC_Oficina__c != null && caso.AccountId == null && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia ) {
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
            if (caso.AccountId != null && caso.AccountId != mapOldObj.get(caso.Id).AccountId && caso.RecordTypeId != rtEmpleado && caso.RecordTypeId != rtBankia ) {
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



}