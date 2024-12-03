public with sharing class SPV_QueueableEnvioGGH implements Queueable, Database.AllowsCallouts {

    List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();

    public SPV_QueueableEnvioGGH(List<SAC_Accion__c> listaAccionesC) {
        listaAcciones = listaAccionesC;
    }

    public void execute(QueueableContext context) {
        envioGGH(listaAcciones);
    }

    public static void envioGGH(List<SAC_Accion__c> listNewAccion){
        Map<Id,SAC_Accion__c> mapaTareas = new Map<Id,SAC_Accion__c>(listNewAccion);
        Map<Id, List<WrapperAdjuntoGGH>> mapaAccionDocumentos = new Map<Id, List<WrapperAdjuntoGGH>>();
        List<SAC_Accion__c> listaAccionesConError = new List<SAC_Accion__c>();
        Set<Id> setIdsAccionesGGH = new Set<Id>();

        User usuario = [SELECT Id, FederationIdentifier FROM User WHERE id =: UserInfo.getUserId() LIMIT 1 ];
        String usuarioAlta = usuario.FederationIdentifier;

        Map<Id,SAC_Accion__c> mapaAccionesGGH = new Map<Id,SAC_Accion__c>(
                                                [SELECT Id, RecordTypeId, SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c, SAC_Reclamacion__r.CC_SuppliedNIF__c 
                                                FROM SAC_Accion__c 
                                                WHERE Id IN :mapaTareas.keySet() 
                                                AND SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'SPV_GGH']);

        if(!mapaAccionesGGH.values().isEmpty()){
            //Pasar Ids a Set para posteriormente buscar sus contentDocumentLink
            for (SAC_Accion__c accionGGH : mapaAccionesGGH.values()) {
                setIdsAccionesGGH.add(accionGGH.Id);
            }
        }

        //Si el set no está vacío, pasamos a buscar los ficheros adjuntos de las tareas
        Boolean heapSizeSuperado = false;
        if (!setIdsAccionesGGH.isEmpty()) {
            //Primero hay que comprobar que no se excede el heap size limit recuperando el peso de cada fichero
            heapSizeSuperado = comprobarContentSize(setIdsAccionesGGH);
            //Si el heap size no se ha superado, recuperamos los documentos
            if (!heapSizeSuperado) {
                mapaAccionDocumentos = recuperarAdjuntosGGH(setIdsAccionesGGH);
            }
        }

        Id profileId=userinfo.getProfileId();
        String profileName = [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;

        for (SAC_Accion__c tareaGGH : mapaAccionesGGH.values()) {
            if (heapSizeSuperado) {
                tareaGGH.SAC_Error__c = 'Ha superado el límite de 12 Megabytes en archivos adjuntos. Inténtelo de nuevo o reduzca el peso total de ficheros adjuntos';
                tareaGGH.SAC_Estado__c = 'SAC_PendienteEnviar';
                listaAccionesConError.add(tareaGGH);
            } else {
                String impNotaria;
                String impGestoria;
                String impRegistro;
                String impTasacion;

                if(mapaTareas.containsKey(tareaGGH.Id)){
                    if(comprobarEstadosGGH(mapaTareas.get(tareaGGH.Id).SAC_EstadoNotaria__c)){
                        impNotaria = reemplazarPunto(mapaTareas.get(tareaGGH.Id).SAC_ImpResueltoNotaria__c);
                    }
                    if(comprobarEstadosGGH(mapaTareas.get(tareaGGH.Id).SAC_EstadoGestoria__c)){
                        impGestoria = reemplazarPunto(mapaTareas.get(tareaGGH.Id).SAC_ImpResueltoGestoria__c);
                    }
                    if(comprobarEstadosGGH(mapaTareas.get(tareaGGH.Id).SAC_EstadoRegistro__c)){
                        impRegistro = reemplazarPunto(mapaTareas.get(tareaGGH.Id).SAC_ImpResueltoRegistros__c);
                    }
                    if(comprobarEstadosGGH(mapaTareas.get(tareaGGH.Id).SAC_EstadoTasacion__c)){
                        impTasacion = reemplazarPunto(mapaTareas.get(tareaGGH.Id).SAC_ImpResueltoTasacion__c);
                    }
                }

                List<SAC_WS_GGH_Callout_RQ.Documentacion> documentacionWrapper = new List<SAC_WS_GGH_Callout_RQ.Documentacion>();
                List<WrapperAdjuntoGGH> contentAuxiliar = new List<WrapperAdjuntoGGH>();
            
                if(!mapaAccionDocumentos.isEmpty()){
                    contentAuxiliar = mapaAccionDocumentos.get(tareaGGH.id);
                }
                //Variable para controlar el total de bytes de todos los archivos de esta tarea
                for(WrapperAdjuntoGGH cv : contentAuxiliar){
                    String content = EncodingUtil.base64Encode(cv.versionData);

                    SAC_WS_GGH_Callout_RQ.Documentacion documentoWrapper = new SAC_WS_GGH_Callout_RQ.Documentacion(content, cv.title + '.' + cv.fileType);
                    documentacionWrapper.add(documentoWrapper);
                }

                //Quitar etiquetas html del campo comentarios en caso de que este relleno
                String comentarios = '';
                if (String.isNotBlank(mapaTareas.get(tareaGGH.Id).SAC_Comentarios__c)) {
                    comentarios = mapaTareas.get(tareaGGH.Id).SAC_Comentarios__c.stripHtmlTags();
                }
                SAC_WS_GGH_Callout_RQ.Reclamacion reclamacionWrapper = new SAC_WS_GGH_Callout_RQ.Reclamacion(
                    mapaTareas.get(tareaGGH.Id).SAC_Pretension__c,
                    tareaGGH.Id,
                    mapaAccionesGGH.get(tareaGGH.Id).SAC_Reclamacion__r.CC_SuppliedNIF__c,
                    impNotaria, impGestoria, impRegistro, impTasacion,
                    mapaTareas.get(tareaGGH.Id).SAC_NumeroContrato__c,
                    mapaTareas.get(tareaGGH.Id).SAC_NCuentaAbono__c,
                    comentarios);
                
                SAC_WS_GGH_Callout_RQ.GGHRequest gghResquesWrapper = new SAC_WS_GGH_Callout_RQ.GGHRequest(usuarioAlta, reclamacionWrapper, documentacionWrapper);
                SAC_WS_GGH_Callout_RP.GGHResponse respuesta = SAC_WS_GGH_Callout.sendRequest(gghResquesWrapper, profileName);
                
                if(respuesta.getResult() == null){
                    tareaGGH.SAC_Estado__c = 'SAC_PendienteEnviar';
                    listaAccionesConError.add(tareaGGH);
                }else if(!respuesta.getResult()) {
                    tareaGGH.SAC_Error__c = respuesta.gestError();
                    tareaGGH.SAC_Estado__c = 'SAC_PendienteEnviar';
                    listaAccionesConError.add(tareaGGH);
                }else if(respuesta.getResult()){
                    tareaGGH.SAC_Error__c = null;
                    tareaGGH.SAC_Estado__c = 'SAC_PendienteRevision';
                    listaAccionesConError.add(tareaGGH);
                }
            }
        }

        if(!listaAccionesConError.isEmpty()){
            Database.update(listaAccionesConError);
        }
    }

    public static Boolean comprobarContentSize(Set<Id> setIdsAccionesGGH) {
        Boolean heapSizeSuperado = false;
        Integer sizeTotal = 0;
        
        List<ContentDocumentLink> listaCDL = [SELECT ContentDocument.LatestPublishedVersion.ContentSize
                                              FROM ContentDocumentLink
                                              WHERE LinkedEntityId IN :setIdsAccionesGGH];

        if (!listaCDL.isEmpty()) {
            // Recorrer los documentos para comprobar si supera el heapSize limit
            for (ContentDocumentLink cdl : listaCDL) {
                sizeTotal = sizeTotal + cdl.ContentDocument.LatestPublishedVersion.ContentSize;
                if (sizeTotal > 8900000) {
                    heapSizeSuperado = true;
                    break;
                }
            }
        }

        return heapSizeSuperado;
    }

    public static Map<Id, List<WrapperAdjuntoGGH>> recuperarAdjuntosGGH(Set<Id> setIdsAccionesGGH) {
        Map<Id, List<WrapperAdjuntoGGH>> mapaAccionDocumentos = new Map<Id, List<WrapperAdjuntoGGH>>();

        List<ContentDocumentLink> listaCDL = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Title,
                                              ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.FirstPublishLocationId,
                                              ContentDocument.LatestPublishedVersion.fileType
                                              FROM ContentDocumentLink
                                              WHERE LinkedEntityId IN :setIdsAccionesGGH];

        if (!listaCDL.isEmpty()) {
            for (ContentDocumentLink cdl : listaCDL) {
                //Crear wrapper con los datos del adjunto
                WrapperAdjuntoGGH wrapAdjunto = new WrapperAdjuntoGGH();
                wrapAdjunto.id = cdl.ContentDocument.LatestPublishedVersionId;
                wrapAdjunto.title = cdl.ContentDocument.LatestPublishedVersion.Title;
                wrapAdjunto.versionData = cdl.ContentDocument.LatestPublishedVersion.VersionData;
                wrapAdjunto.fileType = cdl.ContentDocument.LatestPublishedVersion.fileType;
                if (mapaAccionDocumentos.containsKey(cdl.LinkedEntityId)) {
                    mapaAccionDocumentos.get(cdl.LinkedEntityId).add(wrapAdjunto);
                } else {
                    List<WrapperAdjuntoGGH> listaWrapAdjunto = new List<WrapperAdjuntoGGH>();
                    listaWrapAdjunto.add(wrapAdjunto);
                    mapaAccionDocumentos.put(cdl.LinkedEntityId, listaWrapAdjunto);
                }
            }
        }
        
        return mapaAccionDocumentos;
    }

    public static Boolean comprobarEstadosGGH(String estado) {

        Boolean enviar = false;
        if(estado == null || estado == 'SAC_008' || estado == 'SAC_005' || estado == 'SAC_006' || estado == 'SAC_007'){		
            enviar = true;
        }

        return enviar;
    }

    public static String reemplazarPunto(Decimal importeDecimal) {

        String importe = String.valueOf(importeDecimal);
        String importe2 = '';
        if(String.isNotBlank(importe)){
            String regExp = '.';
            String replacement = ',';
            importe2 = importe.replace(regExp, replacement);
        }
        return importe2;
    }

    /**
    Wrapper para retornar datos de los adjuntos de las tareas de GGH
    */
    public class WrapperAdjuntoGGH{
        public Id id{get; set;}
        public String title{get; set;}
        public Blob versionData{get; set;}
		public String fileType{get; set;}
    }
}