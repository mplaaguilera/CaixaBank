@isTest
public class CC_MetodosUtiles_Test {
    
    @testSetup static void InitDatos() {
        
        //crear usuarios para runAs
        User usuarioAdmin = CC_TestDataFactory.insertUserAdmin();
        System.runAs(usuarioAdmin){
            CC_TestDataFactory.insertarLOVGestorDefault('XXXXXX', 'No asignado');

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

            CC_Lista_Valores__c a5Festivos = new CC_Lista_Valores__c();
            a5Festivos.Name = 'Festivos nacionales';
            a5Festivos.CC_Activa__c = true;
            a5Festivos.RecordTypeId = sTipoRegL;
            oListVal.add(a5Festivos);

            CC_Lista_Valores__c a5CalendarioServicios = new CC_Lista_Valores__c();
            a5CalendarioServicios.Name = 'Calendario_servicios';
            a5CalendarioServicios.CC_Activa__c = true;
            a5CalendarioServicios.RecordTypeId = sTipoRegL;
            oListVal.add(a5CalendarioServicios);

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

            CC_Lista_Valores__c a15 = new CC_Lista_Valores__c();
            a15.Name = '002';
            a15.CC_Activa__c = true;
            a15.RecordTypeId = sTipoRegV;
            a15.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'Festivos nacionales'].Id;
            a15.CC_Valor__c = '25';
            a15.CC_Valor2__c = '12';
            a15.CC_Valor_SFDC__c = '2024';
            oListVal2.add(a15);

            CC_Lista_Valores__c a16 = new CC_Lista_Valores__c();
            a16.Name = '002';
            a16.CC_Activa__c = true;
            a16.RecordTypeId = sTipoRegV;
            a16.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'Calendario_servicios'].Id;
            a16.CC_Valor__c = '25';
            a16.CC_Valor2__c = '12';
            a16.CC_Valor_SFDC__c = '2024';
            oListVal2.add(a16);
            
            insert oListVal2;

            Account testAccount1 = new Account(
                Name = 'Test Account 1',
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'CC_Cliente' LIMIT 1].Id,
                AV_NumPerso__c = '123456',
                CC_NumPerso__c = '654321'
            );
            insert testAccount1;
    
            Account testAccount2 = new Account(
                Name = 'Test Account 2',
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'CC_Cliente' LIMIT 1].Id,
                AV_NumPerso__c = '789012',
                CC_NumPerso__c = '210987'
            );
            insert testAccount2;
    
            // Crear datos de prueba para Contact
            Contact testContact = new Contact(
                LastName = 'Test Contact',
                AccountId = testAccount1.Id,
                RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'CIBE_Apoderado' LIMIT 1].Id,
                CIBE_NumPerso__c = '111111',
                AV_NumPerso__c = '222222',
                CC_NumPerso__c = '333333'
            );
            insert testContact;
    
            // Crear datos de prueba para Case
            Case testCase1 = new Case(
                Subject = 'Test Case 1',
                AccountId = testAccount1.Id,
                ContactId = testContact.Id
            );
            insert testCase1;
    
            Case testCase2 = new Case(
                Subject = 'Test Case 2',
                AccountId = testAccount2.Id
            );
            insert testCase2;
    
            // Crear datos de prueba para CC_Comunicaciones__c
            CC_Comunicaciones__c comunicacion1 = new CC_Comunicaciones__c(
                CC_Case__c = testCase1.Id
            );
            CC_Comunicaciones__c comunicacion2 = new CC_Comunicaciones__c(
                CC_Case__c = testCase2.Id
            );
            insert new List<CC_Comunicaciones__c>{comunicacion1, comunicacion2};
        }    
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

    @isTest 
    static void getLOVNameValueTest() {
    
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                Map<String, Object> values = CC_MetodosUtiles.getLOVNameValue(new List<String>{'CC_Idioma_ALF'}, 'CC_Valor__c' );
                System.assert(!values.isEmpty(), 'No se ha devuelvo la lista de valores');
                System.assert(((String)values.get('000')) == 'DESCONOCIDO', 'No se ha devuelvo el valor correcto');
            }
        Test.stopTest();        
    }

    @isTest 
    static void encriptarSHATest() {
    
        Test.startTest();
            System.runAs(CC_TestDataFactory.getUserAdmin()) {
                String value = CC_MetodosUtiles.encriptarSHA('MD5', 'text');
                System.assert(String.isNotBlank(value), 'No se ha encriptado el texto');

                String valueEmpty = CC_MetodosUtiles.encriptarSHA('', '');
                System.assert(String.isBlank(valueEmpty), 'No ha funcionado la validacion de encriptar');
            }
        Test.stopTest();        
    }

    @isTest
    static void buscarGestorTest() {
        List<String> matriculas = new List<String>{'U012411X', 'XXXXXX'};
        Map<String,User> mapGestor = CC_TestDataFactory.insertUserOperadoresCliente(matriculas);

        User usuarioGestor = mapGestor.get('U012411X');
        User usuarioGenerico = mapGestor.get('XXXXXX');
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            // Test with a specific gestor number
            String numeroGestor = 'U012411X';
            User gestor = CC_MetodosUtiles.buscarGestor(numeroGestor);
            System.assertNotEquals(gestor, null, 'Gestor should not be null for a valid gestor number');
            System.assertEquals(gestor.Id, usuarioGestor.Id, 'Gestor devuelto no correponde con el esperado');

            // Test with a gestor number without U01
            numeroGestor = '2411X';
            User gestor2 = CC_MetodosUtiles.buscarGestor(numeroGestor);
            System.assertNotEquals(gestor2, null, 'Gestor should not be null for a valid gestor number');
            System.assertEquals(gestor2.Id, usuarioGestor.Id, 'Gestor devuelto no correponde con el esperado');
            
            // Test with a generic gestor
            numeroGestor = 'generico';
            User gestor3 = CC_MetodosUtiles.buscarGestor(numeroGestor);
            //User recuperarGenerico = [SELECT Id FROM User WHERE AV_ExternalID__c = '000000' ORDER BY CreatedDate DESC LIMIT 1];
            System.assertNotEquals(gestor3, null, 'Gestor should not be null for a generic gestor');  
            System.assertEquals(gestor3.Id, usuarioGenerico.Id, 'Gestor devuelto no correponde con el esperado');              
        }       
        Test.stopTest();
    }

    @isTest
    static void buscarGestoresTest() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
        // Create a test office account
            Account testOffice = new Account(Name = 'Test Office');
            insert testOffice;
            
            // Create test contacts (gestores)
            Contact gestor1 = new Contact(LastName = 'Gestor 1', AccountId = testOffice.Id, CC_Inactivo__c = false, CC_Num_Empleado_Generico__c = '12345');
            Contact gestor2 = new Contact(LastName = 'Gestor 2', AccountId = testOffice.Id, CC_Inactivo__c = false, CC_Num_Empleado_Generico__c = '67890');
            insert new List<Contact>{gestor1, gestor2};
            
            // Test buscarGestores method
            List<Contact> gestores = CC_MetodosUtiles.buscarGestores(testOffice.Id);
            System.assertNotEquals(gestores, null, 'Gestores should not be null for a valid office');
            System.assertEquals(gestores.size(), 2, 'There should be 2 gestores for the test office');
        }
        Test.stopTest();      
    }
    //buscarGestoresPorMatricula

    @isTest
    static void buscarGestoresPorMatriculaTest() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            // Create test users (gestores)
            List<String> matriculas = new List<String>{'U0123456', 'U0167890', 'XXXXXX'};
            Map<String,User> mapGestor = CC_TestDataFactory.insertUserOperadoresCliente(matriculas);
           
            User gestor1 = mapGestor.get('U0123456');
            User gestor2 = mapGestor.get('U0167890');
            User usuarioGenerico = mapGestor.get('XXXXXX');
            
            // Test buscarGestoresPorMatricula method
            List<String> numeroGestores = new List<String>{'U0123456', 'U0167890'};
            Map<String, User> gestores = CC_MetodosUtiles.buscarGestoresPorMatricula(numeroGestores);

            //Probar el generico
            List<String> numeroGestoresFake = new List<String>{'U01XXXXX', 'U01XXXX2'}; //not exist
            Map<String, User> gestoresGenerico = CC_MetodosUtiles.buscarGestoresPorMatricula(numeroGestoresFake); //debe devolver el generico
            
            Test.stopTest();
            
            System.assertNotEquals(gestores, null, 'Gestores should not be null for valid gestor numbers');
            System.assertEquals(gestores.size(), 2, 'There should be 2 gestores for the given numbers');
            System.assertEquals(gestores.get('U0123456').Id, gestor1.Id, 'Gestor devuelto no correponde con el esperado');
            System.assertEquals(gestores.get('U0167890').Id, gestor2.Id, 'Gestor devuelto no correponde con el esperado');
            //Probar el generico
            System.assertNotEquals(gestoresGenerico, null, 'Gestres debe devolver el generico');
            System.assertEquals(gestoresGenerico.size(), 1, 'Gestores debe devolver un elemento');
            System.assertEquals(gestoresGenerico.get('XXXXXX').Id, usuarioGenerico.Id, 'Gestor devuelto no correponde con el esperado (generico)'); 
        }
    }
    @isTest
    static void testRecuperarNumpersoPorComunicaciones() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
        // Recuperar las comunicaciones de prueba
        List<CC_Comunicaciones__c> comunicaciones = [SELECT Id, CC_Case__r.Account.RecordType.DeveloperName, CC_Case__r.Account.AV_Segmento__c, CC_Case__r.Account.AV_NumPerso__c, CC_Case__r.Account.CC_NumPerso__c, CC_Case__r.Contact.RecordType.DeveloperName, CC_Case__r.Contact.CIBE_NumPerso__c, CC_Case__r.Contact.AV_NumPerso__c, CC_Case__r.Contact.CC_NumPerso__c, CC_Case__r.CC_Representante__c, CC_Case__r.CC_Representante__r.CC_Representante__r.AV_NumPerso__c, CC_Case__r.CC_Representante__r.CC_Representante__r.CC_NumPerso__c FROM CC_Comunicaciones__c];

        // Llamar al método a probar
        Map<Id, String> idToNumPersoMap = CC_MetodosUtiles.recuperarNumpersoPorComunicaciones(comunicaciones);

        // Verificar los resultados
        System.assertEquals(2, idToNumPersoMap.size(), 'El mapa debe contener 2 entradas');

        for (CC_Comunicaciones__c comunicacion : comunicaciones) {
            String numPerso = idToNumPersoMap.get(comunicacion.Id);
            System.assertNotEquals(null, numPerso, 'El numPerso no debe ser nulo');
            //System.debug('Comunicacion Id: ' + comunicacion.Id + ', NumPerso: ' + numPerso);
        }
        }
    }
    @isTest
    static void getCustomSettingTest() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            CC_Settings__c mcs = new CC_Settings__c();
            mcs.Name = 'test';
            insert mcs;

            CC_Settings__c mcsResult = CC_MetodosUtiles.getCustomSetting('test');

            System.assertEquals('test', mcsResult.Name, 'no se ha recuperado el setting');
        }
        Test.stopTest();
    }

    @isTest
    static void generarURLsLimeSurveyTest() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            
            // Crear configuración de encuestas
            List<CC_Envio_Encuesta__c> configEncuestas = new List<CC_Envio_Encuesta__c>();
            
            CC_Envio_Encuesta__c configBase = new CC_Envio_Encuesta__c(
                Name = 'CC_URL_Encuesta',
                CC_Tipo_Encuesta__c = 'URL base',
                CC_Link_LimeSurvey__c = 'https://test.limesurvey.com/survey/index/sid/',
                CC_Id_Encuesta__c = '123456'
            );
            configEncuestas.add(configBase);
            
            CC_Envio_Encuesta__c configPhone = new CC_Envio_Encuesta__c(
                Name = 'CC_TipoLlamada',
                CC_Tipo_Encuesta__c = 'Phone',
                CC_Id_Encuesta__c = '789012'
            );
            configEncuestas.add(configPhone);
            
            CC_Envio_Encuesta__c configChat = new CC_Envio_Encuesta__c(
                Name = 'TipoChat',
                CC_Tipo_Encuesta__c = 'Chat',
                CC_Id_Encuesta__c = '345678'
            );
            configEncuestas.add(configChat);
            
            CC_Envio_Encuesta__c configTercerNivel = new CC_Envio_Encuesta__c(
                Name = 'CC_TercerNivel',
                CC_Tipo_Encuesta__c = 'Caso Tercer Nivel',
                CC_Id_Encuesta__c = '901234'
            );
            configEncuestas.add(configTercerNivel);
            
            CC_Envio_Encuesta__c configFCO = new CC_Envio_Encuesta__c(
                Name = 'CC_EncuestaFormularioOperativas',
                CC_Id_Encuesta__c = '567890'
            );
            configEncuestas.add(configFCO);
            
            insert configEncuestas;

            Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');


            CC_MCC__c tematica = new CC_MCC__c(
                Name = 'Tematica Test',
                RecordTypeId = tematicaId,
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Canal_Operativo__c = 'Cajero',
                CC_Codigo_Externo__c = 'TE-000001'
            );
            insert tematica;

            Contact contactoEmple1 = new Contact();
            contactoEmple1.LastName = 'Contacto empleado';
            contactoEmple1.FirstName = 'Prueba empleado';
            contactoEmple1.CC_Inactivo__c = false;
            contactoEmple1.Email = 'test@test.com';
            contactoEmple1.CC_Matricula__c = 'U0124112';
            contactoEmple1.AV_DescFuncion__c = 'DIRECCION';
            contactoEmple1.RecordtypeId =  rtEmpleado;
            contactoEmple1.CC_Num_Empleado_Generico__c = '12345';
            insert contactoEmple1;
            
            // Recuperar el contacto para asegurar que el campo fórmula se calcule
            contactoEmple1 = [SELECT Id, CC_Matricula__c FROM Contact WHERE Id = :contactoEmple1.Id];

            // Crear casos de prueba
            List<Case> casos = new List<Case>();
            
            // Caso 1: Empleado con llamada telefónica
            Case caso1 = new Case(
                Subject = 'Test Case 1 - Phone',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'),
                Origin = 'Phone',
                CC_Idioma__c = 'es',
                Status = 'Activo',
                CC_Tematica__c = tematica.Name,
                CC_MCC_Tematica__c = tematica.Id,
                ContactId = contactoEmple1.Id
            );
            casos.add(caso1);
            
            // Caso 2: Cliente con chat
            Case caso2 = new Case(
                Subject = 'Test Case 2 - Chat',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'),
                Origin = 'Chat',
                CC_Idioma__c = 'ca',
                Status = 'Activo',
                CC_Tematica__c = tematica.Name,
                CC_MCC_Tematica__c = tematica.Id,
                ContactId = contactoEmple1.Id
            );
            casos.add(caso2);
            
            // Caso 3: Empleado en tercer nivel
            Case caso3 = new Case(
                Subject = 'Test Case 3 - Tercer Nivel',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'),
                Origin = 'Email',
                CC_Idioma__c = 'en',
                CC_En_Tercer_Nivel__c = true,
                Status = 'Activo',
                CC_Tematica__c = tematica.Name,
                CC_MCC_Tematica__c = tematica.Id,
                ContactId = contactoEmple1.Id
            );
            casos.add(caso3);
            
            insert casos;
            
            // Recuperar los casos para asegurar que los campos fórmula se calculen
            casos = [SELECT Id, CC_Matricula_Empleado__c, CC_Idioma__c, CC_MCC_Tematica__c, CC_Tematica__c, 
                     RecordTypeId, Origin, CC_En_Tercer_Nivel__c, CC_Canal_Procedencia__c, CaseNumber 
                     FROM Case WHERE Id IN :casos];

            System.debug('casos: ' + JSON.serializePretty(casos));
            
            // Crear tareas para los casos
            List<Task> tareas = new List<Task>();
            
            // Tarea para caso 1
            Task tarea1 = new Task(
                WhatId = caso1.Id,
                Type = 'Traslado Tercer Nivel',
                Status = 'Completed'
            );
            tareas.add(tarea1);
            
            // Tarea para caso 2
            Task tarea2 = new Task(
                WhatId = caso2.Id,
                Type = 'Llamada transferida',
                Status = 'Completed'
            );
            tareas.add(tarea2);
            
            // Tarea para caso 3
            Task tarea3 = new Task(
                WhatId = caso3.Id,
                Type = 'Traslado colaborador',
                Status = 'Completed'
            );
            tareas.add(tarea3);
            
            insert tareas;

            LiveChatVisitor chatVisitor = new LiveChatVisitor();
            insert chatVisitor;
            
            // Crear LiveChatTranscript para caso 2
            LiveChatTranscript chat = new LiveChatTranscript(
                CaseId = caso2.Id,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('LiveChatTranscript', 'CC_Empleados'),
                LiveChatVisitorId = chatVisitor.Id,
                CC_Cerrado_TimeOut__c = false
            );
            insert chat;
            
            // Llamar al método a probar
            Map<Id, String> urlsEncuestas = CC_MetodosUtiles.generarURLsLimeSurvey(casos);
            
            // Verificar resultados
            System.assertNotEquals(null, urlsEncuestas, 'El mapa de URLs no debe ser nulo');
            
        }
        Test.stopTest();
    }

    @isTest
    static void getValoresCSTest() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            CC_Settings__c mcs = new CC_Settings__c();
            mcs.Name = 'test';
            mcs.CC_Configuracion_1__c = 'test';
            insert mcs;

            List<String> valores = CC_MetodosUtiles.getValoresCS('test');
            System.assertNotEquals(null, valores, 'No debe devolver null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testInicializarCuerpoCorreo() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            
            Case testCase = new Case(
                Subject='Test Case',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                Status = 'Activo',
                CC_Referencia_Correo_Saliente__c = '123456789'
            );
            insert testCase;

                        //Plantilla cuerpo - Buscar las carpetas específicas usando consultas anidadas
            List<Folder> operativasFolders = [SELECT Id FROM Folder WHERE Name = 'Operativas' AND ParentId = null LIMIT 1];
            
            if (!operativasFolders.isEmpty()) {
                Id idFolderOperativas = operativasFolders[0].Id;
                
                // Consulta anidada para obtener todas las carpetas necesarias en una sola consulta
                List<Folder> subFolders = [
                    SELECT Id, Name, ParentId 
                    FROM Folder 
                    WHERE ParentId = :idFolderOperativas 
                    AND Name IN ('Trasladar a colaborador', 'Solicitud de información', 'Responder a cliente Accionista')
                ];
                
                Map<String, Id> folderMap = new Map<String, Id>();
                for (Folder folder : subFolders) {
                    folderMap.put(folder.Name, folder.Id);
                }
                
                // Buscar carpetas de idioma para las rutas específicas
                Set<Id> parentFoldersForLanguage = new Set<Id>();
                if (folderMap.containsKey('Trasladar a colaborador')) {
                    parentFoldersForLanguage.add(folderMap.get('Trasladar a colaborador'));
                }
                if (folderMap.containsKey('Solicitud de información')) {
                    parentFoldersForLanguage.add(folderMap.get('Solicitud de información'));
                }
                if (folderMap.containsKey('Responder a cliente Accionista')) {
                    parentFoldersForLanguage.add(folderMap.get('Responder a cliente Accionista'));
                }
                
                // Consulta anidada para obtener carpetas de idioma
                List<Folder> languageFolders = [
                    SELECT Id, Name, ParentId 
                    FROM Folder 
                    WHERE ParentId IN :parentFoldersForLanguage
                    AND Name = 'Castellano'
                ];
                
                Map<String, Id> languageFolderMap = new Map<String, Id>();
                for (Folder folder : languageFolders) {
                    languageFolderMap.put(folder.ParentId + '_Castellano', folder.Id);
                }
                
                // Buscar carpetas de nivel inferior (Formal/Informal)
                Set<Id> parentFoldersForSubLevel = new Set<Id>();
                for (Id languageFolderId : languageFolderMap.values()) {
                    parentFoldersForSubLevel.add(languageFolderId);
                }
                
                List<Folder> subLevelFolders = [
                    SELECT Id, Name, ParentId 
                    FROM Folder 
                    WHERE ParentId IN :parentFoldersForSubLevel
                    AND Name IN ('Formal', 'Informal')
                ];
                
                Map<String, Id> subLevelFolderMap = new Map<String, Id>();
                for (Folder folder : subLevelFolders) {
                    subLevelFolderMap.put(folder.ParentId + '_' + folder.Name, folder.Id);
                }
                
                // Construir el conjunto de carpetas para buscar plantillas
                Set<Id> carpetasParaBuscar = new Set<Id>{idFolderOperativas};
                
                // Agregar carpetas de las rutas específicas:
                // 1. Operativas > Trasladar a colaborador > Castellano
                if (folderMap.containsKey('Trasladar a colaborador') && 
                    languageFolderMap.containsKey(folderMap.get('Trasladar a colaborador') + '_Castellano')) {
                    carpetasParaBuscar.add(languageFolderMap.get(folderMap.get('Trasladar a colaborador') + '_Castellano'));
                }
                
                // 2. Operativas > Solicitud de información > Castellano > Formal
                if (folderMap.containsKey('Solicitud de información') && 
                    languageFolderMap.containsKey(folderMap.get('Solicitud de información') + '_Castellano')) {
                    Id castellanoSolicitudId = languageFolderMap.get(folderMap.get('Solicitud de información') + '_Castellano');
                    carpetasParaBuscar.add(castellanoSolicitudId);
                    
                    if (subLevelFolderMap.containsKey(castellanoSolicitudId + '_Formal')) {
                        carpetasParaBuscar.add(subLevelFolderMap.get(castellanoSolicitudId + '_Formal'));
                    }
                }
                
                // 3. Operativas > Responder Cliente > Castellano > Informal
                if (folderMap.containsKey('Responder a cliente Accionista') && 
                    languageFolderMap.containsKey(folderMap.get('Responder a cliente Accionista') + '_Castellano')) {
                    Id castellanoResponderId = languageFolderMap.get(folderMap.get('Responder a cliente Accionista') + '_Castellano');
                    carpetasParaBuscar.add(castellanoResponderId);
                    
                    if (subLevelFolderMap.containsKey(castellanoResponderId + '_Informal')) {
                        carpetasParaBuscar.add(subLevelFolderMap.get(castellanoResponderId + '_Informal'));
                    }
                }
                
                // Crear mapas para identificar qué carpeta corresponde a cada operativa
                Map<Id, String> carpetaToOperativaMap = new Map<Id, String>();
                
                // Mapear carpetas de Castellano a sus operativas correspondientes
                if (folderMap.containsKey('Trasladar a colaborador') && 
                    languageFolderMap.containsKey(folderMap.get('Trasladar a colaborador') + '_Castellano')) {
                    carpetaToOperativaMap.put(languageFolderMap.get(folderMap.get('Trasladar a colaborador') + '_Castellano'), 'Trasladar a colaborador');
                }
                
                if (folderMap.containsKey('Solicitud de información') && 
                    languageFolderMap.containsKey(folderMap.get('Solicitud de información') + '_Castellano')) {
                    Id carpetaCastellanoSolicitud = languageFolderMap.get(folderMap.get('Solicitud de información') + '_Castellano');
                    carpetaToOperativaMap.put(carpetaCastellanoSolicitud, 'Solicitud de información');
                    
                    // Mapear también la carpeta Formal si existe
                    if (subLevelFolderMap.containsKey(carpetaCastellanoSolicitud + '_Formal')) {
                        carpetaToOperativaMap.put(subLevelFolderMap.get(carpetaCastellanoSolicitud + '_Formal'), 'Solicitud de información');
                    }
                }
                
                if (folderMap.containsKey('Responder a cliente Accionista') && 
                    languageFolderMap.containsKey(folderMap.get('Responder a cliente Accionista') + '_Castellano')) {
                    Id carpetaCastellanoResponder = languageFolderMap.get(folderMap.get('Responder a cliente Accionista') + '_Castellano');
                    carpetaToOperativaMap.put(carpetaCastellanoResponder, 'Responder a cliente Accionista');
                    
                    // Mapear también la carpeta Informal si existe
                    if (subLevelFolderMap.containsKey(carpetaCastellanoResponder + '_Informal')) {
                        carpetaToOperativaMap.put(subLevelFolderMap.get(carpetaCastellanoResponder + '_Informal'), 'Responder a cliente Accionista');
                    }
                }
                
                // Buscar TODAS las plantillas existentes en las carpetas específicas
                List<EmailTemplate> existingTemplates = [
                    SELECT Id, Name, DeveloperName, Subject, HtmlValue, FolderId, Folder.Name, Folder.ParentId
                    FROM EmailTemplate 
                    WHERE FolderId IN :carpetasParaBuscar 
                    AND IsActive = true 
                    ORDER BY Name
                ];
                
                if (!existingTemplates.isEmpty()) {
                    // Agrupar plantillas por operativa
                    Map<String, EmailTemplate> plantillasPorOperativa = new Map<String, EmailTemplate>();
                    
                    for (EmailTemplate template : existingTemplates) {
                        String operativa = '';
                        
                        // Determinar la operativa basándose en la carpeta donde está la plantilla
                        if (carpetaToOperativaMap.containsKey(template.FolderId)) {
                            operativa = carpetaToOperativaMap.get(template.FolderId);
                        }
                        
                        // Solo agregar si no tenemos ya una plantilla de esta operativa
                        if (String.isNotBlank(operativa) && !plantillasPorOperativa.containsKey(operativa)) {
                            plantillasPorOperativa.put(operativa, template);
                        }
                    }
                    
                    // Procesar una plantilla de cada operativa
                        EmailTemplate testTemplateTrasladar = plantillasPorOperativa.get('Trasladar a colaborador');
                        EmailTemplate testTemplateSolicitud = plantillasPorOperativa.get('Solicitud de información');
                        EmailTemplate testTemplateResponder = plantillasPorOperativa.get('Responder a cliente Accionista');
                        
                        Map<String, String> resultTrasladar = CC_MetodosUtiles.inicializarCuerpoCorreo(testTemplateTrasladar, testCase);
                        Map<String, String> resultSolicitud = CC_MetodosUtiles.inicializarCuerpoCorreo(testTemplateSolicitud, testCase);
                        Map<String, String> resultResponder = CC_MetodosUtiles.inicializarCuerpoCorreo(testTemplateResponder, testCase);
                        
                        // Verify the result contains expected keys
                        System.assertNotEquals(null, resultTrasladar, 'Result should not be null for Trasladar a colaborador');
                        System.assert(resultTrasladar.containsKey('operativa'), 'Result should contain operativa key for Trasladar a colaborador');
                        System.assert(resultTrasladar.containsKey('idioma'), 'Result should contain idioma key for Trasladar a colaborador');
                        System.assert(resultTrasladar.containsKey('tratamiento'), 'Result should contain tratamiento key for Trasladar a colaborador');
                    
                } else {
                    System.debug('No se encontraron plantillas en las carpetas especificadas');
                    System.debug('Carpetas donde se buscó: ' + carpetasParaBuscar);
                }
            } else {
                System.debug('No se encontró la carpeta Operativas');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void subListaTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Test.startTest();
            List<Object> listaOriginal = new List<Object>{'a', 'b', 'c', 'd', 'e', 'f'};
            List<Object> sublista = CC_MetodosUtiles.subLista(listaOriginal, 1, 3);
            System.assertEquals(3, sublista.size(), 'Debe tener 3 elementos');
            System.assertEquals('b', sublista[0], 'El primer elemento debe ser b');
            Test.stopTest();
        }
    }

    @isTest
    static void fechaLimiteFinSemanaFestivosTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Test.startTest();
                DateTime fecha = CBK_UtilsDate.todayDT();
                DateTime fechaLimite = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('123', fecha);
                System.assertNotEquals(null, fechaLimite);
            Test.stopTest();
        }
    }

    @isTest
    static void sacarFestivosPorMesTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Test.startTest();
                Map<Integer, List<Integer>> festivos = CC_MetodosUtiles.sacarFestivosPorMes();
                System.assertNotEquals(null, festivos);
            Test.stopTest();
        }
    }

    @isTest
    public static void testHorarioDiaTurno() {
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            // Crea el mapa de horarios de prueba
            Map<String, List<Time>> horario = new Map<String, List<Time>>{
                'L-V' => new List<Time>{Time.newInstance(9, 0, 0, 0), Time.newInstance(18, 0, 0, 0)}
            };

            // Prueba para el caso de día de la semana 5 y entrada al trabajo
            Time horarioEntrada = CC_MetodosUtiles.horarioDiaTurno(horario, '5', 'Entrada');
            System.assertEquals(Time.newInstance(9, 0, 0, 0), horarioEntrada);

            // Prueba para el caso de día de la semana 5 y salida del trabajo
            Time horarioSalida = CC_MetodosUtiles.horarioDiaTurno(horario, '5', 'Salida');
            System.assertEquals(Time.newInstance(18, 0, 0, 0), horarioSalida);

            // Prueba para el caso de día de la semana 3 y entrada al trabajo
            horarioEntrada = CC_MetodosUtiles.horarioDiaTurno(horario, '3', 'Entrada');
            System.assertEquals(Time.newInstance(9, 0, 0, 0), horarioEntrada);

            // Prueba para el caso de día de la semana 3 y salida del trabajo
            horarioSalida = CC_MetodosUtiles.horarioDiaTurno(horario, '3', 'Salida');
            System.assertEquals(Time.newInstance(18, 0, 0, 0), horarioSalida);
        }
    }
    
    
    @IsTest
    public static void restarHorasTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Time t1 = Time.newInstance(10, 0, 0, 0);
            Time t2 = Time.newInstance(8, 30, 0, 0);

            Double resultadoEsperado = 1.5;
            Double resultadoReal = CC_MetodosUtiles.restarHoras(t1, t2);

            System.assertEquals(resultadoEsperado, resultadoReal);
        }
    }

    
    @IsTest
    public static void restarHorasTest2() {
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            DateTime t1 = DateTime.newInstance(2025, 7, 28, 10, 0, 0);
            DateTime t2 = DateTime.newInstance(2025, 7, 28, 8, 30, 0);

            Double resultadoEsperado = 1.5;
            Double resultadoReal = CC_MetodosUtiles.restarHoras(t1, t2);

            System.assertEquals(resultadoEsperado, resultadoReal);
        }
    }

    @isTest
    static void horariosPorCanalProcedenciaTest() {
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Map<String, Map<String, List<Time>>> horarios = CC_MetodosUtiles.horariosPorCanalProcedencia();
            System.assertNotEquals(null, horarios);
        }
    }
    
    
}