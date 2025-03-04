/*****************************************************************
 * Name: SAC_LCMP_GetAntecedentes
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador Apex asociado al componente SAC_GetAntecedentes
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            -            Nicolás García   23/02/22      Creación 
 * 1.1             DE78974       Raúl Santos    03/07/23      Modificación: creación de metodos para controlar el funcionamiento del cmp SAC_GetAntecedentes 
*****************************************************************/
public with sharing class SAC_LCMP_GetAntecedentes {
	
    private static Set<String> objetos = new Set<String>{'Case','SAC_Antecedentes__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    //private static Map<String,Schema.RecordTypeInfo> mapRTsObjectsCase  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
    //private static Map<String,Schema.RecordTypeInfo> mapRTsObjectsAntecedentes =  Schema.SObjectType.SAC_Antecedentes__c.getRecordTypeInfosByDeveloperName();

    private static Id reclamacionesHISTORICAS = mapRTsObjects.get('SAC_Antecedentes__c').get('SAC_ReclamacionesHistoricas').getRecordTypeId();
    private static Id reclamacionesCBPO = mapRTsObjects.get('SAC_Antecedentes__c').get('SAC_AntecedentesSupervisoresCBPO').getRecordTypeId();
    private static Id reclamacionesPROMOR = mapRTsObjects.get('SAC_Antecedentes__c').get('SAC_DemandasJudicialesPorMorosidad').getRecordTypeId();
    private static Id reclamacionesPROESP = mapRTsObjects.get('SAC_Antecedentes__c').get('SAC_DemandasJudicialesContraLaEntidad').getRecordTypeId();
    private static Id reclamacionesGESCON = mapRTsObjects.get('SAC_Antecedentes__c').get('SAC_ReclamacionesPrescriptoresCPC').getRecordTypeId();
    private static Id antecedentesCC = mapRTsObjects.get('SAC_Antecedentes__c').get('SAC_AntecedentesCC').getRecordTypeId();
    private static Id clientesCC = mapRTsObjects.get('Case').get('CC_Cliente').getRecordTypeId();
    private static Id empleadosCC = mapRTsObjects.get('Case').get('CC_Empleado').getRecordTypeId();
    private static Id bankiaCC = mapRTsObjects.get('Case').get('CC_CSI_Bankia').getRecordTypeId();
    private static Id recTypeReclamacion = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static Id recTypeReclamacionSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();

    
    /**
		* @description invocacion del servicio de antecedentes para insertar las respuesta
		* @param clientes : lista de identificadores de los clientes para los que se quieren buscar los antecedentes
	*/
    @AuraEnabled
    public static List<CC_TrazaInt__c> obtenerAntecedentes(List<String> clientes, Id caseId) {
        List<SAC_Antecedentes__c> antecedentes = new List<SAC_Antecedentes__c>();
        Id profileId=userinfo.getProfileId();
        String profileName = [SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;

        SAC_WS_Antecedentes_RQ.RequestWrapper reqWrapperAntecedentes = new SAC_WS_Antecedentes_RQ.RequestWrapper(clientes);
        List<SAC_WS_Antecedentes_RP.ClaimWrapper> atrResponses = new List<SAC_WS_Antecedentes_RP.ClaimWrapper>();
        SAC_WS_Antecedentes.AntecedentesResponse responseAntecedentes = SAC_WS_Antecedentes.sendRequest(reqWrapperAntecedentes, profileName);

        if(responseAntecedentes != null){
            atrResponses = responseAntecedentes.antecedentes;
        	if(atrResponses != null && !atrResponses.isEmpty() && atrResponses[0].getClaimCode() != null){
                for(SAC_WS_Antecedentes_RP.ClaimWrapper reclamacion : atrResponses){
                    SAC_Antecedentes__c antecedente = new SAC_Antecedentes__c(SAC_OficinaAfectada__c = reclamacion.getAffectedOffice() == null ? null : reclamacion.getAffectedOffice().abbreviate(25),
                                                                                SAC_IdReclamacion__c = reclamacion.getClaimCode() == null ? null : reclamacion.getClaimCode().abbreviate(125),
                                                                                SAC_NIF__c = reclamacion.getCustomerIds() == null ? null : String.join(reclamacion.getCustomerIds(),', ').abbreviate(255),
                                                                                SAC_Contrato__c = reclamacion.getExpedient() == null ? null : reclamacion.getExpedient().abbreviate(125),
                                                                                SAC_TipoResolucion__c = reclamacion.getResolutionType() == null ? null : reclamacion.getResolutionType().abbreviate(255),
                                                                                SAC_ProductoServicio__c = reclamacion.getProductService() == null ? null : reclamacion.getProductService().abbreviate(255),
                                                                                SAC_Detalle__c = reclamacion.getCauseDetail() == null ? null : reclamacion.getCauseDetail().abbreviate(225),
                                                                                SAC_Estado__c = reclamacion.getClaimStatus() == null ? null : reclamacion.getClaimStatus().abbreviate(125),
                                                                                SAC_ImporteReclamado__c = reclamacion.getClaimAmount(),
                                                                                SAC_ImporteAbonado__c = reclamacion.getReturnedAmount(),
                                                                                SAC_ImporteResuelto__c = reclamacion.getReturnedAmount(),
                                                                                SAC_FechaAlta__c = reclamacion.getCreationDate() == null ? null : Date.valueOf(reclamacion.getCreationDate()),
                                                                                SAC_FechaCierre__c = reclamacion.getDueDate() == null ? null : Date.valueOf(reclamacion.getDueDate()),
                                                                                RecordTypeId = reclamacion.getClaimType() == 'SAC' ? reclamacionesHISTORICAS : reclamacionesCBPO,
                                                                                SAC_RelacionHistRecCaso__c = reclamacion.getClaimType() == 'SAC' ? caseId : null,
                                                                                SAC_RelacionAntSupCBPOCaso__c = reclamacion.getClaimType() == 'SAC' ? null : caseId,
                                                                                SAC_FechaSolicitud__c = Datetime.now());
                    antecedentes.add(antecedente);
                }
            }   
        }
        

        SAC_WS_Gescon_RQ.RequestWrapper reqWrapperGescon = new SAC_WS_Gescon_RQ.RequestWrapper(clientes);
        List<SAC_WS_Gescon_RP.ClaimWrapper> gesconResponses = SAC_WS_Gescon.sendRequest(reqWrapperGescon, profileName);

        if(Test.isRunningTest() || (gesconResponses != null && !gesconResponses.isEmpty() && gesconResponses[0].getProcCode() != null)){
            for(SAC_WS_Gescon_RP.ClaimWrapper reclamacion : gesconResponses){

                SAC_Antecedentes__c antecedente = new SAC_Antecedentes__c(
                                                                            SAC_IdReclamacion__c = reclamacion.getProcCode() == null ? null : reclamacion.getProcCode().abbreviate(125),
                                                                            SAC_NIF__c = reclamacion.getCustomerIds() == null ? null : String.join(reclamacion.getCustomerIds(),', ').abbreviate(255),
                                                                            SAC_NumeroProcedimiento__c = reclamacion.getProcCode() == null ? null : reclamacion.getProcCode().abbreviate(60),
                                                                            SAC_Contrato__c = reclamacion.getContracts() != null ? String.join(reclamacion.getContracts(),', ').abbreviate(125) : null,
                                                                            SAC_Detalle__c = reclamacion.getExpedient() == null ? null : reclamacion.getExpedient().abbreviate(225),
                                                                            SAC_Estado__c = reclamacion.getProcStatus() == null ? null : reclamacion.getProcStatus().abbreviate(125),
                                                                            SAC_FechaAlta__c = reclamacion.getCreationDate() == null ? null : Date.valueOf(reclamacion.getCreationDate()),
                                                                            SAC_FechaCierre__c = reclamacion.getDueDate() == null ? null : Date.valueOf(reclamacion.getDueDate()),
                                                                            RecordTypeId = reclamacionesGESCON,
                                                                            SAC_RelacionAntPresCPCCaso__c = caseId,
                                                                            SAC_FechaSolicitud__c = Datetime.now());
                antecedentes.add(antecedente);
            }
        }

        SAC_WS_Promor_RQ.RequestWrapper reqWrapperPromor = new SAC_WS_Promor_RQ.RequestWrapper(clientes);
        List<SAC_WS_Promor_RP.ClaimWrapper> promorResponses = SAC_WS_Promor.sendRequest(reqWrapperPromor, profileName);
        if(Test.isRunningTest() || (promorResponses != null && !promorResponses.isEmpty() && promorResponses[0].getClaimCode() != null)){
            for(SAC_WS_Promor_RP.ClaimWrapper reclamacion : promorResponses){

                SAC_Antecedentes__c antecedente = new SAC_Antecedentes__c(SAC_OficinaAfectada__c = reclamacion.getAffectedOffice() == null ? null : reclamacion.getAffectedOffice().abbreviate(25),
                                                                            SAC_IdReclamacion__c = reclamacion.getClaimCode() == null ? null : reclamacion.getClaimCode().abbreviate(125),
                                                                            SAC_NIF__c = reclamacion.getCustomerIds() == null ? null : String.join(reclamacion.getCustomerIds(),', ').abbreviate(255),
                                                                            SAC_Contrato__c = reclamacion.getContracts() != null ? String.join(reclamacion.getContracts(),', ').abbreviate(125) : null,
                                                                            SAC_ImporteReclamado__c = reclamacion.getClaimAmount(),
                                                                            SAC_ProductoServicio__c = reclamacion.getProduct() == null ? null : reclamacion.getProduct().abbreviate(255),
                                                                            SAC_Estado__c = reclamacion.getClaimStatus() == null ? null : reclamacion.getClaimStatus().abbreviate(125),
                                                                            SAC_FechaAlta__c = reclamacion.getCreationDate() == null ? null : Date.valueOf(reclamacion.getCreationDate()),
                                                                            SAC_FechaCierre__c = reclamacion.getDueDate() == null ? null : Date.valueOf(reclamacion.getDueDate()),
                                                                            RecordTypeId = reclamacionesPROMOR,
                                                                            SAC_RelacionDemJudMorCaso__c = caseId,
                                                                            SAC_FechaSolicitud__c = Datetime.now());
                antecedentes.add(antecedente);
            }
        }

        SAC_WS_Proesp_RQ.RequestWrapper reqWrapperProesp = new SAC_WS_Proesp_RQ.RequestWrapper(clientes);
        List<SAC_WS_Proesp_RP.ClaimWrapper> proespResponses = SAC_WS_Proesp.sendRequest(reqWrapperProesp, profileName);

        if(Test.isRunningTest() || (proespResponses != null && !proespResponses.isEmpty() && proespResponses[0].getProcCode() != null)){
            for(SAC_WS_Proesp_RP.ClaimWrapper reclamacion : proespResponses){

                SAC_Antecedentes__c antecedente = new SAC_Antecedentes__c(SAC_IdReclamacion__c = reclamacion.getProcCode() == null ? null : reclamacion.getProcCode().abbreviate(125),
                                                                            SAC_NumeroProcedimiento__c = reclamacion.getProcCode() == null ? null : reclamacion.getProcCode().abbreviate(60),
                                                                            SAC_NIF__c = reclamacion.getCustomerIds() == null ? null : String.join(reclamacion.getCustomerIds(),', ').abbreviate(255),
                                                                            SAC_Contrato__c = reclamacion.getContracts() != null ? String.join(reclamacion.getContracts(),', ').abbreviate(125) : null,
                                                                            SAC_ProductoServicio__c = reclamacion.getProduct() == null ? null : reclamacion.getProduct().abbreviate(255),
                                                                            SAC_Materia__c = reclamacion.getsubjects() != null ? String.join(reclamacion.getSubjects(),', ') : null,
                                                                            SAC_Estado__c = reclamacion.getProcStatus() == null ? null : reclamacion.getProcStatus().abbreviate(125),
                                                                            SAC_FechaAlta__c = reclamacion.getCreationDate() == null ? null : Date.valueOf(reclamacion.getCreationDate()),
                                                                            SAC_FechaCierre__c = reclamacion.getDueDate() == null ? null : Date.valueOf(reclamacion.getDueDate()),
                                                                            RecordTypeId = reclamacionesPROESP,
                                                                            SAC_RelacionDemJudEntCaso__c = caseId,
                                                                            SAC_FechaSolicitud__c = Datetime.now());
                antecedentes.add(antecedente);
            }
        }

        List<Case> casosCC = [SELECT Id, Account.CC_Numero_Documento__c, Account.FirstName, toLabel(CC_Canal_Resolucion__c), Account.LastName, CC_Importe_Reclamado__c, CC_Detalles_Solucion__c, CC_Oficina_afectada__c, Subject, CreatedDate, ClosedDate, Origin, CC_MCC_Motivo__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Tematica__r.Name FROM Case WHERE AccountId <> null AND Account.CC_Numero_Documento__c IN :clientes AND RecordTypeId IN (:clientesCC, :empleadosCC, :bankiaCC)];

        if(!casosCC.isEmpty()){
            for(Case casoCC : casosCC){
                SAC_Antecedentes__c antecedente = new SAC_Antecedentes__c(
                    SAC_ImporteReclamado__c = casoCC.CC_Importe_Reclamado__c,
                    SAC_TipoResolucion__c = casoCC.CC_Canal_Resolucion__c == null ? null : casoCC.CC_Canal_Resolucion__c.abbreviate(255), 
                    SAC_Resolucion__c = casoCC.CC_Detalles_Solucion__c == null ? null : casoCC.CC_Detalles_Solucion__c.abbreviate(255), 
                    SAC_OficinaAfectada__c = casoCC.CC_Oficina_afectada__c,
                    Name = casoCC.Subject == null ? null : casoCC.Subject.abbreviate(80),
                    SAC_FechaCierre__c = Date.valueOf(casoCC.ClosedDate),
                    SAC_FechaAlta__c = Date.valueOf(casoCC.CreatedDate),
                    SAC_Apellidos__c = casoCC.Account.FirstName == null ? null : casoCC.Account.FirstName.abbreviate(125),
                    SAC_Nombre__c = casoCC.Account.LastName == null ? null : casoCC.Account.LastName.abbreviate(125),
                    SAC_NIF__c = casoCC.Account.CC_Numero_Documento__c,
                    SAC_RelacionAntCCCaso__c = caseId,
                    SAC_FechaSolicitud__c = Datetime.now(),
                    SAC_CanalEntrada__c = casoCC.Origin == null ? null : casoCC.Origin.abbreviate(225), 
                    SAC_Motivo__c = casoCC.CC_MCC_Motivo__r.Name,
                    SAC_ProductoServicio__c = casoCC.CC_MCC_ProdServ__r.Name,
                    SAC_Tematica__c = casoCC.CC_MCC_Tematica__r.Name,
                    SAC_RelacionCasoCC__c = casoCC.Id,
                    RecordTypeId = antecedentesCC
                );
                antecedentes.add(antecedente);
            }
        }

        SAC_DatabaseDML.insertListDML(antecedentes, true);   
        //Database.insert(antecedentes);

        Map<String, String> mapAntecedentesHistoricos = new Map<String, String>();
        for (SAC_Antecedentes__c antecedente : antecedentes){
            mapAntecedentesHistoricos.put(antecedente.SAC_IdReclamacion__c, antecedente.Id);
        }

        List<SAC_AdjuntoAntecedente__c> adjuntos = new List<SAC_AdjuntoAntecedente__c>();

        if(atrResponses != null && !atrResponses.isEmpty()){
            for(SAC_WS_Antecedentes_RP.ClaimWrapper reclamacion : atrResponses){
                String idAntecedente = mapAntecedentesHistoricos.get(reclamacion.getClaimCode());
                if(reclamacion.getResolutionDocuments() != null && !reclamacion.getResolutionDocuments().isEmpty()){
                    for(SAC_WS_Antecedentes_RP.ResolutionDocumentsWrapper doc : reclamacion.getResolutionDocuments()){
                        SAC_AdjuntoAntecedente__c adjunto = new SAC_AdjuntoAntecedente__c(SAC_Adjunto__c = doc.getDownloadLink().abbreviate(255), SAC_Tipo__c = doc.getFileName().abbreviate(255), SAC_Antecedente__c = idAntecedente);
                        adjuntos.add(adjunto);
                    }
                }
                if(reclamacion.getClaimDocuments() != null && !reclamacion.getClaimDocuments().isEmpty()){
                    for(SAC_WS_Antecedentes_RP.ClaimDocumentsWrapper doc : reclamacion.getClaimDocuments()){
                        SAC_AdjuntoAntecedente__c adjunto = new SAC_AdjuntoAntecedente__c(SAC_Adjunto__c = doc.getDownloadLink().abbreviate(255), SAC_Tipo__c = doc.getFileName().abbreviate(255), SAC_Antecedente__c = idAntecedente);
                        adjuntos.add(adjunto);
                    }
                }
            }
        }
        

        if(promorResponses != null && !promorResponses.isEmpty()){
            for(SAC_WS_Promor_RP.ClaimWrapper reclamacion : promorResponses){
                String idAntecedente = mapAntecedentesHistoricos.get(reclamacion.getClaimCode());
                if(reclamacion.getResolutionDocuments() != null && !reclamacion.getResolutionDocuments().isEmpty()){
                    for(SAC_WS_Promor_RP.ResolutionDocumentsWrapper doc : reclamacion.getResolutionDocuments()){
                        SAC_AdjuntoAntecedente__c adjunto = new SAC_AdjuntoAntecedente__c(SAC_Adjunto__c = doc.getDownloadLink().abbreviate(255), SAC_Tipo__c = doc.getFileName().abbreviate(255), SAC_Antecedente__c = idAntecedente);
                        adjuntos.add(adjunto);
                    }
                }
            }
        }

        if(proespResponses != null && !proespResponses.isEmpty()){
            for(SAC_WS_Proesp_RP.ClaimWrapper reclamacion : proespResponses){
                String idAntecedente = mapAntecedentesHistoricos.get(reclamacion.getProcCode());
                if(reclamacion.getResolutionDocuments() != null && !reclamacion.getResolutionDocuments().isEmpty()){
                    for(SAC_WS_Proesp_RP.ResolutionDocumentsWrapper doc : reclamacion.getResolutionDocuments()){
                        SAC_AdjuntoAntecedente__c adjunto = new SAC_AdjuntoAntecedente__c(SAC_Adjunto__c = doc.getDownloadLink().abbreviate(255), SAC_Tipo__c = doc.getFileName().abbreviate(255), SAC_Antecedente__c = idAntecedente);
                        adjuntos.add(adjunto);
                    }
                }
                if(reclamacion.getProcResponseDocuments() != null && !reclamacion.getProcResponseDocuments().isEmpty()){
                    for(SAC_WS_Proesp_RP.ProcResponseDocumentsWrapper doc : reclamacion.getProcResponseDocuments()){
                        SAC_AdjuntoAntecedente__c adjunto = new SAC_AdjuntoAntecedente__c(SAC_Adjunto__c = doc.getDownloadLink().abbreviate(255), SAC_Tipo__c = doc.getFileName().abbreviate(255), SAC_Antecedente__c = idAntecedente);
                        adjuntos.add(adjunto);
                    }
                }
            }
        }

        SAC_DatabaseDML.insertListDML(adjuntos, true);   
        //Database.insert(adjuntos);

        List<CC_TrazaInt__c> trazas = new List<CC_TrazaInt__c>();
        if(proespResponses != null && !proespResponses.isEmpty()){
            trazas.add(proespResponses[0].getTraza());
        }
        if(promorResponses != null && !promorResponses.isEmpty()){
            trazas.add(promorResponses[0].getTraza());
        }
        if(gesconResponses != null && !gesconResponses.isEmpty()){
            trazas.add(gesconResponses[0].getTraza());
        }
        if(responseAntecedentes != null){
            trazas.add(responseAntecedentes.traza);
        }
        return trazas;
    }

    @AuraEnabled
    public static List<String> obtenerDNIReclamantes(Id caseId){
        
        List <SAC_CaseReclamante__c> lstCaseReclamantes = [SELECT SAC_Account__r.CC_Numero_Documento__c FROM SAC_CaseReclamante__c WHERE ((SAC_Case__r.RecordType.DeveloperName LIKE 'SAC_%' OR SAC_Case__r.RecordType.DeveloperName LIKE 'SPV_%') AND SAC_Case__c =: caseId) OR ((SAC_Pretension__r.RecordType.DeveloperName LIKE 'SAC_%' OR SAC_Pretension__r.RecordType.DeveloperName LIKE 'SPV_%') AND SAC_Pretension__c =: caseId)];
        Set <String> lstReclamantes = new Set <String>();

        if (!lstCaseReclamantes.isEmpty()){

            for(SAC_CaseReclamante__c cr : lstCaseReclamantes){
                lstReclamantes.add(cr.SAC_Account__r.CC_Numero_Documento__c);
            }
        
            List<String> lstResult = new List<String>(lstReclamantes);
            //obtenerAntecedentes(lstResult, caseId);
            List<CC_TrazaInt__c> trazas = obtenerAntecedentes(lstResult, caseId);
          
            String jsonTrazas = JSON.serialize(trazas);//<-----
        
            Case caso = [SELECT id, SAC_FechaUltimaSolicitud__c FROM Case WHERE (RecordType.DeveloperName LIKE 'SAC_%' OR RecordType.DeveloperName LIKE 'SPV_%') AND Id =: caseId LIMIT 1];
            caso.SAC_FechaUltimaSolicitud__c = Datetime.now();
            SAC_DatabaseDML.updateDML(caso, false);   
            //Database.update(caso);
        
            SAC_Utils.insertTrazas(jsonTrazas); //<------

            return lstResult;
        }
        return null;
    }

    @AuraEnabled
    public static WrapperInfo recuperarCaseInfo(Id caseId){
        Case reclamacion = new Case();
        Boolean esOwner = false;
        
        List<Case> listaCasos = [SELECT Id, SAC_FechaUltimaSolicitud__c,SAC_Antecedentes_Revisados__c, OwnerId, RecordTypeId FROM Case WHERE Id = :caseId OR SAC_Reclamacion__c = :caseId];
        User usuario = [SELECT Id, SAC_PerteneceCOPSAJ__c FROM User WHERE Id = :UserInfo.getUserId()];

        for(Case caso : listaCasos){
            if(caso.RecordTypeId == recTypeReclamacion || caso.RecordTypeId == recTypeReclamacionSPV){
                reclamacion = caso;
            }
            if(caso.OwnerId == usuario.Id){
                esOwner = true;
            }
        }

        WrapperInfo tw = new WrapperInfo(reclamacion, usuario.SAC_PerteneceCOPSAJ__c, esOwner);
        return tw;
    }

    @AuraEnabled
    public static void establecerCheckRevisados(Id caseId, Boolean revisados){
       
        Case caso = [SELECT Id FROM Case WHERE Id = :caseId LIMIT 1];
        caso.SAC_Antecedentes_Revisados__c = revisados;

        SAC_DatabaseDML.updateDML(caso, false);  
        //Database.update(caso);
    }

    public class WrapperInfo{        
        
        @AuraEnabled public Case caso {get; set;}
        @AuraEnabled public Boolean esCOPSAJ {get; set;}
        @AuraEnabled public Boolean userOwner {get; set;}

        
        public wrapperInfo(Case casoActual, Boolean esCOPSAJActual, Boolean userOwnerActual)
        {
            caso = casoActual;
            esCOPSAJ = esCOPSAJActual;
            userOwner = userOwnerActual;
        }        
    }
}