@istest
public with sharing class SIR_Comunicaciones_Test {

    @testSetup static void makeUserData(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTestSirLcmp',rol,'System Administrator','U0111111','09999');
        System.runAs(usuario) {  
            Map<String,Schema.RecordTypeInfo> mapRTsObjectsAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            Id recordTypeCentro = mapRTsObjectsAccount.get('CC_CentroCaixaBank').getRecordTypeId();            
        
            Account centro7 = new Account();
            centro7.RecordTypeId = recordTypeCentro;
            centro7.Name = 'test centro7';
            centro7.CC_Numero_Empresa__c = '007';
            centro7.CC_Numero_Oficina__c = '09997';
            centro7.CC_Numero_Oficina_Empresa__c = '001-09997';
            insert centro7;
            
            Account centro6 = new Account();
            centro6.RecordTypeId = recordTypeCentro;
            centro6.Name = 'test centro6';
            centro6.CC_Numero_Empresa__c = '006';
            centro6.CC_Numero_Oficina__c = '09996';
            centro6.CC_Numero_Oficina_Empresa__c = '001-09996';
            centro6.AV_CentroSuperior__c = centro7.id;
            insert centro6;
            
            Account centro5 = new Account();
            centro5.RecordTypeId = recordTypeCentro;
            centro5.Name = 'test centro5';
            centro5.CC_Numero_Empresa__c = '005';
            centro5.CC_Numero_Oficina__c = '09995';
            centro5.CC_Numero_Oficina_Empresa__c = '001-09995';
            centro5.AV_CentroSuperior__c = centro6.id;
            insert centro5;
            
            Account centro4 = new Account();
            centro4.RecordTypeId = recordTypeCentro;
            centro4.Name = 'test centro4';
            centro4.CC_Numero_Empresa__c = '004';
            centro4.CC_Numero_Oficina__c = '09994';
            centro4.CC_Numero_Oficina_Empresa__c = '001-09994';
            centro4.AV_CentroSuperior__c = centro5.id;
            insert centro4;
            
            Account centro3 = new Account();
            centro3.RecordTypeId = recordTypeCentro;
            centro3.Name = 'test centro3';
            centro3.CC_Numero_Empresa__c = '003';
            centro3.CC_Numero_Oficina__c = '09993';
            centro3.CC_Numero_Oficina_Empresa__c = '001-09993';
            centro3.AV_CentroSuperior__c = centro4.id;
            insert centro3;
            
            Account centro2 = new Account();
            centro2.RecordTypeId = recordTypeCentro;
            centro2.Name = 'test centro2';
            centro2.CC_Numero_Empresa__c = '002';
            centro2.CC_Numero_Oficina__c = '09992';
            centro2.CC_Numero_Oficina_Empresa__c = '001-09992';
            centro2.AV_CentroSuperior__c = centro3.id;
            insert centro2;
            
            Account centro1 = new Account();
            centro1.RecordTypeId = recordTypeCentro;
            centro1.Name = 'test centro1';
            centro1.CC_Numero_Empresa__c = '001';
            centro1.CC_Numero_Oficina__c = '09991';
            centro1.CC_Numero_Oficina_Empresa__c = '001-09991';
            centro1.AV_CentroSuperior__c = centro2.id;
            insert centro1;
                        
            Contact contacto = new Contact(LastName='Test01',CC_NumPerso__c = '99999991', CC_Matricula__c='U0111111', AccountId= centro1.Id, AV_UsuarioAsociado__c= usuario.Id);
            insert contacto;

            

            Set<Id> setAccountId = new Set<Id>();
            setAccountId.add(centro1.Id);
            SIR_TestDataFactory.crearNotificaciones(setAccountId);
        }    
    }
    
    @IsTest static void sirLcmpGetComunicacionesTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usuarioTestSirLcmp@usertestsirec.com' LIMIT 1];
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'test centro1' LIMIT 1];
        Account acc = accounts[0];
        System.runAs(usuario){       
            Test.startTest();
            List<CBK_Notification__c> lstNotificacion = SIR_LCMP_Comunicaciones.getComunicaciones();
            Test.stopTest();
            Assert.areEqual(1, lstNotificacion.size(), 'SIR_LCMP_Comunicaciones_Test.sirLcmpGetComunicacionesTest No se ha creado la notificación.');
            Assert.areEqual(acc.Id, lstNotificacion.get(0).Account__c, 'SIR_LCMP_Comunicaciones_Test.sirLcmpComunicacionesTest No se ha asignado la notificación al centro.');    
        }
    }

    @IsTest static void sirLcmpGetQueryAccionesTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usuarioTestSirLcmp@usertestsirec.com' LIMIT 1];
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();

            Map<String,Schema.RecordTypeInfo> mapRTsObjectsProcesos = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
            Id recordTypeIdPresol = mapRTsObjectsProcesos.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId();            
        
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
                    Name = SIR_Constantes.tipoProceso_PRESOL,
                    SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1,	
                    SIREC__SIREC_fld_cliente__c    = cuenta.Id,
                    SIREC__SIREC_fld_fechaInicio__c  = date.today(),
                    SIREC__SIREC_fld_fechaLimite__c  = date.today(),
                    SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                    SIREC__SIREC_fld_masterRecordId__c = String.valueof((Math.random() * 100000)),
                    recordtypeId = recordTypeIdPresol
                );
            insert proceso;

            SIREC__SIREC_obj_tarea__c tareaAcc = new SIREC__SIREC_obj_tarea__c(
                SIREC__SIREC_fld_proceso__c = proceso.Id,
                SIREC__SIREC_fld_masterRecordId__c = String.valueof((Math.random() * 100000)),
                SIREC__SIREC_fld_codigo_tarea__c = 'ACT',
                Name = 'Tarea ACT',
                SIREC__SIREC_fld_tipo_tarea__c = 'ACT',
                SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
                SIREC__SIREC_fld_estado__c = 'En curso'
            );
            insert tareaAcc;

            Map<String,Schema.RecordTypeInfo> mapRTsObjectsAccion = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
            Id recordTypeIdAccion = mapRTsObjectsAccion.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_PRESOL).getRecordTypeId();            
        
            SIREC__SIREC_obj_acciones__c accion = new SIREC__SIREC_obj_acciones__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_tarea__c = tareaAcc.Id,
            SIREC__SIREC_fld_accion__c = 'LLAMADA EMITIDA',
            SIREC__SIREC_fld_tipo__c = 'Llamada',
            SIREC__SIREC_fld_fechaContacto__c = date.today(),
            SIREC__SIREC_fld_interviniente__c = cuenta.Id,
            SIR_accionEnviada__c = false,
            SIREC__SIREC_fld_estado__c = 'En curso',
            RecordTypeId = recordTypeIdAccion,
            SIREC__SIREC_fld_responsable__c = usuario.Id
            );
            insert accion;

            Test.startTest();
            List<SIREC__SIREC_obj_acciones__c> lstAcciones = SIR_LCMP_Comunicaciones.getQueryAcciones('SIR_InicioPRESOL');
            Test.stopTest();
            Assert.areEqual(lstAcciones.size()>0, true,'SIR_LCMP_Comunicaciones_Test.sirLcmpGetQueryAccionesTest No se ha obtenido el número de acciones esperado.');
        }
    }

    @IsTest static void sirLcmpGetQueryAccionesNotSirPresolTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usuarioTestSirLcmp@usertestsirec.com' LIMIT 1];
        System.runAs(usuario){
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            Map<String,Schema.RecordTypeInfo> mapRTsObjectsProcesos = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByDeveloperName();
            Id recordTypeIdAmistoso = mapRTsObjectsProcesos.get(SIR_Constantes.PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA).getRecordTypeId();            
        
            SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
                    Name = SIR_Constantes.tipoProceso_PRESOL,
                    SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_PRESOL_E1,	
                    SIREC__SIREC_fld_cliente__c    = cuenta.Id,
                    SIREC__SIREC_fld_fechaInicio__c  = date.today(),
                    SIREC__SIREC_fld_fechaLimite__c  = date.today(),
                    SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                    SIREC__SIREC_fld_masterRecordId__c = String.valueof((Math.random() * 100000)),
                    recordtypeId = recordTypeIdAmistoso
                );
            insert proceso;

            SIREC__SIREC_obj_tarea__c tareaAcc = new SIREC__SIREC_obj_tarea__c(
                SIREC__SIREC_fld_proceso__c = proceso.Id,
                SIREC__SIREC_fld_masterRecordId__c = String.valueof((Math.random() * 100000)),
                SIREC__SIREC_fld_codigo_tarea__c = 'ACT',
                Name = 'Tarea ACT',
                SIREC__SIREC_fld_tipo_tarea__c = 'ACT',
                SIREC__SIREC_fld_fechaLimite__c = Date.today().adddays(60),
                SIREC__SIREC_fld_estado__c = 'En curso'
            );
            insert tareaAcc;

            Map<String,Schema.RecordTypeInfo> mapRTsObjectsAccion = Schema.SObjectType.SIREC__SIREC_obj_acciones__c.getRecordTypeInfosByDeveloperName();
            Id recordTypeIdAccion = mapRTsObjectsAccion.get(SIR_Constantes.ACCION_RECORDTYPE_DEVELOPER_NAME_AMISTOSO).getRecordTypeId();            
        
            SIREC__SIREC_obj_acciones__c accion = new SIREC__SIREC_obj_acciones__c(
            SIREC__SIREC_fld_proceso__c = proceso.Id,
            SIREC__SIREC_fld_tarea__c = tareaAcc.Id,
            SIREC__SIREC_fld_accion__c = 'LLAMADA EMITIDA',
            SIREC__SIREC_fld_tipo__c = 'Llamada',
            SIREC__SIREC_fld_fechaContacto__c = date.today(),
            SIREC__SIREC_fld_interviniente__c = cuenta.Id,
            SIR_accionEnviada__c = false,
            SIREC__SIREC_fld_estado__c = 'En curso',
            RecordTypeId = recordTypeIdAccion,
            SIREC__SIREC_fld_responsable__c = usuario.Id
            );
            insert accion;
            
            Test.startTest();
            List<SIREC__SIREC_obj_acciones__c> lstAcciones = SIR_LCMP_Comunicaciones.getQueryAcciones('Test');
            Test.stopTest();
            Assert.areEqual(lstAcciones.size()>0, true,'SIR_LCMP_Comunicaciones_Test.sirLcmpGetQueryAccionesNotSirPresolTest No se ha obtenido el número de acciones esperado.');
        }
    }

    @IsTest static void sirLcmpGetQueryReportsTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usuarioTestSirLcmp@usertestsirec.com' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            List<Report> lstReports = SIR_LCMP_Comunicaciones.getQueryReports('SIR_InicioPRESOL');
            Test.stopTest();
            Assert.areEqual(lstReports.size()>0, false,'SIR_LCMP_Comunicaciones_Test.sirLcmpGetQueryReportsTest Se ha obtenido un informe donde se esperaba 0.');
        }
    }

    @IsTest static void sirLcmpGetQueryReportsNotSirPresolTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usuarioTestSirLcmp@usertestsirec.com' LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            List<Report> lstReports = SIR_LCMP_Comunicaciones.getQueryReports('Test');
            Test.stopTest();
            Assert.areEqual(lstReports.size()>0, false,'SIR_LCMP_Comunicaciones_Test.sirLcmpGetQueryReportsNotSirPresolTest Se ha obtenido un informe donde se esperaba 0.');
        }
    }
}