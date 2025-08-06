@isTest
private class CC_Calculo_KPI_Tareas_Test {

    @TestSetup
    static void setup() {
        
        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');

        System.runAs(admin){

            Id recordTypeIdLOV = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            Id recordTypeIdLOVValue = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');

            List<CC_Lista_Valores__c> listValores = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c(
                Name = 'Ámbitos cálculo KPI Derivar',
                recordTypeId = recordTypeIdLOV
            );
            CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c(
                Name = 'Ámbitos cálculo KPI Otras Operativas',
                recordTypeId = recordTypeIdLOV
            );
            listValores.add(valor1);
            listValores.add(valor2);

            insert listValores;

            List<CC_Lista_Valores__c> listValoresValue = new List<CC_Lista_Valores__c>();

            CC_Lista_Valores__c valorDocumentacionKPIDerivar = new CC_Lista_Valores__c(
                Name = 'Documentación',
                CC_Lista__c = valor1.Id,
                recordTypeId = recordTypeIdLOVValue,
                CC_Valor__c = 'Solicitud Documentación',
                CC_Valor2__c = 'Documentación',
                CC_Tipo_Tarea__c = 'Solicitud Documentación',
                CC_AmbitoNull__c = false
            );
            listValoresValue.add(valorDocumentacionKPIDerivar);

            CC_Lista_Valores__c valorCSBDKPIDerivar = new CC_Lista_Valores__c(
                Name = 'CSBD No Contratar',
                CC_Lista__c = valor1.Id,
                recordTypeId = recordTypeIdLOVValue,
                CC_Valor__c = 'CSBD',
                CC_Valor2__c = 'CSBD',
                CC_Tipo_Tarea__c = 'CSBD No Contratar',
                CC_AmbitoNull__c = false
            );
            listValoresValue.add(valorCSBDKPIDerivar);

            CC_Lista_Valores__c valorNuloKPIDerivar = new CC_Lista_Valores__c(
                Name = 'Nulo',
                CC_Lista__c = valor1.Id,
                recordTypeId = recordTypeIdLOVValue,
                CC_Valor__c = 'Oficina',
                CC_Valor2__c = 'Oficina',
                CC_Tipo_Tarea__c = 'Oficina',
                CC_AmbitoNull__c = true
            );
            listValoresValue.add(valorNuloKPIDerivar);

            CC_Lista_Valores__c valor3NivelKPIOtrasOperativas = new CC_Lista_Valores__c(
                Name = '3 Nivel',
                CC_Lista__c = valor2.Id,
                recordTypeId = recordTypeIdLOVValue,
                CC_Valor__c = '3 Nivel',
                CC_Valor2__c = '3 Nivel',
                CC_Tipo_Tarea__c = '3 Nivel',
                CC_AmbitoNull__c = false
            );
            listValoresValue.add(valor3NivelKPIOtrasOperativas);

            CC_Lista_Valores__c valorNuloKPIOtrasOperativas = new CC_Lista_Valores__c(
                Name = 'GDPR',
                CC_Lista__c = valor2.Id,
                recordTypeId = recordTypeIdLOVValue,
                CC_Valor__c = 'GDPR',
                CC_Valor2__c = 'GDPR',
                CC_Tipo_Tarea__c = 'GDPR',
                CC_AmbitoNull__c = false
            );
            listValoresValue.add(valorNuloKPIOtrasOperativas);

            insert listValoresValue;

            List<CC_MCC__c> lstMCC = new List<CC_MCC__c>();
            
            CC_MCC__c tematica  = new CC_MCC__c(
                Name = 'Tematica',
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Codigo_Externo__c = 'TE-000001',
                CC_Canal_Operativo__c = 'App BrokerNow',
                recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica')
            );
            insert tematica;
            lstMCC.add(tematica);

            CC_MCC__c producto = new CC_MCC__c(
                Name = 'Producto',
                CC_Detalle__c = 'CaixaBank',
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Tematica__c = tematica.Id,
                CC_Codigo_Externo__c = 'PR-000001',
                recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio')
            );
            insert producto;
            lstMCC.add(producto);

            CC_MCC__c mcc = new CC_MCC__c(
                CC_Producto_Servicio__c = producto.Id,
                Name = 'Test MCC',
                CC_Ambito_Tareas_Caixa__c = 'CSBD no Contratar',
                CC_Ambito_Tareas_Imagin__c = 'Oficina',
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Codigo_Externo__c = 'MO-000001',
                recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo')
            );
            insert mcc;
            lstMCC.add(mcc);

            List<Account> lstAccounts = new List<Account>();
            Account cuenta = new Account(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
                FirstName = 'Cuenta',
                LastName = 'Test',
                CC_Email__c = 'cuenta@test.com',
                PersonMobilePhone = '+34 123456789',
                PersonBirthdate = Date.newInstance(2000, 05, 22),
                CC_NumPerso__c = '206'
            );
            lstAccounts.add(cuenta);
            insert lstAccounts;

            List<Contact> lstContacts = new List<Contact>();
            Contact contacto = new Contact(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
                FirstName = 'Contacto',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto@test.com'
            );
            lstContacts.add(contacto);
            insert lstContacts;
            
            
            // Crear Account Share y Contact Share para el operador
            List<AccountShare> accountShares = new List<AccountShare>();
            List<ContactShare> contactShares = new List<ContactShare>();
            
            // Configurar Account Shares
            for(Account acc : lstAccounts) {
                accountShares.add(new AccountShare(
                    AccountId = acc.Id,
                    UserOrGroupId = operador.Id,
                    AccountAccessLevel = 'Read',
                    OpportunityAccessLevel = 'None',
                    CaseAccessLevel = 'Read',
                    ContactAccessLevel = 'Read'
                ));
            }
            
            // Configurar Contact Shares
            for(Contact con : lstContacts) {
                contactShares.add(new ContactShare(
                    ContactId = con.Id,
                    UserOrGroupId = operador.Id,
                    ContactAccessLevel = 'Read'
                ));
            }
            
            insert accountShares;
            insert contactShares;
            
            List<CC_MCC__Share> mccShares = new List<CC_MCC__Share>();
            for(CC_MCC__c mccMCC : lstMCC) {
                CC_MCC__Share mccShareMCC = new CC_MCC__Share(
                    ParentId = mccMCC.Id,
                    UserOrGroupId = operador.Id,
                        AccessLevel = 'Edit'
                    );
                    mccShares.add(mccShareMCC);
            }
            
            insert mccShares;
        }
    }

    //LISTA OTRAS OPERATIVAS
    @isTest
    static void rellenarKPITest() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            //Solicitud Documentación y 3 Nivel -> Resultado: 3 Nivel
            Case testCase = new Case(
                Subject='Test Case False',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                Status = 'Activo',
                CC_MCC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica'].Id,
                CC_MCC_ProdServ__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto'].Id,
                CC_MCC_Motivo__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Test MCC'].Id,
                AccountId = [SELECT Id FROM Account WHERE FirstName = 'Cuenta'].Id,
                ContactId = [SELECT Id FROM Contact LIMIT 1].Id,
                SAC_EnvioParcial__c = false
            );
            insert testCase;

            List<Task> listTask = new List<Task>();
            //TAREAS CASO 1
            Task testTask4 = new Task(
                Subject='3 Nivel',
                Type = '3 Nivel',
                WhatId = testCase.Id,
                Status = 'In Progress',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')
            );
            listTask.add(testTask4);
            insert listTask;

            CC_Calculo_KPI_Tareas.rellenarKPI(listTask);
            List<Case> listCase = [SELECT Id, Subject, CC_Motivo_Derivacion__c FROM Case WHERE RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente')];
            Assert.areEqual('3 Nivel', listCase[0].CC_Motivo_Derivacion__c, 'El motivo de derivación no es correcto (3 Nivel)');
        }
        Test.stopTest();
    }

    //LISTA OPERATIVA DERIVAR
    @isTest
    static void rellenarKPITest2() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            //Nulo y CSBD no Contratar -> Resultado: CSBD
            Case testCase2 = new Case(
                Subject='Test Case True',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                Status = 'Activo',
                CC_MCC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica'].Id,
                CC_MCC_ProdServ__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto'].Id,
                CC_MCC_Motivo__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Test MCC'].Id,
                AccountId = [SELECT Id FROM Account WHERE FirstName = 'Cuenta'].Id, 
                ContactId = [SELECT Id FROM Contact LIMIT 1].Id,
                SAC_EnvioParcial__c = true
            );
            insert testCase2;

            List<Task> listTask = new List<Task>();
            //TAREAS CASO 2
            Task testTask2 = new Task(
                Subject='Oficina',
                Type = 'Oficina',
                WhatId = testCase2.Id,
                Status = 'In Progress',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')
            );
            listTask.add(testTask2);    
            insert listTask;


            CC_Calculo_KPI_Tareas.rellenarKPI(listTask);
            List<Case> listCase = [SELECT Id, Subject, CC_Motivo_Derivacion__c FROM Case WHERE RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente')];
            Assert.areEqual('Oficina', listCase[0].CC_Motivo_Derivacion__c, 'El motivo de derivación no es correcto (Oficina)');
        }
        Test.stopTest();
    }   

    @isTest
    static void rellenarKPITest3() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            //Nulo y CSBD no Contratar -> Resultado: CSBD
            Case testCase3 = new Case(
                Subject='Test Case GDPR',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                Status = 'Activo',
                CC_MCC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica'].Id,
                CC_MCC_ProdServ__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto'].Id,
                CC_MCC_Motivo__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Test MCC'].Id,
                AccountId = [SELECT Id FROM Account WHERE FirstName = 'Cuenta'].Id, 
                ContactId = [SELECT Id FROM Contact LIMIT 1].Id,
                SAC_EnvioParcial__c = false
            );
            insert testCase3;

            List<Task> listTask = new List<Task>();
            //TAREAS CASO 3
            Task testTask3 = new Task(
                Subject='GDPR',
                Type = 'GDPR',
                WhatId = testCase3.Id,
                Status = 'In Progress',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')
            );
            listTask.add(testTask3);

            Task testTask6 = new Task(
                Subject='Oficina',
                Type = 'Oficina',
                WhatId = testCase3.Id,
                Status = 'In Progress',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task')
            );
            listTask.add(testTask6);

            insert listTask; 

            CC_Calculo_KPI_Tareas.rellenarKPI(listTask);
            List<Case> listCase = [SELECT Id, Subject, CC_Motivo_Derivacion__c FROM Case WHERE RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente')];
            Assert.areEqual('GDPR', listCase[0].CC_Motivo_Derivacion__c, 'El motivo de derivación no es correcto (GDPR)');
        }
        Test.stopTest();
    } 
}