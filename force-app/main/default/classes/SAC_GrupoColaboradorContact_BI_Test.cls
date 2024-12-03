/*****************************************************************
 * Name: SAC_GrupoColaboradorContact_BI_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Grupo_Colaborador_Contact_BI_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE       Description
 * 1.0                     		   Daniel Benito        14/03/22   Creación
 * 1.1            US494240         Jose Carlos Blanco   24/11/22   Modificación (agregado usuario no Admin)
 * 1.2            US563153         Jose Carlos Blanco  	31/03/23   Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_GrupoColaboradorContact_BI_Test {
    
    @TestSetup
    static void makeData(){
       
        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
        Database.insert(usuarios);

        system.runAs(usuarios[0]){
            CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1)[0];
            grupoColaborador.SAC_PorcentajeAsignacion__c=100;
            grupoColaborador.SAC_MaximoCasosDiarios__c = 15;
            Database.insert(grupoColaborador);
        }
        system.runAs(usuarios[1]){
            CC_Grupo_Colaborador__c grupoColaboradorNA = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1)[0];
            grupoColaboradorNA.SAC_PorcentajeAsignacion__c=100;
            grupoColaboradorNA.SAC_MaximoCasosDiarios__c = 15;
            Database.insert(grupoColaboradorNA);
        }
    }
    
    @isTest
    	static void insertarGrupoColaboradorcontact_Test() {
        User usuarioGeneral = [SELECT id From User Where Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label = 'SAC_Administrador'];
		PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);
        Database.insert(psa);
            
        system.runAs(usuarioGeneral){
            
            CC_Grupo_Colaborador__c gc = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedor 0'];
            
            CC_Grupo_Colaborador_Contact__c contact = SAC_TestDataFactory.crearColaboradorContact(usuarioGeneral.id, gc.id);
        
            Test.startTest();
            Database.insert(contact);
            Test.stopTest();
            
            List<CC_Grupo_Colaborador_Contact__c> contacts = [SELECT id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c =: gc.id LIMIT 1];
                        
            system.assertEquals(contact.id, contacts[0].id, 'No se ha insertado el contact.');   
        }       
    }
    @isTest
    	static void insertarGrupoColaboradorcontactNA_Test() {
        User usuarioGeneralNA = [SELECT id From User Where Username = 'usertest1@test.com.testSetup' AND isActive = true Limit 1];
        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label = 'SAC_General'];
		PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = usuarioGeneralNA.id);
		Database.insert(psa);
            
        system.runAs(usuarioGeneralNA){
            
            CC_Grupo_Colaborador__c gcNA = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedor 0'];
            
            CC_Grupo_Colaborador_Contact__c contactNA = SAC_TestDataFactory.crearColaboradorContact(usuarioGeneralNA.id, gcNA.id);
        
            Test.startTest();
            Database.insert(contactNA);
            Test.stopTest();
            
            List<CC_Grupo_Colaborador_Contact__c> contactsNA = [SELECT id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c =: gcNA.id LIMIT 1];
                        
            system.assertEquals(contactNA.id, contactsNA[0].id, 'No se ha insertado el contact.'); 
        }      
    }
}