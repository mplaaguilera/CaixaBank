/*****************************************************************
 * Name: SAC_QueueableEnvioEmail
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US539784       Raúl/Sergio     20/03/23      Creación
 * 1.1            US723742       Raúl Santos     05/03/24      Modificación: añadir lógica envio emails blackList
*****************************************************************/

public with sharing class SAC_QueueableEnvioEmail implements Queueable  {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final String RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();

    Map<Boolean, List<SAC_Accion__c>> mapTareas;
    String numCaso;

    public SAC_QueueableEnvioEmail(Map<Boolean, List<SAC_Accion__c>> mapTareasC, String numCasoC) {
        mapTareas = mapTareasC;
        numCaso = numCasoC;
    }

    public void execute(QueueableContext context) {

        List<Id> idListaGrupos = new List<Id>();
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();

        EmailTemplate emailTemplateOficina = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'SAC_TareaOficina'];
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE name = 'SAC Notificar equipo red'];
        //Recuperar owas y almacenarlas en mapa con key nombre y valor Id.
        List<OrgWideEmailAddress> listaOwas = [SELECT Id, Address, displayname FROM OrgWideEmailAddress WHERE displayname = 'CaixaBank SAC' OR displayname = 'Servicio Atención Cliente M2P'];
        Map<String, String> mapaOwaId = new Map<String, String>();
        for (OrgWideEmailAddress owa : listaOwas) {
            mapaOwaId.put(owa.displayname, owa.Id);
        }

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>{};

        //Recuperar caso
        Case caso = [SELECT Id, SAC_M2P__c FROM Case WHERE CaseNumber =: numCaso];

        for(Boolean oficina : mapTareas.keySet()){
            for(SAC_Accion__c accion : mapTareas.get(oficina)){
                if(oficina == false){  
                    
                    idListaGrupos.add(accion.SAC_EquipoResponsable__c);
                }
                else if(oficina == true){ // Es una tarea a oficina

                    //Compruebo las direcciones de envio con las de la blackList
                    List<String> arrayAddress = accion.SAC_Oficina__r.CC_Email__c.split(',');
                    List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, arrayAddress);

                    //Si existen direcciones válidas, continuo el proceso
                    if(!emailsValidos.isEmpty()){
                        String whoId = UserInfo.getUserId();
                    
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(emailTemplateOficina.Id, whoId, accion.Id);
                        message.toAddresses = emailsValidos;
                        message.optOutPolicy = 'FILTER';
                        message.Subject = renderStored.getSubject();
                        message.HtmlBody = renderStored.getHtmlBody();
                        message.setWhatId(accion.Id);
                        if (caso.SAC_M2P__c && mapaOwaId.containsKey('Servicio Atención Cliente M2P')) {
                            message.setOrgWideEmailAddressId(mapaOwaId.get('Servicio Atención Cliente M2P'));
                        } else if (!caso.SAC_M2P__c && mapaOwaId.containsKey('CaixaBank SAC')) {
                            message.setOrgWideEmailAddressId(mapaOwaId.get('CaixaBank SAC'));
                        }
                        messages.add(message);
                    }
                }
            }
        }

        if(!idListaGrupos.isEmpty()){
            listaGrupos = [SELECT Id, SAC_Email__c FROM CC_Grupo_Colaborador__c WHERE Id IN: idListaGrupos]; 
        }
        
        String [] arrayAddress = new List<String>();
        if(!listaGrupos.isEmpty()){
            for(CC_Grupo_Colaborador__c grupo : listaGrupos){
                arrayAddress.add(grupo.SAC_Email__c);
            }

            //Compruebo las direcciones de envio con las de la blackList
            List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, arrayAddress);

            //Si existen direcciones válidas, continuo el proceso
            if(!emailsValidos.isEmpty()){
                //listaResolucionTarea = envioMailAsin(arrayAddress, numCaso);
                String idCase = caso.Id;
                String whoId = UserInfo.getUserId();

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(emailTemplate.Id, whoId, idCase);
                message.toAddresses = emailsValidos;
                message.optOutPolicy = 'FILTER';
                message.Subject = renderStored.getSubject();
                message.HtmlBody = renderStored.getHtmlBody() + ' ' + numCaso;
                message.setWhatId(idCase);
                if (caso.SAC_M2P__c && mapaOwaId.containsKey('Servicio Atención Cliente M2P')) {
                    message.setOrgWideEmailAddressId(mapaOwaId.get('Servicio Atención Cliente M2P'));
                } else if (!caso.SAC_M2P__c && mapaOwaId.containsKey('CaixaBank SAC')) {
                    message.setOrgWideEmailAddressId(mapaOwaId.get('CaixaBank SAC'));
                }
                messages.add(message);
            }
        }

        if(!messages.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
        
    }
}