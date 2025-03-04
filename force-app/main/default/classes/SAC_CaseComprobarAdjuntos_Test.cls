/**************************************************************************************************
 * Name:  SAC_CaseComprobarAdjuntos_Test
 * Copyright © 2021 CaixaBank
 *
 * Proposito: Testear la clase SAC_CaseComprobarAdjuntos        
 *                                                  
 * Historial
 * 
 * VERSION        USER_STORY       AUTHOR               DATE            Description
 * 1.0            US213187         Marcela Neira        07/05/21        Creación
 * 1.1            US563153         Jose Carlos Blanco   28/03/23        Modificación (test modificada usando el SAC_TestDataFactory)   
 * ************************************************************************************************/

@isTest
  public with sharing class SAC_CaseComprobarAdjuntos_Test {
    @TestSetup
    static void makeData(){

        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
        usuarios[1].ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' OR Name = 'Usuario estándar'].Id;
        SAC_DatabaseDML.insertListDML(usuarios, false);   
        //Database.insert(usuarios);

        //Reclamación Padre
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Tarjeta');
        camposRecl.put('OwnerId', usuarios[0].id);
        
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false);   
        //Database.insert(reclamacion);

        //Reclamacion con Ficheros Adjuntos
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'Con Adjuntos');
        camposRecl2.put('OwnerId', usuarios[0].id);
        
        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        SAC_DatabaseDML.insertDML(reclamacion2, false); 
        //Database.insert(reclamacion2);

        
        ContentVersion contentVersionInsert = new ContentVersion(
                                                    Title = 'Test',
                                                    PathOnClient = 'Test.jpg',
                                                    VersionData = Blob.valueOf('Test Content Data'),
                                                    IsMajorVersion = true);
        SAC_DatabaseDML.insertDML(contentVersionInsert, false); 
        //Database.insert(contentVersionInsert);
 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink documentoLink = new ContentDocumentLink();
        documentoLink.LinkedEntityId = reclamacion2.id ;        
        documentoLink.ContentDocumentId=documents[0].Id;
        SAC_DatabaseDML.insertDML(documentoLink, false); 
        //Database.insert(documentoLink);

    }

    @isTest

    static void reclamacionSinAdjuntos(){

        User usuario = [SELECT id FROM User WHERE Email = 'email0@test.com'];
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);       
        SAC_DatabaseDML.insertDML(psa, false); 
        //Database.insert(psa);

       

        system.runAs(usuario){            
            Case casoParaModificar = [SELECT id, CC_SuppliedFiles__c, SAC_Reclamacion__c, CC_Importe_Reclamado__c FROM Case WHERE Subject = 'Tarjeta'];
            casoParaModificar.CC_SuppliedFiles__c = true;
            Boolean tenemosError = false;

            Test.startTest();
            try{
                SAC_DatabaseDML.updateDML(casoParaModificar, true); 
                //Database.update(casoParaModificar);
            }catch(Exception e){
                tenemosError = true;
            }             
            Test.stopTest();           
           
            system.assertEquals(true, tenemosError, 'Esta marcando la casilla y no tiene adjuntos');
        }
    }
@istest
    static void reclamacionConAdjuntos(){
      
        User usuario = [SELECT id FROM User WHERE Email = 'email0@test.com'];
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);  
        SAC_DatabaseDML.insertDML(psa, false);      
        //Database.insert(psa);

        system.runAs(usuario){  

            Case casoConAdjuntos = [SELECT id, CC_SuppliedFiles__c, SAC_Reclamacion__c, CC_Importe_Reclamado__c FROM Case WHERE Subject = 'Con Adjuntos'];
            casoConAdjuntos.CC_SuppliedFiles__c = true;
            Boolean tenemosError = false;            
            
            Test.startTest();
            try{
                SAC_DatabaseDML.updateDML(casoConAdjuntos, true); 
                //Database.update(casoConAdjuntos);
            }catch(Exception e){
                tenemosError = true;
            }             
            Test.stopTest();           
           
            system.assertEquals(false, tenemosError, 'El Caso no tiene adjuntos');
        }
    }

@isTest

    static void usuarioSinPermisosEnReclamacion(){
 
        User usuario = [SELECT id FROM User WHERE Email = 'email1@test.com'];
        Case casoParaModificar = [SELECT id, CC_SuppliedFiles__c, SAC_Reclamacion__c, CC_Importe_Reclamado__c FROM Case WHERE Subject = 'Tarjeta'];

        system.runAs(usuario){            
            
            casoParaModificar.CC_SuppliedFiles__c = true;
            Boolean tenemosError = false;

            Test.startTest();
            try{           
                SAC_DatabaseDML.updateDML(casoParaModificar, true);      
                //Database.update(casoParaModificar);
            }catch(Exception e){
                tenemosError = true;
            }             
            Test.stopTest();           
           
            system.assertEquals(true, tenemosError, 'No tienes acceso');
        }
    }

}