@isTest
public with sharing class SAC_LCMP_RedaccionPretension_Test {
    @TestSetup
    static void makeData() {
        Test.startTest();

        //MCC
        Id recordTypeIdMCCSAC = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        CC_MCC__c mcc = new CC_MCC__c(
            Name = 'Banca Electrónica de prueba', 
            CC_Codigo_Externo__c = 'd', 
            RecordTypeId = recordTypeIdMCCSAC, 
            CC_Tipo_Cliente__c = 'SAC',
            SAC_esGGH__c = true
        );
        Database.insert(mcc);

        //Cuenta
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
		Database.insert(cuenta);

        //Usuarios
        List<User> lstUser = new List<User>();
        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        User usuarioGeneral;
        User usuarioGeneral2;
        User usuarioAdmin;
        //Usuario Admin
        usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'admin1234pret@caixatest.com';   
        Database.insert(usuarioAdmin);

        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(2)[0];
            usuarioGeneral.Username = 'usergeneral@test.com';    
            lstUser.add(usuarioGeneral);

            //Usuario SAC General 2
            usuarioGeneral2 = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuarioGeneral2.Username = 'usergeneral2@test.com';   
            lstUser.add(usuarioGeneral2);
            Database.insert(lstUser);

            //Permisos
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            permisos.add(permiSetAssi);

            PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
            permiSetAssi2.AssigneeId = usuarioGeneral2.Id;
            permiSetAssi2.PermissionSetId = permiSet2.Id;
            permisos.add(permiSetAssi2);
            Database.insert(permisos);
        }
        Test.stopTest();

        //Reclamacion 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('AccountId', cuenta.id);
        camposRecl.put('OwnerId', usuarioGeneral.Id);
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_SentidoResolucion__c', 'SAC_003');
        camposRecl.put('SAC_RedaccionFinal__c', true);
        
        Case reclamacionTest = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        Database.insert(reclamacionTest);  

        //Pretensiones
        List<Case> pretensiones = new List<Case>();
        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'prueba');
        camposPret.put('AccountId', cuenta.id);
        camposPret.put('OwnerId', usuarioGeneral.Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', reclamacionTest.Id);
        camposPret.put('SEG_Detalle__c', mcc.id);
        camposPret.put('CC_Idioma__c', 'es');
        camposPret.put('SAC_ImpResueltoNotaria__c', 10);
        camposPret.put('SAC_ImpResueltoGestoria__c', 10);
        camposPret.put('SAC_ImpResueltoRegistros__c', 10);
        camposPret.put('SAC_ImpResueltoTasacion__c', 10);
        camposPret.put('SAC_ImpReclamadoInteresesLegales__c', 10);
        camposPret.put('SAC_ImpResueltoInteresesLegales__c', 5);
        
        Case pretensionTest = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
        pretensiones.add(pretensionTest);

        //Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'prueba2');
        camposPret2.put('AccountId', cuenta.id);
        camposPret2.put('OwnerId', usuarioGeneral.Id);
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', reclamacionTest.Id);
        camposPret2.put('SEG_Detalle__c', mcc.id);
        camposPret2.put('CC_Idioma__c', 'ca');
        
        Case pretension2Test = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);
        pretensiones.add(pretension2Test);

        //Pretension 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SuppliedCompany', 'prueba3');
        camposPret3.put('AccountId', cuenta.id);
        camposPret3.put('OwnerId', usuarioGeneral.Id);
        camposPret3.put('Status', 'SAC_001');
        camposPret3.put('SAC_Reclamacion__c', reclamacionTest.Id);
        camposPret3.put('SEG_Detalle__c', mcc.id);
        camposPret3.put('CC_Idioma__c', 'en');
        
        Case pretension3Test = SAC_TestDataFactory.crearCaso('Pretension', camposPret3);
        pretensiones.add(pretension3Test);

        //Pretension 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('SuppliedCompany', 'prueba4');
        camposPret4.put('AccountId', cuenta.id);
        camposPret4.put('OwnerId', usuarioGeneral.Id);
        camposPret4.put('Status', 'SAC_001');
        camposPret4.put('SAC_Reclamacion__c', reclamacionTest.Id);
        camposPret4.put('SEG_Detalle__c', mcc.id);
        camposPret4.put('SAC_Redaccion__c', 'sample testing text');
        camposPret4.put('CC_Idioma__c', 'en');
        
        Case pretension4Test = SAC_TestDataFactory.crearCaso('Pretension', camposPret4);
        pretensiones.add(pretension4Test);

        //Pretension 5
        Map<String, Object> camposPret5 = new Map<String, Object>();
        camposPret5.put('SuppliedCompany', 'prueba5');
        camposPret5.put('AccountId', cuenta.id);
        camposPret5.put('OwnerId', usuarioGeneral.Id);
        camposPret5.put('Status', 'SAC_003');
        camposPret5.put('SAC_Reclamacion__c', reclamacionTest.Id);
        camposPret5.put('SEG_Detalle__c', mcc.id);
        camposPret5.put('SAC_Redaccion__c', 'sample testing text');
        camposPret5.put('CC_Idioma__c', 'en');
        camposPret5.put('SAC_SentidoResolucion__c', 'SAC_004');
        
        Case pretension5Test = SAC_TestDataFactory.crearCaso('Pretension', camposPret5);
        pretensiones.add(pretension5Test);

        Database.insert(pretensiones);

        //Grupo colaborador
        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];

        System.runAs(usuarioGeneral){           
            Database.insert(grupoColaborador);
        }

        //Maestro Acciones
        List<SAC_MaestroAccionesReclamacion__c> registroTareaMaestro = SAC_TestDataFactory.crearMaestroAcciones(2, grupoColaborador.id);
        registroTareaMaestro[0].Name = 'Gastos hipotecarios';
        registroTareaMaestro[0].SAC_Descripcion__c = 'Gastos hipotecarios';
        registroTareaMaestro[0].SAC_PlazoMaximo__c = 2;
        registroTareaMaestro[0].SAC_Prorroga__c = 2;
        registroTareaMaestro[0].SAC_Activo__c=true;
        registroTareaMaestro[0].SAC_DeveloperName__c='GGH';

        registroTareaMaestro[1].Name = 'Facturas especiales';
        registroTareaMaestro[1].SAC_Descripcion__c = 'Facturas especiales';
        registroTareaMaestro[1].SAC_PlazoMaximo__c = 2;
        registroTareaMaestro[1].SAC_Prorroga__c = 2;
        registroTareaMaestro[1].SAC_Activo__c=true;
        registroTareaMaestro[1].SAC_DeveloperName__c='FE';
        Database.insert(registroTareaMaestro);  
    }
    
    @isTest
    static void getTitulosTest() {
        User usuarioAdmin = [SELECT Id, Username FROM User WHERE Username = 'admin1234pret@caixatest.com' AND isActive = true];
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];

        CC_MCC__c mcc = [SELECT Id FROM CC_MCC__c WHERE Name = 'Banca Electrónica de prueba'];
        
        System.runAs(usuarioAdmin){
            EmailTemplate emTemplate = new EmailTemplate(
                DeveloperName = 'SAC_nombreTemplate',
                Name = 'nombreTemplate',
                isActive = true,
                FolderId = usuarioAdmin.id,
                TemplateType = 'text'
            );
            Database.insert(emTemplate);

            String idTemplate = emTemplate.Id;
            SAC_PlantillaRedaccion__c template = new SAC_PlantillaRedaccion__c(
                SAC_MCC__c = mcc.Id, 
                SAC_PlantillaCastellano__c = emTemplate.Name,
                SAC_PlantillaCastellanoId__c = idTemplate,
                SAC_TipoPlantilla__c = 'SAC_Redaccion'
            );
            Database.insert(template);
        }
        
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'prueba'];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_LCMP_RedaccionPretension.plantillasWrapper> resultado = SAC_LCMP_RedaccionPretension.getTitulos(pretension.Id, null);
            Test.stopTest();
            system.assertNotEquals(resultado, null, 'La comparación no funciona correctamente.');
        }
    }

    @isTest
    static void getTitulosTest2() {
        User usuarioAdmin = [SELECT Id, Username FROM User WHERE Username = 'admin1234pret@caixatest.com' AND isActive = true];
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        CC_MCC__c mcc = [SELECT Id FROM CC_MCC__c WHERE Name = 'Banca Electrónica de prueba'];
        
        System.runAs(usuarioAdmin){
            EmailTemplate emTemplate = new EmailTemplate(
                DeveloperName = 'SAC_nombreTemplate',
                Name = 'nombreTemplate',
                isActive = true,
                FolderId = usuarioAdmin.id,
                TemplateType = 'text'
            );
            Database.insert(emTemplate);

            String idTemplate = emTemplate.Id;
            SAC_PlantillaRedaccion__c template = new SAC_PlantillaRedaccion__c(
                SAC_MCC__c = mcc.Id, 
                SAC_PlantillaCastellano__c = emTemplate.Name,
                SAC_PlantillaCastellanoId__c = idTemplate,
                SAC_TipoPlantilla__c = 'SAC_Redaccion'
            );
            Database.insert(template);
        }
        
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'prueba2'];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_LCMP_RedaccionPretension.plantillasWrapper> resultado = SAC_LCMP_RedaccionPretension.getTitulos(pretension.Id, null);
            Test.stopTest();
            system.assertNotEquals(resultado, null, 'La comparación no funciona correctamente.');
        }
    }

    @isTest
    static void getTitulosTest3() {
        User usuarioAdmin = [SELECT Id, Username FROM User WHERE Username = 'admin1234pret@caixatest.com' AND isActive = true];
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        CC_MCC__c mcc = [SELECT Id FROM CC_MCC__c WHERE Name = 'Banca Electrónica de prueba'];
        
        System.runAs(usuarioAdmin){
            EmailTemplate emTemplate = new EmailTemplate(
                DeveloperName = 'SAC_nombreTemplate',
                Name = 'nombreTemplate',
                isActive = true,
                FolderId = usuarioAdmin.id,
                TemplateType = 'text'
            );
            Database.insert(emTemplate);

            String idTemplate = emTemplate.Id;
            SAC_PlantillaRedaccion__c template = new SAC_PlantillaRedaccion__c(
                SAC_MCC__c = mcc.Id, 
                SAC_PlantillaCastellano__c = emTemplate.Name,
                SAC_PlantillaCastellanoId__c = idTemplate,
                SAC_TipoPlantilla__c = 'SAC_Redaccion'
            );
            Database.insert(template);
        }
        
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'prueba3'];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_LCMP_RedaccionPretension.plantillasWrapper> resultado = SAC_LCMP_RedaccionPretension.getTitulos(pretension.Id, null);
            Test.stopTest();
            system.assertNotEquals(resultado, null, 'La comparación no funciona correctamente.');
        }
    }

    @isTest
    static void getBodyTest() {
        User usuarioAdmin = [SELECT Id, Username FROM User WHERE Username = 'admin1234pret@caixatest.com' AND isActive = true];
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        CC_MCC__c mcc = [SELECT Id FROM CC_MCC__c WHERE Name = 'Banca Electrónica de prueba'];

        System.runAs(usuarioAdmin){
            EmailTemplate emTemplate = new EmailTemplate(
                DeveloperName = 'SAC_nombreTemplate',
                Name = 'nombreTemplate',
                isActive = true,
                FolderId = usuarioAdmin.id,
                TemplateType = 'text',
                HtmlValue = '<p>prueba html value</p>'
            );
            Database.insert(emTemplate);

            SAC_PlantillaRedaccion__c template = new SAC_PlantillaRedaccion__c(
                SAC_MCC__c = mcc.Id, 
                SAC_PlantillaCastellano__c = emTemplate.Name,
                SAC_PlantillaCastellanoId__c = emTemplate.Id,
                SAC_TipoPlantilla__c = 'SAC_Redaccion'
            );
            Database.insert(template);
        }

        SAC_PlantillaRedaccion__c plantilla = [SELECT Id, SAC_PlantillaCastellano__c, SAC_PlantillaCastellanoId__c FROM SAC_PlantillaRedaccion__c WHERE SAC_PlantillaCastellano__c = 'nombreTemplate'];
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'prueba'];
        System.runAs(usuario){
            Test.startTest();
            String resultado = SAC_LCMP_RedaccionPretension.getBody(plantilla.SAC_PlantillaCastellanoId__c, pretension.Id);
            Test.stopTest();
            system.assertNotEquals(resultado, null, 'No funciona bien el assert');
        }
    }

    @isTest
    static void insertRedaccionTest() {
        
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        Case pretension = [SELECT Id, SAC_Redaccion__c, SAC_SentidoResolucion__c, SAC_MotivoInadmision__c FROM Case WHERE SuppliedCompany = 'prueba'];
        pretension.SAC_SentidoResolucion__c = 'SAC_004';
        pretension.SAC_MotivoSentidoResolucion__c = 'Motivo sentido resolucion';
        pretension.SAC_MotivoInadmision__c = 'SAC_005';

        Case pretensionInicial2 = [SELECT Id, SAC_Redaccion__c, SAC_SentidoResolucion__c, SAC_MotivoInadmision__c FROM Case WHERE SuppliedCompany = 'prueba5'];
        pretensionInicial2.SAC_SentidoResolucion__c = 'SAC_003';
        pretensionInicial2.SAC_MotivoInadmision__c = 'SAC_005';    //Se le pone uno para comprobar que se pasa A NULL


        System.runAs(usuario){     
            Test.startTest();       
            SAC_LCMP_RedaccionPretension.insertRedaccion('hola esto es una prueba', 'argumento', pretension.id, pretension.SAC_SentidoResolucion__c, pretension.SAC_MotivoInadmision__c, true);
            SAC_LCMP_RedaccionPretension.insertRedaccion('hola esto es una prueba', 'argumento', pretensionInicial2.id, pretensionInicial2.SAC_SentidoResolucion__c, pretensionInicial2.SAC_MotivoInadmision__c, true);
        
            Test.stopTest();
        }
        
        //Recoge la pretensión con sentido de resolución= SAC_004:
        Case pretensionV2 = [SELECT Id, SAC_Redaccion__c, SAC_RedaccionFinal__c, SAC_SentidoResolucion__c, SAC_MotivoInadmision__c, Status, SAC_StatusAuxiliar__c FROM Case WHERE SuppliedCompany = 'prueba'];

        //Recoge la pretensión con sentido de resolución DISTINTO a SAC_004:
        Case pretensionV3 = [SELECT Id, SAC_Redaccion__c, SAC_RedaccionFinal__c, SAC_SentidoResolucion__c, SAC_MotivoInadmision__c, Status, SAC_StatusAuxiliar__c FROM Case WHERE SuppliedCompany = 'prueba5'];

        system.assertNotEquals(pretensionV2.SAC_Redaccion__c, pretension.SAC_Redaccion__c, 'No funciona bien el assert');
        system.assertEquals(pretension.SAC_MotivoInadmision__c , pretensionV2.SAC_MotivoInadmision__c, 'Falla el motivo de inadmision');
        system.assertEquals('SAC_003' , pretensionV2.Status, 'Falla el status de la pretension');
        system.assertEquals('SAC_003' , pretensionV2.SAC_StatusAuxiliar__c, 'Falla el status auxiliar de la pretension');
        system.assertEquals(true , pretensionV2.SAC_RedaccionFinal__c, 'Falla el campo redaccion final');

        //Si el sentido de resolución no es SAC_004
        system.assertEquals(null , pretensionV3.SAC_MotivoInadmision__c , 'Falla el campo motivo de admision cuando no SAC_004');
    }






    @isTest
    static void compruebaPropietarioTest(){
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
        Boolean resultado = true;

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionPretension.compruebaPropietario(caso.Id);
            Test.stopTest();
        }
        system.assertEquals(false, resultado, 'El usuario es propietario del caso');
    }

    @isTest
    static void getRedaccionTest(){
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        Case caso = [SELECT Id FROM Case WHERE SuppliedCompany = 'prueba4'];
        String resultado = '';
        String resultado2 = '';

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionPretension.getRedaccion(caso.Id);
            Test.stopTest();
        }
        
        system.assertNotEquals(resultado2, resultado, 'No se ha podido devolver la redacción.');
    }

    @isTest
    static void getPlantillasInadmisionTest(){
        User usuarioAdmin = [SELECT Id, Username FROM User WHERE Username = 'admin1234pret@caixatest.com' AND isActive = true];
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        
        System.runAs(usuarioAdmin){
            EmailTemplate emTemplate = new EmailTemplate(
                DeveloperName = 'SAC_nombreTemplate',
                Name = 'nombreTemplate',
                isActive = true,
                FolderId = usuarioAdmin.id,
                TemplateType = 'text'
            );
            Database.insert(emTemplate);

            String idTemplate = emTemplate.Id;
            List<SAC_PlantillaRedaccion__c> listaPlantillas = new List<SAC_PlantillaRedaccion__c>();
            SAC_PlantillaRedaccion__c template = new SAC_PlantillaRedaccion__c( 
                SAC_PlantillaCastellano__c = emTemplate.Name,
                SAC_PlantillaCastellanoId__c = idTemplate,
                SAC_TipoPlantilla__c = 'SAC_Inadmision'
            );
            SAC_PlantillaRedaccion__c template2 = new SAC_PlantillaRedaccion__c( 
                SAC_PlantillaCatalan__c = emTemplate.Name,
                SAC_PlantillaCatalanId__c = idTemplate,
                SAC_TipoPlantilla__c = 'SAC_Inadmision'
            );
            SAC_PlantillaRedaccion__c template3 = new SAC_PlantillaRedaccion__c( 
                SAC_PlantillaIngles__c = emTemplate.Name,
                SAC_PlantillaInglesId__c = idTemplate,
                SAC_TipoPlantilla__c = 'SAC_Inadmision'
            );
            listaPlantillas.add(template);
            listaPlantillas.add(template2);
            listaPlantillas.add(template3);
            
            Database.insert(listaPlantillas);
        }
        
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'prueba5'];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_LCMP_RedaccionPretension.plantillasWrapper> resultado = SAC_LCMP_RedaccionPretension.getTitulos(pretension.Id, null);
            Test.stopTest();
            system.assertNotEquals(resultado, null, 'La comparación no funciona correctamente.');
        }
    }
    
    @isTest
    static void recuperarCheckRedaccionFinalTest(){
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
        
        System.runAs(usuario){
            Test.startTest();
            Boolean resultado = SAC_LCMP_RedaccionPretension.recuperarCheckRedaccionFinal(caso.Id);
            Test.stopTest();
            system.assertNotEquals(resultado, null, 'No se ha devuelto la información');
        }   
    }
    
    @isTest
    static void recuperarSentidoResolucionTest(){
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
    
        System.runAs(usuario){
            Test.startTest();
            String resultado = SAC_LCMP_RedaccionPretension.recuperarSentidoResolucion(caso.Id);
            Test.stopTest();
            system.assertNotEquals(resultado, null, 'No se ha devuelto la información');
        } 
    }

    @isTest
    static void argumentarioPreteTest(){
        User usuario = [SELECT Id, Username FROM User WHERE Username = 'usergeneral@test.com' AND isActive = true];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
        String resultado;
        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_LCMP_RedaccionPretension.argumentarioPrete(caso.Id);
            Test.stopTest();
            system.assertNotEquals(resultado, null, 'No se ha devuelto la información');
        } 
    }
}