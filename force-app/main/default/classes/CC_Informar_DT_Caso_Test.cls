@isTest
public class CC_Informar_DT_Caso_Test {
    
    @isTest
    public static void informaDireccionTerritorialTest1N() {
        //Creacion de cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        insert cuenta;
                        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta.Id
        );        
        insert cuenta1;    
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
    @isTest
    public static void informaDireccionTerritorialTest2N() {
        //Creacion de cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        insert cuenta;
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta.Id
        );        
        insert cuenta2;
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        insert cuenta1;    
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta2.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
    @isTest
    public static void informaDireccionTerritorialTest3N() {
        //Creacion de cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        insert cuenta;
        
        Account cuenta3 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 3',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta.Id
        );        
        insert cuenta3;        
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta3.Id
        );        
        insert cuenta2;
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        insert cuenta1;    
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta2.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
    @isTest
    public static void informaDireccionTerritorialTest4N() {
        //Creacion de cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        insert cuenta;
        
        Account cuenta4 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 4',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta.Id
        );        
        insert cuenta4; 
        
        Account cuenta3 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 3',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta4.Id
        );        
        insert cuenta3;        
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta3.Id
        );        
        insert cuenta2;
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        insert cuenta1;    
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta2.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
    @isTest
    public static void informaDireccionTerritorialTest5N() {
        //Creacion de cuenta
        List<Account> ListAcc = new List<Account>();
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        ListAcc.add(cuenta);
        
        Account cuenta5 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 5',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DC',
            ParentId = cuenta.Id
        );        
        ListAcc.add(cuenta5); 
        
        Account cuenta4 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 4',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'GC',
            ParentId = cuenta5.Id
        );        
        ListAcc.add(cuenta4); 
        
        Account cuenta3 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 3',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta4.Id
        );        
        ListAcc.add(cuenta3);     
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta3.Id
        );        
        ListAcc.add(cuenta2); 
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        ListAcc.add(cuenta1);   
        insert ListAcc;
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta2.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
    @isTest
    public static void informaDireccionTerritorialTest6N() {
        //Creacion de cuenta
        List<Account> ListAcc = new List<Account>();
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        ListAcc.add(cuenta);   
        
        Account cuenta6 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 6',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'SC',
            ParentId = cuenta.Id
        );        
        ListAcc.add(cuenta6);   
        
        Account cuenta5 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 5',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DC',
            ParentId = cuenta6.Id
        );        
        ListAcc.add(cuenta5);   
        
        Account cuenta4 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 4',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'GC',
            ParentId = cuenta5.Id
        );        
        ListAcc.add(cuenta4);   
        
        Account cuenta3 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 3',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta4.Id
        );        
        ListAcc.add(cuenta3);           
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta3.Id
        );        
        ListAcc.add(cuenta2);   
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        ListAcc.add(cuenta1);       
        insert ListAcc;
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta2.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
    @isTest
    public static void informaDireccionTerritorialTest7N() {
        //Creacion de cuenta
        List<Account> ListAcc = new List<Account>();
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        //insert cuenta;
        ListAcc.add(cuenta);
        
        Account cuenta7 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 7',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'SC',
            ParentId = cuenta.Id
        );        
        //insert cuenta7;
        ListAcc.add(cuenta7);
        
        Account cuenta6 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 6',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'SC',
            ParentId = cuenta7.Id
        );        
        //insert cuenta6;
        ListAcc.add(cuenta6);
        
        Account cuenta5 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 5',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DC',
            ParentId = cuenta6.Id
        );        
        //insert cuenta5;
        ListAcc.add(cuenta5);
        
        Account cuenta4 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 4',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'GC',
            ParentId = cuenta5.Id
        );        
        //insert cuenta4;
        ListAcc.add(cuenta4);
        
        Account cuenta3 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 3',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta4.Id
        );        
        //insert cuenta3;
        ListAcc.add(cuenta3);
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta3.Id
        );        
        //insert cuenta2;
        ListAcc.add(cuenta2);
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        //insert cuenta1;
        ListAcc.add(cuenta1);
        insert ListAcc;
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta2.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
        
    @isTest
    public static void informaDireccionTerritorialTest55N() {
        //Creacion de cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        insert cuenta;
        
        Account cuenta5 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 5',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta.Id
        );        
        insert cuenta5; 
        
        Account cuenta4 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 4',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta5.Id
        );        
        insert cuenta4; 
        
        Account cuenta3 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 3',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta4.Id
        );        
        insert cuenta3;        
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta3.Id
        );        
        insert cuenta2;
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        insert cuenta1;    
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta1.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
    @isTest
    public static void informaDireccionTerritorialTest66N() {
        //Creacion de cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        insert cuenta;
        
        Account cuenta6 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 6',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta.Id
        );        
        insert cuenta6; 
        
        Account cuenta5 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 5',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta6.Id
        );        
        insert cuenta5; 
        
        Account cuenta4 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 4',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta5.Id
        );        
        insert cuenta4; 
        
        Account cuenta3 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 3',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta4.Id
        );        
        insert cuenta3;        
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta3.Id
        );        
        insert cuenta2;
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        insert cuenta1;    
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta1.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
    @isTest
    public static void informaDireccionTerritorialTest44N() {
        //Creacion de cuenta
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        insert cuenta;
        
        Account cuenta4 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 4',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta.Id
        );        
        insert cuenta4; 
        
        Account cuenta3 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 3',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta4.Id
        );        
        insert cuenta3;        
        
        Account cuenta2 = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 2',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'OF',
            ParentId = cuenta3.Id
        );        
        insert cuenta2;
        
        Account cuenta1 = new Account(
            RecordTypeId = cuentaRecordTypeId,
            Name = 'Maria Antonia',
            CC_Email__c = 'test@test.com',
            ParentId = cuenta2.Id
        );        
        insert cuenta1;    
        
        Id usuarioId = cuenta1.Id;
                
        //Creamos un contacto
        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = recordTypeCliente;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = usuarioId;
        insert cnt1;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
        c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
        c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.ContactId = cnt1.Id;
        c1.AccountId = usuarioId;
        c1.CC_Oficina_Afectada_Lookup__c = cuenta1.Id;
        insert c1;
        
        List<Id> listCaseId = new List<Id>();
        listCaseId.add(c1.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        //CC_Comunicaciones_Informativas_Metodos.actualizarEstadisticasComunicacionInformativa(liveChat.Id);
        CC_Informar_DT_Caso.informaDireccionTerritorial(listCaseId);

        Test.stopTest();
    }
    
 
}