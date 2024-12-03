public with sharing class SPV_LCMP_ReclamacionesVinculadas {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACIONSAC = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSIONSAC = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSIONSPV = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
   
    /*****************************************************************
     * Proposito: Obtener las reclamaciones SAC relacioandas con la reclamación SPV actual
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US934229      Raúl Santos   04/06/2024        Creación
     *****************************************************************/
    @AuraEnabled
    public static List<ReclamacionWrapper> getReclamacionesMismoReclamante(String idCasoActual){

        List<ReclamacionWrapper> listadoFinal = new List<ReclamacionWrapper>();
        List<SAC_CaseReclamante__c> listReclamantesCasoActual = new List<SAC_CaseReclamante__c>();
        Set<Id> idsReclamantesActual = new Set<Id>();
        Set<Id> idsReclamaciones = new Set<Id>();
        Map<Id, String> mapIdRecNombreReclamantePpal = new Map<Id, String>();
        Map<Id, List<Case>> mapReclamacionPretensiones = new Map<Id, List<Case>>();
        Map<id, Case> mapReclamaciones = new Map<Id,Case>();
        Map<Id, List<String>> mapIdRecNombreReclamanteSec = new Map<Id, List<String>>();


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


        //Recupero los reclamantes (principales y secundarios) de reclamaciones SAC, que coincidan con los de la reclamacion actual
        if(!idsReclamantesActual.isEmpty()){
            List<SAC_CaseReclamante__c> listReclamantes = [SELECT Id, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name, SAC_Case__r.CaseNumber
                                    FROM SAC_CaseReclamante__c
                                    WHERE SAC_Case__r.RecordTypeId = :RECTYPERECLAMACIONSAC AND SAC_Account__c IN :idsReclamantesActual AND SAC_Case__c != null];

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
            List<Case> listaCasos = [SELECT Id, RecordTypeId, Account.Name, SAC_Reclamacion__c, CreatedDate, CaseNumber, toLabel(Status), Subject, CC_CasoRelacionado__c, SEG_Grupo__r.Name, Owner.Name, toLabel(SAC_SentidoResolucion__c), 	SAC_ArgumentarioPretensiones__c
                                    FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACIONSAC AND Id IN :idsReclamaciones) OR (RecordTypeId = :RECTYPEPRETENSIONSAC AND SAC_Reclamacion__c IN :idsReclamaciones)];

            if(!listaCasos.isEmpty()){
                //Recorro los casos recuperados, y los almaceno en un mapa apra diferenciar als reclamaciones (con la informacion de estas), y otro mapa para tener las pretensiones relacioandas con su reclamacion padre.
                //Tambien, en caso de que el AccountId de una reclamacion (equivale a su reclamante principal) no este en el mapa de reclamantes principales, le añado al mapa de reclamantes anteriormente creado.
                for (Case caso : listaCasos) {

                    if (caso.RecordTypeId == RECTYPERECLAMACIONSAC) {
                        mapReclamaciones.put(caso.Id, caso);

                        if(!mapReclamacionPretensiones.containsKey(caso.Id)){
                            mapReclamacionPretensiones.put(caso.Id, new List<Case>());
                        }

                        if(caso.Account.Name != null && !mapIdRecNombreReclamantePpal.containsKey(caso.Id)){
                            String nombreReclamantePpal = caso.Account.Name; 
                            mapIdRecNombreReclamantePpal.put(caso.Id, nombreReclamantePpal);
                        }
                    }else if (caso.RecordTypeId == RECTYPEPRETENSIONSAC) {                       
                        List<Case> listPretensiones;
                        Id idReclamacion = caso.SAC_Reclamacion__c;

                        if(mapReclamacionPretensiones.containsKey(idReclamacion)){
                            listPretensiones = mapReclamacionPretensiones.get(idReclamacion);
                        } else {
                            listPretensiones = new List<Case>();
                        }
    
                        listPretensiones.add(caso);
                        mapReclamacionPretensiones.put(idReclamacion, listPretensiones);
                    }
                }
            }

            //Recupero los reclamantes secundatos de las reclamaciones con las que estamos trabajando
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
            //Pasamos el mapa de reclamaciones a un wrapper para retornar una lista con toda la información necesaria para cada reclamacion SAC relacionada
            for(String idReclamacion : mapReclamacionPretensiones.keySet()){
                ReclamacionWrapper reclamacionAuxiliar = new ReclamacionWrapper(mapReclamaciones.get(idReclamacion), mapReclamacionPretensiones.get(idReclamacion), mapIdRecNombreReclamantePpal.get(idReclamacion), mapIdRecNombreReclamanteSec.get(idReclamacion));
                listadoFinal.add(reclamacionAuxiliar);
            }
        }

        return listadoFinal; 
    }

    /*****************************************************************
     * Proposito: Vincular una reclamación SAC a la reclamción de SPV
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US934229      Raúl Santos   04/06/2024        Creación
     *****************************************************************/
    @AuraEnabled
    public static void vincularReclamacion(String idCasoVinculado, String idCasoActual){

        Case casoActual = new Case();
        casoActual.Id = idCasoActual;
        casoActual.CC_CasoRelacionado__c = idCasoVinculado;

        if(Schema.sObjectType.Case.isUpdateable()){
            SPV_DatabaseDML.updateDML(casoActual, true);   
        }            
    }

    /*****************************************************************
     * Proposito: Desvincular una reclamación SAC de la reclamción de SPV
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US934229      Raúl Santos   04/06/2024        Creación
     *****************************************************************/
    @AuraEnabled
    public static void desvincularReclamacion(String idCasoActual){

        Case casoActual = new Case();
        casoActual.Id = idCasoActual;
        casoActual.CC_CasoRelacionado__c = null;

        if(Schema.sObjectType.Case.isUpdateable()){
            SPV_DatabaseDML.updateDML(casoActual, true);
        }           
    }

    /*****************************************************************
     * Proposito:Comprobar si un usuario tiene permisos para vincualr o desvincular reclamaciones SAC desde la reclamacion de SPV.
     * Devolvera un boolean que habilitará o no los botones de vinculación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US934229      Raúl Santos   04/06/2024        Creación
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
     * Proposito: Clase para devolver la reclamación vinculada de una reclamación
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0                            Carlos Gómez    05/09/2024        Creación
     *****************************************************************/
    @AuraEnabled
    public static List<ReclamacionWrapper> getReclamacionVinculada(String idCasoRelacionado){
        List<ReclamacionWrapper> listadoFinal = new List<ReclamacionWrapper>();
        Map<Id, String> mapIdRecNombreReclamantePpal = new Map<Id, String>();
        Map<Id, List<Case>> mapReclamacionPretensiones = new Map<Id, List<Case>>();
        Map<id, Case> mapReclamaciones = new Map<Id,Case>();
        Map<Id, List<String>> mapIdRecNombreReclamanteSec = new Map<Id, List<String>>();

        List<Case> listaCasos = [SELECT Id, RecordTypeId, Account.Name, SAC_Reclamacion__c, CreatedDate, CaseNumber, toLabel(Status), Subject, CC_CasoRelacionado__c, SEG_Grupo__r.Name, Owner.Name, toLabel(SAC_SentidoResolucion__c), SAC_ArgumentarioPretensiones__c
                        FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACIONSAC AND Id = :idCasoRelacionado) OR (RecordTypeId = :RECTYPEPRETENSIONSAC AND SAC_Reclamacion__c=:idCasoRelacionado)];


         if(!listaCasos.isEmpty()){

                for (Case caso : listaCasos) {

                    if (caso.RecordTypeId == RECTYPERECLAMACIONSAC) {
                        mapReclamaciones.put(caso.Id, caso);

                        if(!mapReclamacionPretensiones.containsKey(caso.Id)){
                            mapReclamacionPretensiones.put(caso.Id, new List<Case>());
                        }

                        if(caso.Account.Name != null && !mapIdRecNombreReclamantePpal.containsKey(caso.Id)){
                            String nombreReclamantePpal = caso.Account.Name; 
                            mapIdRecNombreReclamantePpal.put(caso.Id, nombreReclamantePpal);
                        }
                    }else if (caso.RecordTypeId == RECTYPEPRETENSIONSAC) {                       
                        List<Case> listPretensiones;
                        Id idReclamacion = caso.SAC_Reclamacion__c;

                        if(mapReclamacionPretensiones.containsKey(idReclamacion)){
                            listPretensiones = mapReclamacionPretensiones.get(idReclamacion);
                        } else {
                            listPretensiones = new List<Case>();
                        }
    
                        listPretensiones.add(caso);
                        mapReclamacionPretensiones.put(idReclamacion, listPretensiones);
                    }
                }
            }

                //Recupero los reclamantes secundatos de las reclamaciones con las que estamos trabajando
                List<SAC_CaseReclamante__c> listReclamantesSecundarios = [SELECT Id, Name, SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c, SAC_Account__r.Name
                FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: idCasoRelacionado AND SAC_ReclamantePrincipal__c = false];

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
                //Pasamos el mapa de reclamaciones a un wrapper para retornar una lista con toda la información necesaria para cada reclamacion SAC relacionada
                for(String idReclamacion : mapReclamacionPretensiones.keySet()){
                    ReclamacionWrapper reclamacionAuxiliar = new ReclamacionWrapper(mapReclamaciones.get(idReclamacion), mapReclamacionPretensiones.get(idReclamacion), mapIdRecNombreReclamantePpal.get(idReclamacion), mapIdRecNombreReclamanteSec.get(idReclamacion));
                    listadoFinal.add(reclamacionAuxiliar);
                }
            }
    
            return listadoFinal; 
            

    }

    /*****************************************************************
     * Proposito: Clase Wrapper para devolver la información necesaria al LWC spv_AsociarReclamacion
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US912970      Raúl Santos   04/06/2024        Creación
     *****************************************************************/
    public class ReclamacionWrapper{    
        @AuraEnabled public Case reclamacionActual {get; set;}    
        @AuraEnabled public List<Case> listaPretensionesActual {get; set;}
        @AuraEnabled public String reclamantePrincipalActual {get; set;}
        @AuraEnabled public List<String> listaReclamantesSecundariosActual {get; set;}
        
        public ReclamacionWrapper(Case reclamacion, List<Case> listaPretensiones, String reclamantePrincipal, List<String> listaReclamantesSecundarios)
        {
            reclamacionActual = reclamacion;
            listaPretensionesActual = listaPretensiones;     
            reclamantePrincipalActual = reclamantePrincipal;   
            listaReclamantesSecundariosActual = listaReclamantesSecundarios;
        }
    }
}