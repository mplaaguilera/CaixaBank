@isTest
public with sharing class SPV_CaseOperativas_Controller_Test {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();


    @TestSetup
    static void makeData() {
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'useraadmin@test.com.testdata';
        // Database.insert(usuarioAdmin);
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            usuarioGeneral.Username = 'userageneral@test.com.testdata';
            // Database.insert(usuarioGeneral);
            SPV_DatabaseDML.insertDML(usuarioGeneral, true);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            // Database.insert(permiSetAssiAdmin);
            SPV_DatabaseDML.insertDML(permiSetAssiAdmin, true);
        }



        Test.stopTest();

        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoGestor').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        cuenta.CC_Tipo_Centro__c = 'DT';
        // Database.insert(cuenta);
        SPV_DatabaseDML.insertDML(cuenta, true);
        
        //grupo colaborador
        List<CC_Grupo_Colaborador__c> listaGrupos = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',1);
        listaGrupos[0].Name = 'grupo de tareas';
        listaGrupos[0].SAC_PermiteTareas__c = true;
        // Database.insert(listaGrupos);
        SPV_DatabaseDML.insertListDML(listaGrupos, true);

        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'grupoColaboradorTest';
        grupoColaborador.RecordTypeId = recType;
        grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
        grupoColaborador.SAC_PermiteTareas__c = true;
        grupoColaborador.SAC_DeveloperName__c = 'SPV_TestGrupoTest';
        grupos.add(grupoColaborador);

        CC_Grupo_Colaborador__c grupoLetrado1 = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',1)[0];
        grupoLetrado1.SAC_Email__c = 'testSPV@testemail.com.invalid';
        grupoLetrado1.SAC_DeveloperName__c = 'SPV_FYRLEGALLETRADOTEST';
        grupos.add(grupoLetrado1);

        // Database.insert(grupos);
        SPV_DatabaseDML.insertListDML(grupos, true);

        //Colaboradores
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact1 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupoColaborador.Id);
        grupoColaboradorContact1.SAC_Supervisor__c = true;
        listaColaboradores.add(grupoColaboradorContact1);
        // Database.insert(listaColaboradores);
        SPV_DatabaseDML.insertListDML(listaColaboradores, true);
  
        List<Case> listaReclamaciones = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'ReclamacionTest';
        caso.Status = 'SPV_AnalisisDecision';
        caso.SPV_Complementaria_Entidad__c = false;
        caso.SAC_StatusAuxiliar__c = caso.Status;
        caso.SEG_Grupo__c = grupoColaborador.id;
        caso.AccountId = cuenta.Id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        caso.OwnerId = usuarioAdmin.Id;
        caso.SAC_EntidadProductora__c = 'Bankia';
        caso.SAC_ValidacionOficinaAfectada__c = true;
        listaReclamaciones.add(caso);

        //Reclamacion 2
        Case caso2 = new Case();
        caso2.Subject = 'ReclamacionTest2';
        caso2.Status = 'SPV_EnvioOrganismos';
        caso2.SAC_StatusAuxiliar__c = caso.Status;
        caso2.SEG_Grupo__c = grupoColaborador.id;
        caso2.AccountId = cuenta.Id;
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        caso2.SEG_Subestado__c = 'Revision';
        caso2.OwnerId = usuarioAdmin.Id;
        listaReclamaciones.add(caso2);

        //Reclamacion 3
        Case caso3 = new Case();
        caso3.Subject = 'ReclamacionTest3';
        caso3.Status = 'SPV_PendienteRespuestaOrganismos';
        caso3.SAC_StatusAuxiliar__c = caso.Status;
        caso3.SEG_Subestado__c = 'Pendiente respuesta Organismos';
        caso3.SPV_Organismo__c = 'SPV_Consumo';
        caso3.SEG_Grupo__c = grupoColaborador.id;
        caso3.AccountId = cuenta.Id;
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        caso3.OwnerId = usuarioAdmin.Id;
        listaReclamaciones.add(caso3);

        
        //Reclamacion 4
        Case caso4 = new Case();
        caso4.Subject = 'ReclamacionTest4';
        caso4.Status = 'SPV_Envio';
        caso4.SAC_StatusAuxiliar__c = caso.Status;
        caso4.SPV_Organismo__c = 'SPV_Consumo';
        caso4.SEG_Grupo__c = grupoColaborador.id;
        caso4.AccountId = cuenta.Id;
        caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        caso4.OwnerId = usuarioAdmin.Id;
        listaReclamaciones.add(caso4);


        //Reclamacion 5
        Case caso5 = new Case();
        caso5.Subject = 'ReclamacionTest5';
        caso5.Status = 'SPV_EnvioRectificacion';
        caso5.SAC_StatusAuxiliar__c = caso.Status;
        caso5.SPV_Organismo__c = 'SPV_Consumo';
        caso5.SEG_Grupo__c = grupoColaborador.id;
        caso5.AccountId = cuenta.Id;
        caso5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        caso5.OwnerId = usuarioAdmin.Id;
        listaReclamaciones.add(caso5);


        //Reclamacion 5
        Case caso6 = new Case();
        caso6.Subject = 'ReclamacionTest6';
        caso6.Status = 'SAC_001';
        caso6.SAC_StatusAuxiliar__c = caso.Status;
        caso6.SPV_Organismo__c = 'SPV_Consumo';
        caso6.SEG_Grupo__c = grupoColaborador.id;
        caso6.AccountId = cuenta.Id;
        caso6.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
        caso6.OwnerId = usuarioAdmin.Id;
        listaReclamaciones.add(caso6);
        
        // Database.insert(listaReclamaciones);
        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        List<Case> listPretensiones = new List<Case>();
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pruebaPretension');
        camposPret.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret.put('OwnerId', usuarioGeneral.Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', caso.Id);

        Case pretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listPretensiones.add(pretension);

        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'pruebaPretension2');
        camposPret2.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret2.put('OwnerId', usuarioGeneral.Id);
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', caso.Id);
        camposPret2.put('SAC_EsPrincipal__c', true);
        camposPret2.put('SAC_Motivoresultadonegociacion__c', 'Solicita verificar primero documentación no disponible');
        camposPret2.put('SAC_ResultadoNegociacion__c', 'Con acuerdo');
        camposPret2.put('SAC_Observaciones__c', 'Test');

        Case pretension2 = SPV_TestDataFactory.crearCaso('Pretension',camposPret2);
        listPretensiones.add(pretension2);

        //Pretensión 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SuppliedCompany', 'pruebaPretension3');
        camposPret3.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret3.put('OwnerId', usuarioGeneral.Id);
        camposPret3.put('Status', 'SAC_001');
        camposPret3.put('SAC_Reclamacion__c', caso4.Id);
        camposPret3.put('SAC_EsPrincipal__c', true);
        camposPret3.put('SEG_Grupo__c', grupoLetrado1.Id);
        
        Case pretension3 = SPV_TestDataFactory.crearCaso('Pretension',camposPret3);
        listPretensiones.add(pretension3);

        //Pretensión 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('SuppliedCompany', 'pruebaPretension4');
        camposPret4.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret4.put('OwnerId', usuarioGeneral.Id);
        camposPret4.put('Status', 'SAC_001');
        camposPret4.put('SAC_Reclamacion__c', caso5.Id);
        camposPret4.put('SAC_EsPrincipal__c', true);
        camposPret4.put('SEG_Grupo__c', grupoLetrado1.Id);
        
        Case pretension4 = SPV_TestDataFactory.crearCaso('Pretension',camposPret4);
        listPretensiones.add(pretension4);

        //Pretensión 5
        Map<String, Object> camposPret5 = new Map<String, Object>();
        camposPret5.put('SuppliedCompany', 'pruebaPretension4');
        camposPret5.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret5.put('OwnerId', usuarioGeneral.Id);
        camposPret5.put('Status', 'SAC_001');
        camposPret5.put('SAC_Reclamacion__c', caso6.Id);
        camposPret5.put('SAC_EsPrincipal__c', true);
        camposPret5.put('SEG_Grupo__c', grupoLetrado1.Id);
        
        Case pretension5 = SPV_TestDataFactory.crearCaso('Pretension',camposPret5);
        listPretensiones.add(pretension5);

        // Database.insert(listPretensiones);
        SPV_DatabaseDML.insertListDML(listPretensiones, true);

        //Indicar que la pertensión de las reclamaciones 4 y 5 son las principales
        List<Case> casosActualizar = new List<Case>();
        caso4.SAC_PretensionPrincipal__c = pretension3.Id;
        caso5.SAC_PretensionPrincipal__c = pretension4.Id;
        casosActualizar.add(caso4);
        casosActualizar.add(caso5);
        SPV_DatabaseDML.updateListDML(casosActualizar, true);

        System.runAs(usuarioAdmin){
            //Maestro temas
            SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
            maestroTema.Name = 'Prorroga';
            maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_TipoAdjuntos').getRecordTypeId();
            maestroTema.SAC_DeveloperName__c = 'SPV_Prorroga';
            maestroTema.SAC_Activo__c = true;
            // Database.insert(maestroTema);
            SPV_DatabaseDML.insertDML(maestroTema, true);

            //ContentVersion
            ContentVersion cv = SPV_TestDataFactory.crearContentVersion(caso3);
            cv.SAC_TipoAdjunto__c = maestroTema.id;
            List<ContentVersion> listaCV = new List<ContentVersion>();
            listaCV.add(cv);
            // Database.insert(listaCV);
            SPV_DatabaseDML.insertListDML(listaCV, true);

            SAC_MaestroAccionesReclamacion__c maestro2 = SPV_TestDataFactory.crearMaestroAcciones(1,listaGrupos[0].Id)[0];
            maestro2.SAC_DeveloperName__c ='SPV_TareaEnvioOrganismo';
            // Database.insert(maestro2);
            SPV_DatabaseDML.insertDML(maestro2, true);
        }
    }


    @isTest
    static void devolverALetradoTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest4' limit 1];

        Test.startTest();

        System.runAs(usuario){
            SPV_CaseOperativas_Controller.devolverALetrado(reclamacion.Id, 'SPV_010', 'Observaciones');
        }

        Case reclamacionResult = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest4' limit 1];
        Assert.areEqual(reclamacionResult.Status, 'SPV_AnalisisDecision', 'No se ha devuelto la reclamación al letrado.');
    }

    @isTest
    static void comprobarSLAPlazoRegCompOrgCompletadoTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest4' limit 1];
        Boolean result;
        Test.startTest();

        System.runAs(usuario){
            result = SPV_CaseOperativas_Controller.comprobarSLAPlazoRegCompOrgCompletado(reclamacion.Id);
        }

        Assert.areEqual(result, false, 'No se ha comprobado correctamente el SLA.');
    }

    @isTest
    static void devolverALetradoTest2(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest5' limit 1];
        Test.startTest();

        System.runAs(usuario){
            SPV_CaseOperativas_Controller.devolverALetrado(reclamacion.Id, 'SPV_010', 'Observaciones');
        }

        Case reclamacionResult = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest5' limit 1];
        Assert.areEqual(reclamacionResult.Status, 'SPV_Rectificacion', 'No se ha devuelto la reclamación al letrado correctamente.');
    }

    @isTest
    static void descartarReclamacionTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status, SAC_MotivoDescarte__c FROM Case WHERE subject = 'ReclamacionTest6' limit 1];

        Test.startTest();

        System.runAs(usuario){
            SPV_CaseOperativas_Controller.descartarReclamacion(reclamacion.Id, 'SAC_Otros', 'Observaciones');
        }


        Case reclamacionResultado = [SELECT Id, Status, SAC_MotivoDescarte__c FROM Case WHERE subject = 'ReclamacionTest6' LIMIT 1];
        Case pretensionResultado = [SELECT Id, Status, SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c = :reclamacion.Id LIMIT 1];

        Assert.areEqual(reclamacionResultado.Status, 'Descartado', 'No se ha descartado la reclamación.');
        Assert.areEqual(pretensionResultado.Status, 'Descartado', 'No se ha descartado la pretensión.');
        Assert.areEqual(reclamacionResultado.SAC_MotivoDescarte__c, 'SAC_Otros', 'No se ha establecido el motivo de rechazo de la reclamación.');

        Test.stopTest();
    }

    
    @isTest
    static void desactivarComplementariaOrganismoTest(){

        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status, SAC_MotivoRechazo__c FROM Case WHERE subject = 'ReclamacionTest3' limit 1];

        Test.startTest();

        System.runAs(usuario){
            SPV_CaseOperativas_Controller.desactivarComplementariaOrganismo(reclamacion.Id);
        }

        Case reclamacionResultado = [SELECT Id, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_FechaComplementariaOrganismo__c FROM Case WHERE Id = :reclamacion.Id];
        Assert.areEqual(reclamacionResultado.CBK_Case_Extension_Id__r.SPV_FechaComplementariaOrganismo__c, null, 'No se ha desactivado la complementaria organismo.');
        Test.stopTest();
    }

    @isTest
    static void verSiGestorLetrado(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        Test.startTest();

        SPV_CaseOperativas_Controller.GestorLetradoWrapper resultadoDevuelto;
        System.runAs(usuario){
            Case reclamacion = new Case();
            reclamacion.OwnerId = usuario.Id;
            reclamacion.Subject = 'test';
            reclamacion.Status = 'SAC_001';

            // Database.insert(reclamacion);
            SPV_DatabaseDML.insertDML(reclamacion, true);

            Case pretension = new Case();
            pretension.SAC_Reclamacion__c = reclamacion.Id;
            pretension.Status = 'SAC_001';
            // Database.insert(pretension);
            SPV_DatabaseDML.insertDML(pretension, true);

            resultadoDevuelto = SPV_CaseOperativas_Controller.verSiGestorLetrado(reclamacion.Id, reclamacion.OwnerId);
        }

        Assert.areEqual(resultadoDevuelto.esUsuarioGestor, true, 'No se ha comprobado el gestor/letrado correctamente');
        Test.stopTest();
    }


    @isTest
    static void fetchMotivos() {
		
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
		Map<String, String> mapMotivos;

        System.runAs(usuario) {
            mapMotivos = SPV_CaseOperativas_Controller.fetchMotivos();
        }
        Test.stopTest();
        System.assertNotEquals(null, mapMotivos, 'Valor retornado');
	}

    @isTest
    static void tomarPropiedadCasoTest() {

        Test.startTest();
        User usuario = [SELECT Id, SAC_GruposPerteneciente__c FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.tomarPropiedadCaso(caso.id, usuario.id);
        }
        Case casoActualizado = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        Test.stopTest();
        system.assertEquals(usuario.Id, casoActualizado.ownerId, 'No se ha podido tomar propiedad del caso');
    }

    @isTest
    static void recuperarUserTest() {
        Case caso = [SELECT id, OwnerId, SEG_Grupo__c FROM Case WHERE Subject = 'ReclamacionTest'];
        User usuario =[SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupoCaso = [SELECT id FROM CC_Grupo_Colaborador__c WHERE name= 'grupoColaboradorTest' ];
        Map<String,String> resultado = new Map<String,String>();


        System.runAs(usuario) {
            Test.startTest();   
            caso.ownerId = usuario.id;
            // Database.update(caso);
            SPV_DatabaseDML.updateDML(caso, true);

            resultado = SPV_CaseOperativas_Controller.recuperarUser(grupoCaso.id, caso.id, caso.OwnerId);
            Test.stopTest();
        }
        system.assertNotEquals(null, resultado, 'No se ha recuperado el usuario');
    }
    
    @isTest
    static void devolverCasoTest() {
        
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status, SEG_Grupo__C, OwnerId, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.devolverCaso(caso.id, /*'',*/ 'Comentario');
        }
        Test.stopTest();
        Case casoActualizado = [SELECT id, Status, SAC_NumDevoluciones__c,SAC_Motivo__c, OwnerId, CBK_Case_Extension_Id__r.SPV_ComentarioDevolucionCaso__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar'];
        system.assertEquals(cola[0].Id, casoActualizado.ownerId, 'No se ha podido devolver el caso');
        system.assertEquals(1, casoActualizado.SAC_NumDevoluciones__c, 'No se ha podido devolver el caso');
        system.assertEquals(null, casoActualizado.SAC_Motivo__c, 'No se ha podido devolver el caso');
        system.assertNotEquals(null, casoActualizado.CBK_Case_Extension_Id__r.SPV_ComentarioDevolucionCaso__c, 'No se ha añadido el comentario correctamente.');
    }


    @isTest
    static void devolverReclamacionAltaTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Status, SEG_Grupo__C, OwnerId, SPV_VueltaAlta__c, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        Test.startTest();
        System.runAs(usuario){
            SPV_CaseOperativas_Controller.devolverReclamacionAlta(reclamacion.Id, 'SPV_004', 'Observaciones');
        }

        Case reclamacionResultado = [SELECT id, Status, SEG_Grupo__C, OwnerId, SPV_VueltaAlta__c, AccountId, CC_MCC_Motivo__c, CC_MCC_ProdServ__c, CC_MCC_Tematica__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        Assert.areEqual(reclamacionResultado.Status, 'SAC_001', 'No se ha devuelto la reclamación a estado de alta.');
        Test.stopTest();
    }

    /*@isTest
    static void volverAnalisisTest() {
        
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, Status FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        Case pretension = [SELECT id, Status, SAC_EsPrincipal__c FROM Case WHERE SuppliedCompany = 'pruebaPretension2' LIMIT 1];

        System.runAs(usuario) {
            caso.Status = 'SPV_EnvioOrganismos';
            caso.SEG_Subestado__c = 'Revision';
            caso.SAC_PretensionPrincipal__c = pretension.Id;
            // Database.update(caso);
            SPV_DatabaseDML.updateDML(caso, true);

            SPV_CaseOperativas_Controller.volverAnalisis(caso.id, 'observacionesTest');
        }
        Test.stopTest();
        Case casoActualizado = [SELECT id, Status, SPV_ObservacionesVolverAnalisis__c FROM Case WHERE subject = 'ReclamacionTest' limit 1];
        system.assertEquals('SAC_002', casoActualizado.Status, 'No se ha podido devolver el caso a analisis');
        system.assertEquals('observacionesTest', casoActualizado.SPV_ObservacionesVolverAnalisis__c,  'No se ha podido devolver el caso a analisis');
    }*/

    @isTest
    static void establecerPretPpalTest() {
        
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT id, Status, SAC_EsPrincipal__c FROM Case WHERE SuppliedCompany = 'pruebaPretension' LIMIT 1];
        Case pretensionPpal = [SELECT id, Status, SAC_EsPrincipal__c FROM Case WHERE SuppliedCompany = 'pruebaPretension2' LIMIT 1];
        Case caso = [SELECT id, Status FROM Case WHERE subject = 'ReclamacionTest' limit 1];

        System.runAs(usuario) {
            caso.SAC_PretensionPrincipal__c = pretensionPpal.Id;
            // Database.update(caso);
            SPV_DatabaseDML.updateDML(caso, true);

            SPV_CaseOperativas_Controller.establecerPretPpal(pretension.id);
        }
        Test.stopTest();
        
        Case pretActualizada = [SELECT id, Status, SAC_EsPrincipal__c FROM Case WHERE SuppliedCompany = 'pruebaPretension' LIMIT 1];
        Assert.areNotEqual(pretension.SAC_EsPrincipal__c, pretActualizada.SAC_EsPrincipal__c, 'No se ha podido asignar la pretension como principal');
    }

    @isTest
    static void comprobarCamposPasarEnvioTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case Where Subject = 'ReclamacionTest'];
        Case pretension = [SELECT id, Status, SAC_EsPrincipal__c, CBK_Case_Extension_Id__c FROM Case WHERE SuppliedCompany = 'pruebaPretension' LIMIT 1];
        Case pretension2 = [SELECT id, Status, SAC_EsPrincipal__c, CBK_Case_Extension_Id__c FROM Case WHERE SuppliedCompany = 'pruebaPretension2' LIMIT 1];

        CBK_Case_Extension__c caseExtension1 = new CBK_Case_Extension__c();
        caseExtension1.Id = pretension.CBK_Case_Extension_Id__c;
        caseExtension1.SPV_DecisionPretensionLetrado__c = 'Allanamiento';

        CBK_Case_Extension__c caseExtension2 = new CBK_Case_Extension__c();
        caseExtension2.Id = pretension2.CBK_Case_Extension_Id__c;
        caseExtension2.SPV_DecisionPretensionLetrado__c = 'Desistimiento';

        List<CBK_Case_Extension__c> listaCaseExtension = new List<CBK_Case_Extension__c>();
        listaCaseExtension.add(caseExtension1);
        listaCaseExtension.add(caseExtension2);

        String resultado = '';

        System.runAs(usuario){
            SPV_DatabaseDML.updateListDML(listaCaseExtension, true);

            resultado = SPV_CaseOperativas_Controller.comprobarCamposPasarEnvio(reclamacion.Id);
        }

        Assert.areEqual(false, String.isBlank(resultado), 'No se han realizado las comprobaciones correctamente.');
        Test.stopTest();
    }

    @isTest
    static void recuperarGruposLetradoTest() {

        List<CC_Grupo_Colaborador__c> listGruposLet = new List<CC_Grupo_Colaborador__c>();
        
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            listGruposLet = SPV_CaseOperativas_Controller.recuperarGruposLetrado();
        }
        Test.stopTest();
        
        Assert.areNotEqual(null, listGruposLet[0].Id, 'No se ha podido recuperar los grupos letrado');
    }

    @isTest
    static void reasignarGrupoLetradoTest() {

        Case caso = [SELECT id, SAC_MotivoReasignacion__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        CC_Grupo_Colaborador__c grupoLetrado = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'SPV_FYRLEGALLETRADOTEST' LIMIT 1];
        
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.reasignarGrupoLetrado(caso.Id, grupoLetrado.Id, 'test motivo');
        }
        Test.stopTest();
        
        Case casoAct = [SELECT id, SAC_MotivoReasignacion__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Assert.areNotEqual(caso.SAC_MotivoReasignacion__c, casoAct.SAC_MotivoReasignacion__c, 'No se ha podido reasignar el grupo letrado');
    }

    @isTest
    static void activarComplementariaEntidadTest() {

        Case caso = [SELECT id, SPV_Complementaria_Entidad__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.activarComplementariaEntidad(caso.Id);
        }
        Test.stopTest();

        Case casoAct = [SELECT id, SPV_Complementaria_Entidad__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Assert.areEqual(true , casoAct.SPV_Complementaria_Entidad__c, 'Error complementaria');
    }

    @isTest
    static void activarRectificacionTest() {

        Case caso = [SELECT id, status FROM Case WHERE subject = 'ReclamacionTest3' LIMIT 1];
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.activarRectificacion(caso.Id);
        }
        Test.stopTest();

        Case casoAct = [SELECT id, status FROM Case WHERE subject = 'ReclamacionTest3' LIMIT 1];
        Assert.areNotEqual(caso.Status , casoAct.status, 'Error rectificacion');
    }

    @isTest
    static void prorrogarReclamacionTest() {

        Case caso = [SELECT id, status FROM Case WHERE subject = 'ReclamacionTest3' LIMIT 1];
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.prorrogarReclamacion(caso.Id, 'SPV_004', 'Observaciones');
        }
        Test.stopTest();

        Case casoAct = [SELECT id, status, SAC_Prorrogado__c FROM Case WHERE subject = 'ReclamacionTest3' LIMIT 1];
        Assert.areEqual(true , casoAct.SAC_Prorrogado__c, 'Error al prorrogar el caso');
    }

    
    @isTest
    static void anularProrrogaReclamacionTest(){
        Case caso = [SELECT id, status FROM Case WHERE subject = 'ReclamacionTest3' LIMIT 1];
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        caso.SAC_Prorrogado__c = true;
        SPV_DatabaseDML.updateDML(caso, true);
        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.anularProrrogaReclamacion(caso.Id, 'SPV_003', 'Observaciones');
        }
        Test.stopTest();

        Case casoAct = [SELECT id, status, SAC_Prorrogado__c, CBK_Case_Extension_Id__c, CBK_Case_Extension_Id__r.SPV_ObservacionesAnulacionProrroga__c FROM Case WHERE subject = 'ReclamacionTest3' LIMIT 1];
        Assert.areEqual('Observaciones', casoAct.CBK_Case_Extension_Id__r.SPV_ObservacionesAnulacionProrroga__c, 'Error al anular la prórroga del caso');
        Assert.areEqual(false, casoAct.SAC_Prorrogado__c, 'Error al anular la prórroga del caso');
    }

    @isTest
    static void activarComplementariaOrganismoTest() {

        Case caso = [SELECT id, SPV_ComplementariaOrganismo__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.activarComplementariaOrganismo(caso.Id, 'SPV_Otros', 'Observaciones', CBK_UtilsDate.todayDT());
        }
        Test.stopTest();

        Case casoAct = [SELECT id, SPV_ComplementariaOrganismo__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Assert.areEqual(true , casoAct.SPV_ComplementariaOrganismo__c, 'Error complementaria');
    }

    @isTest
    static void reabrirReclamacionTest1() {

        Case caso = [SELECT Id, SAC_MotivoReabrir__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.reabrirReclamacion(caso.Id, false, 'SPV_Otros', '');
        }
        Test.stopTest();

        Case casoAct = [SELECT id, SAC_MotivoReabrir__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Assert.areNotEqual('' , casoAct.SAC_MotivoReabrir__c, 'Error al reabrir la reclamación');
    }

    @isTest
    static void reabrirReclamacionTest2() {

        Case caso = [SELECT Id, SAC_MotivoReabrir__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'SPV_FYRLEGALLETRADOTEST' LIMIT 1];

        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            caso.SAC_GrupoLetrado__c = grupo.Id;
            // Database.update(caso);
            SPV_DatabaseDML.updateDML(caso, true);

            SPV_CaseOperativas_Controller.reabrirReclamacion(caso.Id, true, 'SPV_Otros', '');
        }
        Test.stopTest();

        Case casoAct = [SELECT id, SAC_MotivoReabrir__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Assert.areNotEqual('' , casoAct.SAC_MotivoReabrir__c, 'Error al reabrir la reclamación');
    }

    @isTest
    static void comprobarSLAGeneralActivoTest() {
        Boolean slaActivo;
        Case caso = [SELECT Id, SAC_MotivoReabrir__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];

        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            slaActivo = SPV_CaseOperativas_Controller.comprobarSLAGeneralActivo(caso.Id);
        }
        Test.stopTest();

        Assert.areEqual(true , slaActivo, 'Error al comprobar los sla activos de la reclamacion');
    }

    @isTest
    static void clasificarDocumentoProrrogaTest() {
        List<ContentVersion> cv = new List<ContentVersion>();
        Case caso = [SELECT id, status FROM Case WHERE subject = 'ReclamacionTest3' LIMIT 1];
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.clasificarDocumentoProrroga(caso.Id, 1);
            cv = [SELECT Id, SAC_TipoAdjunto__r.SAC_DeveloperName__c, ContentDocument.Id FROM ContentVersion WHERE FirstPublishLocationId =: caso.Id limit 1];
        }
        Test.stopTest();

        Assert.areEqual('SPV_Prorroga' , cv[0].SAC_TipoAdjunto__r.SAC_DeveloperName__c, 'Error al prorrogar el caso');
    }

    @isTest
    static void faseNegociacionReclamacionTest() {
        List<SPV_Formulario__c> formularioReclamacion = new List<SPV_Formulario__c>();
        Case caso = [SELECT id, status, SAC_PretensionPrincipal__r.SAC_Motivoresultadonegociacion__c FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            List<Case> pretensionesCaso = SPV_CaseOperativas_Controller.getPretensiones(caso.Id);
            SPV_CaseOperativas_Controller.activarNegociacionReclamacion(caso.Id, pretensionesCaso);
            SPV_CaseOperativas_Controller.comprobarCamposNegociacionInformados(caso.Id);
            SPV_CaseOperativas_Controller.finalizarNegociacionReclamacion(caso.Id);
            formularioReclamacion = [SELECT id, SPV_NegociacionEnCurso__c FROM SPV_Formulario__c WHERE SPV_Caso__c =: caso.Id LIMIT 1];
        }
        Test.stopTest();

        Assert.areEqual(false , formularioReclamacion[0].SPV_NegociacionEnCurso__c, 'Error al negociar el caso');
    }


    @isTest
    static void cambioEstadoTest() {
        Case casoEstadoCambiado;
        Case caso = [SELECT Id FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];

        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];

        System.runAs(usuario) {
            SPV_CaseOperativas_Controller.cambioEstado(caso.Id, 'SPV_Envio');
            casoEstadoCambiado = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];
        }
        Test.stopTest();

        Assert.areEqual('SPV_Envio' , casoEstadoCambiado.Status, 'Error al cambiar el estado de la reclamacion');
    }

    @isTest
    static void comprobarTareasPtesTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE subject = 'ReclamacionTest' LIMIT 1];

        Boolean tieneTareas = false;

        Test.startTest();
            System.runAs(usuario) {
                tieneTareas = SPV_CaseOperativas_Controller.comprobarTareasPtes(caso.Id);
            }
        Test.stopTest();

        Assert.areEqual(false, tieneTareas, 'Error al comprobar las tareas pendientes de la reclamación');
    }
    
     @isTest
    static void convertirReclamacionSAC(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest4' limit 1];

        Test.startTest();

        System.runAs(usuario){
            SPV_CaseOperativas_Controller.convertirReclamacion(reclamacion.Id, 'ReclamacionSAC');
        }

        Case reclamacionResult = [SELECT Id, RecordType.DeveloperName FROM Case WHERE subject = 'ReclamacionTest4' limit 1];
        Assert.areEqual(reclamacionResult.RecordType.DeveloperName, 'SAC_Reclamacion', 'No se ha convertido correctamente.');
    }
    
     @isTest
    static void convertirConsultaSPV(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest4' limit 1];

        Test.startTest();

        System.runAs(usuario){
            SPV_CaseOperativas_Controller.convertirReclamacion(reclamacion.Id, 'ConsultaSPV');
        }

        Case reclamacionResult = [SELECT Id, RecordType.DeveloperName FROM Case WHERE subject = 'ReclamacionTest4' limit 1];
        Assert.areEqual(reclamacionResult.RecordType.DeveloperName, 'SAC_ConsultaSAC', 'No se ha convertido correctamente.');
    }
    
     @isTest
    static void convertirConsultaCOPS(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE subject = 'ReclamacionTest4' limit 1];
		Case pretension = [SELECT Id, OwnerId, SEG_Grupo__c FROM Case WHERE SuppliedCompany = 'pruebaPretension3' limit 1];
        Test.startTest();

        System.runAs(usuario){
            SPV_CaseOperativas_Controller.convertirReclamacion(reclamacion.Id, 'ConsultaCOPS');
            SPV_CaseOperativas_Controller.esPrincipal(pretension.Id);
        }

        Case pretensionResult = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'pruebaPretension3' limit 1];

        Assert.areEqual(pretensionResult.Status, 'SAC_009', 'No se ha dado de baja.');
    }
}