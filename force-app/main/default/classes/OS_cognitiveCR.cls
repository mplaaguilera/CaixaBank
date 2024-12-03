/**
*   @description OS_cognitiveCR
*/
public with sharing class OS_cognitiveCR {
    
    @future(callout=true)
    public static void getCRCognitive(id casoId)
    {
        CC_InterfaceSettings__mdt oConfig = getConfig ('OS_COGNITIVE');

        String sDescError = '';
        String sDetalleError = '';
        CC_TrazaInt__c oTraza;
        if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
            List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
            
            oTraza = new CC_TrazaInt__c();
                            oTraza.Name = 'Cognitive_COPS';
                            oTraza.CC_FechaInicio__c = datetime.now();
        }
        
        Case casoCops = new Case();
        casoCops = [SELECT id, Subject, Description, CaseNumber FROM Case WHERE id = :casoid];
        OS_sendToCognitive sendCase = new OS_sendToCognitive();
        sendCase.subject = casoCops.Subject;
        sendCase.body = casoCops.Description.replaceAll('\r\n|\n|\r',' ');  
        sendCase.date_time = Datetime.now().format('yyyy-MM-dd HH:mm:ss', 'Europe/Madrid'); //"2017-12-23 16:30:21" yyyy-MM-dd 
        sendCase.sr=casoCops.CaseNumber;
        System.debug(sendCase);

        String jsonToCognitive = JSON.serialize(sendCase);
        jsonToCognitive=jsonToCognitive.replace('date_time', 'date-time');
        //TODO: reemplazar las variables afectadas por "-"
        //espacio para lanzar llamada HHTP
        
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(oConfig.CC_EndPoint__c );
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setClientCertificateName(oConfig.CC_Certificado__c);
            request.setBody(jsonToCognitive);
            
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                string TextoEntrada = String.valueOf(jsonToCognitive);
                if(TextoEntrada.length() > 131072 ){
                    TextoEntrada = TextoEntrada.substring(0, 131072);
                }

                oTraza.CC_MensajeEntrada__c = TextoEntrada;
            }
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                OS_receiveFromCognitive results = new OS_receiveFromCognitive();
                
                if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){

                    string TextoSalida = response.getBody();
                    if(TextoSalida.length() > 131072 ){
                        TextoSalida = TextoSalida.substring(0, 131072);
                    }

                    oTraza.CC_MensajeSalida__c = TextoSalida; 

                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = true;
                    insert(oTraza);
                }
                
                results = OS_receiveFromCognitive.parse(response.getBody());

                if(results!=null)
                {
                    if(String.isNotBlank(results.category))
                    {
							                        
                        System.debug('Resultado:'+results.category);
                        //sDescError = 'Error comunicaciones.';
                        List<SEG_ClasificacionRapida__c> crCognitive = new List<SEG_ClasificacionRapida__c>([select Id, Name, SEG_Nombre_CR_Cognitive__c, OS_EstadoCaso__c, SEG_Tematica__c,SEG_Producto__c,SEG_Motivo__c, OS_Solucion__c, OS_Causa__c, SEG_Prioridad__c, OS_GrupoTrabajo__r.OS_GrupoTrabajo__c from SEG_ClasificacionRapida__c where SEG_Nombre_CR_Cognitive__c =:results.category]);
                        system.debug('crCognitive' + crCognitive.size());
                        if(crCognitive.size()>0)
                        {
                            List<Group> colaGrupoTrabajo = new List<Group>();

                            //Añadir owner cuyo name de la queue = name grupo trabajo clasificación rápida
                            if(crCognitive[0].OS_GrupoTrabajo__r.OS_GrupoTrabajo__c != null ){
                                colaGrupoTrabajo = [SELECT id FROM Group WHERE Name = :crCognitive[0].OS_GrupoTrabajo__r.OS_GrupoTrabajo__c AND Type = 'Queue'];
                            }
                            //Feedback cognitive

                            /* PBM 19/03/2024   Se ha pedido realizar esto sólo cuando se cierre el caso por lo que se ha trasladado a la clase OS_Case_AU_TRHan

                            OS_feedbackCognitive fbCognitive = new OS_feedbackCognitive(casoCops.CaseNumber, crCognitive[0].SEG_Nombre_CR_Cognitive__c);
                            System.enqueueJob(fbCognitive); 

                            */
                            //insertar MCC para evitar colapso de trigger:                               
                            if(!colaGrupoTrabajo.isEmpty()){ 
                                casoCops.OwnerId = colaGrupoTrabajo[0].Id;
                            }
                            casoCops.OS_GrupoTrabajo__c = crCognitive[0].OS_GrupoTrabajo__r.OS_GrupoTrabajo__c;
                            casoCops.Status = crCognitive[0].OS_EstadoCaso__c;
                            casoCops.Priority = crCognitive[0].SEG_Prioridad__c;
                            casoCops.CC_MCC_Tematica__c = crCognitive[0].SEG_Tematica__c;
                            casoCops.CC_MCC_ProdServ__c = crCognitive[0].SEG_Producto__c;
                            casoCops.CC_MCC_Motivo__c = crCognitive[0].SEG_Motivo__c;			
                            casoCops.CC_MCC_Solucion__c = crCognitive[0].OS_Solucion__c;	 	 	
                            casoCops.CC_MCC_Causa__c = crCognitive[0].OS_Causa__c;	
                            casoCops.OS_ViaClasificacion__c = 'Cognitivo';
                            casoCops.OS_Clasificacion_Cognitivo__c = crCognitive[0].SEG_Tematica__c;     
                            casoCops.SEG_ClasificacionRapida__c = crCognitive[0].Id;                         
                            update casoCops; 
                            
                        }                                             
                    }
                }
                
            }
            else {
                if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                    sDescError = 'Error comunicaciones.';
                    sDetalleError = response.getStatusCode() + ':' + response.getBody();
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = sDescError;
                    oTraza.CC_DetalleError__c = sDetalleError;
                    insert(oTraza);
                }
            }
        } catch (Exception e) {
            
            if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
                sDescError = 'Exception: Error comunicaciones.';
                sDetalleError = e.getMessage();
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
                insert(oTraza);
            }
			
        }
        
        

    }
	/*
    private static List<ContentVersion> getFilesCase(Id casoId)
    {
        List<ContentVersion> listFiles = new List<ContentVersion>();
        listFiles = [select id, versiondata,Title,FileExtension,ContentSize,FirstPublishLocationId from ContentVersion where FirstPublishLocationId=:casoId];
        return listFiles;
    }
	*/
    static public CC_InterfaceSettings__mdt getConfig (String sInterfaz){
        if (sInterfaz == null){
            return null;
        }

        if (sInterfaz == ''){
            return null;
        }

        CC_InterfaceSettings__mdt oInterfaz;

        List<CC_InterfaceSettings__mdt> oConfig = [SELECT Id, CC_EndPoint__c, CC_Certificado__c, CC_TrazaActiva__c, 
                                                   CC_TrazaEntrada__c, CC_Activa__c
                                                   FROM CC_InterfaceSettings__mdt 
                                                   WHERE DeveloperName =: sInterfaz];
        if (oConfig.size()==1){
            if (oConfig[0] != null)
                oInterfaz = oConfig[0];
        }

        return oInterfaz;
    }
}