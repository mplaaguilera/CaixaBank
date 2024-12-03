/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 12-13-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   12-13-2022   Adrian Mariscal   Correcciones Quality Clouds
**/
@isTest
public class CC_LCMP_conversationUnit_Test {

    @testSetup
    public static void makeData(){
        UserRole rol = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        //User a ejecutar tests se tiene que añadir dentro de los metodos para evitar el mixed dml statement error
        User usuarioGeneral = new User();
        usuarioGeneral.Username = 'usergeneral@test.com';
        usuarioGeneral.Email = 'email@test.com';
        usuarioGeneral.LastName = 'usuarioGeneral Test';
        usuarioGeneral.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Analísta y 2º nivel MVP2'].Id;
        usuarioGeneral.Alias = 'alias';
        usuarioGeneral.TimeZoneSidKey = 'GMT';
        usuarioGeneral.LocaleSidKey = 'es_ES';
        usuarioGeneral.EmailEncodingKey = 'ISO-8859-1';
        usuarioGeneral.LanguageLocaleKey = 'en_US';
        usuarioGeneral.isActive = true;
        usuarioGeneral.UserRoleId = rol.Id;
        insert usuarioGeneral;

        System.runAs(usuarioGeneral){
            // Crear oficina.
         Account cuenta = new Account();
         cuenta.Name = 'Cuenta Cliente Test 1';
         cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
         
         insert cuenta;


         // Crear empleado.
         Contact b = new Contact();
         b.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
         b.AccountId = cuenta.Id;
         b.LastName = 'Cliente prueba 1';
         b.FirstName = 'Cliente prueba 1';
         b.CC_Idioma__c = 'es';
         b.Email = 'test@contact.com';
         b.CC_Matricula__c = '9265';
         insert b;
         
         Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
         Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
         Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
         Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
         Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
         
         CC_MCC__c mcc = new CC_MCC__c();
         mcc.RecordTypeId = recordTem;
         mcc.Name = 'App\'s';
         mcc.CC_Tipo_Cliente__c = 'Cliente';
         mcc.CC_Canal_Operativo__c = 'App BrokerNow';
         mcc.CC_Codigo_Externo__c = 'TE-000001';
         insert mcc;
         
         
         CC_MCC__c mcc1 = new CC_MCC__c();
         mcc1.RecordTypeId = recordProd;
         mcc1.Name = 'APP CaixaBank';
         mcc1.CC_Detalle__c = 'CaixaBank';
         mcc1.CC_Tipo_Cliente__c = 'Cliente';
         mcc1.CC_Tematica__c = mcc.Id;
         mcc1.CC_Codigo_Externo__c = 'PR-000001';
         insert mcc1;  
         
         
         //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
         CC_MCC__c mcc2 = new CC_MCC__c();
         mcc2.RecordTypeId = recordMot;
         mcc2.Name = 'Valoración positiva';
         mcc2.CC_Tipo_Cliente__c = 'Cliente';
         mcc2.CC_Producto_Servicio__c = mcc1.Id;
         mcc2.CC_Codigo_Externo__c = 'MO-000001';
         insert mcc2; 
         
         
         CC_MCC__c mcc3 = new CC_MCC__c();
         mcc3.RecordTypeId = recordCau;
         mcc3.Name = 'Causa';
         mcc3.CC_Tipo_Cliente__c = 'Cliente';
         mcc3.CC_Codigo_Externo__c = 'CA-000001';
         insert mcc3;
         
         
         CC_MCC__c mcc4 = new CC_MCC__c();
         mcc4.RecordTypeId = recordSol;
         mcc4.Name = 'Solucion';
         mcc4.CC_Tipo_Cliente__c = 'Cliente';
         mcc4.CC_Codigo_Externo__c = 'SO-000001';
         insert mcc4;

        Case oCaseCerrado = new Case();
        oCaseCerrado.Subject = 'Prueba Conversation Test';
        oCaseCerrado.CC_Idioma__c = 'es';
        oCaseCerrado.CC_NumPerso__c = '123456';
        oCaseCerrado.CC_Tipo_Cliente__c = 'Cliente';
        oCaseCerrado.Status = 'Cerrado';
        oCaseCerrado.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        oCaseCerrado.Origin = 'Phone';
        oCaseCerrado.CC_Tipo_Contacto__c = 'Consulta';
        oCaseCerrado.CC_Canal_Procedencia__c = 'CaixaBankNow';
        oCaseCerrado.CC_Canal_Resolucion__c = 'CaixaBankNow';
        oCaseCerrado.CC_Canal_Operativo__c = 'App BrokerNow';
        oCaseCerrado.CC_MCC_Tematica__c  = mcc.Id;
        oCaseCerrado.CC_MCC_ProdServ__c =  mcc1.Id;
        oCaseCerrado.CC_MCC_Motivo__c=  mcc2.Id;
        oCaseCerrado.CC_Tipo_ChatTranscript__c = 'Hidden';
        oCaseCerrado.CC_Detalles_Consulta__c = 'Prueba';
        oCaseCerrado.CC_Detalles_Solucion__c = 'Prueba';
        oCaseCerrado.CC_Id_Cognitivo__c = '87654321_9999999';
        oCaseCerrado.CC_MCC_Causa__c =  mcc3.Id;
        oCaseCerrado.CC_MCC_Solucion__c =  mcc4.Id;
        oCaseCerrado.AccountId = cuenta.Id;
        oCaseCerrado.ContactId = b.Id;
        insert oCaseCerrado;
        }
         
         
         
         
    }

    @isTest
    public static void recuperarDatosCond1Test(){
        
        User usuario = [SELECT id FROM User WHERE alias = 'alias' Limit 1];
        Case oCaseCerrado = [Select id from Case where subject = 'Prueba Conversation Test' Limit 1];
        Account cuenta = [Select id from Account where name = 'Cuenta Cliente Test 1' Limit 1];

        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', oCaseCerrado.Id, '');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = [SELECT Id, Name, CC_Asunto__c, CC_Id_Cognitivo__c, CC_Idioma__c, CC_Servicio_Genesys__c, CC_Tipo__c, CC_ConnId__c,
                                 CC_ANI__c, CC_Agente__c, CC_Canal_del_Empleado__c, CC_Case_Consulta__c, CC_Cognitivo__c, CC_ConnId_Cognitivo__c,
                                 CC_ConnId_Consulta__c, CC_Contacto__c, CC_Cuenta__c, CC_Datos_Genesys__c, CC_DNIS__c , CC_Extension__c , CC_IdentCliente__c,
                                 CC_Identificado_Manualmente__c, CC_No_Identificado__c
                                 FROM CC_Llamada__c WHERE Id = :idLlamada AND CC_Fecha_Fin__c = NULL];
        llamada.CC_Cuenta__c = cuenta.Id;
        //llamada.CC_ConnId_Cognitivo__c = '87654321_9999999';
        //llamada.CC_Id_Cognitivo__c = '16';
        llamada.CC_ConnId__c = '16';
        update llamada;


        Test.startTest();
        List<CC_ConversationUnit__c> antesEj = [SELECT Id FROM CC_ConversationUnit__c WHERE CC_ThreadId__c = '16_190199932' LIMIT 1];
        System.runAs(usuario){
            List<CC_LCMP_conversationUnit.ObjIniWrapper> result = CC_LCMP_conversationUnit.comprobarDatos(llamada.Id);
        }
        List<CC_ConversationUnit__c> despuesEj = [SELECT Id FROM CC_ConversationUnit__c WHERE CC_ThreadId__c = '16_190199932' LIMIT 1];
        Test.stopTest();
        
        System.assertEquals(antesEj.size(), 0, 'La ejecución no ha almacenado correctamente los datos.');
        //System.assertEquals(antesEj.size(), 1, 'La ejecución no ha almacenado correctamente los datos.');
    }

    @isTest
    public static void recuperarDatosCond2Test(){
        User usuario = [SELECT id FROM User WHERE alias = 'alias' Limit 1];
        Case oCaseCerrado = [Select id from Case where subject = 'Prueba Conversation Test' Limit 1];
        Account cuenta = [Select id from Account where name = 'Cuenta Cliente Test 1' Limit 1];

        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', oCaseCerrado.Id, '');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = [SELECT Id, Name, CC_Asunto__c, CC_Id_Cognitivo__c, CC_Idioma__c, CC_Servicio_Genesys__c, CC_Tipo__c, CC_ConnId__c,
                                 CC_ANI__c, CC_Agente__c, CC_Canal_del_Empleado__c, CC_Case_Consulta__c, CC_Cognitivo__c, CC_ConnId_Cognitivo__c,
                                 CC_ConnId_Consulta__c, CC_Contacto__c, CC_Cuenta__c, CC_Datos_Genesys__c, CC_DNIS__c , CC_Extension__c , CC_IdentCliente__c,
                                 CC_Identificado_Manualmente__c, CC_No_Identificado__c
                                 FROM CC_Llamada__c WHERE Id = :idLlamada AND CC_Fecha_Fin__c = NULL];
        llamada.CC_Cuenta__c = cuenta.Id;
        //llamada.CC_ConnId_Cognitivo__c = '87654321_9999999';
        //llamada.CC_Id_Cognitivo__c = '16';
        llamada.CC_ConnId__c = '16';
        update llamada;

        CC_ConversationUnit__c elementoDetalle = new CC_ConversationUnit__c(
            CC_ThreadId__c = '16_190199932',
            RecordTypeId = Schema.getGlobalDescribe().get('CC_ConversationUnit__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ConversationDetail').getRecordTypeId(),
            CC_Feedback__c = 'OK',
            CC_FechaFin__c = System.now(),
            CC_FechaInicio__c = System.now(),
            CC_Llamada__c = llamada.Id
        );
        insert elementoDetalle;


        Test.startTest();
        List<CC_ConversationUnit__c> antesEj = [SELECT Id FROM CC_ConversationUnit__c WHERE CC_ThreadId__c = '16_190199932' LIMIT 1];
        System.runAs(usuario){
            List<CC_LCMP_conversationUnit.ObjIniWrapper> result = CC_LCMP_conversationUnit.comprobarDatos(llamada.Id);
       }
        List<CC_ConversationUnit__c> despuesEj = [SELECT Id FROM CC_ConversationUnit__c WHERE CC_ThreadId__c = '16_190199932' LIMIT 1];
        Test.stopTest();
        
        System.assertEquals(antesEj.size(), 1, 'La ejecución no ha almacenado correctamente los datos.');
        System.assertEquals(despuesEj.size(), 1, 'La ejecución no ha almacenado correctamente los datos.');
    }

    @isTest
    public static void recuperarDatosCond3Test(){        
        User usuario = [SELECT id FROM User WHERE alias = 'alias' Limit 1];
        Case oCaseCerrado = [Select id from Case where subject = 'Prueba Conversation Test' Limit 1];
        Account cuenta = [Select id from Account where name = 'Cuenta Cliente Test 1' Limit 1];
        Id rtId = Schema.getGlobalDescribe().get('CC_ConversationUnit__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ConversationDetail').getRecordTypeId();

        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', oCaseCerrado.Id, '');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = [SELECT Id, Name, CC_Asunto__c, CC_Id_Cognitivo__c, CC_Idioma__c, CC_Servicio_Genesys__c, CC_Tipo__c, CC_ConnId__c,
                                 CC_ANI__c, CC_Agente__c, CC_Canal_del_Empleado__c, CC_Case_Consulta__c, CC_Cognitivo__c, CC_ConnId_Cognitivo__c,
                                 CC_ConnId_Consulta__c, CC_Contacto__c, CC_Cuenta__c, CC_Datos_Genesys__c, CC_DNIS__c , CC_Extension__c , CC_IdentCliente__c,
                                 CC_Identificado_Manualmente__c, CC_No_Identificado__c
                                 FROM CC_Llamada__c WHERE Id = :idLlamada AND CC_Fecha_Fin__c = NULL];
        llamada.CC_Cuenta__c = cuenta.Id;
        //llamada.CC_ConnId_Cognitivo__c = '87654321_9999999';
        //llamada.CC_Id_Cognitivo__c = '16';
        llamada.CC_ConnId__c = '16';
        update llamada;

        CC_ConversationUnit__c elementoDetalle = new CC_ConversationUnit__c(
            CC_ThreadId__c = '2208090214260635',
            RecordTypeId = Schema.getGlobalDescribe().get('CC_ConversationUnit__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ConversationDetail').getRecordTypeId(),
            CC_Feedback__c = 'OK',
            CC_FechaFin__c = System.now(),
            CC_FechaInicio__c = System.now(),
            CC_Llamada__c = llamada.Id
        );
        insert elementoDetalle;


        Test.startTest();
        List<CC_ConversationUnit__c> antesEj = [SELECT Id FROM CC_ConversationUnit__c WHERE CC_ThreadId__c = '2208090214260635'];
        System.runAs(usuario){
            List<CC_LCMP_conversationUnit.ObjIniWrapper> result = CC_LCMP_conversationUnit.comprobarDatos(llamada.Id);
        }
        List<CC_ConversationUnit__c> despuesEj = [SELECT Id, RecordTypeId FROM CC_ConversationUnit__c WHERE RecordTypeId =: rtId AND (CC_ThreadId__c = '2208090214260635' OR CC_ThreadId__c = '16_190199932')];
        Test.stopTest();
        
        System.assertEquals(antesEj.size(), 1, 'La ejecución no ha almacenado correctamente los datos.');
        //System.assertEquals(antesEj.size(), 3, 'La ejecución no ha almacenado correctamente los datos.');
    }

}