/*****************************************************************
 * Name: SAC_CaseCalcularImporte_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_CaseCalcularImporte
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US213187         Marcela Neira        05/05/21     Creación
 * 1.1            US563153         Jose Carlos Blanco   28/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/

@istest
public with sharing class SAC_CaseCalcularImporte_Test {
    
    @TestSetup
    static void makeData(){

        //Usuario con perfil SAC_General para ejecutar la acción
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);     
        //Database.insert(usuarioGeneral);


        Map<String, Object> camposRecl = new Map<String, Object>();
        
        camposRecl.clear();
        camposRecl.put('Subject', 'reclamacionVinc');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('OwnerId', usuarioGeneral.id);

        Case reclamacionVinc = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacionVinc, false);



        List<Case> listaReclamaciones = new List<Case>();
        //Reclamación Padre
        camposRecl.clear();
        camposRecl.put('Subject', 'Tarjeta');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('OwnerId', usuarioGeneral.id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(reclamacion);

        //Reclamación 2
        camposRecl.clear();
        camposRecl.put('Subject', 'Tarjeta2');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_Naturaleza__c', 'SAC_007');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('CC_CasoRelacionado__c', reclamacionVinc.Id);
        camposRecl.put('OwnerId', usuarioGeneral.id);

        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(reclamacion2);

        SAC_DatabaseDML.insertListDML(listaReclamaciones, false);
        //Database.insert(reclamacion);

        Test.startTest();
        //Pretensiones
        List<Case> listaPretensiones = new List<Case>();
        //Pretension hija
        Map<String, Object> camposPretHija = new Map<String, Object>();
        camposPretHija.put('SAC_Reclamacion__c', reclamacion.id);
        camposPretHija.put('SuppliedCompany', 'prueba');
        camposPretHija.put('CC_Importe_Reclamado__c', 0);
        camposPretHija.put('CC_Importe_Abonado__c', 0);
        camposPretHija.put('SAC_Importe_Resuelto__c', 0);
        camposPretHija.put('OwnerId', usuarioGeneral.id);

        Case pretensionHija = SAC_TestDataFactory.crearCaso('Pretension',camposPretHija);
        listaPretensiones.add(pretensionHija);

        //Pretension hija 2
        Map<String, Object> camposPretHija2 = new Map<String, Object>();
        camposPretHija2.put('SAC_Reclamacion__c', reclamacion.id);
        camposPretHija2.put('CC_Importe_Reclamado__c', 0);
        camposPretHija2.put('OwnerId', usuarioGeneral.id);

        Case pretensionHija2 = SAC_TestDataFactory.crearCaso('Pretension',camposPretHija2);
        listaPretensiones.add(pretensionHija2);

        //Pretension hija 3
        Map<String, Object> camposPretHija3 = new Map<String, Object>();
        camposPretHija3.put('SAC_Reclamacion__c', reclamacion.id);
        camposPretHija3.put('CC_Importe_Reclamado__c', 200);
        camposPretHija3.put('OwnerId', usuarioGeneral.id);
        camposPretHija3.put('SuppliedCompany', 'prueba2');
        camposPretHija3.put('SAC_Importe_Resuelto__c', 200);

        Case pretensionHija3 = SAC_TestDataFactory.crearCaso('Pretension',camposPretHija3);
        listaPretensiones.add(pretensionHija3);

        //Pretensión 4
        Map<String, Object> camposPretHija4 = new Map<String, Object>();
        camposPretHija4.put('SAC_Reclamacion__c', reclamacion2.id);
        camposPretHija4.put('SuppliedCompany', 'pruebaComplementaria');
        camposPretHija4.put('CC_Importe_Reclamado__c', 0);
        camposPretHija4.put('CC_Importe_Abonado__c', 0);
        camposPretHija4.put('SAC_Importe_Resuelto__c', 0);
        camposPretHija4.put('OwnerId', usuarioGeneral.id);

        Case pretensionHija4 = SAC_TestDataFactory.crearCaso('Pretension',camposPretHija4);
        listaPretensiones.add(pretensionHija4);

        
        SAC_DatabaseDML.insertListDML(listaPretensiones, false);
        //Database.insert(listaPretensiones);

        /*System.runAs(usuarioGeneral){
            SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1,reclamacion,false)[0];
            tarea.SAC_ImporteResuelto__c = 100;
            tarea.SAC_ImporteAbonar__c = 100;
            tarea.SAC_ImpResueltoInteresesLegales__c = 100;
            Database.insert(tarea);
        }*/
        Test.stopTest();
    }

    @isTest

    static void comprobarElCalculo(){

        Id recorType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();        
        User usuario = [SELECT id FROM User WHERE Email = 'email0@test.com' AND isActive = true];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa, false);       
        //Database.insert(psa);

       Case reclamacion = [SELECT Id, RecordTypeId FROM Case WHERE Subject = 'Tarjeta'];

        system.runAs(usuario){    
            SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1,reclamacion,false)[0];
            tarea.SAC_ImporteResuelto__c = 100;
            tarea.SAC_ImporteAbonar__c = 100;
            tarea.SAC_ImpResueltoInteresesLegales__c = 100;
            SAC_DatabaseDML.insertDML(tarea, false);  
            //Database.insert(tarea);      
            
            Case casoParaModificar = [SELECT id, SAC_Reclamacion__c, CC_Importe_Reclamado__c, SAC_Quebranto__c,CC_Importe_Abonado__c,SAC_Importe_Resuelto__c FROM Case WHERE SuppliedCompany = 'prueba'];
            casoParaModificar.CC_Importe_Reclamado__c=200;
            casoParaModificar.SAC_Quebranto__c=200;
            casoParaModificar.CC_Importe_Abonado__c=300;
            casoParaModificar.SAC_Importe_Resuelto__c=200;
            casoParaModificar.Status = 'SAC_001';
            casoParaModificar.SAC_StatusAuxiliar__c = 'SAC_001';

            Test.startTest();
            SAC_DatabaseDML.updateDML(casoParaModificar, false);  
            //Database.update(casoParaModificar); 
            Test.stopTest();           

            List<Case> pretensiones = [SELECT id, SAC_Reclamacion__c, CC_Importe_Reclamado__c, SAC_Quebranto__c,SAC_Importe_Resuelto__c, CC_Importe_Abonado__c FROM Case WHERE RecordTypeId =:recorType ];            
        }

        Decimal resultado = [SELECT CC_Importe_Reclamado__c FROM Case WHERE Subject = 'Tarjeta'].CC_Importe_Reclamado__c;
        System.assertEquals(400, resultado, 'No se han sumado los importes de las reclamaciones');
        
    }


    @isTest
    static void comprobarElCalculoTest2(){

        Id recorType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();        
        User usuario = [SELECT id FROM User WHERE Email = 'email0@test.com' AND isActive = true];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        SAC_DatabaseDML.insertDML(psa, false);       
        //Database.insert(psa);

       Case pretension = [SELECT Id, RecordTypeId, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'pruebaComplementaria'];

        System.runAs(usuario){    
             pretension.CC_Importe_Abonado__c = 5;
             SAC_DatabaseDML.updateDML(pretension, false);
        }

        Case resultado = [SELECT CC_Importe_Abonado__c, CC_CasoRelacionado__r.CC_Importe_Abonado__c FROM Case WHERE Subject = 'Tarjeta2'];
        System.assertEquals(5, resultado.CC_Importe_Abonado__c, 'No se han sumado los importes de las reclamaciones');
        
    }


    /*
    @isTest
    static void borrarPretension(){

        Id recorType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();        
        User usuario = [SELECT id FROM User WHERE Email = 'email@test.com'];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);       
        insert psa;

       

        system.runAs(usuario){          
            Case casoParaEliminar = [SELECT id, subject  FROM Case WHERE SuppliedCompany = 'prueba2'];                       
            Test.startTest();
            delete casoParaEliminar;
            Test.stopTest();
            List<Case> pretensiones = [SELECT id, SAC_Reclamacion__c, CC_Importe_Reclamado__c FROM Case WHERE RecordTypeId =:recorType ];          
        }

        Decimal resultado = [SELECT CC_Importe_Reclamado__c FROM Case WHERE Subject = 'Tarjeta'].CC_Importe_Reclamado__c;
        System.assertEquals(null, resultado, 'No se han sumado los importes de las reclamaciones');
    }*/
}