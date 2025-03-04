/*****************************************************************
 * Name: SAC_GrupoColaboradorContact_BU_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Grupo_Colaborador_Contact_BU_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0                     		   Daniel Benito        14/03/22     Creación
 * 1.1            US494240         Jose Carlos Blanco   28/11/22     Modificación
 * 1.2            US563153         Jose Carlos Blanco  	31/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public class SAC_GrupoColaboradorContact_BU_Test {
    
    @TestSetup
    static void makeData(){
        List<CC_Grupo_Colaborador__c> gruposColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',2);
        gruposColaborador[0].SAC_PorcentajeAsignacion__c=100;
        gruposColaborador[0].SAC_MaximoCasosDiarios__c = 15;
        gruposColaborador[1].SAC_PorcentajeAsignacion__c=100;
        gruposColaborador[1].SAC_MaximoCasosDiarios__c = 15;
        
        //Database.insert(gruposColaborador);


        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
        SAC_DatabaseDML.insertListDML(usuarios, false);
        //Database.insert(usuarios);

        System.runAs (usuarios[0]) { 
            PermissionSet ps = [select id from PermissionSet where PermissionSet.Label = 'SAC_Administrador'];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = usuarios[0].id);
            SAC_DatabaseDML.insertDML(psa, false);
            //Database.insert(psa);

            SAC_DatabaseDML.insertDML(gruposColaborador[0], false);
            //Database.insert(gruposColaborador[0]);

            CC_Grupo_Colaborador_Contact__c contact = SAC_TestDataFactory.crearColaboradorContact(usuarios[0].id, gruposColaborador[0].id);
            SAC_DatabaseDML.insertDML(contact, false);
            //Database.insert(contact);
        }

        System.runAs (usuarios[1]) { 
            PermissionSet psNA = [select id from PermissionSet where PermissionSet.Label = 'SAC_General'];
            PermissionSetAssignment psaNA = new PermissionSetAssignment(PermissionSetId = psNA.id, AssigneeId = usuarios[1].id);
            SAC_DatabaseDML.insertDML(psaNA, false);
            //Database.insert(psaNA);

            SAC_DatabaseDML.insertDML(gruposColaborador[1], false);
            //Database.insert(gruposColaborador[1]);

            CC_Grupo_Colaborador_Contact__c contactNA = SAC_TestDataFactory.crearColaboradorContact(usuarios[1].id, gruposColaborador[1].id);
            SAC_DatabaseDML.insertDML(contactNA, false);
            //Database.insert(contactNA);
        }  
    }
    
     @isTest
    	static void insertarGrupoColaboradorcontactTest() {
        User usuarioGeneral = [SELECT id From User Where Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        CC_Grupo_Colaborador_Contact__c contact = [SELECT id, SAC_Administrador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: usuarioGeneral.id LIMIT 1];            
        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label = 'SAC_General'];
		PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);
        SAC_DatabaseDML.insertDML(psa, false);
		//Database.insert(psa);
            
        system.runAs(usuarioGeneral){
            
            CC_Grupo_Colaborador__c gc = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedor 0'];
            
            contact.SAC_Administrador__c = true;
                      
            Test.startTest();
            SAC_DatabaseDML.updateDML(contact, false);
			//Database.update(contact);
            Test.stopTest();
            
            List<CC_Grupo_Colaborador_Contact__c> contacts = [SELECT id,SAC_Administrador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c =: gc.id LIMIT 1];
                        
            system.assertEquals(true, contacts[0].SAC_Administrador__c, 'No se ha actualizado el contact.');   
        }
            
    }
    @isTest
    	static void insertarGrupoColaboradorcontactNATest() {
        User usuarioGeneralNA = [SELECT id From User Where Username = 'usertest1@test.com.testSetup' AND isActive = true Limit 1];
        CC_Grupo_Colaborador_Contact__c contactNA = [SELECT id, SAC_Administrador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: usuarioGeneralNA.id LIMIT 1];            
        PermissionSet psNA = [select id from PermissionSet where PermissionSet.Label = 'SAC_General'];
		PermissionSetAssignment psaNA = new PermissionSetAssignment(PermissionSetId = psNA.id, AssigneeId = usuarioGeneralNA.id);
		/*Database.insert(psaNA);*/
            
        system.runAs(usuarioGeneralNA){
            
            CC_Grupo_Colaborador__c gcNA = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Proveedor 1'];
            
            contactNA.SAC_Administrador__c = true; //true
                      
            Test.startTest();
            SAC_DatabaseDML.updateDML(contactNA, false);
			//Database.update(contactNA);
            Test.stopTest();
            
            List<CC_Grupo_Colaborador_Contact__c> contactsNA = [SELECT id,SAC_Administrador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c =: gcNA.id LIMIT 1];
                        
            system.assertEquals(true, contactsNA[0].SAC_Administrador__c, 'No se ha actualizado el contact.');
        }      
    }
}