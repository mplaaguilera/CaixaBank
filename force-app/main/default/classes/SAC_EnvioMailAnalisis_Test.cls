@isTest
public with sharing class SAC_EnvioMailAnalisis_Test {

    @TestSetup
    static void makeData(){
        //Usuario SAC General
        User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuario.Username = 'sacacuserecibo@test.com';
        Database.insert(usuario);

        //Reclamacion
        List<Case> listaCasos = new List<Case>(); 
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        camposRecl.put('OS_Email__c', 'testsac@testsac.testsac');
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaCasos.add(casoReclamacion);

        //Reclamacion 2
        camposRecl.clear();
        camposRecl.put('Subject', 'TestRec2');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaCasos.add(casoReclamacion2);

        Database.insert(listaCasos);

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

        System.runAs(usuario){
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'nombreTest';
            validEmailTemplate.DeveloperName = 'SAC_Test';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.HtmlValue = '<p>valor del body<p>';
            validEmailTemplate.Body = 'Texted';
            validEmailTemplate.FolderId = usuario.Id;
    
            Database.insert(validEmailTemplate);

            //SAC_Plantilla
            SAC_PlantillaRedaccion__c plantillaSAC = new SAC_PlantillaRedaccion__c();
            plantillaSAC.Name = 'plantillaTest';
            plantillaSAC.RecordTypeId = Schema.SObjectType.SAC_PlantillaRedaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Redaccion').getRecordTypeId();
            plantillaSAC.SAC_PlantillaCastellanoId__c = validEmailTemplate.Id;
            plantillaSAC.SAC_TipoPlantilla__c = 'SAC_CartaAutomatica';
            Database.insert(plantillaSAC);

            //Maestro temas
            SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
            maestroTema.Name = 'pruebaTema';
            maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_EnvioAutomaticoCarta').getRecordTypeId();
            maestroTema.SAC_Dias__c = 1;
            maestroTema.SAC_Plantilla__c = plantillaSAC.Id;
            maestroTema.SAC_Activo__c = true;
            Database.insert(maestroTema);
        }
    }

    @isTest
    static void SAC_enviomailTest() {
        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        Case recla = [SELECT Id FROM Case WHERE Subject = 'TestRec'];

        recla.Status = 'SAC_002';
        recla.SAC_StatusAuxiliar__c = 'SAC_002';
        recla.CC_No_Identificado__c = true;
        recla.SAC_FechaRecepcion__c = System.now().addDays(-2);
        Database.update(recla);

        Test.startTest();
        system.runAs(usuario) {
            Database.executeBatch(new SAC_EnvioMailAnalisis(), 10);
        }
        Test.stopTest();

        Case reclaResult = [SELECT Id, SAC_EnvioParcial__c FROM Case WHERE Subject = 'TestRec'];
        system.assertEquals(reclaResult.SAC_EnvioParcial__c, true, 'No se ha marcado el envio');
    }

    @isTest
    static void SAC_envioCartaTest() {
        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'sacacuserecibo@test.com' AND isActive = true LIMIT 1];
        Case recla = [SELECT Id FROM Case WHERE Subject = 'TestRec2'];

        recla.Status = 'SAC_002';
        recla.SAC_StatusAuxiliar__c = 'SAC_002';
        recla.CC_No_Identificado__c = true;
        recla.SAC_FechaRecepcion__c = System.now().addDays(-2);
        recla.CC_Canal_Respuesta__c = 'SAC_CartaPostal';
        Database.update(recla);

        Test.startTest();
        system.runAs(usuario) {
            Database.executeBatch(new SAC_EnvioMailAnalisis(), 10);
        }
        Test.stopTest();

        Case reclaResult = [SELECT Id, SAC_EnvioParcial__c FROM Case WHERE Subject = 'TestRec2'];
        system.assertEquals(reclaResult.SAC_EnvioParcial__c, true, 'No se ha marcado el envio');
    }
}