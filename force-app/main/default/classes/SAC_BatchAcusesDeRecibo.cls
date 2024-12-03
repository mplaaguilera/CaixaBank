public with sharing class SAC_BatchAcusesDeRecibo implements Database.Batchable<sObject>{

    //Record types
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private final static Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Integer limiteQuery = Integer.valueOf([SELECT SAC_LimitQueryCarta__c FROM SAC_Configuraciones__mdt LIMIT 1].SAC_LimitQueryCarta__c);

        return Database.getQueryLocator([SELECT Id, Status, Origin, CC_Canal_Respuesta__c, SuppliedEmail, CreatedDate, CaseNumber, Subject, CC_Idioma__c
        FROM Case
        WHERE RecordTypeId = :RECTYPERECLAMACION
        AND Origin IN ('Email','SAC_Formulario')
        AND Status NOT IN ('Cerrado','Rechazado','SAC_008','SAC_007','SAC_003','SAC_004','SAC_006')
        AND SuppliedEmail NOT IN ('437494@mailcert.lleida.net','contact@mg.legalpin.com')
        AND CreatedDate >= 2024-05-11T17:30:00.000+02:00
        AND id NOT IN (
            SELECT relatedtoid
            FROM emailmessage
            WHERE  fromname = 'SAC Noreply'
            AND Incoming  = false
            and subject like '%Acuse de recibo%'
            and CreatedDate >= 2024-05-11T17:30:00.000+02:00
            )
        ORDER BY status, CreatedDate desc
        LIMIT :limiteQuery]);
    }

    public void execute(Database.BatchableContext bc, List<Case> newCases){
        //Envio de mails
        Id orgWideId = [SELECT Id,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'SAC Noreply' LIMIT 1].Id;

        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        Map<Id, Case> mapaDatosCasosActualizar = new Map<Id, Case>();
        List<SAC_AcuseRecibo_Email.TemplateWrapper> emailTemplates = SAC_AcuseRecibo_Email.getPlantillaAcuseRecibo(newCases, mapaDatosCasosActualizar);

        List<String> buzonesSalidaValidos = new List<String>();
        
        for (Buzon_SAC__mdt buzonPorDefecto : [SELECT SAC_DireccionCorreo__c FROM Buzon_SAC__mdt WHERE SAC_Activo__c = true]) {
            buzonesSalidaValidos.add(buzonPorDefecto.SAC_DireccionCorreo__c);
        }

        //Recupero los emails no validos de envio (emails en la blackList)
        List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];
        for(SAC_AcuseRecibo_Email.TemplateWrapper emailTemplate : emailTemplates){
            
            //Compruebo las direcciones de envio con las de la blackList
            List<String> listaDireccionesPara = new List<String>{ emailTemplate.SuppliedEmail };
            List<String> emailsValidos = SAC_Utils.comprobarEmailsBlackListAuto(listEmailsNoValidos, listaDireccionesPara);

            //Si existen direcciones válidas, continuo el proceso
            if(!emailsValidos.isEmpty() && (!buzonesSalidaValidos.contains(emailTemplate.SuppliedEmail))){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

                message.setOrgWideEmailAddressId(orgWideId);
                message.setToAddresses( emailsValidos );
                if(Test.isRunningTest()) {
                    message.htmlBody = 'test';
                }else{
                    message.htmlBody = emailTemplate.htmlValueTemplate;
                }
                message.setWhatId(emailTemplate.caseId);
                //message.setTargetObjectId(acnt.PersonContactId);
                message.optOutPolicy = 'FILTER';
                //message.saveAsActivity = false;
                message.subject = emailTemplate.subjectTemplate;
                messageList.add(message);
                //Savepoint sp = Database.setSavepoint();
            }
        }      
        //Enviar mails
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);
    }

    public void finish(Database.BatchableContext bc){
        System.debug('fin del batch emails');
    }
}