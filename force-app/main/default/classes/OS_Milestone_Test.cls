@isTest 
public with sharing class OS_Milestone_Test {

    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
        User usuarioAdmin= OS_Usuarios.usuarioAdmin();

        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdCausa = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica COPS';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
        mccTematica.OS_Horario__c = [SELECT Id FROM BusinessHours WHERE Name = 'CCI HOLABANK'].Id;
        mccTematica.OS_Horas_SLA__c = '48' ;
        mccTematica.OS_Departamento__c = 'HOLABANK';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto COPS';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001';
        insert mccProducto; 
        
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo COPS';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CBK_Traslado_Remitido__c = 'Remitido';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert mccMotivo;

       	CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa COPS';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Tematica__c = mccTematica.Id;
        mccCausa.CC_Codigo_Externo__c = 'CAP-000001';
        mccCausa.OS_Horas_SLA__c = '48';
        insert mccCausa;

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Tematica COPS2';
        mccTematica2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TEC-000002';
        mccTematica2.OS_Horario__c = [SELECT Id FROM BusinessHours WHERE Name = 'EFECTIVO'].Id;
        mccTematica2.OS_Horas_SLA__c = '24' ;
        mccTematica2.OS_Departamento__c = 'EFECTIVO';
        insert mccTematica2;
        
        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Producto COPS2';
        mccProducto2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PRC-000002';
        insert mccProducto2; 
        
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Motivo COPS2';
        mccMotivo2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CBK_Traslado_Remitido__c = 'Remitido';
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MOC-000002';
        insert mccMotivo2;

       	CC_MCC__c mccCausa2 = new CC_MCC__c();
        mccCausa2.Name = 'Causa COPS2';
        mccCausa2.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        mccCausa2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa2.RecordTypeId = recordTypeIdCausa;
        mccCausa2.CC_Motivo__c = mccMotivo2.Id;
        mccCausa2.CC_Tematica__c = mccTematica2.Id;
        mccCausa2.CC_Codigo_Externo__c = 'CAP-000002';
        mccCausa2.OS_Horas_SLA__c = '24';
        insert mccCausa2;
    }    
    
    @isTest 
    public static void testMilestoneTimeCalculatorAntesUAI() {       
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];
        
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'cops'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Toma de propiedad caso COPS' LIMIT 1];      

        //CASO UAI
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        OS_Correo__mdt correoDependencia = [SELECT OS_Cola_Procedencia__c, OS_Canal_Procedencia__c FROM OS_Correo__mdt WHERE OS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1];
        Group colaCanalProcedencia = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = :correoDependencia.OS_Cola_Procedencia__c LIMIT 1];
        caso.OwnerId = colaCanalProcedencia.Id;
        caso.EntitlementId = e.Id;
        insert caso;
        
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 12, 0, 0);
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);  
        
        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();

            if(diaSemana == 'Sat' || diaSemana == 'Sun') {
                System.assertEquals(240, minutosRestantes, 'Minutos restantes.'); 
            }
            else{
                System.assertEquals(360, minutosRestantes, 'Minutos restantes.'); 
            }
        }
    }
    
    
    @isTest 
    public static void testMilestoneTimeCalculatorDespuesUAI() {        
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];
       
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'cops'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Toma de propiedad caso COPS' LIMIT 1];   

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c ='Buzón Comercio Exterior';
        OS_Correo__mdt correoDependencia = [SELECT OS_Cola_Procedencia__c, OS_Canal_Procedencia__c FROM OS_Correo__mdt WHERE OS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1];
        Group colaCanalProcedencia = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = :correoDependencia.OS_Cola_Procedencia__c LIMIT 1];
        caso.OwnerId = colaCanalProcedencia.Id;
        insert caso;
        
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 14, 0, 0);
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();
            
            if(diaSemana == 'Sat' || diaSemana == 'Sun'){
                System.assertEquals(240, minutosRestantes, 'Minutos restantes.');
            }
            else{
                System.assertEquals(480, minutosRestantes, 'Minutos restantes.');
            }
        }
    }

    @isTest 
    public static void testMilestoneTimeCalculatorBOS() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];
		
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS - BOS';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS - BOS' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Business Hours BOS'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;
        

        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Toma de propiedad caso COPS' LIMIT 1];      

        //CASO BOS
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.EntitlementId = e.Id;
        insert caso;
        
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 12, 0, 0);
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);      

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();

            if(diaSemana == 'Sat' || diaSemana == 'Sun'){
                System.assertEquals(300, minutosRestantes, 'Minutos restantes.');
            }
            else{
                System.assertEquals(360, minutosRestantes, 'Minutos restantes.');
            }
        }
    }

    @isTest 
    public static void testMilestoneTimeCalculatorBOSDespues() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];
       
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS - BOS';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS - BOS' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Business Hours BOS'].Id;
        e.StartDate = CBK_UtilsDate.todayDT();
        e.EndDate = CBK_UtilsDate.todayDT();
        insert e;
       
        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Toma de propiedad caso COPS' LIMIT 1];      

        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 14, 0, 0);
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        //CASO BOS
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.EntitlementId = e.Id;
        insert caso;
       
        
        Test.setCreatedDate(caso.Id, fechaEjecucion);      

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();

            if(diaSemana == 'Sat' || diaSemana == 'Sun'){
                System.assertEquals(300, minutosRestantes, 'Minutos restantes.');
            }
            else{
                System.assertEquals(540, minutosRestantes, 'Minutos restantes.');
            }
        }
    }

    @isTest 
    public static void testMilestoneTimeCalculatorGOC() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS - GOC';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS - GOC' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Business Hours GOC'].Id;
        e.StartDate = Date.today();
        e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Toma de propiedad caso COPS' LIMIT 1];      

        //CASO BOS
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        OS_Correo__mdt correoDependencia = [SELECT OS_Cola_Procedencia__c, OS_Canal_Procedencia__c FROM OS_Correo__mdt WHERE OS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1];
        Group colaCanalProcedencia = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = :correoDependencia.OS_Cola_Procedencia__c LIMIT 1];
        caso.OwnerId = colaCanalProcedencia.Id;
        caso.EntitlementId = e.Id;
        insert caso;
       
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 12, 0, 0);
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);      

        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);

            Test.stopTest();

            if(diaSemana == 'Sat' || diaSemana == 'Sun'){
                System.assertEquals(300, minutosRestantes, 'Minutos restantes.');
            }
            else{
                System.assertEquals(360, minutosRestantes, 'Minutos restantes.');
            }
        }
    }

    @isTest 
    public static void testMilestoneTimeCalculatorGOCDespues() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];
        
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 14, 0, 0);
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS - GOC';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS - GOC' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Business Hours GOC'].Id;
        e.StartDate = Date.today();
        e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Toma de propiedad caso COPS' LIMIT 1];      
 
        //CASO BOS
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Contact Center International';
        OS_Correo__mdt correoDependencia = [SELECT OS_Cola_Procedencia__c, OS_Canal_Procedencia__c FROM OS_Correo__mdt WHERE OS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1];
        Group colaCanalProcedencia = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = :correoDependencia.OS_Cola_Procedencia__c LIMIT 1];
        caso.OwnerId = colaCanalProcedencia.Id;
        caso.EntitlementId = e.Id;
        insert caso;
        
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);      
 
        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();
    
            if(diaSemana == 'Sat' || diaSemana == 'Sun'){
                System.assertEquals(300, minutosRestantes, 'Minutos restantes.');
            }
            else{
                System.assertEquals(540, minutosRestantes, 'Minutos restantes.');
            }
        }
    }

    @isTest 
    public static void testMilestoneTimeCalculatorHolabank() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];

		Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;

        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'CCI HOLABANK'].Id;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS - CCI HOLABANK' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = businessHoursId;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Resolución de caso COPS' LIMIT 1];
        
           
        
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Cerrado';
        caso.CC_MCC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica COPS'].Id;
        caso.CC_MCC_Motivo__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Motivo COPS'].Id;
        caso.CC_MCC_ProdServ__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto COPS'].Id;
        caso.CC_MCC_Causa__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Causa COPS'].Id;
        caso.EntitlementId = e.Id;
        insert caso;
        
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 14, 0, 0);
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);
        
        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();

            System.assertEquals(720, minutosRestantes, 'Minutos restantes.');
        }
    }

    @isTest 
    public static void testMilestoneTimeCalculatorEfectivo() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];
		Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;
                
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'EFECTIVO'].Id;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement COPS - EFECTIVO';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS - EFECTIVO' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = businessHoursId;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Resolución de caso COPS' LIMIT 1];             
        
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Efectivo COPS';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Cerrado';
        caso.CC_MCC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica COPS2'].Id;
        caso.CC_MCC_Motivo__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Motivo COPS2'].Id;
        caso.CC_MCC_ProdServ__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto COPS2'].Id;
        caso.CC_MCC_Causa__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Causa COPS2'].Id;
        caso.EntitlementId = e.Id;
        insert caso;
        
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 2, 2, 14, 0, 0);
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);
              
        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();
                
            System.assertEquals(480, minutosRestantes, 'Minutos restantes.');
        }
    }
    @isTest 
    public static void testMilestoneTimeCalculatorUAFEExpress() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];

		Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        System.runAs ( usuarioAdmin ) {
            insert contacto;
        }

        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Buzón UAFE Express'].Id;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement Process COPS - Buzón UAFE Express';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS - Buzón UAFE Express' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = businessHoursId;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Resolución caso COPS UAFE' LIMIT 1];    
        
        //Lista valores horas SLA
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'COPS: Horas SLA para servicios UAFE';
        lista.CC_Activa__c = true;
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert lista;

        CC_Lista_Valores__c valorSLA = new CC_Lista_Valores__c();
        valorSLA.Name = 'Buzón UAFE Express';
        valorSLA.CC_Activa__c = true;
        valorSLA.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valorSLA.CC_Lista__c = lista.Id;
        valorSLA.CC_Valor__c = '6';
        insert valorSLA;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón UAFE Express';
        caso.CC_Tipo_Contacto__c = 'Buzón de Calidad';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Activo';
        caso.Status = 'Cerrado';
        caso.EntitlementId = e.Id;
        insert caso;
        
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 12, 0, 0);
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);
                
        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();

            System.assertEquals(360, minutosRestantes, 'Minutos restantes.');
        }
    }
    @isTest 
    public static void testMilestoneTimeCalculatorColaTelefonia() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Email = 'usuario_test@test.com' LIMIT 1];

        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024, 3, 5, 14, 0, 0);
		Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        insert contacto;
        
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Buzón UAFE Express'].Id;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement Process COPS - Buzón UAFE Express';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS - Buzón UAFE Express' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = businessHoursId;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> milestone = [SELECT Id, name FROM MilestoneType WHERE Name = 'Resolución caso COPS UAFE' LIMIT 1];    
        
        //Lista valores horas SLA

        List<CC_Lista_Valores__c> listasInsert = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'COPS: Horas SLA para servicios UAFE';
        lista.CC_Activa__c = true;
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listasInsert.add(lista);
        CC_Lista_Valores__c listaProcedencias = new CC_Lista_Valores__c();
        listaProcedencias.Name = 'COPS: SLA Relación colas telefonía y canal de procedencia email';
        listaProcedencias.CC_Activa__c = true;
        listaProcedencias.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listasInsert.add(listaProcedencias);
        insert listasInsert;
       
        List<CC_Lista_Valores__c> valoresInsert = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valorSLA = new CC_Lista_Valores__c();
        valorSLA.Name = 'Buzón UAFE Express';
        valorSLA.CC_Activa__c = true;
        valorSLA.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valorSLA.CC_Lista__c = lista.Id;
        valorSLA.CC_Valor__c = '6';
        valoresInsert.add(valorSLA);
        CC_Lista_Valores__c valorProcedencia = new CC_Lista_Valores__c();
        valorProcedencia.Name = 'C12970';
        valorProcedencia.CC_Activa__c = true;
        valorProcedencia.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valorProcedencia.CC_Lista__c = listaProcedencias.Id;
        valorProcedencia.CC_Valor__c = 'Buzón UAFE Express';
        valoresInsert.add(valorProcedencia);
        insert valoresInsert;

        //Caso teléfono
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
		caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Teléfono UAFE';
        caso.OS_Cola_Telefonia__c = 'C12970';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.Status = 'Activo';
        caso.Status = 'Cerrado';
        caso.EntitlementId = e.Id;
        insert caso;
        
        Datetime fechaEjecucion = CBK_UtilsDate.nowDT();
        String diaSemana = fechaEjecucion.format('E');
        Test.setCreatedDate(caso.Id, fechaEjecucion);
             
        System.runAs (usuarioAdmin) {
            Test.startTest();
            caso = [SELECT Id, CreatedDate FROM Case WHERE Id = :caso.Id];
            OS_Milestone milestonesCops = new OS_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, milestone[0].Id);
            Test.stopTest();
            
            System.assertEquals(360, minutosRestantes, 'Minutos restantes.');  
        } 
    }
}