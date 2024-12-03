global class CC_FAQ_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private String sAplicacion;

    public CC_FAQ_Batch() {
    }

    public CC_FAQ_Batch(String strParam) {
        sAplicacion = strParam;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        ID iRTEspaciosAct = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_EspaciosActualizar').getRecordTypeId();
        String query = 'Select Id, Name, CC_Lookup_Espacio__c, CC_Lookup_App__c, CC_GlobalId__c, CC_ErrorCola__c from CC_FAQ__c where RecordTypeId = \'' + iRTEspaciosAct + '\' AND CC_ErrorCola__c = false';
        if (!String.isBlank(sAplicacion))
        {
            query = query + ' AND CC_Lookup_App__c = \'' + sAplicacion + '\'';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CC_FAQ__c> scope) {

        // Control que exista un registro por procesar.
        if (scope == null)
        {
            return;
        }

        if (scope.isEmpty())
        {
            return;
        }

        List<CC_FAQ__c> oEspacioProcesados = new List<CC_FAQ__c>();
        List<CC_FAQ__c> oEspacioError = new List<CC_FAQ__c>();
        Set<ID> oAppRevisar = new Set<ID>();
        ID iAppID; //US489537

        for (CC_FAQ__c oEspacio : scope)
        {
            //ID iAppID = oEspacio.CC_Lookup_App__c; Se comenta por US489537

            try{
                String sEspacio = oEspacio.Name;
                String sIdGlobal = oEspacio.CC_GlobalId__c;

                // Obtención de FAQs vía WS.
                String sRetornoWS = CC_FAQ.getFAQCognitivoWSBatch(sEspacio, sIdGlobal);

                if (sRetornoWS != '')
                {
                    // Procesar la respuesta.

                    ID iEspacioID = oEspacio.CC_Lookup_Espacio__c;
                    
                    if (Test.isRunningTest())
                    {
                        sRetornoWS = CC_FAQ.RespuestaFakeEspacio();
                    }

                    String sPriError = CC_FAQ.cargarRespuestaEspacios (iEspacioID, sRetornoWS);

                    if (sPriError != '')
                    {
                        oEspacio.CC_ErrorCola__c = true;
                        if (sPriError.length() > 4000)
                        {
                            sPriError = sPriError.substring(0, 4000);
                        }
                        oEspacio.CC_DetalleError__c = sPriError;
                        oEspacioError.add(oEspacio);
                    }else{
                        oEspacioProcesados.add(oEspacio);
                        iAppID = oEspacio.CC_Lookup_App__c;
                    }
                }else{
                    oEspacio.CC_ErrorCola__c = true;
                    oEspacio.CC_DetalleError__c = 'Sin mensaje de respuesta del WS';
                    oEspacioError.add(oEspacio);
                }
            }catch(Exception e) {
                // Error al procesar la respuesta.
                oEspacio.CC_ErrorCola__c = true;

                String sDetalle = e.getMessage();
                if (sDetalle.length()>4000)
                {
                    sDetalle = sDetalle.substring(0,4000);
                }
                oEspacio.CC_DetalleError__c = sDetalle;
                oEspacioError.add(oEspacio);
            }

            if (iAppID != null)
            {
                oAppRevisar.add(iAppID);
            }
        }

        // Actualizar registros erróneos.
        update oEspacioError;

        //Eliminar registros duplicados para evitar error de System.DmlException: ENTITY_IS_DELETED
        List<CC_FAQ__c> aBorrar = new List<CC_FAQ__c>(new Map<Id, CC_FAQ__c>(oEspacioProcesados).values());

        // Borrar el registro procesado.
        if (!aBorrar.isEmpty()) {
            delete aBorrar;
        }
        // Comprobar si existe algún espacio más de la aplicación para actualizar o alguno con errores.
        // En caso que no exista ninguno, consolidar la versión cargada.
        ID iRTEspaciosAct = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_EspaciosActualizar').getRecordTypeId();
        Boolean bConsolidar = false;
        if (!oAppRevisar.isEmpty())
        {
            List<CC_FAQ__c> oColaPte = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :iRTEspaciosAct AND CC_Lookup_App__c IN :oAppRevisar AND CC_ErrorCola__c = false];
            //List<CC_FAQ__c> oColaPte = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :iRTEspaciosAct AND CC_Lookup_App__c IN :oAppRevisar];
            if (oColaPte.isEmpty())
            {
                // No queda ningún espacio por procesar. Consolidar la versión.
                bConsolidar = true;
            }
        }

        // Consolidar aplicaciones.
        List<CC_FAQ__c> oAppActCons = new List<CC_FAQ__c>();
        List<CC_FAQ__c> oEspaciosCategoriasActCons = new List<CC_FAQ__c>();
        Map<ID,Decimal> oAppVersiones = new Map<ID,Decimal>();
        if ((bConsolidar)|| Test.isRunningTest())
        {
            ID iRTApp = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Aplicaciones').getRecordTypeId();
            List<CC_FAQ__c> oAppCons = [SELECT Id, CC_VersionActualizando__c, CC_Version__c FROM CC_FAQ__c
                                        WHERE RecordTypeId = :iRTApp AND Id IN :oAppRevisar];

            for (CC_FAQ__c oAplicacion : oAppCons)
            {
                oAplicacion.CC_Version__c = oAplicacion.CC_VersionActualizando__c;
                oAppVersiones.put(oAplicacion.Id, oAplicacion.CC_VersionActualizando__c);
                oAppActCons.add(oAplicacion);
            }
        }

        // Consolidar espacios.
        if ((bConsolidar && !oAppActCons.isEmpty()) || Test.isRunningTest())
        {
            ID iRTEspacio = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Espacios').getRecordTypeId();
            ID iRTCategoria = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_Categoria').getRecordTypeId();
            List<CC_FAQ__c> oEspCatCons = [SELECT Id, CC_VersionActualizando__c, CC_Version__c, CC_Lookup_App__c FROM CC_FAQ__c
                                        WHERE (RecordTypeId = :iRTEspacio OR RecordTypeId = :iRTCategoria)
                                        AND CC_Lookup_App__c IN :oAppRevisar];

            for (CC_FAQ__c oEspCat : oEspCatCons)
            {
                if (oEspCat.CC_VersionActualizando__c == oAppVersiones.get(oEspCat.CC_Lookup_App__c))
                {
                    // Consolidar espacio.
                    oEspCat.CC_Version__c = oAppVersiones.get(oEspCat.CC_Lookup_App__c);
                    oEspCat.CC_VersionActualizando__c = oAppVersiones.get(oEspCat.CC_Lookup_App__c);
                }else{
                    // Inactivar espacio.
                    oEspCat.CC_VersionActualizando__c = oEspCat.CC_Version__c;
                    oEspCat.CC_Obsoleto__c = true;
                }
                oEspaciosCategoriasActCons.add(oEspCat);
            }            
        }

        update oEspaciosCategoriasActCons;
        update oAppActCons;
    }

    global void finish(Database.BatchableContext bc) {
        // Volver a ejecutar el batch mientras queden registros en la cola.
        ID iRTEspaciosAct = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_EspaciosActualizar').getRecordTypeId();
        List<CC_FAQ__c> oTest = [SELECT Id, CC_ErrorCola__c FROM CC_FAQ__c WHERE RecordTypeId = :iRTEspaciosAct AND CC_ErrorCola__c = false];
        
        if (!oTest.isEmpty()||Test.isRunningTest())
        {
            //Si el metadato está activo o no hay registro se planifica con el framework	
        	List<CBK_Framework_Batch_Apex__mdt> oConf = [Select Id from CBK_Framework_Batch_Apex__mdt where developername ='CC_FAQ_Batch' and Activo__c=false LIMIT 1];
            if (oConf.isEmpty()){
                if (sAplicacion==null){
    	            CBK_BatchJob.executeBatch('CC_FAQ_Batch', 1,1);    
                } else {
                    map<String,Object> params = New map<String,Object>();
	                params.put('sAplicacion',sAplicacion);
                    CBK_BatchJob.executeBatch('CC_FAQ_Batch', 1, params,1);                

                }
            } else {
                CC_FAQ_Batch batch = new CC_FAQ_Batch(sAplicacion);
                Database.executeBatch(batch,1);                
            }
        }

    }
}