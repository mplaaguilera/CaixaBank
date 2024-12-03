@IsTest
public class CC_WS_Methods_Maximo_Test {
	
    @isTest
    static void enviarIncidenciaMAXIMO() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Notificacion_Agrupador_Empleado_es';
        template1.DeveloperName = 'Notificacion_Agrupador_Empleado_es';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_01());
        
        Set<ID> oIDs = new Set<ID>();
        oIDs.add(oAgr.Id);                
        CC_WS_Methods_Maximo.crearIncidenciaMaximo(oIDs);
		
		System.assertNotEquals(oAgr, null);
        
        Test.stopTest();
    }
    
    @isTest
    static void auraGestionMaximo() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        Id recordTypeAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            
        Account cuenta1 = new Account();
        cuenta1.Name = 'CuentaEmpleado1';
        cuenta1.CC_Email__c = 'cuentasemp1@test.com';
        cuenta1.RecordTypeId=recordTypeAccount;
        insert cuenta1;
        
        Id recordTypeContacto = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId= recordTypeContacto;
        insert oContacto;
        
        Id recordTypeEmpleado = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Case oCaso = new Case();
        oCaso.RecordTypeId = recordTypeEmpleado;
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.AccountId =cuenta1.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_01());
        

        String sRes = CC_WS_Methods_Maximo.auraGestionMaximo(oAgr.Id);
		
		System.assertEquals(sRes, '');
        
        Test.stopTest();
    }
    
    @isTest
    static void enviarIncidenciaMAXIMO_error01() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Id_Maximo__c = 'IN0001';
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_01());
        
        Set<ID> oIDs = new Set<ID>();
        oIDs.add(oAgr.Id);                
        CC_WS_Methods_Maximo.crearIncidenciaMaximo(oIDs);
		
		System.assertNotEquals(oAgr, null);
        
        Test.stopTest();
    }
    
    @isTest
    static void enviarIncidenciaMAXIMO_error02() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_01());
        
        Set<ID> oIDs = new Set<ID>();
        oIDs.add(oAgr.Id);                
        CC_WS_Methods_Maximo.crearIncidenciaMaximo(oIDs);
		
		System.assertNotEquals(oAgr, null);
        
        Test.stopTest();
    }
    
    @isTest
    static void auraGestionMaximo_error01() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_01());
        
        String sRes = CC_WS_Methods_Maximo.auraGestionMaximo(oAgr.Id);
		
		System.assertNotEquals(sRes, '');
        
        String sRes2 = CC_WS_Methods_Maximo.auraGestionMaximo(null);
		
		System.assertNotEquals(sRes, '');
        
        Test.stopTest();
    }
    
    @isTest
    static void enviarEventoMAXIMO() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Id_Maximo__c = 'IN0001';
        oAgr.CC_Evento__c = true;
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        CC_Notificacion_Volumen__c oVol = new CC_Notificacion_Volumen__c();
        oVol.CC_Agrupador_Id__c = oAgr.Id;
        oVol.CC_Contenido__c = 'texto';
        oVol.CC_Estado__c = 'Envío pendiente';
        oVol.CC_Llamadas_Abandonadas__c = 0;
        oVol.CC_Llamadas_Atendidas__c = 0;
        oVol.CC_Mensaje__c = 'texto';
        oVol.CC_Llamadas_Abandonadas_Parcial__c = 0;
        oVol.CC_Llamadas_Atendidas_Parcial__c = 0;
        oVol.CC_Tipo__c = 'Notificación';
        insert oVol;
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_02());
        
        Set<ID> oIDs = new Set<ID>();
        oIDs.add(oVol.Id);                
        Map<String,String> oRes = CC_WS_Methods_Maximo.crearActualizarEventoMaximo(oIDs);
		
		System.assertNotEquals(oRes, null);
        
        Test.stopTest();
    }
    
    @isTest
    static void enviarEventoMAXIMO_error01() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Id_Maximo__c = 'IN0001';
        oAgr.CC_Evento__c = true;
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        CC_Notificacion_Volumen__c oVol = new CC_Notificacion_Volumen__c();
        oVol.CC_Agrupador_Id__c = oAgr.Id;
        oVol.CC_Contenido__c = 'texto';
        oVol.CC_Estado__c = 'Envío pendiente';
        oVol.CC_Llamadas_Abandonadas__c = 0;
        oVol.CC_Llamadas_Atendidas__c = 0;
        oVol.CC_Mensaje__c = 'texto';
        oVol.CC_Llamadas_Abandonadas_Parcial__c = 0;
        oVol.CC_Llamadas_Atendidas_Parcial__c = 0;
        oVol.CC_Tipo__c = 'Notificación';
        insert oVol;
        
        oVol.CC_Estado__c = 'Enviada';
        update oVol;
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_02());
        
        Set<ID> oIDs = new Set<ID>();
        oIDs.add(oVol.Id);                
        Map<String,String> oRes = CC_WS_Methods_Maximo.crearActualizarEventoMaximo(oIDs);
		
		System.assertNotEquals(oRes, null);
        
        Test.stopTest();
    }
    
    @isTest
    static void enviarEventoMAXIMO_error02() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Evento__c = true;
        oAgr.CC_Id_Maximo__c = 'INC1230';
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        CC_Notificacion_Volumen__c oVol = new CC_Notificacion_Volumen__c();
        oVol.CC_Agrupador_Id__c = oAgr.Id;
        oVol.CC_Estado__c = 'Envío pendiente';
        oVol.CC_Llamadas_Abandonadas__c = 0;
        oVol.CC_Llamadas_Atendidas__c = 0;
        oVol.CC_Mensaje__c = 'texto';
        oVol.CC_Contenido__c = 'texto';
        oVol.CC_Llamadas_Abandonadas_Parcial__c = 0;
        oVol.CC_Llamadas_Atendidas_Parcial__c = 0;
        oVol.CC_Tipo__c = 'Notificación';
        insert oVol;
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_02());
        
        Set<ID> oIDs = new Set<ID>();
        oIDs.add(oVol.Id);                
        Map<String,String> oRes = CC_WS_Methods_Maximo.crearActualizarEventoMaximo(oIDs);
		
		System.assertNotEquals(oRes, null);
        
        Test.stopTest();
    }
    
    @isTest
    static void enviarEventoMAXIMO_error03() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Id_Maximo__c = 'IN0001';
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        CC_Notificacion_Volumen__c oVol = new CC_Notificacion_Volumen__c();
        oVol.CC_Agrupador_Id__c = oAgr.Id;
        oVol.CC_Contenido__c = 'texto';
        oVol.CC_Estado__c = 'Envío pendiente';
        oVol.CC_Llamadas_Abandonadas__c = 0;
        oVol.CC_Llamadas_Atendidas__c = 0;
        oVol.CC_Mensaje__c = 'texto';
        oVol.CC_Llamadas_Abandonadas_Parcial__c = 0;
        oVol.CC_Llamadas_Atendidas_Parcial__c = 0;
        oVol.CC_Tipo__c = 'Notificación';
        insert oVol;
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_02());
        
        Set<ID> oIDs = new Set<ID>();
        oIDs.add(oVol.Id);                
        Map<String,String> oRes = CC_WS_Methods_Maximo.crearActualizarEventoMaximo(oIDs);
		
		System.assertNotEquals(oRes, null);
        
        Test.stopTest();
    }

    @isTest
    static void enviarReclamacionMAXIMO() {
        List<Id> IdRecl = new List<Id>();
        CC_Agrupador__c inc = new CC_Agrupador__c();
        inc.CC_Titulo__c = 'Incidencia';
        inc.CC_Id_Maximo__c = 'MAX-1234';
        insert inc;
        Id idInc = [SELECT Id FROM CC_Agrupador__c LIMIT 1].Id;
        CC_Agrupador_Reclamacion__c recl = new CC_Agrupador_Reclamacion__c();
        recl.CC_Agrupador_Id__c = idInc;
        recl.CC_Contenido__c = 'Prueba';
        recl.CC_Descripcion__c = 'Prueba';
        insert recl;

        List<CC_Agrupador_Reclamacion__c> ListRecl = [SELECT Id FROM CC_Agrupador_Reclamacion__c WHERE CC_Descripcion__c='Prueba'];
        for(CC_Agrupador_Reclamacion__c agr : ListRecl){
            IdRecl.add(agr.Id);            
        }
                
        CC_WS_Methods_Maximo.enviarReclamacionMAXIMO(IdRecl);
    }   
    
    @isTest
    static void enviarEventoMAXIMOFUTURE() {
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;
		System.assertNotEquals(oGrupo, null);
        
        CC_Grupo_Colaborador_Contact__c oGrupoUser = new CC_Grupo_Colaborador_Contact__c();
        oGrupoUser.CC_Usuario__c = UserInfo.getUserId();
        oGrupoUser.CC_Grupo_Colaborador__c = oGrupo.Id;
        insert oGrupoUser;
		System.assertNotEquals(oGrupoUser, null);
        
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
		System.assertNotEquals(oClasif, null);
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Id_Maximo__c = 'IN0001';
        oAgr.CC_Evento__c = true;
        insert oAgr;
		System.assertNotEquals(oAgr, null);
        
        CC_Notificacion_Volumen__c oVol = new CC_Notificacion_Volumen__c();
        oVol.CC_Agrupador_Id__c = oAgr.Id;
        oVol.CC_Contenido__c = 'texto';
        oVol.CC_Estado__c = 'Envío pendiente';
        oVol.CC_Llamadas_Abandonadas__c = 0;
        oVol.CC_Llamadas_Atendidas__c = 0;
        oVol.CC_Mensaje__c = 'texto';
        oVol.CC_Llamadas_Abandonadas_Parcial__c = 0;
        oVol.CC_Llamadas_Atendidas_Parcial__c = 0;
        oVol.CC_Tipo__c = 'Notificación';
        insert oVol;
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        insert oContacto;
        
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.ContactId = oContacto.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Agrupador_Id__c = oAgr.Id;
        oCaso.CC_Idioma__c = 'es';
        insert oCaso;
		System.assertNotEquals(oCaso, null);
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Maximo_Mock_02());
        
        Set<ID> oIDs = new Set<ID>();
        oIDs.add(oVol.Id);                
        CC_WS_Methods_Maximo.crearActualizarEventoMaximoFuture(oIDs);
		
		System.assertNotEquals(oVol, null);
        
        Test.stopTest();
    }
    
    @isTest
    static void notificacionEmpleadoES() {
        
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Notificacion_Agrupador_Empleado_es';
        template1.DeveloperName = 'Notificacion_Agrupador_Empleado_es';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Titulo__c = 'Test';
        agrupador.CC_Descripcion__c = 'Test';
        agrupador.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        agrupador.CC_Evento__c = true;
        insert agrupador;
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;
        
        Id recordTypeEmpleado = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeEmpleado;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        /*
        EmailTemplate plantilla = new EmailTemplate();
        plantilla.DeveloperName = 'Notificacion_Agrupador_Empleado_es';
        plantilla.Name ='Notificacion_Agrupador_Empleado_es';
        insert plantilla;*/

        
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = oContacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
        caso.CC_Canal_Resolucion__c = 'Cajeros';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Agrupador_Id__c = agrupador.Id;  
        insert caso;
        
        CC_WS_Methods_Maximo.notificacionEmpleado(agrupador.Id);
        
        List<Case> casos = [Select Id, AccountId From Case where AccountId =: cuenta.Id ];
		System.assert(casos.size() > 0);
    }
    
    @isTest
    static void notificacionEmpleadoCA() {
        /*
        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;*/

        
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Notificacion_Agrupador_Empleado_ca';
        template1.DeveloperName = 'Notificacion_Agrupador_Empleado_ca';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Titulo__c = 'Test';
        agrupador.CC_Descripcion__c = 'Test';
        agrupador.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        agrupador.CC_Evento__c = true;
        insert agrupador;
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;
        
        Id recordTypeEmpleado = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeEmpleado;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Case caso = new Case();
        caso.CC_Idioma__c = 'ca';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = oContacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Oficina Feedback';
        caso.CC_Canal_Resolucion__c = 'Cajeros';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Agrupador_Id__c = agrupador.Id;  
        insert caso;
        
        CC_WS_Methods_Maximo.notificacionEmpleado(agrupador.Id);
        
        List<Case> casos = [Select Id, AccountId From Case where AccountId =: cuenta.Id ];
		System.assert(casos.size() > 0);
        
    }
    
    @isTest
    static void notificacionEmpleadoCISBankiaES() {
        
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Notificacion_Agrupador_Empleados_CSI_es';
        template1.DeveloperName = 'Notificacion_Agrupador_Empleados_CSI_es';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Titulo__c = 'Test';
        agrupador.CC_Descripcion__c = 'Test';
        agrupador.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        agrupador.CC_Evento__c = true;
        insert agrupador;
        
        Id recordTypeCuenta = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Test Solicitud Info Empleado';
        cuenta.CC_Email__c = 'cuentasolinfoemp@test.com';
        cuenta.RecordTypeId = recordTypeCuenta;
        insert cuenta;
        
        Id recordTypeEmpleado = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        
        Contact oContacto = new Contact();
        oContacto.LastName = 'Test contacto';
        oContacto.Email = 'test@test.es';
        oContacto.RecordTypeId = recordTypeEmpleado;
        oContacto.AccountId = cuenta.Id;
        insert oContacto;
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba';
        caso.AccountId = cuenta.Id;
        caso.ContactId = oContacto.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'CCO CSI';
        caso.CC_Canal_Resolucion__c = 'CCO CSI';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Agrupador_Id__c = agrupador.Id;  
        insert caso;
        
        Test.startTest();
            CC_WS_Methods_Maximo.notificacionEmpleado(agrupador.Id);
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'An email should be sent');
        
    }
     
}