@isTest
public class CC_WS_Intents_Test 
{
    @testSetup
    public static void makeData(){
         // Crear oficina.
         Account cuenta = new Account();
         cuenta.Name = 'Cuenta Cliente Test 1';
         cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
         insert cuenta;
         
         // Crear empleado.
         Contact b = new Contact();
          Id RecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
         b.RecordTypeId = RecordType;
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
        oCaseCerrado.Subject = 'Prueba intents Test';
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

    //Test donde lanzamos el método getConversationId
    @isTest
    public static void testGeTConversationId(){
      Case oCaseCerrado = [Select id from Case where subject = 'Prueba intents Test' Limit 1];
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

        String status = CC_WS_Intents.getConversationId(llamada).statusCode;

        System.assertEquals('200', status);

    }
   
    @isTest 
    public static void getConversationDetail(){

        String status = CC_WS_Intents.getConversationDetail('2132132132').statusCode;
        
        System.assertEquals('200',status);
    }

}