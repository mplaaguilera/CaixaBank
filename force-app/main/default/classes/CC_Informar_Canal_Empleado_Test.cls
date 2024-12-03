@isTest
public class CC_Informar_Canal_Empleado_Test {
	@isTest
    public static void informaCanalEmpleadoTest() {
        
        //Creacion de una cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		
        Account cuenta = new Account(
        	RecordTypeId = cuentaRecordTypeId,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com'
        );        
        insert cuenta;	
        Id usuarioId = cuenta.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
		cnt1.AccountId = usuarioId;
        insert cnt1;
        
        //Se crea un caso con todos los datos necesarios informados
        Case caso = new Case(
            Origin = 'Chat',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            //OwnerId = usuarioId,
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Canal_Procedencia__c = 'Web',
            ContactId = cnt1.Id
        );
        insert caso;
		
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        LiveChatTranscript liveChat1 = new LiveChatTranscript ();
        liveChat1.CC_Tipo__c = 'Chatbot';
        liveChat1.CC_CasoAsociado__c = caso.Id;
        liveChat1.LiveChatVisitorId = liveChatVisitor.Id;
        insert liveChat1;
        
        LiveChatTranscript liveChat2 = new LiveChatTranscript ();
        liveChat2.CC_Tipo__c = 'Hidden';
        liveChat2.CC_CasoAsociado__c = caso.Id;
        liveChat2.LiveChatVisitorId = liveChatVisitor.Id;
        insert liveChat2;
        
        List<Id> listLiveChat = new List<Id>();
        listLiveChat.add(liveChat1.Id);
        listLiveChat.add(liveChat2.Id);

        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_Canal_Empleado.informaCanalEmpleado(listLiveChat);

        Test.stopTest();

        //Evaluación del resultado de la prueba
        //...
    }

    @isTest
    public static void informaCanalEmpleadoCompletoTest() {
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        List<LiveChatTranscript> chatTranscripList = new List<LiveChatTranscript>();

        //Creacion de una cuenta Cliente
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		
        Account cuenta = new Account(
        	RecordTypeId = cuentaRecordTypeId,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com'
        );
        accountList.add(cuenta);

        //Creacion de una cuenta Empleado
        Account accountTest = new Account();
        accountTest.Name = 'Account Test';
        accountList.add(accountTest);

        insert accountList;	
               
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
		cnt1.AccountId = accountList[0].Id;
        contactList.add(cnt1);

        
        //Creacion de un contacto de tipo Empleado
        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        Contact testContact = new Contact();
        testContact.FirstName = 'Contacto';
        testContact.LastName = 'Test';
        testContact.CC_Matricula__c = 'U0000001';
        testContact.Email = 'test@test.com';
        testContact.AccountId = accountList[1].Id;
        testContact.RecordTypeId = recordTypeEmpleado;
        testContact.CC_Idioma__c = 'ES';
        contactList.add(testContact);
        
        insert contactList;
        
        //Se crea un caso con todos los datos necesarios informados
        Case caso = new Case(
            Origin = 'Chat',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            //OwnerId = usuarioId,
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Canal_Procedencia__c = 'Web',
            ContactId = contactList[0].Id
        );
        caseList.add(caso);

        //Se crea un caso con todos los datos necesarios informados
        Case caso2 = new Case(
            Origin = 'Chat',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            //OwnerId = usuarioId,
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Canal_Procedencia__c = 'Web',
            ContactId = contactList[0].Id
        );
        caseList.add(caso2);

        //Se crea un caso con todos los datos necesarios informados
        Id recordTypeIdCSIBankia = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Pendiente Colaborador';
        oCaso.ContactId = contactList[1].Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdCSIBankia;
        oCaso.Canal_del_Empleado__c = 'CSI';
        oCaso.CC_Canal_Procedencia__c = 'CCO CSI';
        oCaso.CC_Canal_Respuesta__c = 'Email';
        caseList.add(oCaso);

        insert caseList;
		
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        LiveChatTranscript liveChat1 = new LiveChatTranscript();
        liveChat1.CC_Tipo__c = 'Chatbot';
        liveChat1.CaseId = caseList[0].Id;
        liveChat1.CC_CasoAsociado__c = caso.Id;
        liveChat1.LiveChatVisitorId = liveChatVisitor.Id;
        chatTranscripList.add(liveChat1);
        
        LiveChatTranscript liveChat2 = new LiveChatTranscript();
        liveChat2.CC_Tipo__c = 'Hidden';
        liveChat2.CaseId = caseList[1].Id;
        liveChat2.CC_CasoAsociado__c = caso2.Id;
        liveChat2.LiveChatVisitorId = liveChatVisitor.Id;
        chatTranscripList.add(liveChat2);

        LiveChatTranscript liveChat3 = new LiveChatTranscript();
        liveChat3.CC_Tipo__c = 'Chatbot';
        liveChat3.CaseId = caseList[2].Id;
        liveChat3.CC_CasoAsociado__c = oCaso.Id;
        liveChat3.LiveChatVisitorId = liveChatVisitor.Id;
        chatTranscripList.add(liveChat3);
        
        insert chatTranscripList;
        
        List<Id> listLiveChat = new List<Id>();
        listLiveChat.add(liveChat1.Id);
        listLiveChat.add(liveChat2.Id);
        listLiveChat.add(liveChat3.Id);

        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_Canal_Empleado.informaCanalEmpleado(listLiveChat);

        Test.stopTest();

        List<Case> caseUpdatedList = [SELECT Id, Canal_del_Empleado__c FROM Case WHERE Id IN : caseList];

        for (Case updatedCase : caseUpdatedList)
        {
            if (updatedCase.Canal_del_Empleado__c == 'Hidden')
            {
                System.assertEquals(caso2.Id, updatedCase.Id, 'Un caso se ha actualizado a Canal_del_Empleado__c Hidden');
            }
            else if (updatedCase.Canal_del_Empleado__c == 'CSI')
            {
                System.assertEquals(oCaso.Id, updatedCase.Id, 'Un caso se ha actualizado a Canal_del_Empleado__c CSI');
            }
            else
            {
                System.assertEquals(caso.Id, updatedCase.Id, 'Un caso se ha actualizado a Canal_del_Empleado__c Agente');
            }
        }
    }
}