/*****************************************************************
 * Name: SAC_CargarDatosMaestro_Test
 * Copyright © 2021  CaixaBank
 *  
 * Proposito: Testear la clase SAC_CargarDatosMaestro
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US204750         Marcela Neira        18/05/21     Creación
 * 1.1            US563153         Jose Carlos Blanco   08/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_CargarDatosMaestro_Test {
    @TestSetup
    static void makeData(){
      
        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }

        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
        SAC_DatabaseDML.insertDML(grupoColaborador, false);

        List <SAC_MaestroAccionesReclamacion__c> registroTareaMaestro = SAC_TestDataFactory.crearMaestroAcciones(2,grupoColaborador.id);
        registroTareaMaestro[0].SAC_Descripcion__c = 'Llamar cliente';
        registroTareaMaestro[1].SAC_Descripcion__c = 'Rellenar Formulario';
        SAC_DatabaseDML.insertListDML(registroTareaMaestro, false);

        //PRETENSION
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'TestPret');
        camposPret.put('OwnerId', usuarioGeneral.id);

        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        SAC_DatabaseDML.insertDML(pretension, false);

        SAC_Accion__c tareaParaModificar = SAC_TestDataFactory.crearTareas(1,pretension,false)[0];
        tareaParaModificar.SAC_EquipoResponsable__c = grupoColaborador.id;
        tareaParaModificar.SAC_MaestroAccionesReclamacion__c = registroTareaMaestro[1].id;
        tareaParaModificar.SAC_Estado__c = 'SAC_PendienteEnviar';
        tareaParaModificar.OwnerId = usuarioGeneral.id;
        SAC_DatabaseDML.insertDML(tareaParaModificar, false);
    }

    @istest
    static void insertarTarea(){
       
        SAC_MaestroAccionesReclamacion__c maestroTarea = [SELECT id, SAC_Descripcion__c 
                                                            FROM SAC_MaestroAccionesReclamacion__c 
                                                            WHERE SAC_Descripcion__c = 'Llamar cliente' 
                                                            LIMIT 1];
       
        Case pretension = [SELECT Id, RecordTypeId FROM Case WHERE SuppliedCompany = 'TestPret'];

        SAC_Accion__c tareaRTMaestro = SAC_TestDataFactory.crearTareas(1, pretension, true)[0];
        tareaRTMaestro.SAC_MaestroAccionesReclamacion__c = maestroTarea.id;
        SAC_DatabaseDML.insertDML(tareaRTMaestro, false);
            
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
    
		System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(pretension, false);
            Test.stopTest();
        }        

        SAC_Accion__c tareaInsertada = [SELECT SAC_Descripcion__c 
                                        FROM SAC_Accion__c 
                                        WHERE SAC_MaestroAccionesReclamacion__c = :maestroTarea.id];
 
        System.assertEquals(maestroTarea.SAC_Descripcion__c, tareaInsertada.SAC_Descripcion__c, 'No se ha modificado la descripción');          
    }

    @istest
    static void modificarTarea(){
       
        SAC_MaestroAccionesReclamacion__c maestroTarea = [SELECT id, SAC_Descripcion__c 
                                                            FROM SAC_MaestroAccionesReclamacion__c 
                                                            WHERE SAC_Descripcion__c = 'Rellenar Formulario' 
                                                            LIMIT 1];

        SAC_Accion__c tareaParaModificar = [SELECT id, SAC_Descripcion__c, SAC_EquipoResponsable__c 
                                            FROM SAC_Accion__c
                                            LIMIT 1];

        tareaParaModificar.SAC_MaestroAccionesReclamacion__c = maestroTarea.id;
            
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.updateDML(tareaParaModificar, false);
            Test.stopTest(); 
        }       

        String idMaestroTareaParaModificar = [SELECT SAC_MaestroAccionesReclamacion__c 
                                                FROM SAC_Accion__c
                                                LIMIT 1 ].SAC_MaestroAccionesReclamacion__c;
                                
        System.assertEquals(maestroTarea.id, idMaestroTareaParaModificar, 'No se ha modificado la tarea');  
    }
    
    @istest
    static void borrarTarea(){
       
        SAC_MaestroAccionesReclamacion__c maestroTarea = [SELECT id, SAC_Descripcion__c 
                                                            FROM SAC_MaestroAccionesReclamacion__c 
                                                            WHERE SAC_Descripcion__c = 'Llamar cliente' 
                                                            LIMIT 1];
       
        SAC_Accion__c tareaParaModificar = [SELECT id, SAC_Descripcion__c, SAC_EquipoResponsable__c 
                                            FROM SAC_Accion__c
                                            LIMIT 1];

        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            SAC_DatabaseDML.deleteDML(tareaParaModificar, false);
            Test.stopTest(); 
        }       
                               
        System.assertEquals([SELECT Count() FROM SAC_Accion__c WHERE SAC_MaestroAccionesReclamacion__c = :maestroTarea.id], 0, 'No se ha borrado la tarea');            
    }
}