@isTest
public with sharing class SAC_ReasignInteraccionMasiva_LWC_VF_Test {

    @TestSetup
    static void makeData(){

        Id recordTypeRecla = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();

        User usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];    
        SAC_DatabaseDML.insertDML(usuarios, false);  
        //Database.insert(usuarios);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarios.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);  
        //Database.insert(permiSetAssi);

        System.runAs(usuarios){
       //grupo colaborador
        CC_Grupo_Colaborador__c grupo = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
        grupo.Name = 'grupoTest';
        grupo.SAC_PermiteEscalado__c = true;
        grupo.SAC_NivelGrupo__c = 'SAC_Nivel3';
        grupo.recordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        grupo.SAC_Email__c = 'correo@test.com';
        grupo.SAC_Email2__c = 'correo2@test.com';
        grupo.SAC_Email3__c = 'correo3@test.com';
        grupo.SAC_Externo__c = true;
        grupo.SAC_DeveloperName__c   = 'AJ';
        SAC_DatabaseDML.insertDML(grupo, false);  
        //Database.insert(grupo);

        CC_Grupo_Colaborador__c grupo2 = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
        grupo2.Name = 'grupoTest';
        grupo2.SAC_PermiteEscalado__c = true;
        grupo2.SAC_NivelGrupo__c = 'SAC_Nivel3';
        grupo2.recordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        grupo2.SAC_Email__c = 'correo@test.com';
        grupo2.SAC_Email2__c = 'correo2@test.com';
        grupo2.SAC_Email3__c = 'correo3@test.com';
        grupo2.SAC_DeveloperName__c   = 'CDMX';
        SAC_DatabaseDML.insertDML(grupo2, false);  
        //Database.insert(grupo2);

        //grupo colaborador contact
        CC_Grupo_Colaborador_Contact__c grupoColabContact = SAC_TestDataFactory.crearColaboradorContact(usuarios.Id, grupo.id);
        SAC_DatabaseDML.insertDML(grupoColabContact, false);  
        //Database.insert(grupoColabContact);

        //grupo colaborador contact 2
        CC_Grupo_Colaborador_Contact__c grupoColabContact2 = SAC_TestDataFactory.crearColaboradorContact(usuarios.Id, grupo2.id);
        SAC_DatabaseDML.insertDML(grupoColabContact2, false);  
        //Database.insert(grupoColabContact2);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuarios.Id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);  
        //Database.insert(casoReclamacion);

        //Reclamacion
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'Alta');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl2.put('SAC_CasoEspecial__c', 'SAC_Presidencia');

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        SAC_DatabaseDML.insertDML(casoReclamacion2, false);  
        //Database.insert(casoReclamacion2);

        //Interaccion Escalado
        List<SAC_Interaccion__c> listaInteracciones = new List<SAC_Interaccion__c>();

        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Titulo__c', 'propuesta test');
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_CasoEscalado__c', casoReclamacion.Id);
        camposEsc.put('SAC_Email1__c', 'testing@test.test');
        camposEsc.put('OwnerId', usuarios.Id);
        camposEsc.put('SAC_GrupoColaborador__c', grupo.Id);
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposEsc.put('SAC_ImporteAutorizado__c', 20);
        
        SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
        listaInteracciones.add(escalado);

        Map<String, Object> camposEsc2 = new Map<String, Object>();
        camposEsc2.put('SAC_Titulo__c', 'propuesta test2');
        camposEsc2.put('SAC_Propuesta__c', 'propuesta test2');
        camposEsc2.put('SAC_CasoEscalado__c', casoReclamacion.Id);
        camposEsc2.put('SAC_Email1__c', 'testing@test.test');
        camposEsc2.put('OwnerId', usuarios.Id);
        camposEsc2.put('SAC_GrupoColaborador__c', grupo.Id);
        camposEsc2.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposEsc2.put('SAC_ImporteAutorizado__c', 20);
        
        SAC_Interaccion__c escalado2 = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc2);
        listaInteracciones.add(escalado2);

        Map<String, Object> camposEsc3 = new Map<String, Object>();
        camposEsc3.put('SAC_Titulo__c', 'grupo');
        camposEsc3.put('SAC_Propuesta__c', 'propuesta test2');
        camposEsc3.put('SAC_CasoEscalado__c', casoReclamacion.Id);
        camposEsc3.put('SAC_Email1__c', 'testing@test.test');
        camposEsc3.put('OwnerId', usuarios.Id);
        camposEsc3.put('SAC_GrupoColaborador__c', grupo2.Id);
        camposEsc3.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposEsc3.put('SAC_ImporteAutorizado__c', 20);
        
        SAC_Interaccion__c escalado3 = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc3);
        listaInteracciones.add(escalado3);

        SAC_DatabaseDML.insertListDML(listaInteracciones, false);  
        //Database.insert(listaInteracciones);
        
        //Interaccion Consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Reclamacion__c', casoReclamacion.id);
        camposCons.put('SAC_EmailRespuesta__c', 'emailentrante@entrante.com');
        camposCons.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposCons.put('SAC_Titulo__c', 'consulta');
        camposCons.put('SAC_Propuesta__c', 'propuesta test2');
        camposCons.put('SAC_Email1__c', 'testing@test.test');
        camposCons.put('OwnerId', usuarios.Id);
        
        SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        SAC_DatabaseDML.insertDML(consulta, false);  
        //Database.insert(consulta);

        // //Interaccion Consulta
        // Map<String, Object> camposCons2 = new Map<String, Object>();
        // camposCons2.put('SAC_Reclamacion__c', casoReclamacion.id);
        // camposCons2.put('SAC_EmailRespuesta__c', 'emailentrante@entrante.com');
        // camposCons2.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        // camposCons2.put('SAC_Titulo__c', 'consulta2');
        // camposCons2.put('SAC_Propuesta__c', 'propuesta test2');
        // camposCons2.put('SAC_Email1__c', 'testing@test.test');
        // camposCons2.put('OwnerId', usuarios.Id);
        
        // SAC_Interaccion__c consulta2 = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons2);
        // Database.insert(consulta2);

        Map<String, Object> camposRe = new Map<String, Object>();
        camposRe.put('SAC_Titulo__c', 'propuesta test3');
        camposRe.put('SAC_Propuesta__c', 'propuesta test3');
        camposRe.put('SAC_CasoEscalado__c', casoReclamacion2.Id);
        camposRe.put('SAC_Email1__c', 'testing@test.test');
        camposRe.put('OwnerId', usuarios.Id);
        camposRe.put('SAC_GrupoColaborador__c', grupo.Id);
        camposRe.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposRe.put('SAC_ImporteAutorizado__c', 20);
        
        SAC_Interaccion__c reescalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposRe);

        SAC_DatabaseDML.insertDML(reescalado, false);  
        //Database.insert(reescalado);        
        }
    }

    @isTest
    public static void testAsignUsers(){
        List<CC_Grupo_Colaborador_Contact__c> lstColaboradoresGrupo = new List<CC_Grupo_Colaborador_Contact__c>();
        User usuario =  [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        List<SAC_Interaccion__c> lstscalados = [SELECT id, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                                FROM SAC_Interaccion__c WHERE SAC_Titulo__c != 'consulta' AND SAC_Titulo__c != 'grupo'];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                       FROM SAC_Interaccion__c WHERE SAC_Titulo__c != 'consulta' AND SAC_Titulo__c != 'grupo' LIMIT 1];
       List<String> lstId = new List<String>();
       String error = '';
        
        System.runAs(usuario){
        Test.startTest();
        PageReference testPage = Page.SAC_ReasignacionGruposMasivo;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstscalados);
        stdSetController.setSelected(lstscalados);
            SAC_ReasignacionInteraccionMasiva_LWC_VF reasignacion = new SAC_ReasignacionInteraccionMasiva_LWC_VF(stdSetController);
            
            for(SAC_Interaccion__c interaccion : lstscalados){
                lstId.add(interaccion.id);
            }
            error = SAC_ReasignacionInteraccionMasiva_LWC_VF.validationComponente(lstId);
            lstColaboradoresGrupo = SAC_ReasignacionInteraccionMasiva_LWC_VF.getUsuarios(lstId);
    
        Test.stopTest();
        }
        System.assertEquals(1, lstColaboradoresGrupo.size());
    }

    @isTest
    public static void testChangeOwnerInteraccion(){
        List<CC_Grupo_Colaborador_Contact__c> lstColaboradoresGrupo = new List<CC_Grupo_Colaborador_Contact__c>();
        User usuario =  [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        List<SAC_Interaccion__c> lstscalados = [SELECT id, OwnerId, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                                FROM SAC_Interaccion__c WHERE SAC_Titulo__c  = 'propuesta test'];
        SAC_Interaccion__c escalado = [SELECT id, OwnerId, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                       FROM SAC_Interaccion__c WHERE SAC_Titulo__c  = 'propuesta test' LIMIT 1];
        String error = '';
        system.runAs(usuario){
        Test.startTest();
        PageReference testPage = Page.SAC_ReasignacionGruposMasivo;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstscalados);
        stdSetController.setSelected(lstscalados);

            SAC_ReasignacionInteraccionMasiva_LWC_VF reasignacion = new SAC_ReasignacionInteraccionMasiva_LWC_VF(stdSetController);
            List<String> lstId = new List<String>();
            for(SAC_Interaccion__c interaccion : lstscalados){
                lstId.add(interaccion.id);
            }
            error = SAC_ReasignacionInteraccionMasiva_LWC_VF.validationComponente(lstId);
            SAC_ReasignacionInteraccionMasiva_LWC_VF.setNewOwnerToEscalate(lstId, usuario.Id);
        
        Test.stopTest();
        }
        List<SAC_Interaccion__c> lstupdatedScalados = [SELECT id, OwnerId, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                                       FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test'];

        system.assertEquals(usuario.Id, lstupdatedScalados[0].OwnerId);
        system.assertEquals('No', error);
    }

    @isTest
    public static void testCatchError(){
        List<CC_Grupo_Colaborador_Contact__c> lstColaboradoresGrupo = new List<CC_Grupo_Colaborador_Contact__c>();
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        List<SAC_Interaccion__c> lstscalados = [SELECT id, OwnerId, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                                FROM SAC_Interaccion__c WHERE SAC_Titulo__c != 'consulta' AND SAC_Titulo__c != 'grupo'];
        SAC_Interaccion__c consultaRecord = [SELECT id, OwnerId, SAC_Conclusion__c, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                       FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta'LIMIT 1];
        SAC_Interaccion__c grupo = [SELECT id, OwnerId, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                       FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'grupo' LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT id, OwnerId, SAC_ImporteAutorizado__c, SAC_Respuesta__c, SAC_Propuesta__c, SAC_GrupoColaborador__c 
                                       FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test2' LIMIT 1];

        String error = '';
        String consulta = '';
        String recordType = '';
        
        String owner = '';
        List<String> lstEmpty = new List<String>();
		List<String> lstConsulta = new List<String>();
        List<String> lstGrupo = new List<String>();
        List<String> lstGrupo2 = new List<String>();

		lstConsulta.add(consultaRecord.Id);
        lstGrupo.add(grupo.Id);
        lstGrupo.add(consultaRecord.Id);
        lstGrupo2.add(grupo.Id);
        lstGrupo2.add(escalado.Id);
        System.runAs(usuario){
        Test.startTest();
            PageReference testPage = Page.SAC_ReasignacionGruposMasivo;
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstscalados);
            stdSetController.setSelected(lstscalados);
            SAC_ReasignacionInteraccionMasiva_LWC_VF reasignacion = new SAC_ReasignacionInteraccionMasiva_LWC_VF(stdSetController);
            error = SAC_ReasignacionInteraccionMasiva_LWC_VF.validationComponente(lstEmpty);
            consulta = SAC_ReasignacionInteraccionMasiva_LWC_VF.validationComponente(lstConsulta);
            recordType = SAC_ReasignacionInteraccionMasiva_LWC_VF.validationComponente(lstGrupo);
            SAC_ReasignacionInteraccionMasiva_LWC_VF.validationComponente(lstGrupo2);
            owner = SAC_ReasignacionInteraccionMasiva_LWC_VF.setNewOwnerToEscalate(lstEmpty, usuario.Id);
        Test.stopTest();
        }

        system.assertEquals('Escalado', error);
        system.assertEquals('EMPTY', owner);
    }
}