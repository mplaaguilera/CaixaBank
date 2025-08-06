/*****************************************************************
 * Name: SAC_CasosEnNegociacion_Test
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Testear la clase SAC_CasosEnNegociacion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US447862         Marcela Neira        07/09/22     Creación
 * 1.1            US563153         Jose Carlos Blanco   29/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_CasosEnNegociacion_Test {
    @TestSetup
    static void makeData(){
 
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);       
        //Database.insert(usuarioGeneral);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'cambio naturaleza');
        camposRecl.put('SAC_TipoConsumidor__c', 'Sí');
        camposRecl.put('OwnerId', usuarioGeneral.id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false); 
        //Database.insert(reclamacion);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'TestPret');
        camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
        camposPret.put('OwnerId', usuarioGeneral.id);
        camposPret.put('Status', 'SAC_003');
        

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(casoPretension, false); 
        //Database.insert(casoPretension);  
    }

    @istest
    static void informarFechaResolucionTest() {
        Case caso = [SELECT Id, OS_Fecha_Resolucion__c, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'TestPret'];
        caso.Status = 'SAC_007';
        caso.SAC_StatusAuxiliar__c = 'SAC_007';

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(caso, false); 
            //Database.update(caso);
            Test.stopTest();
        }

        Case reclamacion = [SELECT Id, OS_Fecha_Resolucion__c, SAC_Reclamacion__c FROM Case WHERE Id =:caso.SAC_Reclamacion__c];

        System.assertNotEquals(null, reclamacion.OS_Fecha_Resolucion__c, 'Ha fallado el metodo.');
    }
}