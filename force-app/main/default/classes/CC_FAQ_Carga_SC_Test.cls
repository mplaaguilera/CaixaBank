@isTest
public class CC_FAQ_Carga_SC_Test {
	public static String CRON_EXP = '0 0 0 15 3 ? 2040';
    @TestSetup
    static void setData() {

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);

		insert userList;        
    }

    @isTest
    public static void test() {
        //Respuesta de Tool para pruebas almacenada en recurso estático "JSON_FAQ"
        /*StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('JSON_FAQ');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        HttpResponse result = CC_FAQ_Carga.cargar();
        Test.stopTest();
        
        //Comprobaciones
        System.assertNotEquals(null, result, 'The callout returned a null response.');
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.');
        System.assertEquals('application/json;charset=UTF-8', result.getHeader('Content-Type'), 'The content type value is not expected.');  
        */
        
        Id recordTypeIdAplicacion = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Aplicaciones').getRecordTypeId();
        CC_FAQ__c aplicacion = new CC_FAQ__c();
        aplicacion.Name = 'LiniaObertaApp';
        aplicacion.CC_Id_App__c='2';
        aplicacion.RecordTypeId = recordTypeIdAplicacion;
        insert aplicacion;
        
        Id recordTypeIdEspacio = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Espacios').getRecordTypeId();
        CC_FAQ__c espacio = new CC_FAQ__c();
        espacio.Name = 'liniaObertaWSLOE';
        espacio.CC_Id_Espacio__c='15000000';
        espacio.CC_Descripcion_ca__c ='Línia Oberta de LOE';
        espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Lookup_App__c = aplicacion.Id;
        espacio.RecordTypeId = recordTypeIdEspacio;
        insert espacio;

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new CC_FAQ_Carga_SC());    
        Test.stopTest();
        
        //Se considera que si el System.schedule retorna un jobId, se ha programado correctamente ka ejecución.
        //La carga en sí de las FAQs se prueba en la clase CC_FAQ_Test.
        System.assert(jobId != null);
    }

    @isTest
    public static void Test_CC_FAQ_Batch_No_OK() {
        
        Id recordTypeIdAplicacion = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Aplicaciones').getRecordTypeId();
     	
     	CC_FAQ__c aplicacion = new CC_FAQ__c();
       	aplicacion.Name = 'TestOnly';
        aplicacion.CC_Id_App__c='99999999';
        aplicacion.RecordTypeId = recordTypeIdAplicacion;
        insert aplicacion;
        
        Id recordTypeIdEspacio = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Espacios').getRecordTypeId();
     	
     	CC_FAQ__c espacio = new CC_FAQ__c();
       	espacio.Name = 'TestOnlyWSLOE';
        espacio.CC_Id_Espacio__c='9999999915000012';
        espacio.CC_Descripcion_ca__c ='Línia Oberta de LOE';
 		espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Lookup_App__c = aplicacion.Id;
        espacio.RecordTypeId = recordTypeIdEspacio;
        insert espacio;       

        Id iRTEspaciosAct = Schema.SObjectType.CC_FAQ__c.getRecordTypeInfosByDeveloperName().get('CC_EspaciosActualizar').getRecordTypeId();
        CC_FAQ__c espacioActualizar = new CC_FAQ__c();
        espacioActualizar.Name = 'TestOnlyWSLOE';
        espacioActualizar.CC_Id_Espacio__c='9999999915000012';
        espacioActualizar.CC_Descripcion_ca__c ='Línia Oberta de LOE';
        espacioActualizar.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacioActualizar.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacioActualizar.CC_Lookup_App__c = aplicacion.Id;
        espacioActualizar.RecordTypeId = iRTEspaciosAct;
        espacioActualizar.CC_ErrorCola__c = false;
        insert espacioActualizar;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CC_FAQ_App_Mock());
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            CC_FAQ_Batch ejecutar = new CC_FAQ_Batch();
            Database.executeBatch(ejecutar);
        }
        Test.stopTest();
        
        List<CC_FAQ__c> oTest = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdAplicacion AND CC_Id_App__c = '99999999'];        
        System.assertEquals(1, oTest.size());

    }

    @isTest
    public static void Test_CC_FAQ_Batch_OK() {
        
        Id recordTypeIdAplicacion = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Aplicaciones').getRecordTypeId();
     	
     	CC_FAQ__c aplicacion = new CC_FAQ__c();
       	aplicacion.Name = 'TestOnly';
        aplicacion.CC_Id_App__c='99999999';
        aplicacion.RecordTypeId = recordTypeIdAplicacion;
        insert aplicacion;
        
        Id recordTypeIdEspacio = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Espacios').getRecordTypeId();
     	
     	CC_FAQ__c espacio = new CC_FAQ__c();
       	espacio.Name = 'TestOnlyWSLOE';
        espacio.CC_Id_Espacio__c='9999999915000012';
        espacio.CC_Descripcion_ca__c ='Línia Oberta de LOE';
 		espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Lookup_App__c = aplicacion.Id;
        espacio.RecordTypeId = recordTypeIdEspacio;
        insert espacio;       
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CC_FAQ_App_Mock());
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
        CC_FAQ.cargarApps();
        }
        Test.stopTest();
        
        List<CC_FAQ__c> oTest = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdAplicacion AND CC_Id_App__c = '99999999'];        
        System.assertEquals(1, oTest.size());
        
        List<CC_FAQ__c> oTest2 = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdEspacio AND CC_Id_Espacio__c = '9999999915000012'];        
        System.assertEquals(2, oTest2.size());
    }
}