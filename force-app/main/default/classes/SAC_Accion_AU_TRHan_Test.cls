/*****************************************************************
 * Name: SAC_Accion_AU_TRHan_Test
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: test de SAC_Accion_AU_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US356803         alex perez           21/10/22     Creación
 * 1.1            US563153         Jose Carlos Blanco   20/02/23     Modificación (test modificada usando el SAC_TestDataFactory)
*****************************************************************/
@istest
public with sharing class SAC_Accion_AU_TRHan_Test {
    @TestSetup
    static void makeData(){
        
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);     
        //Database.insert(usuarioGeneral);
        
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);  
        //Database.insert(permiSetAssi);
        
        System.runAs(usuarioGeneral){
            Test.startTest();
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(reclamacion, false);  
            //Database.insert(reclamacion);
            
            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
            
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            SAC_DatabaseDML.insertDML(pretension, false);
            //Database.insert(pretension);
            
            //Tareas
            List<SAC_Accion__c> listaTareas = SAC_TestDataFactory.crearTareas(2,pretension,false);
            SAC_DatabaseDML.insertListDML(listaTareas, false);
            //Database.insert(listaTareas);
            
            CC_Grupo_Colaborador__c grupoTareas = new CC_Grupo_Colaborador__c();
            grupoTareas = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
            grupoTareas.SAC_DeveloperName__c = 'COPS';
            SAC_DatabaseDML.insertDML(grupoTareas, false);
            //Database.insert(grupoTareas);
            
            CC_Grupo_Colaborador_Contact__c grupoTareas1 = new CC_Grupo_Colaborador_Contact__c();
            grupoTareas1 = SAC_TestDataFactory.crearColaboradorContact(usuarioGeneral.id, grupoTareas.id);
            grupoTareas1.SAC_Administrador__c = true;
            SAC_DatabaseDML.insertDML(grupoTareas1, false);
            //Database.insert(grupoTareas1);
            Test.stopTest();
            
        } 
    }
    @istest
    static void updateImportesTarea(){
        list<SAC_Accion__c> listaTareas = [SELECT Id, SAC_ImporteResuelto__c, SAC_ImpResueltoInteresesLegales__c, SAC_ImporteAbonar__c, SAC_Pretension__c
                                           FROM SAC_Accion__c];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
		System.runAs(usuario){
            listaTareas[0].SAC_ImporteResuelto__c = 100.0;
            listaTareas[0].SAC_ImpResueltoInteresesLegales__c= 100.0;
            listaTareas[0].SAC_ImporteAbonar__c = 100.0;
            SAC_DatabaseDML.updateDML(listaTareas[0], false);    
            //Database.update(listaTareas[0]);

            //ver que el recalculo funciona
            for(SAC_Accion__c tarea : listaTareas) {
                decimal importes = 100.0;
                decimal importes2 = 100.0;
                if(tarea.SAC_ImporteResuelto__c == 100.0) {
                    importes = null;
                    importes2 = 50.0;
                }
                tarea.SAC_ImporteResuelto__c = importes;
                tarea.SAC_ImpResueltoInteresesLegales__c = importes;
                tarea.SAC_ImporteAbonar__c = importes2;
            }
            test.startTest();
            SAC_DatabaseDML.updateListDML(listaTareas, false);
            //Database.update(listaTareas);
            test.stopTest();
        }

        case preten = [SELECT id, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c FROM Case WHERE ID = : listaTareas[0].SAC_Pretension__c];
        system.assert(preten.SAC_Importe_Resuelto__c == 200.0 && preten.CC_Importe_Abonado__c == 150.0, 'los importes calculados no son los esperados ' + 
        preten.SAC_Importe_Resuelto__c + ' ' + preten.CC_Importe_Abonado__c);
    }

    @istest
    static void tareaActivaDescar(){
        list<SAC_Accion__c> listaTareas = [SELECT Id, SAC_ImporteResuelto__c, SAC_ImpResueltoInteresesLegales__c, SAC_ImporteAbonar__c, SAC_Pretension__c
                                           FROM SAC_Accion__c LIMIT 1];

        //ver que descuenta los importes cuando se descarta
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            listaTareas[0].SAC_ImporteResuelto__c = 100.0;
            listaTareas[0].SAC_ImpResueltoInteresesLegales__c= 100.0;
            listaTareas[0].SAC_ImporteAbonar__c = 100.0;
            SAC_DatabaseDML.updateListDML(listaTareas, false);     
            //Database.update(listaTareas);
            test.startTest();
            listaTareas[0].SAC_Estado__c = 'SAC_Descartada';
            SAC_DatabaseDML.updateListDML(listaTareas, false);   
            //Database.update(listaTareas);
            test.stopTest();
        }

        case preten = [SELECT id, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c FROM Case WHERE ID = : listaTareas[0].SAC_Pretension__c];
        system.assert(preten.SAC_Importe_Resuelto__c == 0 && preten.CC_Importe_Abonado__c == 0, 'los importes calculados no son los esperados ');
    }

    @istest
    static void tareaDescarActiva(){
        list<SAC_Accion__c> listaTareas = [SELECT Id, SAC_ImporteResuelto__c, SAC_ImpResueltoInteresesLegales__c, SAC_ImporteAbonar__c, SAC_Pretension__c
                                           FROM SAC_Accion__c LIMIT 1];

        //ver que vuelve a contar los importes cuando se vuelve a activar
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            listaTareas[0].SAC_ImporteResuelto__c = 100.0;
            listaTareas[0].SAC_ImpResueltoInteresesLegales__c= 100.0;
            listaTareas[0].SAC_ImporteAbonar__c = 100.0;
            listaTareas[0].SAC_Estado__c = 'SAC_Descartada';
            SAC_DatabaseDML.updateListDML(listaTareas, false);      
            //Database.update(listaTareas);
            test.startTest();
            listaTareas[0].SAC_Estado__c = 'SAC_PendienteEnviar';
            SAC_DatabaseDML.updateListDML(listaTareas, false);
            //Database.update(listaTareas);
            test.stopTest();
        }

        case preten = [SELECT id, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c FROM Case WHERE ID = : listaTareas[0].SAC_Pretension__c];
        system.assert(preten.SAC_Importe_Resuelto__c == 200 && preten.CC_Importe_Abonado__c == 100, 'los importes calculados no son los esperados ' + 
        preten.SAC_Importe_Resuelto__c + ' ' + preten.CC_Importe_Abonado__c);
    }
}