public with sharing class SPV_LCMP_ReclamacionesVinculadas {

    private static Set<String> objetos = new Set<String>{'Case','CBK_CaseToCaseRelationship__c','CBK_Case_Extension__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACIONSAC = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSIONSAC = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSIONSPV = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPECASORELACIONADOSPV = mapRTsObjects.get('CBK_CaseToCaseRelationship__c').get('SPV_CasoRelacionado').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_ReclamacionCaseExt').getRecordTypeId();


    /*****************************************************************
     * @description Obtener las reclamaciones SAC/SPV relacionadas con la reclamación SPV actual
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US934229      Raúl Santos   04/06/2024        Creación
     * 1.1             US1208255     Raúl Santos   23/05/2025        Modificación: múltiple vinculación
     *****************************************************************/
    @AuraEnabled
    public static List<ReclamacionWrapper> getReclamacionesMismoReclamante(String idCasoActual, String regProyecto){

        List<ReclamacionWrapper> listadoFinal = new List<ReclamacionWrapper>();
        List<SAC_CaseReclamante__c> listReclamantesCasoActual = new List<SAC_CaseReclamante__c>();
        Set<Id> idsReclamantesActual = new Set<Id>();
        Set<Id> idsReclamaciones = new Set<Id>();
        Set<Id> idsPretensiones = new Set<Id>();
        Set<Id> idsCasosRelacionados = new Set<Id>();
        Map<Id, String> mapIdRecNombreReclamantePpal = new Map<Id, String>();
        Map<Id, List<Case>> mapReclamacionPretensiones = new Map<Id, List<Case>>();
        Map<id, Case> mapReclamaciones = new Map<Id,Case>();
        Map<Id, List<String>> mapIdRecNombreReclamanteSec = new Map<Id, List<String>>();
        Map<Id, List<String>> mapIdPretContratos = new Map<Id, List<String>>();
        Id rtReclamacion;
        Id rtPretension;

        if(regProyecto == 'SAC'){
            rtReclamacion = RECTYPERECLAMACIONSAC;
            rtPretension = RECTYPEPRETENSIONSAC;
        }else if(regProyecto == 'Supervisores'){
            rtReclamacion = RECTYPERECLAMACIONSPV;
            rtPretension = RECTYPEPRETENSIONSPV;
        }

        if(String.isNotBlank(rtReclamacion) && String.isNotBlank(rtPretension)){
            //Recupero los reclamantes (principal y secundarios) de la reclamación actual
            if(Schema.sObjectType.SAC_CaseReclamante__c.isAccessible()){
                listReclamantesCasoActual = [SELECT Id, SAC_Account__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c = :idCasoActual];
            }

            //Almaceno el id de estos reclamantes, para posteriormente recuperar los registros SAC_CaseReclamante__c, con reclamantes iguales a los de la reclamacion actual
            if(!listReclamantesCasoActual.isEmpty()){
                for(SAC_CaseReclamante__c reclamante : listReclamantesCasoActual){
                    idsReclamantesActual.add(reclamante.SAC_Account__c);
                }
            }


            //Recupero los reclamantes (principales y secundarios) de reclamaciones SAC o SPV, que coincidan con los de la reclamacion actual
            if(!idsReclamantesActual.isEmpty()){
                List<SAC_CaseReclamante__c> listReclamantes = [SELECT Id, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name, SAC_Case__r.CaseNumber
                                        FROM SAC_CaseReclamante__c
                                        WHERE SAC_Case__r.RecordTypeId = :rtReclamacion AND SAC_Account__c IN :idsReclamantesActual AND SAC_Case__c != null];

                if(!listReclamantes.isEmpty()){
                    //Recorro los reclamantes para obtener los id de sus reclamaciones correspondientes, y aquellos que sean principales los añado a un mapa relacionandolos con la reclamacion para imprimirlos por pantalla de cara al usuario final
                    for(SAC_CaseReclamante__c reclamante : listReclamantes){

                        idsReclamaciones.add(reclamante.SAC_Case__c);

                        if(reclamante.SAC_ReclamantePrincipal__c){
                            String nombreReclamantePpal = reclamante.SAC_Account__r.Name; 
                            mapIdRecNombreReclamantePpal.put(reclamante.SAC_Case__c, nombreReclamantePpal);
                        }
                    }
                }
            }
            
            //Recupero la información necesaria de las reclamaciones y sus pretensiones hijas, para mostrar los datos deseados al usuario final
            if(!idsReclamaciones.isEmpty() && Schema.sObjectType.Case.isAccessible()){
                List<Case> listaCasos = [SELECT Id, RecordTypeId, Account.Name, SAC_Reclamacion__c, CreatedDate, CaseNumber, toLabel(Status), Subject, CC_CasoRelacionado__c, SEG_Grupo__r.Name, Owner.Name, toLabel(SAC_SentidoResolucion__c), SAC_ArgumentarioPretensiones__c, SPV_NumExpediente__c
                                        FROM Case WHERE ((RecordTypeId = :rtReclamacion AND Id IN :idsReclamaciones) OR (RecordTypeId = :rtPretension AND SAC_Reclamacion__c IN :idsReclamaciones)) AND (Id != :idCasoActual AND SAC_Reclamacion__c != :idCasoActual)];

                if(!listaCasos.isEmpty()){
                    Set<Id> setIdsReclamaciones = new Set<Id>();

                    //Recorro los casos recuperados, y los almaceno en un mapa para diferenciar las reclamaciones (con la informacion de estas), y otro mapa para tener las pretensiones relacionadas con su reclamacion padre.
                    //Tambien, en caso de que el AccountId de una reclamacion (equivale a su reclamante principal) no este en el mapa de reclamantes principales, le añado al mapa de reclamantes anteriormente creado.
                    for (Case caso : listaCasos) {

                        if (caso.RecordTypeId == rtReclamacion) {
                            setIdsReclamaciones.add(caso.Id);
                            mapReclamaciones.put(caso.Id, caso);

                            if(!mapReclamacionPretensiones.containsKey(caso.Id)){
                                mapReclamacionPretensiones.put(caso.Id, new List<Case>());
                            }

                            if(caso.Account.Name != null && !mapIdRecNombreReclamantePpal.containsKey(caso.Id)){
                                String nombreReclamantePpal = caso.Account.Name; 
                                mapIdRecNombreReclamantePpal.put(caso.Id, nombreReclamantePpal);
                            }
                        }else if (caso.RecordTypeId == rtPretension) {                       
                            List<Case> listPretensiones;
                            Id idReclamacion = caso.SAC_Reclamacion__c;

                            if(mapReclamacionPretensiones.containsKey(idReclamacion)){
                                listPretensiones = mapReclamacionPretensiones.get(idReclamacion);
                            } else {
                                listPretensiones = new List<Case>();
                            }
        
                            listPretensiones.add(caso);
                            mapReclamacionPretensiones.put(idReclamacion, listPretensiones);
                            idsPretensiones.add(caso.Id);
                        }
                    }

                    //Compruebo si el caso actual tiene alguno de los casos recuperados ya vinculado
                    List<CBK_CaseToCaseRelationship__c> listCasosRelacionados = [SELECT Id, SPV_CasoVinculado__c FROM CBK_CaseToCaseRelationship__c WHERE RecordTypeId = :RECTYPECASORELACIONADOSPV AND SPV_CasoPadre__c = :idCasoActual AND SPV_CasoVinculado__c IN :setIdsReclamaciones];
                    if(!listCasosRelacionados.isEmpty()){
                        for(CBK_CaseToCaseRelationship__c casoRelacionado : listCasosRelacionados){
                            idsCasosRelacionados.add(casoRelacionado.SPV_CasoVinculado__c);
                        }
                    }
                }

                //Recupero los reclamantes secundarios de las reclamaciones con las que estamos trabajando
                List<SAC_CaseReclamante__c> listReclamantesSecundarios = [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
                                        FROM SAC_CaseReclamante__c WHERE SAC_Case__c IN: idsReclamaciones AND SAC_ReclamantePrincipal__c = false];

                if(!listReclamantesSecundarios.isEmpty()){
                    //Recorremos los reclamantes secundarios, para clasificarlos en un mapa de cara a la presentación al usuario final
                    for(SAC_CaseReclamante__c reclamante : listReclamantesSecundarios){
                        List<String> nombreReclamantes;

                        if(mapIdRecNombreReclamanteSec.containsKey(reclamante.SAC_Case__c)){
                            nombreReclamantes = mapIdRecNombreReclamanteSec.get(reclamante.SAC_Case__c);
                        } else {
                            nombreReclamantes = new List<String>();
                        }

                        String nombreReclamanteSec = reclamante.SAC_Account__r.Name;
                        nombreReclamantes.add(nombreReclamanteSec);
                        mapIdRecNombreReclamanteSec.put(reclamante.SAC_Case__c, nombreReclamantes);
                    }
                }

            }
            
            if(!mapReclamacionPretensiones.isEmpty()){
                //Recuperamos los Nº de contrato de los productos asociados a cada pretension
                List<SAC_ProductCase__c> listaProdContrato = [SELECT Id, SAC_Pretension__c, N_Contrato__c FROM SAC_ProductCase__c WHERE SAC_Pretension__c IN :idsPretensiones];
                if(!listaProdContrato.isEmpty()){
                    for(SAC_ProductCase__c contrato : listaProdContrato){
                        List<String> listNumerosContratos;

                        if(mapIdPretContratos.containsKey(contrato.SAC_Pretension__c)){
                            listNumerosContratos = mapIdPretContratos.get(contrato.SAC_Pretension__c);
                        } else {
                            listNumerosContratos = new List<String>();
                        }

                        String numeroContrato = contrato.N_Contrato__c;
                        listNumerosContratos.add(numeroContrato);
                        mapIdPretContratos.put(contrato.SAC_Pretension__c, listNumerosContratos);
                    }
                }

                //Pasamos el mapa de reclamaciones a un wrapper para retornar una lista con toda la información necesaria para cada reclamacion SAC relacionada
                for(String idReclamacion : mapReclamacionPretensiones.keySet()){

                    Boolean estaVinculado = false;

                    if(idsCasosRelacionados.contains(idReclamacion)){
                        estaVinculado = true;
                    }   

                    ReclamacionWrapper reclamacionAuxiliar = new ReclamacionWrapper(mapReclamaciones.get(idReclamacion), mapReclamacionPretensiones.get(idReclamacion), mapIdRecNombreReclamantePpal.get(idReclamacion), mapIdRecNombreReclamanteSec.get(idReclamacion), mapIdPretContratos, estaVinculado);
                    listadoFinal.add(reclamacionAuxiliar);
                }
            }
        }

        return listadoFinal; 
    }

    /*****************************************************************
     * @description Vincular una reclamación SAC a la reclamción de SPV
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US934229      Raúl Santos   04/06/2024        Creación
     * 1.1             US1208255     Raúl Santos   23/05/2025        Modificación: múltiple vinculación
     *****************************************************************/
    @AuraEnabled
    public static void vincularReclamacion(String idCasoVinculado, String idCasoActual){

        CBK_CaseToCaseRelationship__c casoVinculado = new CBK_CaseToCaseRelationship__c();
        casoVinculado.SPV_CasoPadre__c = idCasoActual;
        casoVinculado.SPV_CasoVinculado__c = idCasoVinculado;
        casoVinculado.RecordTypeId = RECTYPECASORELACIONADOSPV;

        if(Schema.sObjectType.CBK_CaseToCaseRelationship__c.isCreateable()){
            SPV_DatabaseDML.insertDML(casoVinculado, true);   
        }          

            // Obtener extensiones de ambos casos
        // List<Id> idsCasos = new List<Id>{ idCasoActual, idCasoVinculado };

        List<CBK_Case_Extension__c> caseExt = [SELECT Id, SPV_TieneCasosVinculados__c FROM CBK_Case_Extension__c WHERE RecordTypeId = :RECTYPERECLAMACIONEXTENSION AND Case_Id__c = :idCasoVinculado];

        if(!caseExt.isEmpty() && !caseExt[0].SPV_TieneCasosVinculados__c){
            caseExt[0].SPV_TieneCasosVinculados__c = true;
        }

        // Marcar los casos que aún no tienen el flag activado
        // List<CBK_Case_Extension__c> caseExtsToUpdate = new List<CBK_Case_Extension__c>();
        // for (CBK_Case_Extension__c ext : caseExts) {
        //     if (!ext.SPV_TieneCasosVinculados__c) {
        //         ext.SPV_TieneCasosVinculados__c = true;
        //         caseExtsToUpdate.add(ext);
        //     }
        // }

        if (!caseExt.isEmpty() && Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()) {
            SPV_DatabaseDML.updateListDML(caseExt, true);   
        }   
    }


    /*****************************************************************
     * @description Desvincular una reclamación SAC de la reclamción de SPV
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US934229      Raúl Santos   04/06/2024        Creación
     * 1.1             US1208255     Raúl Santos   23/05/2025        Modificación: múltiple vinculación
     *****************************************************************/
    @AuraEnabled
    public static void desvincularReclamacion(String idCasoVinculado, String idCasoActual){

        List<CBK_CaseToCaseRelationship__c> listCasoVinculado = [SELECT Id, SPV_CasoPadre__c, SPV_CasoVinculado__c FROM CBK_CaseToCaseRelationship__c WHERE RecordTypeId = :RECTYPECASORELACIONADOSPV AND SPV_CasoVinculado__c = :idCasoVinculado]; //SPV_CasoPadre__c = :idCasoActual
        // List<CBK_CaseToCaseRelationship__c> listCasoVinculadoDelVinculado = [SELECT Id, SPV_CasoPadre__c, SPV_CasoVinculado__c FROM CBK_CaseToCaseRelationship__c WHERE RecordTypeId = :RECTYPECASORELACIONADOSPV AND SPV_CasoPadre__c = :idCasoVinculado];


        if(!listCasoVinculado.isEmpty()){

            List<CBK_CaseToCaseRelationship__c> vinculacionEliminar = new List<CBK_CaseToCaseRelationship__c>();
            Integer contador = 0;

            for(CBK_CaseToCaseRelationship__c relacionado : listCasoVinculado){
                if(relacionado.SPV_CasoPadre__c == idCasoActual){ //   if(relacionado.SPV_CasoVinculado__c == idCasoVinculado){
                    vinculacionEliminar.add(relacionado);
                }
                contador++;
            }

            if(!vinculacionEliminar.isEmpty()){
                SPV_DatabaseDML.deleteListDML(vinculacionEliminar, true);

                if(contador == 1){
                    //Actualizar caso (no vinculadas)
                    List<CBK_Case_Extension__c> caseExt = [SELECT Id, SPV_TieneCasosVinculados__c FROM CBK_Case_Extension__c WHERE RecordTypeId = :RECTYPERECLAMACIONEXTENSION AND Case_Id__c = :idCasoVinculado LIMIT 1];
                    if(!caseExt.isEmpty()){
                        caseExt[0].SPV_TieneCasosVinculados__c = false;

                        if(Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){
                            SPV_DatabaseDML.updateListDML(caseExt, true);   
                        }        
                    }       
                }
            }
        }  
        // if(listCasoVinculadoDelVinculado.isEmpty()){
        //     // Si no hay vínculos en el caso vinculado, se actualiza el estado del caso
        //     List<CBK_Case_Extension__c> caseExt = [SELECT Id, SPV_TieneCasosVinculados__c FROM CBK_Case_Extension__c WHERE RecordTypeId = :RECTYPERECLAMACIONEXTENSION AND Case_Id__c = :idCasoVinculado LIMIT 1];
        //     if(!caseExt.isEmpty()){
        //         caseExt[0].SPV_TieneCasosVinculados__c = false;

        //         if(Schema.sObjectType.CBK_Case_Extension__c.isUpdateable()){
        //             SPV_DatabaseDML.updateListDML(caseExt, true);
        //         }
        //     }
        // }
    }

    /*****************************************************************
     * @description Comprobar si un usuario tiene permisos para vincualr o desvincular reclamaciones SAC/SPV desde la reclamacion de SPV.
     * Devolvera un boolean que habilitará o no los botones de vinculación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US934229      Raúl Santos   04/06/2024        Creación
     * 1.1             US1208255     Raúl Santos   23/05/2025        Modificación: múltiple vinculación
     *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean comprobarPermisosVinculacion(String idCaso){

        List<Case> listaCasos = new List<Case>();

        //Recuperamos los campos necesarios de la reclamación y sus pretensiones hijas
        if(Schema.sObjectType.Case.isAccessible()){
            listaCasos = [SELECT Id, Status, OwnerId, RecordTypeId, SAC_Reclamacion__r.OwnerId, SAC_PretensionPrincipal__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACIONSPV 
                                        AND Id = :idCaso) OR (RecordTypeId = :RECTYPEPRETENSIONSPV AND SAC_Reclamacion__c = :idCaso)];
        }   

        if(!listaCasos.isEmpty()){
            Id usuarioActual = UserInfo.getUserId();
            Boolean permiso = false;

            for(Case caso : listaCasos){
                if(caso.OwnerId == usuarioActual && caso.Status == 'SAC_001'){
                    permiso = true;
                    break;
                }
            }
            
            return permiso;
    
        }else{
            return false;
        }
    }


     /*****************************************************************
     * @description Clase para devolver la reclamación vinculada de una reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                            Carlos Gómez    05/09/2024        Creación
     * 1.1             US1208255      Raúl Santos     23/05/2025        Modificación: múltiple vinculación
     *****************************************************************/
    @AuraEnabled
    public static List<ReclamacionWrapper> getReclamacionesVinculadas(String idCasoActual){
        List<ReclamacionWrapper> listadoFinal = new List<ReclamacionWrapper>();
        Map<Id, String> mapIdRecNombreReclamantePpal = new Map<Id, String>();
        Map<Id, List<Case>> mapReclamacionPretensiones = new Map<Id, List<Case>>();
        Map<id, Case> mapReclamaciones = new Map<Id,Case>();
        Map<Id, List<String>> mapIdRecNombreReclamanteSec = new Map<Id, List<String>>();
        Map<Id, List<String>> mapIdPretContratos = new Map<Id, List<String>>();


        List<CBK_CaseToCaseRelationship__c> listCasosRelacionados = [SELECT Id, SPV_CasoVinculado__c, SPV_CasoPadre__c FROM CBK_CaseToCaseRelationship__c WHERE RecordTypeId = :RECTYPECASORELACIONADOSPV AND SPV_CasoVinculado__c = :idCasoActual AND SPV_CasoVinculado__c != null]; //(SPV_CasoPadre__c = :idCasoActual OR SPV_CasoVinculado__c = :idCasoActual) 

        if(!listCasosRelacionados.isEmpty()){

            Set<Id> setIdsCasosRelacionados = new Set<Id>();
            Set<Id> idsReclamaciones = new Set<Id>();
            Set<Id> idsPretensiones = new Set<Id>();

            for(CBK_CaseToCaseRelationship__c casoRelacionado : listCasosRelacionados){ 
                if(String.isNotBlank(casoRelacionado.SPV_CasoPadre__c)){
                    setIdsCasosRelacionados.add(casoRelacionado.SPV_CasoPadre__c);
                }
            }

            // for (CBK_CaseToCaseRelationship__c casoRelacionado : listCasosRelacionados) {
            //     if (casoRelacionado.SPV_CasoPadre__c == idCasoActual && 
            //         String.isNotBlank(casoRelacionado.SPV_CasoVinculado__c)) {
            //         setIdsCasosRelacionados.add(casoRelacionado.SPV_CasoVinculado__c);
        
            //     } else if (casoRelacionado.SPV_CasoVinculado__c == idCasoActual && 
            //         String.isNotBlank(casoRelacionado.SPV_CasoPadre__c)) {
            //         setIdsCasosRelacionados.add(casoRelacionado.SPV_CasoPadre__c);
            //     }
            // }

            List<Case> listaCasos = [SELECT Id, RecordTypeId, RecordType.DeveloperName, Account.Name, SAC_Reclamacion__c, CreatedDate, CaseNumber, toLabel(Status), Subject, CC_CasoRelacionado__c, SEG_Grupo__r.Name, Owner.Name, toLabel(SAC_SentidoResolucion__c), SAC_ArgumentarioPretensiones__c, SPV_NumExpediente__c
                        FROM Case WHERE (RecordTypeId IN (:RECTYPERECLAMACIONSAC, :RECTYPERECLAMACIONSPV) AND Id IN :setIdsCasosRelacionados) OR (RecordTypeId IN (:RECTYPEPRETENSIONSAC, :RECTYPEPRETENSIONSPV) AND SAC_Reclamacion__c IN :setIdsCasosRelacionados)];

            if(!listaCasos.isEmpty()){
                for (Case caso : listaCasos) {

                    if (caso.RecordTypeId == RECTYPERECLAMACIONSAC || caso.RecordTypeId == RECTYPERECLAMACIONSPV) {
                        idsReclamaciones.add(caso.Id);
                        mapReclamaciones.put(caso.Id, caso);

                        if(!mapReclamacionPretensiones.containsKey(caso.Id)){
                            mapReclamacionPretensiones.put(caso.Id, new List<Case>());
                        }

                        if(caso.Account.Name != null && !mapIdRecNombreReclamantePpal.containsKey(caso.Id)){
                            String nombreReclamantePpal = caso.Account.Name; 
                            mapIdRecNombreReclamantePpal.put(caso.Id, nombreReclamantePpal);
                        }
                    }else if (caso.RecordTypeId == RECTYPEPRETENSIONSAC || caso.RecordTypeId == RECTYPEPRETENSIONSPV) {                       
                        List<Case> listPretensiones;
                        Id idReclamacion = caso.SAC_Reclamacion__c;

                        if(mapReclamacionPretensiones.containsKey(idReclamacion)){
                            listPretensiones = mapReclamacionPretensiones.get(idReclamacion);
                        } else {
                            listPretensiones = new List<Case>();
                        }
    
                        listPretensiones.add(caso);
                        mapReclamacionPretensiones.put(idReclamacion, listPretensiones);
                        idsPretensiones.add(caso.Id);
                    }
                }
            }

            //Recupero los reclamantes secundarios de las reclamaciones con las que estamos trabajando
            List<SAC_CaseReclamante__c> listReclamantesSecundarios = [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name FROM SAC_CaseReclamante__c WHERE SAC_Case__c IN :idsReclamaciones AND SAC_ReclamantePrincipal__c = false];

            if(!listReclamantesSecundarios.isEmpty()){
                //Recorremos los reclamantes secundarios, para clasificarlos en un mapa de cara a la presentación al usuario final
                for(SAC_CaseReclamante__c reclamante : listReclamantesSecundarios){
                    List<String> nombreReclamantes;

                    if(mapIdRecNombreReclamanteSec.containsKey(reclamante.SAC_Case__c)){
                        nombreReclamantes = mapIdRecNombreReclamanteSec.get(reclamante.SAC_Case__c);
                    } else {
                        nombreReclamantes = new List<String>();
                    }

                    String nombreReclamanteSec = reclamante.SAC_Account__r.Name;
                    nombreReclamantes.add(nombreReclamanteSec);
                    mapIdRecNombreReclamanteSec.put(reclamante.SAC_Case__c, nombreReclamantes);
                }
            }

            if(!mapReclamacionPretensiones.isEmpty()){
                //Recuperamos los Nº de contrato de los productos asociados a cada pretension
                List<SAC_ProductCase__c> listaProdContrato = [SELECT Id, SAC_Pretension__c, N_Contrato__c FROM SAC_ProductCase__c WHERE SAC_Pretension__c IN :idsPretensiones];
                if(!listaProdContrato.isEmpty()){
                    for(SAC_ProductCase__c contrato : listaProdContrato){
                        List<String> listNumerosContratos;

                        if(mapIdPretContratos.containsKey(contrato.SAC_Pretension__c)){
                            listNumerosContratos = mapIdPretContratos.get(contrato.SAC_Pretension__c);
                        } else {
                            listNumerosContratos = new List<String>();
                        }

                        String numeroContrato = contrato.N_Contrato__c;
                        listNumerosContratos.add(numeroContrato);
                        mapIdPretContratos.put(contrato.SAC_Pretension__c, listNumerosContratos);
                    }
                }

                //Pasamos el mapa de reclamaciones a un wrapper para retornar una lista con toda la información necesaria para cada reclamacion SAC relacionada
                for(String idReclamacion : mapReclamacionPretensiones.keySet()){
                    ReclamacionWrapper reclamacionAuxiliar = new ReclamacionWrapper(mapReclamaciones.get(idReclamacion), mapReclamacionPretensiones.get(idReclamacion), mapIdRecNombreReclamantePpal.get(idReclamacion), mapIdRecNombreReclamanteSec.get(idReclamacion), mapIdPretContratos, true);
                    listadoFinal.add(reclamacionAuxiliar);
                }
            }
        }

        return listadoFinal; 
    }

    /*****************************************************************
     * @description Clase Wrapper para devolver la información necesaria al LWC spv_AsociarReclamacion
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912970      Raúl Santos   04/06/2024        Creación
     * 1.1             US1208255     Raúl Santos   23/05/2025        Modificación: múltiple vinculación
     *****************************************************************/
    public class ReclamacionWrapper{    
        @AuraEnabled public Case reclamacionActual {get; set;}    
        @AuraEnabled public List<Case> listaPretensionesActual {get; set;}
        @AuraEnabled public String reclamantePrincipalActual {get; set;}
        @AuraEnabled public List<String> listaReclamantesSecundariosActual {get; set;}
        @AuraEnabled public Map<Id, List<String>> mapPretNumerosContratosActual {get; set;}
        @AuraEnabled public Boolean casoVinculadoActual {get; set;}
        
        public ReclamacionWrapper(Case reclamacion, List<Case> listaPretensiones, String reclamantePrincipal, List<String> listaReclamantesSecundarios, Map<Id, List<String>> mapPretNumerosContratos, Boolean casoVinculado)
        {
            reclamacionActual = reclamacion;
            listaPretensionesActual = listaPretensiones;     
            reclamantePrincipalActual = reclamantePrincipal;   
            listaReclamantesSecundariosActual = listaReclamantesSecundarios;
            mapPretNumerosContratosActual = mapPretNumerosContratos;
            casoVinculadoActual = casoVinculado;
        }
    }
}