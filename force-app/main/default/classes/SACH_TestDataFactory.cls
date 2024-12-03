/*****************************************************************
 * Name: SACH_TestDataFactory
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Clase para crear datos para las clases test de forma centralizada. (Basado en SAC_TestDataFactory)
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US804406         Moisés Cano         14/03/24          Creación
*****************************************************************/

public with sharing class SACH_TestDataFactory {
   
     /*-----CREACION USUARIO-----*/
     public static List<User> crearUsuarioSACHGeneral(Integer numUsers){
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'SACH_Usuario_CaixaBank'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SACH'];
        for(Integer i=0;i<numUsers;i++){
            User user = new User(
                Username = 'usertest' + i + '@test.com.testSetup',
                Email = 'email' + i + '@test.com',
                LastName = 'Usuario Test' + i,
                ProfileId = profileId,
                Alias = 'alias' + i,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'es_ES',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                isActive = true,
                userRole = uRole // <---- añadido recientemente   
            );
            userList.add(user);
        }
        return userList;
    }

      /*-----CREACION USUARIO-----*/
      public static List<User> crearUsuarioaSACH(Integer numUsers){
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' or Name = 'Administrador del sistema'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SACH'];
        for(Integer i=0;i<numUsers;i++){
            User user = new User(
                Username = 'useratest' + i + '@test.com.testSetup',
                Email = 'emailadmin' + i + '@test.com',
                LastName = 'Usuario adminTest' + i,
                ProfileId = profileId,
                Alias = 'aladmin' + i,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'es_ES',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                isActive = true,
                userRole = uRole // <---- añadido recientemente   
            );
            userList.add(user);
        }
        return userList;
    }


}