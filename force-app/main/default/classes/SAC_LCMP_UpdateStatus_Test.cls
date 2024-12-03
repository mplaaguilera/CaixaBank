/*****************************************************************
 * Name: SAC_LCMP_UpdateStatus_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_UpdateStatus_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE       Description 
 * 1.0                             IBM                  17/09/21 	 Creación	            
 * 1.1			  US507573		   Jose Carlos Blanco	29/12/22	 Modificación (agregada assertion)
 * 1.2            US643756         Jose Carlos Blanco  	18/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest 
public with sharing class SAC_LCMP_UpdateStatus_Test {
    
    @TestSetup
    static void makeData() {

        User usuario;

        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        System.runAs(usuarioAdmin) {
            List<User> usuariosGenerales = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
            usuariosGenerales[0].Username = 'Name12345@test.com';            
            usuario = usuariosGenerales[0];
            Database.insert(usuariosGenerales);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }
        
        //Cuentas
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];       
        Account ofi = SAC_TestDataFactory.crearCuentasOficina(1)[0];
        
        List<Account> listaCuentas = new List<Account>();
        listaCuentas.add(cuenta);
        listaCuentas.add(ofi);
        Database.insert(listaCuentas);
        Test.stopTest();
        
        //RECLAMACION 1 
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('OwnerId', usuario.Id);
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('AccountId', cuenta.Id);
        camposRecl.put('SAC_ProrrogaCounter__c', 0);
        camposRecl.put('SuppliedEmail', 't.t@t.t');
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);

        //RECLAMACION 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestNegocio');
        camposRecl3.put('Origin', 'Otros');
        camposRecl3.put('Status', 'SAC_001');
        camposRecl3.put('OwnerId', usuario.Id);
        camposRecl3.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl3.put('AccountId', cuenta.Id);
        camposRecl3.put('SuppliedEmail', 't.t@t.t');
        
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl3);
        
        //RECLAMACION 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestRec4');
        camposRecl4.put('SAC_TipoConsumidor__c', 'Si');
        camposRecl4.put('Origin', 'Otros');
        camposRecl4.put('Status', 'SAC_002');
        camposRecl4.put('OwnerId', usuario.Id);
        camposRecl4.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposRecl4.put('AccountId', cuenta.Id);
        camposRecl4.put('SuppliedEmail', 't.t@t.t');
        
        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl4);

        //RECLAMACION 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'TestRec5');
        camposRecl5.put('SAC_TipoConsumidor__c', 'Si');
        camposRecl5.put('Origin', 'Otros');
        camposRecl5.put('CC_Canal_Respuesta__c', 'SAC_CartaPostal');
        camposRecl5.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposRecl5.put('OS_Email__c', 'testsac@testsac.testsac');
        camposRecl5.put('Status', 'SAC_001');
        camposRecl5.put('OwnerId', usuario.Id);
        camposRecl5.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl5.put('AccountId', cuenta.Id);
        camposRecl5.put('SuppliedEmail', 't.t@t.t');
        camposRecl5.put('CC_Oficina_Afectada_Lookup__c', ofi.Id);
        camposRecl5.put('SAC_Naturaleza__c', 'SAC_004');
        
        Case casoReclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl5);

        // //RECLAMACION 6 
        Map<String, Object> camposRecl7 = new Map<String, Object>();
        camposRecl7.put('Subject', 'TestRec7');
        camposRecl7.put('Origin', 'Otros');
        camposRecl7.put('Status', 'SAC_007');
        camposRecl7.put('OwnerId', usuario.Id);
        camposRecl7.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposRecl7.put('AccountId', cuenta.Id);
        camposRecl7.put('SAC_ProrrogaCounter__c', 0);
        camposRecl7.put('SuppliedEmail', 't.t@t.t');
        camposRecl7.put('SAC_TipoConsumidor__c', 'Si');
        camposRecl7.put('CC_Oficina_Afectada_Lookup__c', ofi.Id);
        
        Case casoReclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl7);

        List<Case> casosReclamacion = new List<Case>();
        casosReclamacion.add(casoReclamacion);
        casosReclamacion.add(casoReclamacion3);
        casosReclamacion.add(casoReclamacion4);
        casosReclamacion.add(casoReclamacion5);
        casosReclamacion.add(casoReclamacion7);
        Database.insert(casosReclamacion);
        
        //Creacion MCC tipo PSD2
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.Name = 'PSD2';
        mcc.SAC_EsPsd2__c = true;
        mcc.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        Database.insert(mcc);

        //PRETENSION 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Subject', 'TestPretNegocio');
        camposPret2.put('SuppliedCompany', 'TestPretNegocio');
        camposPret2.put('Origin', 'Otros');
        camposPret2.put('Status', 'SAC_002');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposPret2.put('OwnerId', usuario.Id);
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion3.Id);
        camposPret2.put('AccountId', cuenta.Id);
        camposPret2.put('SEG_Detalle__c', mcc.Id);
        camposPret2.put('SAC_CASE_esPSD2__c', true);
        
        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);

        // //PRETENSION 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('Subject', 'TestPretNegocio2');
        camposPret3.put('SuppliedCompany', 'TestPretNegocio2');
        camposPret3.put('Origin', 'Otros');
        camposPret3.put('Status', 'SAC_001');
        camposPret3.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret3.put('OwnerId', usuario.Id);
        camposPret3.put('SAC_Reclamacion__c', casoReclamacion3.Id);
        camposPret3.put('AccountId', cuenta.Id);
        camposPret3.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension3 = SAC_TestDataFactory.crearCaso('Pretension', camposPret3);

        //PRETENSION 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('Subject', 'TestPret5');
        camposPret4.put('SuppliedCompany', 'TestPret5');
        camposPret4.put('Origin', 'Otros');
        camposPret4.put('Status', 'SAC_001');
        camposPret4.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret4.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposPret4.put('SAC_RedaccionFinal__c', true);
        camposPret4.put('OwnerId', usuario.Id);
        camposPret4.put('SAC_Reclamacion__c', casoReclamacion5.Id);
        camposPret4.put('AccountId', cuenta.Id);
        camposPret4.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension4 = SAC_TestDataFactory.crearCaso('Pretension', camposPret4);

       

        // //PRETENSION 7
        Map<String, Object> camposPret7 = new Map<String, Object>();
        camposPret7.put('Subject', 'TestPret8');
        camposPret7.put('SuppliedCompany', 'TestPret8');
        camposPret7.put('Origin', 'Otros');
        camposPret7.put('Status', 'SAC_007');
        camposPret7.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposPret7.put('SAC_SentidoResolucion__c', 'SAC_002');
        camposPret7.put('SAC_RedaccionFinal__c', true);
        camposPret7.put('SAC_NegociacionFinalizada__c', true);
        camposPret7.put('CC_Importe_Reclamado__c', 50);
        camposPret7.put('SAC_Importe_Resuelto__c', 50);
        camposPret7.put('CC_Importe_Abonado__c', 50);
        camposPret7.put('SAC_Importe_ResultadoNegociacion__c', 50);
        camposPret7.put('SAC_ResultadoNegociacion__c', 'Con acuerdo');
        camposPret7.put('SAC_DetalleResultadoNegociacion__c', 'Factoría');
        camposPret7.put('OwnerId', usuario.Id);
        camposPret7.put('SAC_Reclamacion__c', casoReclamacion7.Id);
        camposPret7.put('AccountId', cuenta.Id);
        camposPret7.put('SEG_Detalle__c', mcc.Id);
        
        Case pretension7 = SAC_TestDataFactory.crearCaso('Pretension', camposPret7);
        
        List<Case> casosPretension = new List<Case>();
        // casosPretension.add(pretension);
        casosPretension.add(pretension2);
        casosPretension.add(pretension3);
        casosPretension.add(pretension7);
        casosPretension.add(pretension4);
        Database.insert(casosPretension);
        
        
        //Informar pretension principal
        List<Case> listaRecsUpdatear = new List<Case>();
        casoReclamacion3.SAC_PretensionPrincipal__c = pretension2.Id;
        casoReclamacion5.SAC_PretensionPrincipal__c = pretension4.Id;
        listaRecsUpdatear.add(casoReclamacion3);
        listaRecsUpdatear.add(casoReclamacion5);
        Database.update(listaRecsUpdatear);
        
        //Parametrizacion SLA
        SAC_ParametrizacionSLATME__c tme = SAC_TestDataFactory.crearParamsSla('SLANegociacion', 1)[0];
        tme.Name = 'Negociación';
        tme.SAC_Duracion__c = 10;
        Database.insert(tme);
        
        //ContentVersion
        ContentVersion cv = new Contentversion();
        cv.Title = 'ABC Test';
        cv.PathOnClient = 'test';
        // Blob b = Blob.valueOf('Unit Test Attachment Body');
        cv.FirstPublishLocationId = casoReclamacion.Id;
        cv.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion';
        Database.insert(cv);
        // Test.stopTest();

        System.runAs(usuarioAdmin){
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'nombreTest';
            validEmailTemplate.DeveloperName = 'SAC_Test';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.HtmlValue = '<p>valor del body<p>';
            validEmailTemplate.Body = 'Texted';
            validEmailTemplate.FolderId = usuarioAdmin.Id;
    
            Database.insert(validEmailTemplate);

            SAC_PlantillaRedaccion__c plantillaSAC = new SAC_PlantillaRedaccion__c();
            plantillaSAC.Name = 'plantillaTest';
            plantillaSAC.RecordTypeId = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
            plantillaSAC.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
            plantillaSAC.SAC_TipoPlantilla__c = 'SAC_FastTrack';
            Database.insert(plantillaSAC);

            SAC_MaestroTemas__c marcaFastTrack = new SAC_MaestroTemas__c();
            marcaFastTrack.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_FastTrack').getRecordTypeId();
            marcaFastTrack.SAC_TipoFastTrack__c = 'SAC_Completo';
            marcaFastTrack.SAC_Activo__c = true;
            marcaFastTrack.SAC_Plantilla__c = plantillaSAC.Id;
            Database.insert(marcaFastTrack);
        }

        List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1);
        Database.insert(listaGrupos);

        SAC_MaestroAccionesReclamacion__c maestroTareas = SAC_TestDataFactory.crearMaestroAcciones(1, listaGrupos[0].Id)[0];
        maestroTareas.Name = 'IMPRIMIR CARTAS ORDINARIO';
        maestroTareas.SAC_DeveloperName__c = 'SAC_ImprimirCartasOrdinario';
        maestroTareas.SAC_Descripcion__c = 'IMPRIMIR CARTAS ORDINARIO';
        maestroTareas.SAC_PlazoMaximo__c = 3;
        maestroTareas.SAC_Prorroga__c = 3;
        maestroTareas.SAC_Activo__c = true;
        Database.insert(maestroTareas);
    }

    @isTest
    static void testUpdateRecordStatus(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status, SAC_SentidoResolucion__c FROM Case WHERE Subject = 'TestRec4'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            SAC_LCMP_UpdateStatus.updateRecordStatus(reclamacion.Id, 'SAC_003');
        }
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec4'];
        Test.stopTest();
        System.assertEquals(reclamacion2.Status, 'SAC_003','No se ha podido actualizar el estado de la Reclamación');
    }

    @isTest
    static void testUpdateRecordStatus2(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status, SAC_SentidoResolucion__c FROM Case WHERE Subject = 'TestRec5'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            reclamacion.Origin = 'SAC_CartaPostal';
            reclamacion.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
            reclamacion.SAC_DireccionContacto__c = 'test';
            reclamacion.SAC_CodigoPostalContacto__c = '3123213';
            reclamacion.SAC_PoblacionContacto__c = 'test';
            reclamacion.SAC_ProvinciaContacto__c ='test';
            reclamacion.SAC_PaisContacto__c = 'España';
            reclamacion.CC_AcuseRecibo__c = '0';
            Database.update(reclamacion);

            SAC_LCMP_UpdateStatus.updateRecordStatus(reclamacion.Id, 'SAC_002');
        }
        Case reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec5'];
        Test.stopTest();
        System.assertEquals(reclamacion2.Status, 'SAC_002','No se ha podido actualizar el estado de la Reclamación');
    }

    @isTest
    static void testUpdateRecordStatusbajaPretensionPrincipal() {
        Test.startTest();
        Case reclamacion = [SELECT Id, Status, SAC_SentidoResolucion__c FROM Case WHERE Subject = 'TestNegocio'];
        Case pretension = [SELECT Id, Status FROM Case WHERE SuppliedCompany = 'TestPretNegocio'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
     
		System.runAs(usuario){
            
            reclamacion.SAC_PretensionPrincipal__c = pretension.id;
            Database.update(reclamacion);
            SAC_LCMP_UpdateStatus.updateRecordStatus(pretension.Id, 'SAC_009');
            
        }
        Case pretension2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestPretNegocio'];
        Test.stopTest();
        System.assertEquals(pretension2.Status, 'SAC_009','No se ha podido actualizar el estado de la Reclamación');
    }

    @isTest
    static void testUpdateRecordLastStatus(){
        Test.startTest();       
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        Case reclamacion2 = new Case();
		System.runAs(usuario){
            reclamacion.Status = 'SAC_005';
            reclamacion.SAC_StatusAuxiliar__c = 'SAC_005';
            Database.update(reclamacion);    
            SAC_LCMP_UpdateStatus.updateRecordLastStatus(reclamacion.Id);
            
        }
        reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        Test.stopTest();
        System.assertEquals(reclamacion.Status, 'SAC_005','No se ha podido actualizar el estado de la Reclamación. Falla parte 1');
        System.assertEquals(reclamacion2.Status, 'SAC_001', 'No se ha podido actualizar el estado de la Reclamación. Falla parte 2');
    }

    @isTest
    static void testEsPropietarioV2(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];

        Boolean resultado;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            resultado = SAC_LCMP_UpdateStatus.esPropietario(reclamacion.Id);
        }
        Test.stopTest();
        System.assertEquals(resultado, true, 'No viene del estado alta la reclamacion. Falla parte 3');
    }

    @istest
    static void insertarComentarioTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        String mensaje = 'Mensaje de prueba para el comentario en chatter';
        String comentario;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            SAC_LCMP_UpdateStatus.insertarComentario(reclamacion.Id, mensaje);
            
        }   
        comentario = [select id, ParentId,  body from FeedItem where ParentId =:reclamacion.Id].body;
        Test.stopTest();

        System.assertEquals(mensaje, comentario, 'No hay ningún comentario');
    }

    @isTest
    static void testTienePretensiones(){
        Test.startTest();

        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestNegocio'];
        Boolean result ;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            // List <Case> pretensiones = [SELECT Id, Status,SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
            result= SAC_LCMP_UpdateStatus.tienePretensiones(reclamacion.Id);
        } 
        Test.stopTest();  

        System.assertEquals(result, true,'El caso no tiene pretensiones'); 
    }

    @isTest
    static void testEsPSD2YNoJunta(){
        Test.startTest();

        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestNegocio'];
        Boolean result ;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
       
		System.runAs(usuario){
            // List <Case> pretensiones = [SELECT Id, Status,SAC_Reclamacion__c FROM Case WHERE SAC_Reclamacion__c =: reclamacion.Id];
            result= SAC_LCMP_UpdateStatus.esPSD2YNoJunta(reclamacion.Id);
        }  
        Test.stopTest(); 

        System.assertEquals(result, true,'El caso no tiene el MCC correcto o pertenece a Junta Andalucia'); 
    }

    @isTest
    static void testControladorEnvioEmail(){
        Test.startTest();

        String motivoProrroga = 'envio';
        String toSend = 'garawel@hotmail.com';
        String subject = 'Test';
        String result;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            SAC_LCMP_UpdateStatus.controladorEnvioEmail(motivoProrroga, toSend, subject);
        } 
        result = [SELECT ID, HtmlBody, subject FROM EmailMessage WHERE subject =: 'Test' LIMIT 1].subject;
        System.assertEquals(result, 'Test','El email no se ha mandado correctamente.'); 
        Test.stopTest();  
    }
    
    @isTest
    static void reclamacionHuerfana(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
        Boolean result;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            result = SAC_LCMP_UpdateStatus.reclamacionHuerfana(reclamacion.Id);
        }
        System.assertEquals(result, false, 'La reclamación no tiene pretensiones'); 
        Test.stopTest();     
    }
    
    @isTest
    static void reclamacionHuerfanaTest2(){
        Test.startTest();
        Case pretension = [SELECT Id, Status FROM Case WHERE Subject = 'TestPret5'];
        Boolean result;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            result = SAC_LCMP_UpdateStatus.reclamacionHuerfana(pretension.Id);
        }
        System.assertEquals(result, true, 'La reclamación tiene pretensiones'); 
        Test.stopTest();     
    }

    @isTest
    static void reclamacionHuerfanaTest3(){
        Test.startTest();
        Case pretension = [SELECT Id, Status FROM Case WHERE Subject = 'TestPret5'];
        Boolean result;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec5'];

        //PRETENSION
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('Subject', 'TestPret5');
        camposPret4.put('SuppliedCompany', 'TestPret5');
        camposPret4.put('Origin', 'Otros');
        camposPret4.put('Status', 'SAC_009');
        camposPret4.put('SAC_StatusAuxiliar__c', 'SAC_009');
        camposPret4.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposPret4.put('SAC_RedaccionFinal__c', true);
        camposPret4.put('OwnerId', usuario.Id);
        camposPret4.put('SAC_Reclamacion__c', reclamacion.Id);

        
        Case pretension4 = SAC_TestDataFactory.crearCaso('Pretension', camposPret4);
        Database.insert(pretension4);
        
		System.runAs(usuario){
            result = SAC_LCMP_UpdateStatus.reclamacionHuerfana(pretension.Id);
        }
        System.assertNotEquals(result, false, 'La reclamación no tiene pretensiones'); 
        Test.stopTest();     
    }

    @isTest
    static void recuperarDatos(){
        Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
       
		System.runAs(usuario){
            SAC_LCMP_UpdateStatus.recuperarDatosCaso(reclamacion.Id);
        }
        System.assertNotEquals(null, reclamacion.Id, 'No se ha podido recupear la plantilla'); 
        Test.stopTest();    
    }
    
    @isTest
    static void tieneReclamacionesVinculadasTest(){
        Test.startTest();

        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];
		Boolean respuesta;
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            respuesta = SAC_LCMP_UpdateStatus.tieneReclamacionesVinculadas(reclamacion.Id);
        } 
        Test.stopTest();

        System.assertEquals(respuesta, false, 'No se ha podido comprobar');
    }
    
    @isTest
    static void motivos(){
        Test.startTest();

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            List<String> listaComprobacion = SAC_LCMP_UpdateStatus.listaMotivos();
            System.assertNotEquals(listaComprobacion, null, 'Lista vacía.');
        }    
        Test.stopTest();  
    }
    
    @isTest
    static void subsanar(){
		Test.startTest();
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];        
        List<EmailMessage> antesDeEnviar = [SELECT Id FROM EmailMessage];
        //ContentVersion y serializar
        List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE Title = 'ABC Test'];
        List<String> listaIds = new List<String>();
        for (ContentVersion cv : listaCV) {
            listaIds.add(cv.Id);
        } 
        
        String idsAdjuntos = JSON.serialize(listaIds);
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            
            SAC_LCMP_UpdateStatus.subsanarCaso(reclamacion.id, 'Varios', 'SAC_006', 'prueba@test.com', 'copiaprueba@test.com', '', 'pruebaCuerpo', 'pruebaAsunto', idsAdjuntos);
            
        }
        List<EmailMessage> despuesDeEnviar = [SELECT Id FROM EmailMessage];
        Test.stopTest();
        System.assertNotEquals(antesDeEnviar.size(), despuesDeEnviar.size(), 'No se ha podido subsanar');     
	}

    @isTest
    static void subsanarCartaPostal(){
        Test.startTest();

        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec']; 
        Case reclamacion2;
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){

            SAC_DocumentoEnvio__c documentoEnviar = new SAC_DocumentoEnvio__c();
            documentoEnviar.SAC_Caso__c = reclamacion.id;
            documentoEnviar.SAC_TipoDocumento__c = 'subsanación';
            Database.insert(documentoEnviar);

            reclamacion.SAC_DireccionContacto__c = 'direc';
            reclamacion.SAC_CodigoPostalContacto__c = '43';
            reclamacion.SAC_PoblacionContacto__c = 'pobla';
            reclamacion.SAC_ProvinciaContacto__c = 'provi';
            reclamacion.SAC_PaisContacto__c = 'España';
            Database.update(reclamacion);
            
            SAC_LCMP_UpdateStatus.subsanarCasoCartaPostal(reclamacion.id, 'Varios', 'SAC_006');
            reclamacion2 = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];        
        }
        Test.stopTest();

        System.assertEquals(reclamacion.Id, reclamacion2.Id, 'No se ha podido subsanar');
        System.assertNotEquals(reclamacion.Status, reclamacion2.Status, 'No se ha podido subsanar');
	}
    
    @isTest
    static void getPlantillasCastellanoTest() {
        Test.startTest();

	 	Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];        
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){

            SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
            plantilla.SAC_TipoPlantilla__c = 'SAC_Subsanacion';
            plantilla.SAC_MotivoSubsanacion__c = 'Varios';
            plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
            plantilla.Name = 'testPlantilla';
            Database.insert(plantilla);
            SAC_LCMP_UpdateStatus.TemplateWrapper templateWrap = SAC_LCMP_UpdateStatus.getPlantillaSubsanacion(reclamacion.id, 'ES', 'Varios');
        }
        Test.stopTest();
        System.assertNotEquals(null, reclamacion.Id, 'No se ha podido recupear la plantilla');
    }

    @isTest
    static void getPlantillasCatalanTest() {
        Test.startTest();

	 	Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];        
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];        

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){

            SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
            plantilla.SAC_TipoPlantilla__c = 'SAC_Subsanacion';
            plantilla.SAC_MotivoSubsanacion__c = 'Varios';
            plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
            plantilla.Name = 'testPlantilla';
            Database.insert(plantilla);
            SAC_LCMP_UpdateStatus.TemplateWrapper templateWrap = SAC_LCMP_UpdateStatus.getPlantillaSubsanacion(reclamacion.id, 'CAT', 'Varios');
        }
        Test.stopTest();
        System.assertNotEquals(null, reclamacion.Id, 'No se ha podido recupear la plantilla');
    }

    @isTest
    static void getPlantillasInglesTest() {
        Test.startTest();

	 	Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];        
        EmailTemplate validEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'SAC_Test'];

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){

            SAC_PlantillaRedaccion__c plantilla = new SAC_PlantillaRedaccion__c();
            plantilla.SAC_TipoPlantilla__c = 'SAC_Subsanacion';
            plantilla.SAC_MotivoSubsanacion__c = 'Varios';
            plantilla.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaCatalanId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaInglesId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaGallegoId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaValencianoId__c = validEmailTemplate.Id;
            plantilla.SAC_PlantillaEuskeraId__c = validEmailTemplate.Id;
            plantilla.Name = 'testPlantilla';
            Database.insert(plantilla);
            SAC_LCMP_UpdateStatus.TemplateWrapper templateWrap = SAC_LCMP_UpdateStatus.getPlantillaSubsanacion(reclamacion.id, 'ING', 'Varios');
            SAC_LCMP_UpdateStatus.TemplateWrapper templateWrap2 = SAC_LCMP_UpdateStatus.getPlantillaSubsanacion(reclamacion.id, 'EUSK', 'Varios');
            SAC_LCMP_UpdateStatus.TemplateWrapper templateWrap3 = SAC_LCMP_UpdateStatus.getPlantillaSubsanacion(reclamacion.id, 'VAL', 'Varios');
            SAC_LCMP_UpdateStatus.TemplateWrapper templateWrap4 = SAC_LCMP_UpdateStatus.getPlantillaSubsanacion(reclamacion.id, 'GAL', 'Varios');

        }
        Test.stopTest();
        System.assertNotEquals(null, reclamacion.Id, 'No se ha podido recupear la plantilla');
    }

    @isTest
    static void obtieneAdjuntosTest() {
        Test.startTest();

	 	Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec'];        
        List<ContentVersion> listaContentVersion = new List<ContentVersion>();

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            listaContentVersion = SAC_LCMP_UpdateStatus.obtieneAdjuntos(reclamacion.Id);
        }
        Test.stopTest();

        System.assertNotEquals(null, listaContentVersion, 'No se han podido recupear los adjuntos');
    }

    @isTest
    static void obtenerParaTest(){
        Test.startTest();

        Case reclamacion = [SELECT Id, Origin, OS_Email__c, SAC_DireccionPostal__c, CC_Canal_Respuesta__c, SuppliedEmail, Account.CC_Email__c, 
        Status, RecordType.Name, AccountId, CC_Idioma__c, Account.RecordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.CC_Canal_Respuesta__c FROM Case WHERE Subject = 'TestRec'];
        String resultado;
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            resultado = SAC_LCMP_UpdateStatus.obtenerPara(reclamacion, 'Reclamacion');
        }
        Test.stopTest();

        System.assertEquals(resultado, reclamacion.SuppliedEmail, 'Ha fallado la asignacion del para en el email.');
    }
    
    @isTest 
    static void recuperarSLAnegocioTest(){
        Test.startTest();
        Decimal duracion;
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
       
		System.runAs(usuario){
            duracion = SAC_LCMP_UpdateStatus.recuperarSLAnegocio();
        }
        System.assertNotEquals(duracion, null, 'No se ha recuperado la duración del TME'); 
        Test.stopTest();
    }
    
    @isTest
    static void recuperarFechaNegociacionTest(){
        Test.startTest();
        DateTime fechaNegociacion;
        Case reclamacion;
        Case pretension1;
        Case pretension2;
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        SAC_LCMP_UpdateStatus.NegociacionWrapper resultado;
        
		System.runAs(usuario){
            List<Case> reclamaciones = [SELECT Id, Status, SAC_StatusAuxiliar__C, SAC_PretensionPrincipal__c, Subject, SuppliedCompany  FROM Case WHERE Subject = 'TestNegocio' OR SuppliedCompany = 'TestPretNegocio2' OR SuppliedCompany = 'TestPretNegocio'];  

            for(Case caso : reclamaciones){
                if(caso.Subject == 'TestNegocio'){
                    reclamacion = caso;
                }
                if(caso.SuppliedCompany == 'TestPretNegocio2'){
                    pretension1 = caso;
                }
                if(caso.SuppliedCompany == 'TestPretNegocio'){
                    pretension2 = caso;
                }
            }
            pretension1.Status = 'SAC_007';
            pretension1.SAC_StatusAuxiliar__c = 'SAC_007';
            
            pretension2.Status = 'SAC_007';
            pretension2.SAC_StatusAuxiliar__c = 'SAC_007';
            
            List<Case> pretensiones = new List<Case>();
            pretensiones.add(pretension1);
            pretensiones.add(pretension2);
            Database.update(pretensiones);
            
            resultado = SAC_LCMP_UpdateStatus.recuperarFechaNegociacion(reclamacion.id);
        }
        Test.stopTest();
        System.assertEquals(resultado.fechaNegociacion, null, 'El método que devuelve la fecha de negociación ha fallado.');
    }

    @isTest
    static void reclamacionConPretensionTest(){
        Test.startTest();

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean result;

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            result = SAC_LCMP_UpdateStatus.reclamacionConPretension(reclamacion.Id);
        }
        Test.stopTest();

        System.assertEquals(result, false, 'El método que comprueba si una reclamación tiene pretensiones o no ha fallado.');
    }

    @isTest
    static void fastTrackEmailTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec5' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        SAC_MaestroTemas__c marca = [SELECT Id FROM SAC_MaestroTemas__c WHERE SAC_TipoFastTrack__c = 'SAC_Completo'];

		System.runAs(usuario){
            
            reclamacion.CC_Canal_Respuesta__c = 'Email';
            reclamacion.OS_Email__c = 'testsac@testsac.testsac';
            Database.update(reclamacion);
            SAC_LCMP_UpdateStatus.fastTrack(reclamacion.Id, marca.Id);
            
        }
        Case caseResult = [SELECT Id, Status FROM Case WHERE Id = :reclamacion.Id];
        Test.stopTest();
        System.assertEquals('Cerrado', caseResult.Status, 'No se ha ejecutado correctamente el fast track de email');
    }

    @isTest
    static void fastTrackCartaPostalTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec5' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        SAC_MaestroTemas__c marca = [SELECT Id FROM SAC_MaestroTemas__c WHERE SAC_TipoFastTrack__c = 'SAC_Completo'];

		System.runAs(usuario){
            
            reclamacion.SAC_DireccionContacto__c = 'direc';
            reclamacion.SAC_CodigoPostalContacto__c = '43';
            reclamacion.SAC_PoblacionContacto__c = 'pobla';
            reclamacion.SAC_ProvinciaContacto__c = 'provi';
            reclamacion.SAC_PaisContacto__c = 'España';
            Database.update(reclamacion);
            reclamacion.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
            Database.update(reclamacion);
            SAC_LCMP_UpdateStatus.fastTrack(reclamacion.Id, marca.Id);
            
        }
        Case caseResult = [SELECT Id, Status FROM Case WHERE Id = :reclamacion.Id];
        Test.stopTest();
        System.assertEquals('SAC_004', caseResult.Status, 'No se ha ejecutado correctamente el fast track de email');
    }

    @isTest
    static void updateRecordStatusReclamacionTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec7'];
        // Boolean hayError = false;

        System.runAs(usuario){
            SAC_LCMP_UpdateStatus.updateRecordStatusReclamacion(reclamacion.id, 'SAC_003');
            
        }
        Case reclamacionUpd = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec7'];
        Test.stopTest();
        System.assertEquals('SAC_003', reclamacionUpd.Status, 'No se ha actualizado correctamente el caso.');
    }

    @isTest
    static void updateRecordStatusNegociacionReclamacionTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec7'];
        // Boolean hayError = false;
        
        System.runAs(usuario){
            SAC_LCMP_UpdateStatus.updateRecordStatusNegociacionReclamacion(reclamacion.id);
            
        }
        Case reclamacionUpd = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec7'];
        Test.stopTest();
        System.assertEquals('SAC_007', reclamacionUpd.Status, 'No se ha actualizado correctamente el caso.');
    }

    @isTest
    static void finalizarNegociacionTest(){
        Test.startTest();

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec7'];
        System.runAs(usuario){
            SAC_LCMP_UpdateStatus.finalizarNegociacion(reclamacion.id);
        }
        Case reclamacionUpd = [SELECT Id, Status FROM Case WHERE Subject = 'TestRec7'];
        Test.stopTest();

        System.assertEquals('Cerrado', reclamacionUpd.Status, 'No se ha actualizado correctamente el caso.');
    }

    @isTest
    static void recuperarTiposFastTrackTest(){
        Test.startTest();

        User usuario = [SELECT id FROM User WHERE Username = 'Name12345@test.com' AND isActive = true LIMIT 1];

        List<SAC_MaestroTemas__c> listFT = new List<SAC_MaestroTemas__c>();
        System.runAs(usuario){
            listFT = SAC_LCMP_UpdateStatus.recuperarTiposFastTrack('SAC_Completo');
        }
        Test.stopTest();

        System.assertNotEquals(0, listFT.size(), 'No se ha encontrado los tipos de fast track.');
    }
}