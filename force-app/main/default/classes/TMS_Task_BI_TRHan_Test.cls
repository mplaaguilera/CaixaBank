@isTest
public class TMS_Task_BI_TRHan_Test {
    
     @TestSetup
    public static void crearDatosPrueba() {
        

        User us = TMS_Usuarios.usuarioAdminTMS();
        
        System.runAs(us) {
            // The following code runs as user 'u'
//Añadir cuenta
            
            Account oficinaGestora = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId(), 
                LastName = 'Cuenta oficina gestora', 
                CC_Email__c = 'test@test.com', 
                CC_Numero_Oficina__c = '00001');

            insert oficinaGestora;

            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.LastName = 'Contacto test';
            contacto.Email='test@test.com';
            contacto.AV_NumPerso__c = '2147483647';
            contacto.Account = oficinaGestora;
            insert contacto;

            Case caso = new Case();
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
            caso.Subject = 'Caso TMS ' + System.Today();
			caso.Origin = 'SAC_Manual';
            caso.CC_Canal_Procedencia__c = 'Testamentarias';
            caso.TMS_Numexp__c = '11111111';
            caso.CC_Tipo_Contacto__c='Gestión expediente';
            caso.Status='TMS_001';
            caso.ContactId = contacto.Id;
            caso.OwnerId= us.Id;
            
            insert caso;
            
            
        }
    }
    @isTest
    static void testTaskManual(){
        
        User us = [SELECT Id FROM User WHERE Alias = 'adminTMS'];
        Case caso =[SELECT Id, Status, TMS_Numexp__c FROM Case WHERE TMS_Numexp__c = '11111111' LIMIT 1];
        List<CaseStatus> estadoCaso =[SELECT MasterLabel, ApiName FROM CaseStatus WHERE ApiName = :caso.Status];
        System.runAs (us){
            
            Test.startTest();
            Task tarea = new Task();
            tarea.RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
            tarea.WhatId=caso.Id;
            tarea.Type='Actividad manual';
            
            insert tarea;
            
            tarea = [SELECT Id, CC_Consulta__c, CC_Categoria__c FROM Task WHERE WhatId = :caso.Id LIMIT 1];
            System.AssertEquals(caso.TMS_Numexp__c, tarea.CC_Consulta__c);
            System.AssertEquals(estadoCaso[0].MasterLabel, tarea.CC_Categoria__c);
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testTaskAuto(){
        
        User us = [SELECT Id FROM User WHERE Alias = 'adminTMS'];
        Case caso =[SELECT Id, Status, TMS_Numexp__c FROM Case WHERE TMS_Numexp__c = '11111111' LIMIT 1];
        System.runAs (us){
            Test.startTest();
            Task tarea = new Task();
            tarea.RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
            tarea.WhatId=caso.Id;
            tarea.Type='Rechazado Email';
            
            insert tarea;

            //Primero se calcula los dos días en milisegundos
            Long intervaloDias = 2 * 24 * 60 * 60 * 1000;

            //Se guarda el horario laboral a partir de la query de la BusinessHours que se llama TMS_Horario_Laboral
            BusinessHours horarioLaboral = [SELECT Id FROM BusinessHours WHERE Name = 'TMS_Horario_Laboral'];
            
            //Se calcula la fecha de cierre para compararla con la fecha de la tarea
            Date fechaFinal = BusinessHours.add(horarioLaboral.Id, System.Now(), intervaloDias).date();

            tarea = [SELECT Id, ActivityDate FROM Task WHERE WhatId = :caso.Id LIMIT 1];
            
            //Se compara la fecha para que solo cuente los días laborales y no los fines de semana o festivos
            System.AssertEquals(fechaFinal, tarea.ActivityDate, 'La fecha de cierre es un fin de semana o festivo');         
            
            Test.stopTest();
            
        }
    }

}