/*****************************************************************
 * Name: SACH_TestDataFactory_Test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Testear la clase SACH_TestDataFactory.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US535374         Moisés Cano   15/03/24     Creación
*****************************************************************/




@isTest
public with sharing class SACH_TestDataFactory_Test {
    @TestSetup
    public static void crearDatosPrueba() {
        
        //Usuario SAC General
            User usuarioGeneral = SACH_TestDataFactory.crearUsuarioaSACH(1)[0];      
            Database.insert(usuarioGeneral);
    }

    @isTest
    static void crearTestData(){
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){

        Map<String, Object> camposCaso = new Map<String, Object>();
        camposCaso.put('Subject', 'Test Subject');
        camposCaso.put('Status', 'SAC_001');
        camposCaso.put('Description', 'Test Description');

        
            Test.startTest();
            List<User> usuariosDos = SACH_TestDataFactory.crearUsuarioSACHGeneral(2);
            List<User> usuariosTres = SACH_TestDataFactory.crearUsuarioSACHGeneral(3);
            List<User> usuarioAdmin = SACH_TestDataFactory.crearUsuarioaSACH(1);
            Database.insert(usuariosDos);
            System.assertEquals(2, usuariosDos.size(), 'No se han creado los dos usuarios.');
            System.assertEquals(3, usuariosTres.size(), 'No se han creado los tres usuarios.');
            System.assertEquals(1, usuarioAdmin.size(), 'No se han creado el usuario admin.');
            Test.stopTest();
        }     
    } 
    @isTest
    public static void crearTestData2(){
        User usuario = [SELECT id FROM User WHERE Username = 'useratest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Test.startTest();
            List<User> usuariosDos = SACH_TestDataFactory.crearUsuarioSACHGeneral(2);
            List<User> usuariosTres = SACH_TestDataFactory.crearUsuarioSACHGeneral(3);
            Database.insert(usuariosDos);
            System.assertEquals(2, usuariosDos.size(), 'No se han creado los dos usuarios.');
            System.assertEquals(3, usuariosTres.size(), 'No se han creado los tres usuarios.');
            
            Test.stopTest();
        }
    }
   
}