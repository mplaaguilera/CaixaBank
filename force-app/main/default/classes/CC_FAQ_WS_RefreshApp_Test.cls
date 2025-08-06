@isTest
public class CC_FAQ_WS_RefreshApp_Test {

    @isTest
    public static void testRefrescarApp() {
        
        // Desde este método se lanza el proceso Batch --> CC_FAQ_Batch.
        
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
        
        CC_FAQ_WS_RefreshApp.CC_WS_Input oEntrada = new CC_FAQ_WS_RefreshApp.CC_WS_Input();
        oEntrada.Aplicacion = 'TestOnly';

        CC_FAQ_WS_RefreshApp.CC_WS_Output oRes = CC_FAQ_WS_RefreshApp.refrescarApp(oEntrada);

        Test.stopTest();
        
        List<CC_FAQ__c> oTest = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdAplicacion AND CC_Id_App__c = '99999999'];        
        System.assertEquals(1, oTest.size());
        
        List<CC_FAQ__c> oTest2 = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdEspacio AND CC_Id_Espacio__c = '9999999915000012'];        
        System.assertEquals(2, oTest2.size());

        System.assertEquals(true, oRes != null);
    }
    
    @isTest
    public static void testRefrescarAppNueva() {
        
        // Desde este método se lanza el proceso Batch --> CC_FAQ_Batch.
        
        Id recordTypeIdAplicacion = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Aplicaciones').getRecordTypeId();
     	
     	CC_FAQ__c aplicacion = new CC_FAQ__c();
       	aplicacion.Name = 'TestOnly';
        aplicacion.CC_Id_App__c='4444';
        aplicacion.RecordTypeId = recordTypeIdAplicacion;
        insert aplicacion;
        
        Id recordTypeIdEspacio = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Espacios').getRecordTypeId();
     	
     	CC_FAQ__c espacio = new CC_FAQ__c();
       	espacio.Name = 'TestOnlyWSLOE';
        espacio.CC_Id_Espacio__c='444415000012';
        espacio.CC_Descripcion_ca__c ='Línia Oberta de LOE';
 		espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Lookup_App__c = aplicacion.Id;
        espacio.RecordTypeId = recordTypeIdEspacio;
        insert espacio;        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CC_FAQ_App_Mock());

        CC_FAQ_WS_RefreshApp.CC_WS_Input oEntrada = new CC_FAQ_WS_RefreshApp.CC_WS_Input();
        oEntrada.Aplicacion = 'TestOnlyNEW';

        CC_FAQ_WS_RefreshApp.CC_WS_Output oRes = CC_FAQ_WS_RefreshApp.refrescarApp(oEntrada);

        Test.stopTest();
        
        List<CC_FAQ__c> oTest = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdAplicacion AND CC_Id_App__c = '4444'];        
        System.assertEquals(1, oTest.size());
        
        List<CC_FAQ__c> oTest2 = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdEspacio AND CC_Id_Espacio__c = '444415000012'];        
        System.assertEquals(1, oTest2.size());

        System.assertEquals(true, oRes != null);
    }

    @isTest
    public static void testRefrescarAppNULL() {
        
        // Desde este método se lanza el proceso Batch --> CC_FAQ_Batch.
        
        Id recordTypeIdAplicacion = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Aplicaciones').getRecordTypeId();
     	
     	CC_FAQ__c aplicacion = new CC_FAQ__c();
       	aplicacion.Name = 'TestOnly';
        aplicacion.CC_Id_App__c='4444';
        aplicacion.RecordTypeId = recordTypeIdAplicacion;
        insert aplicacion;
        
        Id recordTypeIdEspacio = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Espacios').getRecordTypeId();
     	
     	CC_FAQ__c espacio = new CC_FAQ__c();
       	espacio.Name = 'TestOnlyWSLOE';
        espacio.CC_Id_Espacio__c='444415000012';
        espacio.CC_Descripcion_ca__c ='Línia Oberta de LOE';
 		espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Lookup_App__c = aplicacion.Id;
        espacio.RecordTypeId = recordTypeIdEspacio;
        insert espacio;        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CC_FAQ_App_Mock());

        CC_FAQ_WS_RefreshApp.CC_WS_Input oEntrada;

        CC_FAQ_WS_RefreshApp.CC_WS_Output oRes = CC_FAQ_WS_RefreshApp.refrescarApp(oEntrada);

        Test.stopTest();
        
        List<CC_FAQ__c> oTest = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdAplicacion AND CC_Id_App__c = '4444'];        
        System.assertEquals(1, oTest.size());
        
        List<CC_FAQ__c> oTest2 = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdEspacio AND CC_Id_Espacio__c = '444415000012'];        
        System.assertEquals(1, oTest2.size());

        System.assertEquals(true, oRes != null);
    }
    
    @isTest
    public static void testRefrescarAppVacia() {
        
        // Desde este método se lanza el proceso Batch --> CC_FAQ_Batch.
        
        Id recordTypeIdAplicacion = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Aplicaciones').getRecordTypeId();
     	
     	CC_FAQ__c aplicacion = new CC_FAQ__c();
       	aplicacion.Name = 'TestOnly';
        aplicacion.CC_Id_App__c='4444';
        aplicacion.RecordTypeId = recordTypeIdAplicacion;
        insert aplicacion;
        
        Id recordTypeIdEspacio = Schema.getGlobalDescribe().get('CC_FAQ__c').getDescribe().getRecordTypeInfosByName().get('Espacios').getRecordTypeId();
     	
     	CC_FAQ__c espacio = new CC_FAQ__c();
       	espacio.Name = 'TestOnlyWSLOE';
        espacio.CC_Id_Espacio__c='444415000012';
        espacio.CC_Descripcion_ca__c ='Línia Oberta de LOE';
 		espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Descripcion_es__c ='Línea Abierta de LOE';
        espacio.CC_Lookup_App__c = aplicacion.Id;
        espacio.RecordTypeId = recordTypeIdEspacio;
        insert espacio;        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CC_FAQ_App_Mock());

        CC_FAQ_WS_RefreshApp.CC_WS_Input oEntrada = new CC_FAQ_WS_RefreshApp.CC_WS_Input();
		oEntrada.Aplicacion = '';
        CC_FAQ_WS_RefreshApp.CC_WS_Output oRes = CC_FAQ_WS_RefreshApp.refrescarApp(oEntrada);

        Test.stopTest();
        
        List<CC_FAQ__c> oTest = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdAplicacion AND CC_Id_App__c = '4444'];        
        System.assertEquals(1, oTest.size());
        
        List<CC_FAQ__c> oTest2 = [SELECT Id FROM CC_FAQ__c WHERE RecordTypeId = :recordTypeIdEspacio AND CC_Id_Espacio__c = '444415000012'];        
        System.assertEquals(1, oTest2.size());

        System.assertEquals(true, oRes != null);
    }    
}