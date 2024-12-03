@isTest
public with sharing class SAC_AsignarTMEs_Test {
    @isTest
    static void actualizacionCaso() {

        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        //Usuario SAC Admin
		User usuarioAdmin = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioAdmin.Username = 'usertestadmin@test.com.testSetup';      
        Database.insert(usuarioAdmin);

        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        Database.insert(permiSetAssiAdmin);

        System.runAs(usuarioAdmin){
            List<CC_MCC__c> mccs = SAC_TestDataFactory.crearMCCs();
            Database.insert(mccs);
            List<SAC_ParametrizacionSLATME__c> listaParams = SAC_TestDataFactory.crearParamsSla('TME',3);
            listaParams[0].SAC_Duracion__c = 5; 
            listaParams[0].SAC_Estados__c='SAC_002';
            listaParams[1].SAC_Duracion__c = 10;
            listaParams[1].SAC_Estados__c='SAC_002;SAC_003';
            listaParams[2].SAC_Duracion__c = 15;
            listaParams[2].SAC_Estados__c='SAC_007';  
            Database.insert(listaParams);
        }
        
        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'TestPret');
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            Database.insert(casoPretension);
        }

        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestPret' LIMIT 1];

        List<SAC_TMECaso__c> tmeCreado = [SELECT Id, SAC_Parametrizacion__c, SAC_Caso__c, SAC_TMEDefinido__c, Name
                            FROM SAC_TMECaso__c 
                            WHERE SAC_Caso__c =: caso.Id];

        caso.Status = 'SAC_002';
        caso.SAC_StatusAuxiliar__c = caso.Status;

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Database.update(caso);        
            
            Case casov2 = caso;

            List<SAC_TMECaso__c> tmeCreadov2 = [SELECT Id, SAC_Parametrizacion__c, SAC_Caso__c, SAC_TMEDefinido__c, Name
                                FROM SAC_TMECaso__c 
                                WHERE SAC_Caso__c =: caso.Id];

            casov2.Status = 'SAC_007';
            casov2.SAC_StatusAuxiliar__c = casov2.Status;

            SAC_Case_BU_TRHan.actualizarVariablesControl();
            Database.update(casov2);

            Case casov3 = casov2;

            List<SAC_TMECaso__c> tmeCreadov3 = [SELECT Id, SAC_Parametrizacion__c, SAC_Caso__c, SAC_TMEDefinido__c, Name
                FROM SAC_TMECaso__c 
                WHERE SAC_Caso__c =: casov2.Id];

            casov3.Status = 'SAC_002';
            casov3.SAC_StatusAuxiliar__c = casov3.Status;
            casov3.CC_Importe_Reclamado__c = 200;
            casov3.SAC_Importe_Resuelto__c = 100;
            casov3.SAC_ResultadoNegociacion__c = 'Con acuerdo';
            SAC_Case_BU_TRHan.actualizarVariablesControl();
            Database.update(casov3);

            system.assertNotEquals(tmeCreado, tmeCreadov2, 'No se han creado TMEs en la actualizacion');
            system.assertNotEquals(tmeCreadov2, tmeCreadov3, 'No se han creado TMEs en la actualizacion');
            Test.stopTest();
        }  
    }
}