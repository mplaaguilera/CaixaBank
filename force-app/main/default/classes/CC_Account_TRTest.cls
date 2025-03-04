@isTest
public with sharing class CC_Account_TRTest {
    
    @TestSetup
    static void makeData(){
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profile3NId = [SELECT Id FROM Profile WHERE Name = 'CC_Tercer_Nivel_CBKNow_MVP2'].Id;
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileIdAdmin;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211053';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);
       
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
         insert userList;
    }
    
    
    
    public static testMethod void aftertInsertCentroRegisteredCaracteristica(){
		Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id caracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId();
		
        CC_Caracteristica__c caracteristica =new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Centro_CaixaBank Test',
            RecordTypeId = caracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;
        
        CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Identificador__c = '98789'
        );
        insert detalle;
        
        Account cuenta = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Numero_Oficina__c = '98789'
        );
        insert cuenta;		
        
        List<CC_Caracteristica_Detalle__c> detalleId = [Select Id From CC_Caracteristica_Detalle__c Where CC_Centro_CaixaBank__c = :cuenta.Id]; 

//Comentado por trigger desactivado        
//        System.assertNotEquals(0, detalleId.size());
    }

    public static testMethod void aftertInsertClienteCuentaRegisteredCaracteristica(){
		Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id caracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Cliente_Cuenta').getRecordTypeId();
		
        CC_Caracteristica__c caracteristica =new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Centro_CaixaBank Test',
            RecordTypeId = caracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;
        
        CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Identificador__c = '00000000T'
        );
        insert detalle;
        
        Account cuenta = new Account(
        	RecordTypeId = cuentaRecordTypeId,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Numero_Documento__c = '00000000T'
        );
        insert cuenta;		
        
        List<CC_Caracteristica_Detalle__c> detalleId = [Select Id From CC_Caracteristica_Detalle__c Where CC_Cuenta__c = :cuenta.Id]; 
//Comentado por trigger desactivado        
//        System.assertNotEquals(0, detalleId.size());
    }

    public static testMethod void aftertUpdateCentroNumeroOficina(){
		Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id caracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId();
		
        CC_Caracteristica__c caracteristica =new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Centro_CaixaBank Test',
            RecordTypeId = caracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;
        
        CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Identificador__c = '98789'
        );
        insert detalle;
        
        Account cuenta = new Account(
        	RecordTypeId = centroRecordTypeId,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Numero_Oficina__c = '12321'
        );
        insert cuenta;

        cuenta.CC_Numero_Oficina__c = '98789';
        update cuenta;		
        
        List<CC_Caracteristica_Detalle__c> detalleId = [Select Id From CC_Caracteristica_Detalle__c Where CC_Centro_CaixaBank__c = :cuenta.Id]; 
//Comentado por trigger desactivado        
//       System.assertNotEquals(0, detalleId.size());
    }
    
    
    public static testMethod void afterUpdateClienteConfidencial(){
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();		
        
        User sysAdminUser = [Select id from User where email = 'aalsdna@kfsb.com' limit 1];
        if (sysAdminUser != null) {
            System.runAs(sysAdminUser) {
                
                Account cuenta = new Account(
                    RecordTypeId = cuentaRecordTypeId,
                    FirstName = 'Cuenta',
                    LastName = 'Cliente Confidencial',
                    CC_NumPerso__c = '00000001',
                    CC_Numero_Documento__c = '00000001R'
                );
                insert cuenta;
                
                Test.startTest();
                cuenta.CC_Confidencial__c = true;
                update cuenta;		
                Test.stopTest();
                
                Account cuentaConf = [Select Name From Account Where Id = :cuenta.Id LIMIT 1]; 
                
                System.assertEquals('CONFIDENCIAL', cuentaConf.Name);
            }
        }
    }
    
    public static testMethod void afterUpdateClienteConfidencialNUEVA(){
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();		
        
        User sysAdminUser = [Select id from User where email = 'aalsdna@kfsb.com' limit 1];
        if (sysAdminUser != null) {
            System.runAs(sysAdminUser) {        
                Account cuenta = new Account(
                    RecordTypeId = cuentaRecordTypeId,
                    FirstName = 'Cuenta',
                    LastName = 'Cliente Confidencial',
                    CC_NumPerso__c = '00000002',
                    AV_NumPerso__c = '00000002',
                    CC_Numero_Documento__c = '00000002R'
                );
                insert cuenta;
                Test.startTest();
                cuenta.CC_Confidencial__c = true;
                update cuenta;
                Test.stopTest();
                
                
                Account cuentaConf = [Select Name From Account Where Id = :cuenta.Id LIMIT 1]; 
                
                System.assertNotEquals('CONFIDENCIAL', cuentaConf.Name);
            }
        }
    }
    
    
    
    
    
    
    

    public static testMethod void afterUpdateClienteCuentaNumeroDocumento(){
		Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id caracteristicaRecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Cliente_Cuenta').getRecordTypeId();
		
        CC_Caracteristica__c caracteristica =new CC_Caracteristica__c(
            Name = 'Caracteristica tipo Centro_CaixaBank Test',
            RecordTypeId = caracteristicaRecordTypeId,
            CC_Prioridad__c = '1 - Alta',
            CC_Descripcion__c = 'Prueba'
        );
        insert caracteristica;
        
        CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c(
            CC_Caracteristica__c = caracteristica.Id,
            CC_Identificador__c = '00000000T'
        );
        insert detalle;
        
        Account cuenta = new Account(
        	RecordTypeId = cuentaRecordTypeId,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Numero_Documento__c = '00000001R'
        );
        insert cuenta;

        cuenta.CC_Numero_Documento__c = '00000000T';
        update cuenta;		
        
        List<CC_Caracteristica_Detalle__c> detalleId = [Select Id From CC_Caracteristica_Detalle__c Where CC_Cuenta__c = :cuenta.Id]; 
//Comentado por trigger desactivado        
//      System.assertNotEquals(0, detalleId.size());
    }
    
   /* 
    public static testMethod void beforeDeleteAccount(){

        Id centroCBRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                      .get('CC_CentroCaixaBank').getRecordTypeId();

        Account cuenta = new Account(Name = 'Centro 1', RecordTypeId = centroCBRecordTypeId,CC_Tipo_Centro__c = 'OF');
        insert cuenta;

        List<Account> cuentaId = new List<Account>{cuenta};
        CC_Grupo_Colaborador.tratarGrupo(cuentaId);

        delete cuenta;

        List<CC_Grupo_Colaborador__c> grupos = [Select Id From CC_Grupo_Colaborador__c Where CC_Cuenta__c = :cuenta.Id];

        System.assertEquals(0, grupos.size());
    }
*/
    
    public static testMethod void AccountCaseTelefono(){
        
        // Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        Id recordTypeCuenta = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Account cuenta = new Account();
        cuenta.LastName = 'Prueba';
        cuenta.CC_Numero_Documento__c = '64850344G';
        cuenta.RecordTypeId = recordTypeCuenta;
        cuenta.Phone = '123456789';
        cuenta.PersonMobilePhone = '987654321';
        insert cuenta;
        
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.OS_Account_Phone__c = '000000000';
        caso.OS_Account_Mobile__c = '000000000';
        insert caso;

        Test.startTest();
        cuenta.Phone = '000000042';
        cuenta.PersonMobilePhone = '000000043';
        update cuenta;
        Test.stopTest();

        Case querycaso = [SELECT OS_Account_Phone__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(cuenta.Phone, querycaso.OS_Account_Phone__c);

    }
}