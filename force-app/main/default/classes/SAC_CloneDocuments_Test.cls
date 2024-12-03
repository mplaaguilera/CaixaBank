/*****************************************************************
 * Name: SAC_CloneDocuments_Test
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Testear SAC_CloneDocuments
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US478280         Marcela Neira        10/11/22     Creación Clase
 * 1.1            US563153         Jose Carlos Blanco   29/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_CloneDocuments_Test {
        
        @testSetup 
        static void setup() {

            System.runAs(new User(Id = Userinfo.getUserId())) {
                //Usuario SAC General
                User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];       
                Database.insert(usuarioAdmin);

                PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
                PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
                permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
                permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
                Database.insert(permiSetAssiAdmin);
            
                System.runAs(usuarioAdmin){
                    // create accounts
                    List<Account> acctList = SAC_TestDataFactory.crearCuentasNoClientePA(4);
                    Database.insert(acctList);
            
                    // create ContentVersions
                    list<ContentVersion> cvList = new list<ContentVersion>();
                    cvList.add( new ContentVersion(Title = 'test1',PathOnClient = 'Test1.txt',VersionData = Blob.valueOf('test data 1'), IsMajorVersion = true) );
                    cvList.add( new ContentVersion(Title = 'test2',PathOnClient = 'Test2.txt',VersionData = Blob.valueOf('test data 2'), IsMajorVersion = true) );
                    cvList.add( new ContentVersion(Title = 'test3',PathOnClient = 'Test3.txt',VersionData = Blob.valueOf('test data 3'), IsMajorVersion = true) );
                    Database.insert(cvList);
            
                    // retrieve Ids for ContentDocuments created on insert of ContentVersions
                    list<Id> cdIdList = new list<Id>();
                    for (ContentDocument cd : [SELECT Id, LatestPublishedVersionId
                                            FROM ContentDocument
                                            WHERE (LatestPublishedVersionId = :cvList[0].Id 
                                                    OR LatestPublishedVersionId = :cvList[1].Id
                                                    OR LatestPublishedVersionId = :cvList[2].Id)
                                            ORDER BY Title]) {
                        cdIdList.add(cd.Id);
                    }
                    system.assertEquals(3, cdIdList.size());
                    
                    // create ContentDocumentLink links. 2 for TestAcct (1) and 1 for TestAcct (2)
                    list<ContentDocumentLink> cdlList = new list<ContentDocumentLink>();
                    cdlList.add(new ContentDocumentLink(ContentDocumentId=cdIdList[0], LinkedEntityId=acctList[0].Id, ShareType='V'));
                    cdlList.add(new ContentDocumentLink(ContentDocumentId=cdIdList[1], LinkedEntityId=acctList[0].Id, ShareType='V'));
                    cdlList.add(new ContentDocumentLink(ContentDocumentId=cdIdList[2], LinkedEntityId=acctList[1].Id, ShareType='V'));
                    Database.insert(cdlList); 
                }
            }
        }
    
        @isTest 
        static void testDocumentClone() {
            SAC_CloneDocuments pbcd;
            list<SAC_CloneDocuments> pbcdList = new list<SAC_CloneDocuments>();
            list<Account> acctList = [SELECT Id, Name FROM Account];
    
            // clone from account (1) to (2) - 2 docs
            pbcdList.add(new SAC_CloneDocuments(acctList[0].Id, acctList[1].Id) );
            // clone from account (1) to (3) - 2 docs
            pbcdList.add(new SAC_CloneDocuments(acctList[0].Id, acctList[2].Id) );
            // clone from account (1) to (4) - 2 docs
            pbcdList.add(new SAC_CloneDocuments(acctList[0].Id, acctList[3].Id) );
            // clone from account (2) to (4) - 1 doc
            pbcdList.add(new SAC_CloneDocuments(acctList[1].Id, acctList[3].Id) );
            
            
            User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		    System.runAs(usuario){
                // run SAC_CloneDocuments method
                SAC_CloneDocuments.cloneDocuments(pbcdList);
             
                // check total number documents
                system.assertEquals(10, [SELECT count() FROM ContentDocument]);
                // check documents linked per account
                system.assertEquals(2, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId=:acctList[0].Id]);
                system.assertEquals(3, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId=:acctList[1].Id]);
                system.assertEquals(2, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId=:acctList[2].Id]);
                system.assertEquals(3, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId=:acctList[3].Id]);
            }
        }
}