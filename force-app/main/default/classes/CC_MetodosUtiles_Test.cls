@isTest
public class CC_MetodosUtiles_Test {
    
    @testSetup static void InitDatos() {
        
        // Inicialización de datos.
        List<CC_Lista_Valores__c> oListVal = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> oListVal2 = new List<CC_Lista_Valores__c>();
        
        ID sTipoRegL = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();        
        ID sTipoRegV = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();        
        
        CC_Lista_Valores__c a1 = new CC_Lista_Valores__c();
        a1.Name = 'CC_Idioma_ALF';
        a1.CC_Activa__c = true;
        a1.RecordTypeId = sTipoRegL;
        oListVal.add(a1);
        
        CC_Lista_Valores__c a2 = new CC_Lista_Valores__c();
        a2.Name = 'CC_TipoCom_ALF';
        a2.CC_Activa__c = true;
        a2.RecordTypeId = sTipoRegL;
        oListVal.add(a2);
        
        CC_Lista_Valores__c a3 = new CC_Lista_Valores__c();
        a3.Name = 'CC_ClaseCom_ALF';
        a3.CC_Activa__c = true;
        a3.RecordTypeId = sTipoRegL;
        oListVal.add(a3);
        
        CC_Lista_Valores__c a4 = new CC_Lista_Valores__c();
        a4.Name = 'CC_Sexo_ALF';
        a4.CC_Activa__c = true;
        a4.RecordTypeId = sTipoRegL;
        oListVal.add(a4);
        
        insert oListVal;
        
        CC_Lista_Valores__c a5 = new CC_Lista_Valores__c();
        a5.Name = '000';
        a5.CC_Activa__c = true;
        a5.RecordTypeId = sTipoRegV;
        a5.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Idioma_ALF'].Id;
        a5.CC_Valor__c = 'DESCONOCIDO';
        a5.CC_Valor_SFDC__c = 'es';
        oListVal2.add(a5);
        
        CC_Lista_Valores__c a6 = new CC_Lista_Valores__c();
        a6.Name = '001';
        a6.CC_Activa__c = true;
        a6.RecordTypeId = sTipoRegV;
        a6.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Idioma_ALF'].Id;
        a6.CC_Valor__c = 'CATALÀ';
        a6.CC_Valor_SFDC__c = 'ca';
        oListVal2.add(a6);
        
        CC_Lista_Valores__c a7 = new CC_Lista_Valores__c();
        a7.Name = '002';
        a7.CC_Activa__c = true;
        a7.RecordTypeId = sTipoRegV;
        a7.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Idioma_ALF'].Id;
        a7.CC_Valor__c = 'CASTELLANO';
        a7.CC_Valor_SFDC__c = 'es';
        oListVal2.add(a7);
        
        CC_Lista_Valores__c a8 = new CC_Lista_Valores__c();
        a8.Name = '0';
        a8.CC_Activa__c = true;
        a8.RecordTypeId = sTipoRegV;
        a8.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_ClaseCom_ALF'].Id;
        a8.CC_Valor__c = 'Personal';
        a8.CC_Valor_SFDC__c = '0';
        oListVal2.add(a8);
        
        CC_Lista_Valores__c a9 = new CC_Lista_Valores__c();
        a9.Name = '1';
        a9.CC_Activa__c = true;
        a9.RecordTypeId = sTipoRegV;
        a9.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_ClaseCom_ALF'].Id;
        a9.CC_Valor__c = 'Trabajo';
        a9.CC_Valor_SFDC__c = '1';
        oListVal2.add(a9);
        
        CC_Lista_Valores__c a10 = new CC_Lista_Valores__c();
        a10.Name = 'V';
        a10.CC_Activa__c = true;
        a10.RecordTypeId = sTipoRegV;
        a10.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Sexo_ALF'].Id;
        a10.CC_Valor__c = 'Varón';
        a10.CC_Valor_SFDC__c = 'V';
        oListVal2.add(a10);
        
        CC_Lista_Valores__c a11 = new CC_Lista_Valores__c();
        a11.Name = 'M';
        a11.CC_Activa__c = true;
        a11.RecordTypeId = sTipoRegV;
        a11.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Sexo_ALF'].Id;
        a11.CC_Valor__c = 'Mujer';
        a11.CC_Valor_SFDC__c = 'M';
        oListVal2.add(a11);
        
        CC_Lista_Valores__c a12 = new CC_Lista_Valores__c();
        a12.Name = '006';
        a12.CC_Activa__c = true;
        a12.RecordTypeId = sTipoRegV;
        a12.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_TipoCom_ALF'].Id;
        a12.CC_Valor__c = 'Móvil-Principal';
        a12.CC_Valor_SFDC__c = '006';
        oListVal2.add(a12);
        
        CC_Lista_Valores__c a13 = new CC_Lista_Valores__c();
        a13.Name = '001';
        a13.CC_Activa__c = true;
        a13.RecordTypeId = sTipoRegV;
        a13.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_TipoCom_ALF'].Id;
        a13.CC_Valor__c = 'Fijo';
        a13.CC_Valor_SFDC__c = '001';
        oListVal2.add(a13);
        
        CC_Lista_Valores__c a14 = new CC_Lista_Valores__c();
        a14.Name = '002';
        a14.CC_Activa__c = true;
        a14.RecordTypeId = sTipoRegV;
        a14.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_TipoCom_ALF'].Id;
        a14.CC_Valor__c = 'Móvil';
        a14.CC_Valor_SFDC__c = '002';
        oListVal2.add(a14);
        
        insert oListVal2;
    }

    @isTest
    static void test01_getLOV() {
        
        Test.startTest();
        
        List<String> oLOV = new List<String>();
        oLOV.add('CC_Sexo_ALF');
        
        Map<String, Object> oData = CC_MetodosUtiles.getLOV (oLOV);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('CC_Sexo_ALF'),null);
        
        Map<String,String> oVal = (Map<String,String>)oData.get('CC_Sexo_ALF');
        
        System.assertEquals(oVal.get('M'),'M');
        
    }
    
    @isTest
    static void test02_getLOV() {
        
        Test.startTest();
        
        List<String> oLOV = new List<String>();
        oLOV.add('CC_Sexo_ALF');
        
        Map<String, Object> oData = CC_MetodosUtiles.getLOV (oLOV);
        
        Test.stopTest();
        
        System.assertNotEquals(oData.get('CC_Sexo_ALF'),null);
        
        Map<String,String> oVal = (Map<String,String>)oData.get('CC_Sexo_ALF');
        
        System.assertEquals(oVal.get('Y'),null);
        
    }    
    
    @isTest
    static void test03_getLOV() {
        
        Test.startTest();
        
        List<String> oLOV = new List<String>();
        oLOV.add('CC_Sexo_ALF');
        
        Map<String, Object> oData = CC_MetodosUtiles.getLOV (oLOV);
        
        Test.stopTest();
        
        System.assertEquals(oData.get('CC_Sexo_ALF2'),null);        
    }    
    
    @isTest
    static void test04_getInterfazConfig() {
        
        Test.startTest();
        
		CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfig ('CC_Int_ALF');
        
        Test.stopTest();
        
        System.assertNotEquals(oConfig,null);     
    }  
    
    @isTest
    static void test05_getInterfazConfig() {
        
        Test.startTest();
        
		CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfig ('CC_Int_ALF2');
        
        Test.stopTest();
        
        System.assertEquals(oConfig,null);     
    }  
    
    @isTest
    static void test06_getInterfazConfig() {
        
        Test.startTest();
        
		CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF2');
        
        Test.stopTest();
        
        System.assertEquals(oConfig,null);     
    }  
    
    @isTest
    static void test07_getInterfazConfig() {
        
        Test.startTest();
        
		CC_InterfaceSettings__mdt oConfig = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_ALF');
        
        Test.stopTest();
        
        System.assertNotEquals(oConfig,null);     
    }  
    
    @isTest
    static void test08_getLOVMeta() {
        
        Test.startTest();
        
        List<String> oListaOrig = new List<String>();
        
        oListaOrig.add('CC_Idioma_ALF');
        
        Map<String, Object> oMap = CC_MetodosUtiles.getLOVMeta (oListaOrig);
        
        Test.stopTest();
        
        System.assertEquals(oMap.size() > 0, true);     
    } 
    
    @isTest
    static void test09_getValueLOVMeta() {
        
        Test.startTest();
        
        List<String> oListaOrig = new List<String>();
        
        String sValor = CC_MetodosUtiles.getValueLOVMeta ('CC_Idioma_ALF','001');
        
        Test.stopTest();
        
        System.assertEquals(sValor != '', true);     
    } 
    
    @isTest
    static void test10_getValueLOVMeta() {
        
        Test.startTest();
        
        Set<String> oLOV = new Set<String>();
        Set<String> oVal = new Set<String>();
        
        oLOV.add('CC_Idioma_ALF');
        oVal.add('001');
        
        Map<String, Object> oRes = CC_MetodosUtiles.getLOVWithVal (oLOV,oVal);
        
        Test.stopTest();
        
        System.assertEquals(!oRes.isEmpty(), true);     
    } 
    
    @isTest
    static void test11_getNotificacionesConfig() {
        
        Test.startTest();
        
        List<CC_ConfigNotifCliente__mdt> oRes = CC_MetodosUtiles.getNotificacionesConfig ('CC_AcuseRecibo','Email');
        List<CC_ConfigNotifCliente__mdt> oRes2= CC_MetodosUtiles.getNotificacionesConfig ('CC_AcuseRecibo','');
        
        Test.stopTest();
        
        System.assertEquals(!oRes.isEmpty(), true);
        System.assertEquals(!oRes2.isEmpty(), true);
    } 
    
    @isTest
    static void test12_getLOV_null() {
        
        Test.startTest();
        
        Map<String, Object> oData = CC_MetodosUtiles.getLOV (null);
        
        Test.stopTest();
        
        System.assertEquals(oData.isEmpty(),true);        
    }
    
    @isTest
    static void test13_getLOV_empty() {
        
        Test.startTest();
        
        List<String> oLOV = new List<String>();
        
        Map<String, Object> oData = CC_MetodosUtiles.getLOV (oLOV);
        
        Test.stopTest();
        
        System.assertEquals(oData.isEmpty(),true);        
    }
    
    @isTest
    static void test14_getLOVWithVal_null() {
        
        Test.startTest();
        
        Map<String, Object> oData = CC_MetodosUtiles.getLOVWithVal (null, null);
        
        Test.stopTest();
        
        System.assertEquals(oData.isEmpty(),true);        
    }
    
    @isTest
    static void test15_getLOVWithVal_empty() {
        
        Test.startTest();
        
        Set<String> oLOV = new Set<String>();
        
        Map<String, Object> oData = CC_MetodosUtiles.getLOVWithVal (oLOV, oLOV);
        
        Test.stopTest();
        
        System.assertEquals(oData.isEmpty(),true);        
    }
    
    @isTest
    static void test16_getDestValueLOVMeta() {
        
        Test.startTest();
        
        String lista = 'lista';
        String valor = 'valor';
        
        String oData = CC_MetodosUtiles.getDestValueLOVMeta (lista, valor);
        
        Test.stopTest();
        
        System.assertNotEquals(oData, null);
    }
    
    @isTest
    static void getLOVSimpleMethod () {
        
        Test.startTest();
        
        String lista = 'lista';
        String valor = 'valor';
        Map<String,String> oData = new Map<String,String>();
        oData = CC_MetodosUtiles.getLOVSimpleMethod (lista, valor);
        
        Test.stopTest();
        
        System.assertNotEquals(oData, null);
    }
    
    @isTest
    static void decimalToHex () {
        
        Test.startTest();
        
        Decimal dec = decimal.valueOf('1111222233334444');
        String result = '';
        result = CC_MetodosUtiles.decimalToHex(dec);
        Test.stopTest();
        
        System.assertNotEquals(result, null);
    }
    
    @isTest
    static void obtenerRecordTypes() {
        
        Map<Id, String> mapaRecordTypes = CC_MetodosUtiles.obtenerRecordTypes('CC_Derecho__c');
        
        List<Recordtype> recordTypesDerecho = [SELECT Id from Recordtype WHERE SobjectType ='CC_Derecho__c'];
        System.assertEquals(recordTypesDerecho.size(), mapaRecordTypes.size());
    } 
    
    @isTest
    static void fechaLimiteFinSemanaFestivos_Test() {
        Datetime result = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('120');
        System.assertNotEquals(result, null);
    }
    @isTest
    static void hexadecimalToDecimal() {
        
        Test.startTest();
        String hexadecimalNumber = '2F2';
        Double valueDecimal = CC_MetodosUtiles.HexToDecimal(hexadecimalNumber);
        hexadecimalNumber = 'D5FD';
        Double valueDecimal2 = CC_MetodosUtiles.HexToDecimal(hexadecimalNumber);
        Test.stopTest();
        System.assertEquals(valueDecimal,754);
        System.assertEquals(valueDecimal2,54781);        
    }
    
    
    @isTest
    static void validarNIF() {
        Test.startTest();
        String cifNif = '18716671F';
        String result = CC_MetodosUtiles.validarCIFNIF(cifNif);
        Test.stopTest();
        System.assertEquals(result,'NIF');
    }
    @isTest
    static void validarNIE() {
        Test.startTest();
        String cifNif = 'Y1265606E';
        String result = CC_MetodosUtiles.validarCIFNIF(cifNif);
        Test.stopTest();
        System.assertEquals(result,'NIE');
    }
    @isTest
    static void validarCIF() {
        Test.startTest();
        String cifNif = 'A76939792';
        String result = CC_MetodosUtiles.validarCIFNIF(cifNif);
        Test.stopTest();
        System.assertEquals(result,'CIF');
    }
    
    @isTest
    static void delayContactoIntermedio() {
        Test.startTest();
        String devName = 'CC_AcuseRecibo_AC_ES';
        String proceso = 'Acuse recibo';
        DateTime result = CC_MetodosUtiles.delayContactoIntermedio(devName,proceso);
        Test.stopTest();
    }
    @isTest
    static void mapaCampo() {
        
        
        Test.startTest();
    	Map<String, SObject> mapaCampo= CC_MetodosUtiles.mapaCampo([SELECT Name FROM Account LIMIT 3], 'Name');
		Test.stopTest();
        System.assertNotEquals(null, mapaCampo);
        
    }
    
    @isTest
    static void descartarDuplicadosLista() {

        List<String> lista = new List<String>{'c', 'b', 'c', 'z', 'f', 'f'};
        List<String> listaSinDuplicados = new List<String>{'c', 'b', 'z', 'f'};

        Test.startTest();
        lista = CC_MetodosUtiles.descartarDuplicadosLista(lista);
        Test.stopTest();

        System.assert(lista.equals(listaSinDuplicados), 'La lista debería mantener el orden y no tener elementos duplicados.');
    }
    
	@isTest
	static void listaCampo_Test()
	{
        List<CC_Lista_Valores__c> lstValores = [SELECT id FROM CC_Lista_Valores__c];
		String campo = 'test';
        
        Test.startTest();
        	CC_MetodosUtiles.listaCampo(lstValores, campo);
        	CC_MetodosUtiles.mapaCampo(lstValores, campo);
        Test.stopTest();
    }
    
	@isTest
	static void getRecordType_Test()
	{
        ID rtSegCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();        
        Test.startTest();
        	CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SEG_Cliente');
        	CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Case', 'SEG_Cliente');
        	CC_MetodosUtiles.getRecordTypeDeveloperNameFromId('Case', rtSegCliente);
        	CC_MetodosUtiles.getRecordTypeNameFromId('Case', rtSegCliente);
        Test.stopTest();
    }

    @isTest 
    static void getApplicationName() {

        Test.startTest();
        CC_MetodosUtiles.getApplicationName();
        Test.stopTest();        
    }
}