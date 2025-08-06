public with sharing class SPV_LCMP_ResponderConsulta {

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    private static final Id RECTYPECONSULTA_TAREA = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_ConsultaTarea').getRecordTypeId();
    
    /*********************************************************************************************
     * Proposito: Responder la consutkla y actualizar su estado
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US975885     Raúl Santos    17/07/2024         Creación    
    *********************************************************************************************/
    @AuraEnabled
    public static void responderConsulta(String consultaId, String respuesta, String motivo) {

        if(Schema.sObjectType.SAC_Interaccion__c.isAccessible()){
            SAC_Interaccion__c consulta = [SELECT Id, Name, SAC_Reclamacion__c, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.SAC_DeveloperName__c FROM SAC_Interaccion__c WHERE RecordTypeId IN (:RECTYPECONSULTA, :RECTYPECONSULTA_TAREA) AND Id = :consultaId ];

            if(consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c == 'OFICINA'){
                Datetime fechaActual = Datetime.now();
                String fechaFormateada = fechaActual.format('dd') + '/' + fechaActual.format('MM') + '/' + fechaActual.format('yyyy') + ' ' + fechaActual.format('kk:mm');
        
                consulta.SAC_Respuesta__c = '<b>Respuesta Oficina </b>' + fechaFormateada + '<br/><br/>' + respuesta + '<br/>';
                consulta.SAC_Motivo_Devolucion__c = motivo;
            }else{
                consulta.SAC_Respuesta__c = respuesta;
                consulta.SAC_Motivo_Devolucion__c = motivo;  
            }
        
            consulta.SAC_Estado__c = 'SAC_Resuelta';
            consulta.SAC_FechaRespuesta__c = System.now();

            SPV_DatabaseDML.updateDML(consulta,true);
        }
    }

    /*********************************************************************************************
     * Proposito: Guardar la respuesta de la consulta
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US975885     Raúl Santos    17/07/2024         Creación    
    *********************************************************************************************/
    @AuraEnabled
    public static void guardarConsulta(String consultaId, String respuesta, String motivo) {

        if(Schema.sObjectType.SAC_Interaccion__c.isAccessible()){
            SAC_Interaccion__c consulta = [SELECT Id, Name, SAC_Reclamacion__c,SAC_GrupoColaborador__r.SAC_DeveloperName__c FROM SAC_Interaccion__c WHERE RecordTypeId IN (:RECTYPECONSULTA, :RECTYPECONSULTA_TAREA) AND Id = :consultaId ];

            if(consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c == 'OFICINA'){
                Datetime fechaActual = Datetime.now();
                String fechaFormateada = fechaActual.format('dd') + '/' + fechaActual.format('MM') + '/' + fechaActual.format('yyyy') + ' ' + fechaActual.format('kk:mm');

                consulta.SAC_Respuesta__c = '<b>Respuesta Oficina (borrador) </b><span>' + fechaFormateada + '</span><br/><br/>' + respuesta + '<br/>';
                consulta.SAC_Motivo_Devolucion__c = motivo;
            }else{
                consulta.SAC_Respuesta__c = respuesta;
                consulta.SAC_Motivo_Devolucion__c = motivo;
            }

            SPV_DatabaseDML.updateDML(consulta,true);
        }  
    }

    /*********************************************************************************************
     * Proposito: Obtener la respuesta guardada de la consulta
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE          Description
     * 1.0             US975885     Raúl Santos    17/07/2024         Creación    
    *********************************************************************************************/
    @AuraEnabled
    public static String getRespuestaConsulta(String consultaId) {

        String outputString = '';

        if(Schema.sObjectType.SAC_Interaccion__c.isAccessible()){
            SAC_Interaccion__c consulta = [SELECT Id, SAC_Respuesta__c, SAC_GrupoColaborador__r.SAC_DeveloperName__c FROM SAC_Interaccion__c WHERE RecordTypeId IN (:RECTYPECONSULTA, :RECTYPECONSULTA_TAREA) AND Id = :consultaId ];

            if(consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c == 'OFICINA' && consulta.SAC_Respuesta__c != null){
                outputString = consulta.SAC_Respuesta__c.replace('<b>', '').replace('</b>', '').replace('<br>', '').replace('<br>', '');
                outputString = outputString.replace('Respuesta Oficina (borrador)', '');
                outputString = outputString.replaceFirst('<span>.*?</span>', '');
            }else{
                outputString = consulta.SAC_Respuesta__c;
            }
        }

        return outputString;
    }


    @AuraEnabled
    public static void insertarAdjuntoCaso(Id consultaId, Integer numFicheros){

        if(Schema.sObjectType.SAC_Interaccion__c.isAccessible()){

            SAC_Interaccion__c consulta = [SELECT id, SAC_Reclamacion__c, CreatedDate FROM SAC_Interaccion__C WHERE RecordTypeId IN (:RECTYPECONSULTA, :RECTYPECONSULTA_TAREA) AND Id=: consultaId LIMIT 1];
            
            List<ContentVersion> archivo = [SELECT id, CreatedDate, FirstPublishLocationId, Title, PathOnClient ,VersionData FROM ContentVersion WHERE FirstPublishLocationId =: consultaId ORDER BY CreatedDate DESC LIMIT :numFicheros];
            
            if(!archivo.isEmpty()) {
                List<ContentVersion> archivoInsertar = new List<ContentVersion>();

                for (Integer i = 0; i < numFicheros; i++) {
                    ContentVersion newcont = new ContentVersion();
                    newcont.Title = archivo[i].Title;
                    newcont.PathOnClient = archivo[i].PathOnClient;
                    newcont.VersionData = archivo[i].VersionData;
                    newcont.FirstPublishLocationId = consulta.SAC_Reclamacion__c;
                    archivoInsertar.add(newcont);
                }
                SPV_DatabaseDML.insertListDML(archivoInsertar,true);
            }
        }
    }
}