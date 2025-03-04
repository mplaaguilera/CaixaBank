/*********************************************************************************************************
 * Name: SAC_GrupoColaboradorContact_Test
 * Copyright © 2022  CaixaBank
 *  
 * Proposito: Testear la clase SAC_GrupoColaboradorContact
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US361683         Marcela Neira        05/02/22     Creación
 * 1.1            US563153         Jose Carlos Blanco  	12/04/23     Modificación (test modificada usando el SAC_TestDataFactory)
**********************************************************************************************************/
@istest
public with sharing class SAC_GrupoColaboradorContact_Test {
    @TestSetup
    static void makeData(){
        
        //USUARIO SAC_General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);
        //Database.insert(usuarioGeneral);

        System.runAs(usuarioGeneral){
            List <CC_Grupo_Colaborador__c> listaGrupos = new List <CC_Grupo_Colaborador__c>();

            List<CC_Grupo_Colaborador__c> gProveedores = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',3);
            gProveedores[0].Name = 'Proveedor'; 
            gProveedores[0].SAC_MaximoCasosDiarios__c = 10; 
            gProveedores[0].SAC_PorcentajeAsignacion__c = 100;
            gProveedores[1].Name = 'Asesoría Jurídica';
            gProveedores[1].SAC_MaximoCasosDiarios__c = 10; 
            gProveedores[1].SAC_PorcentajeAsignacion__c = 100;
            gProveedores[2].Name = 'VidaCaixa'; 
            gProveedores[2].SAC_MaximoCasosDiarios__c = 10;
            gProveedores[2].SAC_PorcentajeAsignacion__c = 100;

            CC_Grupo_Colaborador__c gTareas = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            gTareas.Name = 'COPS'; 
            gTareas.SAC_MaximoCasosDiarios__c = 10; 
            gTareas.SAC_PorcentajeAsignacion__c = 100;
           
            listaGrupos.addAll(gProveedores);
            listaGrupos.add(gTareas);
            SAC_DatabaseDML.insertListDML(listaGrupos, false);
            //Database.insert(listaGrupos);
        }
    }

    @istest
    static void accionesDMLColaborador(){
        CC_Grupo_Colaborador__c gProveedor = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Proveedor'];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true];

        CC_Grupo_Colaborador_Contact__c contact = new CC_Grupo_Colaborador_Contact__c();
        contact.CC_Grupo_Colaborador__c = gProveedor.id;
        contact.CC_Usuario__c = usuario.id;
        
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.insertDML(contact, false);
            //Database.insert(contact);
            contact.CC_Usuario__c = null;
            SAC_DatabaseDML.updateDML(contact, false);
            //Database.update(contact);
            SAC_DatabaseDML.deleteDML(contact, false);
            //Database.delete(contact);
            Test.stopTest();
    
            gProveedor = [SELECT Id, SAC_TieneUsuariosActivos__c FROM CC_Grupo_Colaborador__c WHERE Name = 'Proveedor'];
    
            System.assertEquals(false, gProveedor.SAC_TieneUsuariosActivos__c, 'No ha funcionado el método');
        }
        
    } 


    @istest
    static void accionesDMLColaboradorCOPS(){
        CC_Grupo_Colaborador__c gProveedor = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS'];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true];

        CC_Grupo_Colaborador_Contact__c contact = new CC_Grupo_Colaborador_Contact__c();
        contact.CC_Grupo_Colaborador__c = gProveedor.id;
        contact.CC_Usuario__c = usuario.id;
        contact.SAC_Administrador__c = true;
        
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.insertDML(contact, false);
            //Database.insert(contact);
            contact.CC_Usuario__c = null;
            SAC_DatabaseDML.updateDML(contact, false);
            //Database.update(contact);
            SAC_DatabaseDML.deleteDML(contact, false);
            //Database.delete(contact);
            Test.stopTest();
    
            gProveedor = [SELECT Id, SAC_TieneUsuariosActivos__c FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS'];
    
            System.assertEquals(false, gProveedor.SAC_TieneUsuariosActivos__c, 'No ha funcionado el método');
        }
        
    } 

    @istest
    static void accionesDMLColaboradorAJ(){
        CC_Grupo_Colaborador__c gProveedor = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Asesoría Jurídica'];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true];

        CC_Grupo_Colaborador_Contact__c contact = new CC_Grupo_Colaborador_Contact__c();
        contact.CC_Grupo_Colaborador__c = gProveedor.id;
        contact.CC_Usuario__c = usuario.id;
        
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.insertDML(contact, false);
            //Database.insert(contact);
            contact.CC_Usuario__c = null;
            SAC_DatabaseDML.updateDML(contact, false);
            //Database.update(contact);
            SAC_DatabaseDML.deleteDML(contact, false);
            //Database.delete(contact);
            Test.stopTest();
    
            gProveedor = [SELECT Id, SAC_TieneUsuariosActivos__c FROM CC_Grupo_Colaborador__c WHERE Name = 'Asesoría Jurídica'];
    
            System.assertEquals(false, gProveedor.SAC_TieneUsuariosActivos__c, 'No ha funcionado el método');
        }
        
    } 

    @istest
    static void accionesDMLColaboradorVidaCaixa(){
        CC_Grupo_Colaborador__c gProveedor = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'VidaCaixa'];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true];

        CC_Grupo_Colaborador_Contact__c contact = new CC_Grupo_Colaborador_Contact__c();
        contact.CC_Grupo_Colaborador__c = gProveedor.id;
        contact.CC_Usuario__c = usuario.id;
        
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.insertDML(contact, false);
            //Database.insert(contact);
            contact.CC_Usuario__c = null;
            SAC_DatabaseDML.updateDML(contact, false);
            //Database.update(contact);
            SAC_DatabaseDML.deleteDML(contact, false);
            //Database.delete(contact);
            Test.stopTest();
    
            gProveedor = [SELECT Id, SAC_TieneUsuariosActivos__c FROM CC_Grupo_Colaborador__c WHERE Name = 'VidaCaixa'];
    
            System.assertEquals(false, gProveedor.SAC_TieneUsuariosActivos__c, 'No ha funcionado el método');
        }  
    } 

    @istest
    static void accionesDMLColaboradorAdministrador(){
        CC_Grupo_Colaborador__c gProveedor = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS'];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true];

        CC_Grupo_Colaborador_Contact__c contact = new CC_Grupo_Colaborador_Contact__c();
        contact.CC_Grupo_Colaborador__c = gProveedor.id;
        contact.CC_Usuario__c = usuario.id;
        contact.SAC_Administrador__c = false;
        
        System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.insertDML(contact, false);
            //Database.insert(contact);
            contact.CC_Usuario__c = null;
            SAC_DatabaseDML.updateDML(contact, false);
            //Database.update(contact);
            SAC_DatabaseDML.deleteDML(contact, false);
            //Database.delete(contact);
            Test.stopTest();
    
            gProveedor = [SELECT Id, SAC_TieneUsuariosActivos__c FROM CC_Grupo_Colaborador__c WHERE Name = 'COPS'];
    
            System.assertEquals(false, gProveedor.SAC_TieneUsuariosActivos__c, 'No ha funcionado el método');
        }
        
    } 
}