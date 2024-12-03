/*****************************************************************
 * Name: SAC_GenialView_Controller_Test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Testear el componente SAC_GenialView_Controller
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            genial           David Ramos       06/11/23     Creación
 * 1.1            US866228         David Ramos       17/04/24     Añadido test testGetRecSecundariosPropuestos
 * 1.2            US869509         Borja Lavesiera   22/04/24     Campo Resumen y su Valoración  
*****************************************************************/
@isTest
public with sharing class SAC_GenialView_Controller_Test {
    @TestSetup
    static void makeData(){
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'Subject de prueba');
            camposRecl.put('Description', 'Descripcion de prueba');
            camposRecl.put('SAC_GenialEstado__c', 'SAC_002');
            camposRecl.put('CC_Idioma__c', 'es');
            camposRecl.put('CC_Importe_Reclamado__c', 0);
            camposRecl.put('SAC_Importe_Tipo__c', 'Sin importe');
            camposRecl.put('SAC_Naturaleza__c', null);

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            reclamacion.SAC_NumeroDelDocumento__c = '86645006G';
            reclamacion.SAC_EmailRepresentante__c = 'rec@invalid.com';
            Database.insert(reclamacion);

            //Pretension
            Map<String, Object> camposPretl = new Map<String, Object>();
            camposPretl.put('Subject', 'Subject de prueba');
            camposPretl.put('Description', 'Descripcion de prueba');
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPretl);
            pretension.SAC_NumeroDelDocumento__c = '86645006G';
            pretension.SAC_EmailRepresentante__c = 'pret@invalid.com';
            Database.insert(pretension);

            String recResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion_IA').getRecordTypeId();
            String pretResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Pretension_IA').getRecordTypeId();
            
            
            //Resultado genial Reclamacion
            SAC_Genial_Resultado__c genRes;
            genRes = new SAC_Genial_Resultado__c(
                SAC_Reclamacion__c = reclamacion.id,
                SAC_NumeroDelDocumento__c = '86645006G',
                SAC_LastName__c = 'Pelaes',
                SAC_FirstName__c = 'Paco',
                SAC_EmailRepresentante__c = 'diferente@invalid.com',
                SAC_Idioma__c = 'ca',
                SAC_Importe_Reclamado__c = 100,
                SAC_Importe_Tipo__c = null,
                SAC_Naturaleza__c = 'SAC_001',
                recordTypeId = recResRT
            );
            Database.insert(genRes);

            //Resultado genial Pretension
            SAC_Genial_Resultado__c genResPret;
            genResPret = new SAC_Genial_Resultado__c(
                SAC_Reclamacion__c = reclamacion.id,
                SAC_Pretension__c = pretension.id,
                SAC_Json__c = 'JSON.serialize(pretension)',
                SAC_NumeroDelDocumento__c = '86645006G',
                SAC_EmailRepresentante__c = 'diferente@invalid.com',
                recordTypeId = pretResRT
            );
            Database.insert(genResPret);
        }
    }

    @isTest
    public static void testGetResultadoGenialReclamacion() {
        Case reclamacion = [SELECT Id, Subject, Description, SAC_NumeroDelDocumento__c, SAC_EmailRepresentante__c, SAC_GenialEstado__c, CC_Idioma__c, CC_Importe_Reclamado__c, SAC_Importe_Tipo__c, SAC_Naturaleza__c FROM Case WHERE SAC_EmailRepresentante__c = 'rec@invalid.com'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialView_Controller.IdResGenialConIconos resultado = new SAC_GenialView_Controller.IdResGenialConIconos();
        resultado.iconosCampos = new Map<String, String>();

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_GenialView_Controller.getResultadoGenial(reclamacion);
            Test.stopTest();
        }

        Boolean campoIgual = resultado.iconosCampos.get('SAC_NumeroDelDocumento__c') == SAC_GenialView_Controller.ICONMODIFICADOIA;
        Boolean campoDiferente = resultado.iconosCampos.get('SAC_EmailRepresentante__c') == SAC_GenialView_Controller.ICONMODIFICADOUSER;

        System.assertEquals(true, (campoIgual && campoDiferente),'El resultado no se obtiene correctamente');
    }

    @isTest
    public static void testGetResultadoGenialPretension() {
        Case pretension = [SELECT Id, Subject, Description, SAC_NumeroDelDocumento__c, SAC_EmailRepresentante__c, SAC_GenialEstado__c FROM Case WHERE SAC_EmailRepresentante__c = 'pret@invalid.com'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialView_Controller.IdResGenialConIconos resultado = new SAC_GenialView_Controller.IdResGenialConIconos();
        resultado.iconosCampos = new Map<String, String>();

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_GenialView_Controller.getResultadoGenial(pretension);
            Test.stopTest();
        }
   
        Boolean campoIgual = resultado.iconosCampos.get('SAC_NumeroDelDocumento__c') == SAC_GenialView_Controller.ICONMODIFICADOIA;
        Boolean campoDiferente = resultado.iconosCampos.get('SAC_EmailRepresentante__c') == SAC_GenialView_Controller.ICONMODIFICADOUSER;
        
        System.assertEquals(true, (campoIgual && campoDiferente),'El resultado no se obtiene correctamente');
    }

    @isTest
    public static void testGetPretensionesPropuestas() {
        Case reclamacion = [SELECT Id, Subject, Description, SAC_NumeroDelDocumento__c, SAC_EmailRepresentante__c FROM Case WHERE SAC_EmailRepresentante__c = 'rec@invalid.com'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        list<SAC_Genial_Resultado__c> resultado = new list<SAC_Genial_Resultado__c>();

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_GenialView_Controller.obtenerPretensionesIA(reclamacion.Id);
            Test.stopTest();
        }

        System.assertEquals(1, resultado.size(),'Debería devolver 1 pretensión propuesta');
    }

    @isTest
    public static void testGetRecSecundariosPropuestos() {
        Case reclamacion = [SELECT Id, Subject, Description, SAC_NumeroDelDocumento__c, SAC_EmailRepresentante__c FROM Case WHERE SAC_EmailRepresentante__c = 'rec@invalid.com'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        String recSecResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamante_IA').getRecordTypeId();
            
        //Resultado genial reclamante secundario
        SAC_Genial_Resultado__c genResRecSec;
        genResRecSec = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Email__c = 'rec@invalid.com', 
            SAC_SuppliedNIF__c = '9999999Z',
            SAC_Telefono_Contacto__c = '999999999', 
            SAC_DireccionContacto__c = 'Direccion Test', 
            SAC_CodigoPostalContacto__c = '99999',
            SAC_PoblacionContacto__c = 'Poblacion Test', 
            SAC_ProvinciaContacto__c = 'Provincia Test', 
            SAC_PaisContacto__c = 'Pais Test',
            SAC_NombreContacto__c = 'Nombre Test',
            recordTypeId = recSecResRT
        );
        Database.insert(genResRecSec);

        list<SAC_Genial_Resultado__c> resultado = new list<SAC_Genial_Resultado__c>();

        System.runAs(usuario){
            Test.startTest();
            resultado = SAC_GenialView_Controller.obtenerReclamantesSecundariosIA(reclamacion.Id);
            Test.stopTest();
        }

        System.assertEquals(1, resultado.size(),'Debería devolver 1 reclamante seundario propuesto');
    }

    @isTest
    public static void testObtenerRecordTypeReclamacion() {
        Case reclamacion = [SELECT Id, RecordTypeId FROM Case WHERE SAC_EmailRepresentante__c = 'rec@invalid.com'];
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        Id idRTRecResultado;

        System.runAs(usuario){
            Test.startTest();
            idRTRecResultado = SAC_GenialView_Controller.obtenerRecordTypeReclamacion();
            Test.stopTest();
        }

        System.assertEquals(idRTRecResultado, reclamacion.RecordTypeId,'El Id de Recordtype devuelto no es correcto');
    }
    

    @isTest
    public static void testGetValorResumen() {
        Case reclamacion = [SELECT Id FROM Case WHERE SAC_EmailRepresentante__c = 'rec@invalid.com' LIMIT 1];
        Case pretension = [SELECT Id FROM Case WHERE SAC_EmailRepresentante__c = 'pret@invalid.com' LIMIT 1];
        Id recSecResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Pretension_IA').getRecordTypeId();      
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String valoracionResumen;

        System.runAs(usuario){
            SAC_Genial_Resultado__c genResShadow = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Pretension__c = pretension.Id,
            SAC_ValoracionResumen__c = 'Neutral',
            SAC_NombreContacto__c = 'Nombre Test Valoracion',
            RecordTypeId = recSecResRT
            );
        	insert genResShadow;
            Test.startTest();
            //Modificamos el valor del resumen
            genResShadow.SAC_ValoracionResumen__c = 'Positivo';
            update genResShadow;
            SAC_Genial_Resultado__c genResShadowList = [SELECT Id, SAC_ValoracionResumen__c , SAC_Pretension__c
                                                         FROM SAC_Genial_Resultado__c WHERE SAC_NombreContacto__c = 'Nombre Test Valoracion'];
            valoracionResumen = SAC_GenialView_Controller.GetValorResumen(genResShadowList.SAC_Pretension__c);
            Test.stopTest();
        }
        System.assertNotEquals(valoracionResumen, 'Positivo','La valoración ha sido modificada correctamente');
    }
    @isTest
    public static void testGuardarValorResumen() {
        Case reclamacion = [SELECT Id FROM Case WHERE SAC_EmailRepresentante__c = 'rec@invalid.com' LIMIT 1];
        Id recSecResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Pretension_IA').getRecordTypeId();      
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        //pretension
        Map<String, Object> camposPretl = new Map<String, Object>();
            camposPretl.put('Subject', 'Subject de prueba');
            camposPretl.put('Description', 'Descripcion de prueba');
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPretl);
            pretension.SAC_NumeroDelDocumento__c = '86645006G';
            pretension.SAC_EmailRepresentante__c = 'pretensiontest@invalid.com';
            Database.insert(pretension);

        
        // Crear un registro de resultado genial con el record type obtenido y asociarlo al caso
        SAC_Genial_Resultado__c genResShadow = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_Pretension__c = pretension.Id,
            SAC_ValoracionResumen__c = 'Neutral',
            SAC_NombreContacto__c = 'Test Nueva Valoracion',
            RecordTypeId = recSecResRT
            );
        	insert genResShadow;

        // Cambiar la valoración del resultado genial
        String nuevaValoracion = 'Negativo';

        System.runAs(usuario){
        Test.startTest();
        SAC_GenialView_Controller.guardarValorResumen(pretension.Id, nuevaValoracion);
        Test.stopTest();
        }
        // Verificar que la valoración se haya actualizado correctamente
        SAC_Genial_Resultado__c resultadoGenial = [SELECT SAC_ValoracionResumen__c FROM SAC_Genial_Resultado__c WHERE Id = :genResShadow.Id];
        System.assertEquals(nuevaValoracion, resultadoGenial.SAC_ValoracionResumen__c, 'La valoración se actualizó correctamente');
    }
    
    //test boton de asignar reclamantes
    @istest
    public static void asignarReclamantes() {
        Case reclamacion = [SELECT Id FROM Case WHERE SAC_EmailRepresentante__c = 'rec@invalid.com' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String reclaResRT = Schema.SObjectType.SAC_Genial_Resultado__c.getRecordTypeInfosByDeveloperName().get('SAC_Reclamante_IA').getRecordTypeId();
		SAC_Genial_Resultado__c genResPret;
        genResPret = new SAC_Genial_Resultado__c(
            SAC_Reclamacion__c = reclamacion.id,
            SAC_NumeroDelDocumento__c = '52739416F',
            SAC_FirstName__c = 'Baptista',
            SAC_LastName__c = 'Pous',
            SAC_EmailRepresentante__c = 'diferente2@invalid.com',
            recordTypeId = reclaResRT
        );
        Database.insert(genResPret);
        
        
        System.runAs(usuario){
            Test.startTest();
            SAC_GenialView_Controller.asignarReclamantes(reclamacion.id);
            Test.stopTest();
        }
        
        system.assertEquals(2, [SELECT count() FROM ACCOUNT], 'debería haber 2 accounts');
    } 
}