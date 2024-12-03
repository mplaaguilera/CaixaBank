/***********************************************************************
 * Name: SAC_LCMP_ResponderConsulta
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para operaciones de LWC sAC_ResponderConsulta
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US361683       Marcela Neira  28/04/2022      Creación
 * 1.1            US632598        Raúl Santos   11/08/2023      Modificación: dar formato a las respuestas a consultas oficina
*************************************************************************/
public without sharing class SAC_LCMP_ResponderConsulta {
    @AuraEnabled
    public static String responderConsulta(String consultaId, String respuesta, String motivo) {

        SAC_Interaccion__c consulta = [SELECT Id, Name, SAC_Reclamacion__c, SAC_GrupoColaborador__c, SAC_GrupoColaborador__r.SAC_DeveloperName__c FROM SAC_Interaccion__c WHERE Id = :consultaId ];

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
        Database.update(consulta);
        
        return respuesta;
    }


    /*****************************************************************
    * Proposito: Guardar una respuesta de una consulta interna
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US606705     Sergio Martín   25/05/2023      Creación
    *****************************************************************/
    @AuraEnabled
    public static String guardarConsulta(String consultaId, String respuesta, String motivo) {

        SAC_Interaccion__c consulta = [SELECT Id, Name, SAC_Reclamacion__c,SAC_GrupoColaborador__r.SAC_DeveloperName__c FROM SAC_Interaccion__c WHERE Id = :consultaId ];

        if(consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c == 'OFICINA'){
            Datetime fechaActual = Datetime.now();
            String fechaFormateada = fechaActual.format('dd') + '/' + fechaActual.format('MM') + '/' + fechaActual.format('yyyy') + ' ' + fechaActual.format('kk:mm');

            consulta.SAC_Respuesta__c = '<b>Respuesta Oficina (borrador) </b><span>' + fechaFormateada + '</span><br/><br/>' + respuesta + '<br/>';
            consulta.SAC_Motivo_Devolucion__c = motivo;
        }else{
            consulta.SAC_Respuesta__c = respuesta;
            consulta.SAC_Motivo_Devolucion__c = motivo;
        }

        Database.update(consulta);
  
        return respuesta;
    }


    /*****************************************************************
    * Proposito: Obtener la respuesta de un caso
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US606705     Sergio Martín   25/05/2023      Creación
    *****************************************************************/
    @AuraEnabled
    public static String getRespuestaConsulta(String consultaId) {
        SAC_Interaccion__c consulta = [SELECT Id, SAC_Respuesta__c, SAC_GrupoColaborador__r.SAC_DeveloperName__c FROM SAC_Interaccion__c WHERE Id = :consultaId ];
        String outputString;

        if(consulta.SAC_GrupoColaborador__r.SAC_DeveloperName__c == 'OFICINA' && consulta.SAC_Respuesta__c != null){
            outputString = consulta.SAC_Respuesta__c.replace('<b>', '').replace('</b>', '').replace('<br>', '').replace('<br>', '');
            outputString = outputString.replace('Respuesta Oficina (borrador)', '');
            outputString = outputString.replaceFirst('<span>.*?</span>', '');
        }else{
            outputString = consulta.SAC_Respuesta__c;
        }

        return outputString;
    }


    /*****************************************************************
    * Proposito: Copiar el los archivos adjuntados en la Consulta dentro del caso padre
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0             US606705     Sergio Martín   29/05/2023      Creación
    *****************************************************************/
    @AuraEnabled
    public static void insertarAdjuntoCaso(Id caseId, Integer numFicheros){
        SAC_Interaccion__c consulta = [SELECT id, SAC_Reclamacion__c, CreatedDate FROM SAC_Interaccion__C WHERE id=: caseId ORDER BY CreatedDate DESC LIMIT 1];
        List<ContentVersion> archivo = [SELECT id, CreatedDate, FirstPublishLocationId, Title, PathOnClient ,VersionData FROM ContentVersion WHERE FirstPublishLocationId =: caseId ORDER BY CreatedDate DESC LIMIT :numFicheros];
        
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
            Database.insert(archivoInsertar);
        }
    }
}