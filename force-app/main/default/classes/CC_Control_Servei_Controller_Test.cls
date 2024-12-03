@isTest
public with sharing class CC_Control_Servei_Controller_Test {
    @testSetup
    static void makeData() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank_Empleados'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        PermissionSet psOperadorEmpleado = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet psAnalistaEmpleado = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Analista_CCO'];
        PermissionSet supervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        //PermissionSet control = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Control_Servei'];
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> insertpsa = new List<PermissionSetAssignment>();
        
        User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        userList.add(usuarioAdmin);
        
        User operadorEmpleado = new User();        
        operadorEmpleado.profileId = profileId;
        operadorEmpleado.UserRoleId = roleCC;
        operadorEmpleado.FirstName = '';
        operadorEmpleado.AV_ExternalID__c = 'U0124112';
        operadorEmpleado.LastName = 'Operador Empleado';
        operadorEmpleado.Email = 'tuser000@amamamama.com';
        operadorEmpleado.Username = 'tuser000@amamamama.com' + System.currentTimeMillis();
        operadorEmpleado.CompanyName = 'MST';
        operadorEmpleado.Title = 'title';
        operadorEmpleado.Alias = 'alias';
        operadorEmpleado.TimeZoneSidKey = 'Europe/Paris';
        operadorEmpleado.EmailEncodingKey = 'UTF-8';
        operadorEmpleado.LanguageLocaleKey = 'es';
        operadorEmpleado.LocaleSidKey = 'es_ES';        
        userList.add(operadorEmpleado);
        
        insert userList;
        
         PermissionSetAssignment psaEmpleado = new PermissionSetAssignment(AssigneeId = operadorEmpleado.Id, PermissionSetId = psOperadorEmpleado.Id);
            insertpsa.add(psaEmpleado);
            PermissionSetAssignment psaAnalista = new PermissionSetAssignment(AssigneeId = operadorEmpleado.Id, PermissionSetId = psAnalistaEmpleado.Id);
            insertpsa.add(psaAnalista);
        PermissionSetAssignment psSup = new PermissionSetAssignment(AssigneeId = operadorEmpleado.Id, PermissionSetId = supervisor.Id);
            insertpsa.add(psSup);
        //PermissionSetAssignment pscontrol = new PermissionSetAssignment(AssigneeId = operadorEmpleado.Id, PermissionSetId = control.Id);
            //insertpsa.add(pscontrol);
            Database.insert(insertpsa);
        
        System.runAs(usuarioAdmin) {
            String sRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia');
            List<CC_Agrupador__c> listaAgrup = new  List<CC_Agrupador__c>();
            CC_Agrupador__c agrupadorAbierto = new CC_Agrupador__c();
            agrupadorAbierto.RecordTypeId = sRecordType;
            agrupadorAbierto.CC_Titulo__c = 'Agrupador abierto';
            agrupadorAbierto.CC_Descripcion__c = 'Agrupador abierto';
            agrupadorAbierto.CC_Estado__c = 'Activo';
            listaAgrup.add(agrupadorAbierto);

            
            CC_Agrupador__c agrupadorCerrado = new CC_Agrupador__c();
            agrupadorCerrado.RecordTypeId = sRecordType;
            agrupadorCerrado.CC_Titulo__c = 'Agrupador Cerrado';
            agrupadorCerrado.CC_Descripcion__c = 'Agrupador Cerrado';
            agrupadorCerrado.CC_Estado__c = 'Cerrado';
            agrupadorCerrado.CC_Fecha_Cierre__c = DateTime.now().addHours(-2);
            listaAgrup.add(agrupadorCerrado);
            insert listaAgrup;
            
            Contact contactoEmpledo = new Contact();
            contactoEmpledo.LastName = 'Test contacto';
            contactoEmpledo.Email = 'test@test.es';
            contactoEmpledo.RecordtypeId =  CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            insert contactoEmpledo;
            
            //List<ContactShare> totalPermisosContact = new List<ContactShare>();
            ContactShare contactShare = new ContactShare();
            contactShare.ContactId = contactoEmpledo.Id;
            contactShare.UserOrGroupId = operadorEmpleado.Id;
            contactShare.ContactAccessLevel = 'Edit';
            insert contactShare;
            //totalPermisosContact.add(contactShare);
            
            //insert totalPermisosContact;
            
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            List<Case> listaCasos = new List<Case>();
            Case caso = new Case();
            caso.Subject = 'Test Incidencia';
            caso.Origin = 'Email';
            caso.ContactId = contactoEmpledo.Id;
            caso.CC_NotIncidencia__c = '1';
            caso.CC_MailTelfNotif__c = 'test@test.es';
            caso.CC_CanalNotifCli__c = 'Email';
            caso.CC_Agrupador_Id__c = agrupadorAbierto.Id;
            caso.CC_Idioma__c = 'es';
            caso.RecordTypeId = recordTypeCaso;
            listaCasos.add(caso);
            //insert caso;

            //Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
            Case caso2 = new Case();
            caso2.Subject = 'Test Incidencia2';
            caso2.Origin = 'Email';
            caso2.ContactId = contactoEmpledo.Id;
            caso2.CC_NotIncidencia__c = '1';
            caso2.CC_MailTelfNotif__c = 'test@test.es';
            caso2.CC_CanalNotifCli__c = 'Email';
            caso2.CC_Agrupador_Id__c = agrupadorAbierto.Id;
            caso2.CC_Idioma__c = 'es';
            caso2.RecordTypeId = recordTypeCaso;
            listaCasos.add(caso2);
            insert listaCasos;

            // Simular que el caso fue creado hace 60 minutos
            DateTime createdDate = DateTime.now().addMinutes(-60);
            Test.setCreatedDate(caso2.Id, createdDate);

            Case caso3 = new Case();
            caso3.Subject = 'Test Incidencia3';
            caso3.Origin = 'Email';
            caso3.ContactId = contactoEmpledo.Id;
            caso3.CC_NotIncidencia__c = '1';
            caso3.CC_MailTelfNotif__c = 'test@test.es';
            caso3.CC_CanalNotifCli__c = 'Email';
            caso3.CC_Agrupador_Id__c = agrupadorAbierto.Id;
            caso3.CC_Idioma__c = 'es';
            caso3.RecordTypeId = recordTypeCaso;
            insert caso3;

            // Simular que el caso fue creado hace 60 minutos
            DateTime createdDate2 = DateTime.now().addMinutes(-120);
            Test.setCreatedDate(caso3.Id, createdDate2);

            EmailTemplate plantilla = new EmailTemplate();
            plantilla.name = 'plantilla1';
            plantilla.FolderId = usuarioAdmin.Id;
            plantilla.DeveloperName = 'Plantilla_incidencia_masiva_comunicaci_n_informativa_AFECTADOS_1715861371451';
            plantilla.TemplateType = 'Text';
            insert plantilla;
        }
    }
    
    @isTest
    public static void getCasosTest() {
 
        Datetime fechaInicio = DateTime.now().addHours(-1);
        Datetime fechaFin = DateTime.now().addHours(1);
        CC_Agrupador__c agrupadorAbierto = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Agrupador abierto' LIMIT 1];
        CC_Agrupador__c agrupadorCerrado = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Agrupador cerrado' LIMIT 1];
       
        Test.startTest();
            List<Case> casosSinFechas = CC_Control_Servei_Controller.getCasos(agrupadorAbierto.Id, null, null, false);
            List<Case> casosFechaInicio = CC_Control_Servei_Controller.getCasos(agrupadorAbierto.Id, fechaInicio, null, false);
            List<Case> casosFechaFin = CC_Control_Servei_Controller.getCasos(agrupadorAbierto.Id, null, fechaFin, false);
            List<Case> casosConFechas = CC_Control_Servei_Controller.getCasos(agrupadorAbierto.Id, fechaInicio, fechaFin, true);
            List<Case> casoAgrupadorCerrado = CC_Control_Servei_Controller.getCasos(agrupadorCerrado.Id, null, null, false);

       
        User operador = [SELECT Id FROM User Where LastName = 'Operador Empleado' LIMIT 1];
        System.runAs(operador) {
            System.assert(casosFechaInicio.size() >0);
           System.assert(casosSinFechas.size() >0);
           System.assert(casosFechaFin.size() >0);
           System.assert(casosConFechas.size() >0);
        }
        Test.stopTest();
    }
 
    @isTest
    public static void initTest() {
        Test.startTest();
        Datetime fechaInicio = DateTime.now().addHours(-1);
        Datetime fechaFin = DateTime.now().addHours(1);
        CC_Agrupador__c agrupadorAbierto = [SELECT Id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Agrupador abierto' LIMIT 1];
        User operador = [SELECT Id FROM User Where LastName = 'Operador Empleado' LIMIT 1];
        System.runAs(operador) {
            Map<String, Object> retorno = CC_Control_Servei_Controller.init(agrupadorAbierto.Id, null, null);            
            System.assertEquals(1, retorno.size(), 'El mapa retornado debería tener 1 registro');
        }
        Test.stopTest();
    }
  
    @isTest
    public static void enviarComunicacionTest() {
        User operador = [SELECT Id FROM User Where LastName = 'Operador Empleado' LIMIT 1];
        
        Test.startTest();
            List<Case> casos = [SELECT Id, ContactId, Contact.Email FROM Case];
            CC_Control_Servei_Controller.enviarComunicacion('test', casos);
            
       System.runAs(operador) {
        Integer correo = [SELECT Count() FROM EmailMessage];
            System.assert(correo > 0, true);
              Test.stopTest();
        }
      
    }
}