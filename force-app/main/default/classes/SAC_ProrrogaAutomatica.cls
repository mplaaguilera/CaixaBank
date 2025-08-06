/***************************************************************************
 * Name: SAC_ProrrogaAutomatica
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Prorrogar todos los casos que vayan a caducar mañana y que cumplan
 * las condiciones del codigo.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US568372      Raul y Sergio      18/05/2023      Creación
 * 1.1            US650149       Raul Santos       29/06/2023      Modificación: optimización del código
 * 1.2            US723742       Raúl Santos       05/03/2024      Modificación: añadir lógica envio emails blackList
 * 1.3            US1114134     Sergio Martín      31/12/2024      Modificación: añadir lógica campo SAC_PendienteEnvioProrroga__c
***************************************************************************/
public without sharing class SAC_ProrrogaAutomatica implements Database.batchable<sObject>{

    private static Set<String> objetos = new Set<String>{'Case','SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION =  mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION =  mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext dbc) {

        List<Case> listaPretensiones = new List<Case>();

        if(!Test.isRunningTest()){
            listaPretensiones = [SELECT Id, SAC_Reclamacion__c,SAC_Prorrogado__c, recordTypeId
                                FROM Case
                                WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_CASE_esPSD2__c = True AND SAC_Reclamacion__C IN (SELECT caseId
                                    FROM caseMilestone 
                                    WHERE case.RecordTypeId = :RECTYPERECLAMACION
                                    AND (case.Status = 'SAC_001' OR case.Status = 'SAC_002' OR case.Status = 'SAC_003') AND case.SAC_Prorrogado__c = False 
                                    AND case.CC_Canal_Procedencia__c != 'Junta Andalucia' AND  MilestoneType.Name = 'SLA Regulatorio' AND TargetDate = TOMORROW)];
        }
        else{
            listaPretensiones = [SELECT Id, SAC_Reclamacion__c,SAC_Prorrogado__c, recordTypeId
                                FROM Case
                                WHERE RecordTypeId =: RECTYPEPRETENSION AND SAC_CASE_esPSD2__c = True AND SAC_Reclamacion__C IN (SELECT caseId
                                    FROM caseMilestone 
                                    WHERE case.RecordTypeId = :RECTYPERECLAMACION
                                    AND (case.Status = 'SAC_001' OR case.Status = 'SAC_002' OR case.Status = 'SAC_003') AND case.SAC_Prorrogado__c = False 
                                    AND case.CC_Canal_Procedencia__c != 'Junta Andalucia' AND  MilestoneType.Name = 'SLA Regulatorio')];
        }
                                        
        Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();
        Set<Id> setIdsPsd2 = new set<Id>();

        for (Case caso : listaPretensiones) {
            mapaReclamaciones.put(caso.SAC_Reclamacion__c, caso);
        }

        setIdsPsd2.addAll(mapaReclamaciones.keySet());

        return Database.getQueryLocator([SELECT Id, SAC_Prorrogado__c,SAC_FechaProrroga__c,SAC_FechaVencimientoSLA__c, recordTypeId, CC_Canal_Procedencia__c, OS_Alerta_Descripcion__c, OS_Email__c, CaseNumber, SAC_M2P__c, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c
                                                FROM case 
                                                WHERE recordTypeId =: RECTYPERECLAMACION 
                                                AND id IN: setIdsPsd2
                                                AND CC_Canal_Procedencia__c != 'Junta Andalucia'
                                                AND SAC_Prorrogado__c = False]);
    }

    public void execute(Database.BatchableContext dbc, List<Case> cases){
        if(!cases.isEmpty()) {

            String owaCaixabankName = 'Caixabank SAC';
            String owaM2PName = 'Servicio Atención Cliente M2P';

            Map<Id, Case> casos = new Map<id,Case>();
            for (Case caso : cases){
                casos.put(caso.id,caso);
            }
            

            List<caseMilestone> milestoneData = [SELECT id, caseId, MilestoneType.Name, TargetDate 
                                                FROM caseMilestone 
                                                WHERE caseId IN: cases 
                                                AND MilestoneType.Name =: 'SLA Regulatorio']; 
                                        
            Map<Id, caseMilestone> reclamacionesConMilestones = new Map<Id, caseMilestone>();
            
            for (caseMilestone milestone : milestoneData) {
                reclamacionesConMilestones.put(milestone.caseID, milestone);
            }
            
            List<Case> listaPretensiones = [SELECT Id, SAC_Reclamacion__c,SAC_Prorrogado__c, recordTypeId, OwnerId, CBK_Case_Extension_Id__c
                                            FROM Case
                                            WHERE SAC_Reclamacion__c IN: cases];                         
                                            
            List<Case> casosFinales = new List<Case>();
            List<CBK_Case_Extension__c> listaUpdateExtension = new List<CBK_Case_Extension__c>();

            // Id ideBH = [SELECT Id, name FROM BusinessHours WHERE name ='SAC_Calendario'].id; 

            for (id rec : reclamacionesConMilestones.keyset()) {
                // caseMilestone milestone = reclamacionesConMilestones.get(rec); 
                case reclamacion = casos.get(rec);
                if(reclamacion.OS_Email__c == null && reclamacion.CBK_Case_Extension_Id__c != null) {
                    if(reclamacion.CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c == false) {
                        reclamacion.CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c = true;
                        CBK_Case_Extension__c extension = new CBK_Case_Extension__c();
                        extension.id = reclamacion.CBK_Case_Extension_Id__c;
                        extension.SAC_PendienteEnvioProrroga__c = true;
                        listaUpdateExtension.add(extension); 
                        casosFinales.add(reclamacion);
                        casos.put(reclamacion.id,reclamacion);
                    }
                } else {
                    reclamacion.SAC_Prorrogado__c = true;
                    reclamacion.SAC_FechaProrroga__c = system.now();
                    //reclamacion.SAC_FechaVencimientoSLA__c = BusinessHours.add(ideBH, milestone.TargetDate, SAC_AccionMetodos.cacularMilisegundos(15));
                    reclamacion.OS_Alerta_Descripcion__c = 'Prorrogado';
                    reclamacion.SAC_ProrrogaCounter__c = 1;  
                    casosFinales.add(reclamacion);
                    casos.put(reclamacion.id,reclamacion);
                }
            }

            Map<Id, Case> mapaPretensiones = new Map<id,Case>();
            for (case pretension : listaPretensiones) {
                case reclamacion = casos.get(pretension.SAC_Reclamacion__c);
                if(reclamacion.OS_Email__c == null && reclamacion.CBK_Case_Extension_Id__c != null) {
                    if(reclamacion.CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c == false) {
                        reclamacion.CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c = true;
                        CBK_Case_Extension__c extension = new CBK_Case_Extension__c();
                        extension.id = pretension.CBK_Case_Extension_Id__c;
                        extension.SAC_PendienteEnvioProrroga__c = true;
                        listaUpdateExtension.add(extension); 
                        casosFinales.add(pretension);  
                    }
                } else {
                    pretension.SAC_Prorrogado__c = reclamacion.SAC_Prorrogado__c ;
                    pretension.SAC_FechaProrroga__c = reclamacion.SAC_FechaProrroga__c;
                    //pretension.SAC_FechaVencimientoSLA__c = reclamacion.SAC_FechaVencimientoSLA__c;
                    pretension.OS_Alerta_Descripcion__c = reclamacion.OS_Alerta_Descripcion__c;
                    casosFinales.add(pretension);  
                }

                if(!mapaPretensiones.containsKey(pretension.SAC_Reclamacion__c)) {
                    mapaPretensiones.put(pretension.SAC_Reclamacion__c, pretension);
                } 
            }

            EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE name = 'SAC_ProrrogarCasoCXB'];
            //Recuperar owas y almacenarlas en mapa con key nombre y valor Id.
            List<OrgWideEmailAddress> listaOwas = [SELECT Id, Address, displayname FROM OrgWideEmailAddress WHERE displayname = :owaCaixabankName OR displayname = :owaM2PName];
            Map<String, String> mapaOwaId = new Map<String, String>();
            for (OrgWideEmailAddress owa : listaOwas) {
                mapaOwaId.put(owa.displayname, owa.Id);
            }
            //Recupero los emails no validos de envio (emails en la blackList)
            List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>{};
            List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();

            // Crear fecha para posteriormente recoger el valor fecha actual de la plantilla (FECHAACTUAL) y sustituirlo por el System.Today
            // De esta manera sacamos la fecha ya que no es posible obtenerla en el Email Template con el mergeo de datos
            Datetime d = System.today();
            String formattedDate = d.day() + '-' + d.month()  + '-' + d.year();
            if(Case.SObjectType.getDescribe().isUpdateable()) {
                Database.SaveResult[] lstResp = Database.update(casosFinales,false); 
                for(Database.SaveResult res : lstResp) {
                    if (res.isSuccess() && casos.get(res.getId()) != null) { 
                        case reclamacion = casos.get(res.getId());
                        String [] arrayAddress = new List<String>();
                        if(reclamacion.recordTypeId == RECTYPERECLAMACION && reclamacion.OS_Email__c != null) {
                            //Compruebo la dirección de envio con las de la blackList
                            arrayAddress.add(reclamacion.OS_Email__c);
                            List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, arrayAddress);

                            //Si la dirección de envio es válida (no está en la blackList), continuo el proceso
                            if(!emailsValidos.isEmpty()){
                                String whoId = UserInfo.getUserId();

                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(emailTemplate.Id, whoId, res.getId());
                                message.toAddresses = emailsValidos;
                                message.optOutPolicy = 'FILTER';
                                message.Subject = renderStored.getSubject();
                                if(renderStored.getHtmlBody().contains('(FECHAACTUAL)')){
                                    message.HtmlBody = renderStored.getHtmlBody().replace('(FECHAACTUAL)', formattedDate);
                                } else {
                                    message.HtmlBody = renderStored.getHtmlBody();
                                } 
                                message.setWhatId(res.getId());
                                if (reclamacion.SAC_M2P__c && mapaOwaId.containsKey(owaM2PName)) {
                                    message.setOrgWideEmailAddressId(mapaOwaId.get(owaM2PName));
                                } else if (!reclamacion.SAC_M2P__c && mapaOwaId.containsKey(owaCaixabankName)) {
                                    message.setOrgWideEmailAddressId(mapaOwaId.get(owaCaixabankName));
                                }
                                messages.add(message);
                            }
                        } else if(reclamacion.recordTypeId == RECTYPERECLAMACION && mapaPretensiones.containsKey(reclamacion.id) && reclamacion.OS_Email__c == null && reclamacion.CBK_Case_Extension_Id__r.SAC_PendienteEnvioProrroga__c == true) {
                            SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(reclamacion.Id,'SAC_CasoPendienteEnvioProrroga','La reclamación ' + reclamacion.CaseNumber + ' tiene una prórroga pendiente de enviar.',mapaPretensiones.get(reclamacion.id).OwnerId,'','','');
                            //Añadirla a la lista para posteriormente llamar al método
                            listaWrapperAlerta.add(wrapAlerta);
                        }        
                    }
                }
                if(!messages.isEmpty()) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                } 
                //Si tenemos alertas que enviar, se llama al método que las envía
                if (!listaWrapperAlerta.isEmpty()) {
                    SAC_Alertas.generarAlertas(listaWrapperAlerta);
                }

                if(!listaUpdateExtension.isEmpty()) {
                    SAC_DatabaseDML.updateListDML(listaUpdateExtension, true);  
                }
            }  
        }  
    }

    public void finish(Database.BatchableContext dbc){
       CBK_Log.debug('Prorroga automatica ejecutada con exito');
    }
}