public with sharing class GRR_CaseTriggerHelper {
     //private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'CC_Grupo_Colaborador__c','SAC_Interaccion__c', 'Account', 'SAC_ImagenDocumento__c', 'CBK_Case_Extension__c'};
   // private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);


    //private static final Id RECTYPECASEEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_ReclamacionCaseExt').getRecordTypeId();

   
    public static List<Case> filtrarCasosGRR(List<Case> lstCasos) {
        List<Case> casosGRR = new List<Case>();
        Id grrCasoRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        for (Case caso : lstCasos) {
            if (caso.recordTypeId == grrCasoRTId) {
                casosGRR.add(caso);
            }
        } 
        return casosGRR;
    }

    public static void crearActividadReasignacion( List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Task> lstTareas = new List<Task>();
        List<Case> casosTraspasados = new List<Case>();
        Set<Id> setIdCasos = new Set<Id>();
        for (Case caso : lstCasos) {
            if(mapOldObj.containsKey(caso.Id) && caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.OwnerId != null){
                casosTraspasados.add(caso);
                setIdCasos.add(caso.Id);
            }
        }
    
        if(!casosTraspasados.isEmpty()){
            Map<ID, Case> mapCasos = new Map<ID, Case>([SELECT Id, Owner.Name FROM Case WHERE Id IN :setIdCasos]);
            
            if(!mapCasos.isEmpty()){
                for (Case casoTrasladado : casosTraspasados) {
                    String titulo = 'Reasignación del caso';
                
                    if((String.valueOf(casoTrasladado.OwnerId).startsWith('005') || String.valueOf(casoTrasladado.OwnerId).startsWith('00G')) && mapCasos.containsKey(casoTrasladado.Id)){
                        titulo = 'Reasignación del caso a ' + mapCasos.get(casoTrasladado.Id).Owner.Name;
                        Task createTask = new Task(Type = 'Reasignación' , Subject = 'Reasignación', ActivityDate = System.today(), Status = 'Completed', WhatId = casoTrasladado.Id,
                        Description = titulo, RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task'));
                        lstTareas.add(createTask);
                    }


                }
            }
        }
    
        if(!lstTareas.isEmpty()){
            insert lstTareas;
        }
        
    }

    public static void informarCamposOficina(List<Case> lstCasos, Map<Id, Case> mapOldObj) {
        List<Case> lstCasosComprobar = new List<Case>();     
        Set<Id> setIdsOficinas = new Set<Id>();
        for (Case caso : lstCasos) {
            if (mapOldObj.containsKey(caso.Id) && caso.CC_Oficina__c != mapOldObj.get(caso.Id).CC_Oficina__c) {
                setIdsOficinas.add(caso.CC_Oficina__c);
                lstCasosComprobar.add(caso);
            }
        }

        if(!lstCasosComprobar.isEmpty()){
            Map<Id, Account> listaOficinas = new Map<Id, Account>([SELECT Id,CC_Gerencia_Comercial__c,CC_Direccion_Territorial__c
                                                        FROM Account WHERE Id = :setIdsOficinas]);

            for (Case caso : lstCasosComprobar) {
                if (caso.CC_Oficina__c != null) {
                    caso.CC_DAN__c = listaOficinas.get(caso.CC_Oficina__c).CC_Gerencia_Comercial__c;
                    caso.CC_Direccion_Territorial__c = listaOficinas.get(caso.CC_Oficina__c).CC_Direccion_Territorial__c; 
                } else {
                    caso.CC_DAN__c = null;
                    caso.CC_Direccion_Territorial__c = null;
                }   
            }
        }
    }


     @AuraEnabled(cacheable=true)
    public static Case informarCambioTipo(Id extensionId) {

       // if (extensionId == null) return;

         // Cargar la extensión con el campo GRR_Tipo_Recobro__c
        CBK_Case_Extension__c extension = [
                SELECT Id, GRR_Tipo_Recobro__c
                FROM CBK_Case_Extension__c
                WHERE Id = :extensionId
                LIMIT 1
            ];

            // Buscar el Case que tenga esta extensión
            List<Case> casos = [
                SELECT Id, CBK_Case_Extension_Id__c
                FROM Case
                WHERE CBK_Case_Extension_Id__c = :extensionId
                LIMIT 1
            ];

            if (casos.isEmpty()) return null;

            Case caso = casos[0];

            // Map para MCC de producto (por nombre)
            Map<String, CC_MCC__c> mapMccProducto = new Map<String, CC_MCC__c>();
            for (CC_MCC__c mcc : [
                SELECT Id, Name, CC_Tematica__c
                FROM CC_MCC__c
                WHERE Name IN ('Semanal', 'Urgente')
            ]) {
                mapMccProducto.put(mcc.Name, mcc);
            }

            String tipo = extension.GRR_Tipo_Recobro__c;

            if (tipo == 'Recurrente' && mapMccProducto.containsKey('Semanal')) {
                CC_MCC__c producto = mapMccProducto.get('Semanal');
                caso.CC_MCC_ProdServ__c = producto.Id;
                caso.CC_MCC_Tematica__c = producto.CC_Tematica__c;
             } else if (tipo == 'Urgente' && mapMccProducto.containsKey('Urgente')) {
                CC_MCC__c producto = mapMccProducto.get('Urgente');
                caso.CC_MCC_ProdServ__c = producto.Id;
                caso.CC_MCC_Tematica__c = producto.CC_Tematica__c;
            }

             return caso; // solo devuelves el caso con los nuevos valores, sin hacer update
    }



    public static void informarDatosEntradaCOPS(List<Case> lstCasos) {

        //Recogemos el producto y tematica 
        List <CC_MCC__c> lstMcc = [SELECT Id,CC_Tematica__c  from CC_MCC__c
        WHERE Name = 'Semanal' limit 1];

        if(!lstMcc.isEmpty()){

            for (Case caso : lstCasos) {
                if (caso.SAC_OrigenConsulta__c == 'Servicio Recobro') {
                        caso.CC_Canal_Procedencia__c = 'Servicio Recobro';
                        caso.CC_MCC_Tematica__c = lstMCC[0].CC_Tematica__c;
						caso.CC_MCC_ProdServ__c = lstMCC[0].Id;
					    caso.Origin = 'SAC_Manual';
                        caso.Subject = 'Caso de recobro';
                    }
                }
        }
    }

     

    public static void asignarDirecciones(List<Case> listCasosSPV, Map<Id, Case> mapOldObj) {

        // Mapa de provincias a Comunidad Autónoma con los valores exactos de picklist
            Map<String, String> provinciaToComunidad = new Map<String, String>{
            'ÁLAVA' => 'PAÍS VASCO',
            'ALBACETE' => 'CASTILLA-LA MANCHA',
            'ALICANTE' => 'COMUNIDAD VALENCIANA',
            'ALMERÍA' => 'ANDALUCÍA',
            'ASTURIAS' => 'PRINCIPADO DE ASTURIAS',
            'ÁVILA' => 'CASTILLA Y LEÓN',
            'BADAJOZ' => 'EXTREMADURA',
            'BALEARES' => 'ISLAS BALEARES',
            'BARCELONA' => 'CATALUÑA',
            'BURGOS' => 'CASTILLA Y LEÓN',
            'CÁCERES' => 'EXTREMADURA',
            'CÁDIZ' => 'ANDALUCÍA',
            'CANTABRIA' => 'CANTABRIA',
            'CASTELLÓN' => 'COMUNIDAD VALENCIANA',
            'CEUTA' => 'CIUDAD AUTÓNOMA DE CEUTA',
            'CIUDAD REAL' => 'CASTILLA-LA MANCHA',
            'CÓRDOBA' => 'ANDALUCÍA',
            'CUENCA' => 'CASTILLA-LA MANCHA',
            'GERONA' => 'CATALUÑA',
            'GRANADA' => 'ANDALUCÍA',
            'GUADALAJARA' => 'CASTILLA-LA MANCHA',
            'GUIPÚZCOA' => 'PAÍS VASCO',
            'HUELVA' => 'ANDALUCÍA',
            'HUESCA' => 'ARAGÓN',
            'JAÉN' => 'ANDALUCÍA',
            'LA CORUÑA' => 'GALICIA',
            'LA RIOJA' => 'LA RIOJA',
            'LAS PALMAS' => 'CANARIAS',
            'LEÓN' => 'CASTILLA Y LEÓN',
            'LÉRIDA' => 'CATALUÑA',
            'LUGO' => 'GALICIA',
            'MADRID' => 'Comunidad de Madrid',
            'MÁLAGA' => 'ANDALUCÍA',
            'MELILLA' => 'CIUDAD AUTÓNOMA DE MELILLA',
            'MURCIA' => 'REGIÓN DE MURCIA',
            'NAVARRA' => 'COMUNIDAD FORAL DE NAVARRA',
            'ORENSE' => 'GALICIA',
            'PALENCIA' => 'CASTILLA Y LEÓN',
            'PONTEVEDRA' => 'GALICIA',
            'SALAMANCA' => 'CASTILLA Y LEÓN',
            'SANTA CRUZ DE TENERIFE' => 'CANARIAS',
            'SEGOVIA' => 'CASTILLA Y LEÓN',
            'SEVILLA' => 'ANDALUCÍA',
            'SORIA' => 'CASTILLA Y LEÓN',
            'TARRAGONA' => 'CATALUÑA',
            'TERUEL' => 'ARAGÓN',
            'TOLEDO' => 'CASTILLA-LA MANCHA',
            'VALENCIA' => 'COMUNIDAD VALENCIANA',
            'VALLADOLID' => 'CASTILLA Y LEÓN',
            'VIZCAYA' => 'PAÍS VASCO',
            'ZAMORA' => 'CASTILLA Y LEÓN',
            'ZARAGOZA' => 'ARAGÓN'
        };



        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // 1. Recolectamos los AccountId y ContactId
        for (Case c : listCasosSPV) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            } else if (c.ContactId != null) {
                contactIds.add(c.ContactId);
            }
        }

        // 2. Consultamos los contactos con sus cuentas
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        if (!contactIds.isEmpty()) {
            contactMap = new Map<Id, Contact>(
                [SELECT Id, AccountId
                 FROM Contact
                 WHERE Id IN :contactIds AND AccountId != null]
            );

            for (Contact c : contactMap.values()) {
                if (c.AccountId != null) {
                    accountIds.add(c.AccountId);
                }
            }
        }

        // 3. Consultamos las cuentas con las direcciones
        Map<Id, Account> accountMap = new Map<Id, Account>();
        if (!accountIds.isEmpty()) {
            accountMap = new Map<Id, Account>(
                [SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry,PersonMobilePhone
                 FROM Account
                 WHERE Id IN :accountIds]
            );
        }

        // 4. Asignamos los datos al caso
        for (Case c : listCasosSPV) {
            Account acc = null;

            if (c.AccountId != null && accountMap.containsKey(c.AccountId)) {
                acc = accountMap.get(c.AccountId);
            } else if (c.ContactId != null && contactMap.containsKey(c.ContactId)) {
                Id accIdFromContact = contactMap.get(c.ContactId).AccountId;
                if (accountMap.containsKey(accIdFromContact)) {
                    acc = accountMap.get(accIdFromContact);
                }
            }

            if (acc != null) {

                //Mapeamos la Oficina y el DAN

                c.SAC_DireccionContacto__c = acc.BillingStreet;
                c.SAC_PoblacionContacto__c = acc.BillingCity;
                c.GRR_Provincia__c = acc.BillingState;
                c.CC_DAN__c = acc.Id;
                c.CC_Oficina__c = acc.Id;
                c.CC_Direccion_Territorial__c = acc.Id;
                c.CC_MailTelfNotif__c = acc.PersonMobilePhone;

                String provincia = acc.BillingState != null ? acc.BillingState.trim().toUpperCase() : null;

                // Solo asigna comunidad si hay equivalencia exacta
                if (provincia != null && provinciaToComunidad.containsKey(provincia)) {
                    c.GRR_ComunidadAutonoma__c = provinciaToComunidad.get(provincia);
                } else {
                    c.GRR_ComunidadAutonoma__c = null; // o algún valor por defecto permitido
                }
            }
        }
    }

     public static void limpiarDireccionesSiCambiaContacto(List<Case> listCasos, Map<Id, Case> mapOldCasos) {

        

        for (Case c : listCasos) {
            Case oldCase = mapOldCasos.get(c.Id);
           
            // Si el contacto ha cambiado o ha sido eliminado
            if (c.AccountId != oldCase.AccountId){
                
                c.SAC_DireccionContacto__c = null;
                c.SAC_PoblacionContacto__c = null;
                c.GRR_Provincia__c = null;
                c.GRR_ComunidadAutonoma__c = null;
                c.CC_Oficina__c = null;
                c.CC_Direccion_Territorial__c = null;
                c.CC_MailTelfNotif__c = null;
                c.CC_DAN__c = null;
            }
        }
    }

    public static void handleAfterInsert(List<Case> newCases) {
        
        List<CBK_Case_Extension__c> extensionsToInsert = new List<CBK_Case_Extension__c>();
        Map<Id, Id> caseToExtensionMap = new Map<Id, Id>();

        // Primero creamos los Case_Extension__c
        for (Case c : newCases) {
           
            // Aplica aquí tu condición
            if (c.CC_Canal_Procedencia__c == 'Servicio Recobro' && c.CBK_Case_Extension_Id__c == null) {
                
                CBK_Case_Extension__c extension = new CBK_Case_Extension__c();
                extension.Case_Id__c = c.Id;
                //extension.GRR_Fecha_EnvioDT__c = Date.today();
                //extension.GRR_Fecha_RespuestaDT__c = Date.today();
                extension.GRR_Tipo_Recobro__c = 'Recurrente';
                extension.GRR_Agencia__c = '';
                extension.GRR_Ingresos__c = 0;
                extension.GRR_Resumen_Sondeo__c = '';
                extension.GRR_Numero_Expediente__c ='';
                extension.GRR_Informacion_Oficina__c = '';
                extension.GRR_Propuesta_Servicio__c ='';
                extension.GRR_Identificador_Llamada__c = '';
                extensionsToInsert.add(extension);
            }
        }

        if (!extensionsToInsert.isEmpty()) {
           
            insert extensionsToInsert;

            // Relacionar el Case con su Case_Extension__c
            for (CBK_Case_Extension__c ext : extensionsToInsert) {
                caseToExtensionMap.put(ext.Case_Id__c, ext.Id);
                
            }

            List<Case> casesToUpdate = new List<Case>();
            Integer i = 0;
            for (Case c : newCases) {
                if (caseToExtensionMap.containsKey(c.Id)) {
                    Case updatedCase = new Case(
                        Id = c.Id,
                        CBK_Case_Extension_Id__c = extensionsToInsert[i].Id
                    );
                    casesToUpdate.add(updatedCase);
                    i++;

                }
            }

            if (!casesToUpdate.isEmpty()) {
                
                update casesToUpdate;
            }
        }
    }

     @AuraEnabled(cacheable=true)
    public static Id getCaseExtensionId(Id recordId) {
        List<CBK_Case_Extension__c> caseExtensions = [SELECT Id FROM CBK_Case_Extension__c
                                                            WHERE Case_Id__c = :recordId LIMIT 1];
        return caseExtensions.isEmpty() ? null : caseExtensions[0].Id;
    }
    
    @AuraEnabled(cacheable=true)
    public static CBK_Case_Extension__c getCaseExtension(Id caseId) {
        return [SELECT Id,GRR_Agencia__c,GRR_Entidad__c,
                       GRR_Fecha_EnvioDT__c,
                       GRR_Fecha_RespuestaDT__c,
                       GRR_Tipo_Recobro__c,
                       GRR_Clasificacion__c,
                       GRR_Servicio__c,
                       GRR_Garantia__c,
                       GRR_Origen__c,
                       GRR_Ingresos__c,
                       GRR_Motivo_Bloqueo__c,
                       GRR_Resumen_Sondeo__c,
                       GRR_Numero_Expediente__c,
                       GRR_Informacion_Oficina__c,
                       GRR_Propuesta_Servicio__c,
                       GRR_Identificador_Llamada__c
                FROM CBK_Case_Extension__c
                WHERE Case_Id__c = :caseId
                LIMIT 1];
    }

     @AuraEnabled(cacheable=true)
    public static String getUserRoleName() {
        User u = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return u.UserRole != null ? u.UserRole.Name : '';
       
    }


}