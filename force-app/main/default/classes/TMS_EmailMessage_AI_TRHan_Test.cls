@isTest
public class TMS_EmailMessage_AI_TRHan_Test {
   @TestSetup
    static void setData() {

        
        User uOs = TMS_Usuarios.usuarioAdminTMS();
        
		System.runAs(uOs) {
            

            EmailTemplate template1 = new EmailTemplate();
            template1.FolderId = uOs.Id;
            template1.Name = 'Plantilla TMS';
            template1.Subject = 'esto es una prueba';
            template1.HtmlValue = 'Test';
            template1.DeveloperName = 'TMS_Plantilla_Prueba';
            template1.TemplateType = 'Text';
            insert template1;
    
            List<Case> lstCasos = new List<Case>();
            Id recordTypeCasoTMS = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
    
            Case caso = new Case();
            caso.Subject = 'Caso de prueba TMS';
            caso.recordtypeId= recordTypeCasoTMS;
            caso.Origin = 'SAC_Manual';
            caso.Status = 'TMS_001';
            caso.CC_Canal_Procedencia__c = 'Testamentarias';
            caso.CC_Buzon_Salida__c = [SELECT TMS_Correo__c FROM TMS_Correo__mdt LIMIT 1].TMS_Correo__c;
            caso.TMS_Numexp__c='87458569878';
            caso.SuppliedEmail='test2@test.com';
            lstCasos.add(caso);
            
            Case caso2 = new Case();
            caso2.Subject = 'Caso de prueba TMS 2';
            caso2.recordtypeId= recordTypeCasoTMS;
            caso2.Origin = 'SAC_Manual';
            caso2.Status = 'TMS_002';
            caso2.CC_Canal_Procedencia__c = 'Testamentarias';
            caso2.TMS_Numexp__c='24785478548';
            lstCasos.add(caso2);
            
            insert lstCasos;
        }
    }
    
    
    
    @isTest
    public static void mensajeSaliente() {
        User u = [SELECT Id FROM User WHERE Alias  = 'adminTMS'];

        System.runAs(u){

        Test.startTest();
        
            Case casoTMS = [SELECT Id, CC_Buzon_Salida__c FROM Case WHERE CC_Canal_Procedencia__c = 'Testamentarias' LIMIT 1];
            
            EmailTemplate plantilla = [SELECT Name, DeveloperName, Subject, HTMLValue FROM EmailTemplate WHERE DeveloperName LIKE '%TMS%' LIMIT 1];
            String direccion= [SELECT TMS_Correo__c FROM TMS_Correo__mdt LIMIT 1].TMS_Correo__c;
            
            
            EmailMessage correo = new EmailMessage();
            correo.FromAddress =casoTMS.CC_Buzon_Salida__c;
            correo.ToAddress = direccion;
            correo.parentId = casoTMS.Id;
            correo.Incoming = false;
        	correo.Subject = plantilla.Subject;
        	correo.HtmlBody = plantilla.HtmlValue;
            insert correo;
            

            List<Task> tarea = [SELECT Id FROM Task WHERE WhatId = :correo.parentId AND Subject ='Envio correo'];
            System.AssertEquals(1, tarea.size());
            Test.stopTest();
        }
    }
}