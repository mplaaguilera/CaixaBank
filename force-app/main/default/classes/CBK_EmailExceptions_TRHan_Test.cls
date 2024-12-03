@isTest
public with sharing class CBK_EmailExceptions_TRHan_Test {
    
    @TestSetup
    private static void makeData(){
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;

        CBK_ActivateParenHan_Test__c conf = new CBK_ActivateParenHan_Test__c(name = 'ActivarHandlerTest', Active__c = true);
        insert conf;
    }

    @isTest
    private static void emailMessageTest(){
        CC_Grupo_Colaborador__c grupoColab = [SELECT Id,Name FROM CC_Grupo_Colaborador__c limit 1];

        List<EmailMessage> lst =  new List<EmailMessage>();
        EmailMessage correo = new EmailMessage();
        correo.Incoming = true;
        correo.Subject = 'OPORTUN';
        correo.TextBody = 'OPORTUN';
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.ToAddress = 'prueba2@ibm.com';
        correo.Headers = '[{"value": "Prueba@IBM","name": "X-SFDC-Original-RCPT"}]';
        lst.add(correo);
        
        CC_TriggerParameters tp =  new CC_TriggerParameters();
        tp.newList = lst;

        Test.startTest();
        try{
            User u = [SELECT Id FROM User LIMIT 2];
        }catch (Exception e){
            Type handlerClassType2 = Type.forName('CBK_EmailExceptions_TRHan');
            CBK_EmailExceptions_TRHan emailHand = (CBK_EmailExceptions_TRHan) handlerClassType2.newInstance();
            emailHand.handledException(e, tp, 'CBK_EmailExceptions_TRHan');
        }
        Test.stopTest();
    }


    @isTest
    private static void emailMessageWorksTest(){
        CC_Grupo_Colaborador__c grupoColab = [SELECT Id,Name FROM CC_Grupo_Colaborador__c limit 1];

        List<EmailMessage> lst =  new List<EmailMessage>();
        EmailMessage correo = new EmailMessage();
        correo.Incoming = true;
        correo.Subject = 'OPORTUN';
        correo.TextBody = 'OPORTUN';
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.ToAddress = 'prueba2@ibm.com';
        correo.Headers = 'yghgchgf';
        lst.add(correo);

        Test.startTest();
        try{
            insert lst;
        }catch (Exception e){
            
        }
        Test.stopTest();
    }

    @isTest
    private static void emailMessageWorks2Test(){
        CBK_ActivateParenHan_Test__c conf = [SELECT Id, Active__c from CBK_ActivateParenHan_Test__c limit 1];
        conf.Active__c = false;
        update conf;
        CC_Grupo_Colaborador__c grupoColab = [SELECT Id,Name FROM CC_Grupo_Colaborador__c limit 1];

        List<EmailMessage> lst =  new List<EmailMessage>();
        EmailMessage correo = new EmailMessage();
        correo.Incoming = true;
        correo.Subject = 'OPORTUN';
        correo.TextBody = 'OPORTUN';
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.CC_Procedencia__c = 'Remitir Colaboradorfdasdfa';
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.ToAddress = 'prueba2@ibm.com';
        correo.Headers = '[{"value": "Prueba@IBM","name": "X-SFDC-Original-RCPT"}]';
        lst.add(correo);

        Test.startTest();
        try{
            insert lst;
        }catch (Exception e){
            
        }
        Test.stopTest();
    }

    @isTest
    private static void emailServiceTest(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Create Contact';
        email.fromAddress = 'ac@email.com';
        email.toAddresses = new List < String > {'toac@email.com','toac2@email.com'};
        email.ccAddresses = new List < String > {'ccac@email.com','ccac2@email.com'};
        email.plainTextBody = 'email body\n2225256325\nTitle';
        Messaging.InboundEmail.Header hditem= new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1];
        hditem.name='X-SFDC-Original-RCPT';
        hditem.value='Prueba@IBM';
        email.headers[0]=hditem;

        Test.startTest();
        try{
            User u = [SELECT Id FROM User LIMIT 2];
        }catch(Exception e){
            CBK_EmailExceptions_TRHan.handledEmailServiceException(e, email);
        }
        Test.stopTest();
    }
}