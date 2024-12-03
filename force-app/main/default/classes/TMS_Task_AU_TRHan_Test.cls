@isTest
public class TMS_Task_AU_TRHan_Test {
    
    @TestSetup
    public static void crearDatosPrueba() {
        
        User u = TMS_Usuarios.usuarioAdminTMS();
        System.runAs(u) {
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
			caso.Origin = 'Backend';
            caso.CC_Canal_Procedencia__c = 'Testamentarias';
            caso.TMS_Numexp__c = '11111111';
            caso.CC_Tipo_Contacto__c='Gestión expediente';
            caso.ContactId = contacto.Id;
            caso.OwnerId= u.Id;
            
            insert caso;

            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c','CC_Lista_Valores');
            lista.Name  = 'TMS - Creación de tareas automáticas';
            
            insert lista;

            List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
            valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor.CC_Lista__c = lista.Id;
            valor.Name  = 'Acreditación Heredero';
            valor.CC_Valor__c  = 'Primer intento de llamada';
            valores.add(valor);

            
            CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
            valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor2.CC_Lista__c = lista.Id;
            valor2.Name  = 'Acreditación Heredero';
            valor2.CC_Valor__c  = 'Segundo intento de llamada';
            valores.add(valor2);

            insert valores;
        }
    }
    
    

    @isTest
    static void test01_updateTask() {
        // Testar control numperso.
        TMS_WS_Udp_Case_DTO.RequestDTO requestTms = new TMS_WS_Udp_Case_DTO.RequestDTO();
        TMS_WS_Udp_Case_DTO.ResponseDTO responseTms;
        
        Case caso =[SELECT Id, TMS_Numexp__c FROM Case WHERE TMS_Numexp__c = '11111111' LIMIT 1];

        requestTms.numExp = caso.TMS_Numexp__c;
        requestTms.estado = 'TMS_002';
        requestTms.gestoria = '5';

        
        String jsonMsg=JSON.serialize(requestTms);
        
        User us = [SELECT Id FROM User WHERE Alias = 'adminTMS'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/tms/case/upd';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Udp_Case_DTO.ResponseDTO respuesta = TMS_WS_Udp_Case.updateCase();
            List<Task> tareasPendientes = [SELECT Id, Subject, Status FROM TASK WHERE WhatId = :caso.Id];
            
            System.AssertEquals('OK', respuesta.estado);
            System.assertNotEquals(0, tareasPendientes.size());
            

            Task tareaLlamada = new Task();
            for(Task tarea: tareasPendientes){
                if(tarea.Subject == 'Primer intento de llamada' && tarea.Status != 'Completed'){
                    tarea.Status='Completed';
                    tareaLlamada=tarea;
                }
            }
            update tareaLlamada;
            Task segundaLlamada=[SELECT Id,Status FROM Task WHERE WhatId = :caso.Id AND Subject = 'Segundo intento de llamada' LIMIT 1];
            System.assertEquals('Rechazada', segundaLlamada.Status);
            Test.stopTest();
        }

    }

   
    
}