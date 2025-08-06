@isTest
public class CBK_SCH_CSBD_ScheduleTest {
    
    @TestSetup
    public static void datosAltaTest(){
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;
        
        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Hipoteca';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;
        
        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;
        
        User usuario1 = new User();
        usuario1.Alias = 'standt1';
        usuario1.Email = 'standarduser1@testorg.com';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LastName = 'Testing';
        usuario1.LanguageLocaleKey ='en_US';
        usuario1.LocaleSidKey = 'en_US';
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
        usuario1.TimeZoneSidKey = 'America/Los_Angeles';
        usuario1.UserName = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0,8) + '@myorg.com';
        insert usuario1;
        
        User usuario2 = new User();
        usuario2.Alias = 'standt2';
        usuario2.Email = 'standarduser2@testorg.com';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LastName = 'Testing';
        usuario2.LanguageLocaleKey ='en_US';
        usuario2.LocaleSidKey = 'en_US';
        usuario2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
        usuario2.TimeZoneSidKey = 'America/Los_Angeles';
        usuario2.UserName = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0,8) + '@myorg.com';
        insert usuario2;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '46979396X';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;
    }
    
    @isTest
    public static void CBK_SCH_CSBD_SchedulePendienteCita_Test() {
        
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c  FROM Account WHERE Name='test@test.com'];
        
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666666');
        Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
        
        hipoteca.OwnerId = [SELECT Id FROM User WHERE Email = 'standarduser1@testorg.com'].Id;
        update hipoteca;
        
        CSBD_Opportunity.programarCita(hipoteca.Id, false, hipoteca.OwnerId, datetime.now());
        
        List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = [SELECT Id, RecordId__c, Schedule_Time__c, ClassName__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c =: hipoteca.Id];
        System.assert(!pendingProcessInsertList.isEmpty());
        
        test.startTest();
        
        CBK_SCH_CSBD_SchedulePendienteCita implClass = new CBK_SCH_CSBD_SchedulePendienteCita();
        implClass.lstInfoProcess = pendingProcessInsertList;
        System.enqueueJob(implClass);
        
        test.stopTest();

        System.assert([SELECT Id, CSBD_Estado__c FROM Opportunity WHERE Id =: hipoteca.Id].CSBD_Estado__c == 'Activa');        
    }
    
    @isTest
    public static void CBK_SCH_CSBD_ScheduleReclamaCliente_Test(){
        
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c  FROM Account WHERE Name='test@test.com'];
        Contact contacto = [SELECT Id, Email FROM Contact WHERE Email=:'test@test.com'];
        
        
        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
        campos.put('CSBD_Email_Solicitud__c', 'test@test.com');
        campos.put('CSBD_Telefono_Solicitud__c', '666666666');
        campos.put('CSBD_Estado__c', 'Activa');
        Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
        
        hipoteca.OwnerId = [SELECT Id FROM User WHERE Email = 'standarduser1@testorg.com'].Id;
        hipoteca.CSBD_Estado__c = 'Pendiente Cliente';
        hipoteca.CSBD_Contact__c = contacto.Id;
        hipoteca.CSBD_Email_Solicitud__c = contacto.Email;
        
        update hipoteca;
        
        List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c> ();
        Datetime vToday = datetime.now();      
        
        CBK_SCH_PendingProcess__c pendingProcess2 = new CBK_SCH_PendingProcess__c();
        pendingProcess2.RecordId__c = hipoteca.Id;
        pendingProcess2.Param1__c = '1';
        pendingProcess2.Schedule_Time__c = vToday.addDays(- 1);
        pendingProcess2.ClassName__c = 'CBK_SCH_CSBD_ScheduleReclamaCliente';
        pendingProcessInsertList.add(pendingProcess2);
        
        Insert pendingProcessInsertList;
        
        System.debug('hipoteca.CSBD_Estado__c '+hipoteca.CSBD_Estado__c);
        System.debug('hipoteca.CSBD_Contact__c '+hipoteca.CSBD_Contact__c);
        System.debug('hipoteca.CSBD_Email_Solicitud__c '+hipoteca.CSBD_Email_Solicitud__c);
        
        test.startTest();
        
        CBK_SCH_CSBD_ScheduleReclamaCliente implClass = new CBK_SCH_CSBD_ScheduleReclamaCliente();
        implClass.lstInfoProcess = pendingProcessInsertList;
        System.enqueueJob(implClass);
        
        test.stopTest();
        
        
        
    }
}