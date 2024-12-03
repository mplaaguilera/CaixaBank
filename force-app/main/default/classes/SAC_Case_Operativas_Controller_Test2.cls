@isTest
public with sharing class SAC_Case_Operativas_Controller_Test2 {
    @TestSetup
    static void makeData(){

        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        Id recTypeLetrado = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            Database.insert(usuarioGeneral);
        
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        /*User usuarioGeneral = new User();
        usuarioGeneral.Username = 'usergeneral@test.com';
        usuarioGeneral.Email = 'email@test.com';
        usuarioGeneral.LastName = 'usuarioGeneral Test';
        usuarioGeneral.ProfileId = profileId;
        usuarioGeneral.Alias = 'alias';
        usuarioGeneral.TimeZoneSidKey = 'GMT';
        usuarioGeneral.LocaleSidKey = 'es_ES';
        usuarioGeneral.EmailEncodingKey = 'ISO-8859-1';
        usuarioGeneral.LanguageLocaleKey = 'en_US';
        usuarioGeneral.isActive = true;  
        
        Database.insert(usuarioGeneral);*/

        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador_Contact__c> listaGruposColab = new List<CC_Grupo_Colaborador_Contact__c>();

        System.runAs(usuarioGeneral){
            CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
            grupoColaborador.name = 'grupoColaboradorTest';
            grupoColaborador.RecordTypeId = recType;
            grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
            grupoColaborador.SAC_MaximoCasosDiarios__c = 30;
            listaGrupos.add(grupoColaborador);

            CC_Grupo_Colaborador__c grupoLetrado = new CC_Grupo_Colaborador__c();
            grupoLetrado.name = 'letrado';
            grupoLetrado.RecordTypeId = recTypeLetrado; 
            listaGrupos.add(grupoLetrado);
            Database.insert(listaGrupos);
    
            CC_Grupo_Colaborador_Contact__c grupoColabContact = new CC_Grupo_Colaborador_Contact__c();
            grupoColabContact.CC_Grupo_Colaborador__c = grupoColaborador.id;
            grupoColabContact.CC_Usuario__c = usuarioGeneral.id;    
            listaGruposColab.add(grupoColabContact);

            CC_Grupo_Colaborador_Contact__c grupoColabLetrado = new CC_Grupo_Colaborador_Contact__c();
            grupoColabLetrado.CC_Grupo_Colaborador__c = grupoLetrado.id;
            grupoColabLetrado.CC_Usuario__c = usuarioGeneral.id;    
            listaGruposColab.add(grupoColabLetrado);

            Database.insert(listaGruposColab);

        }       

        Group colaSupervisores = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PteSupervisor' LIMIT 1];
        GroupMember miembroGrupo = new GroupMember(GroupId = colaSupervisores.id, UserOrGroupId = usuarioGeneral.Id);
        Database.insert(miembroGrupo);
  
    }

    @istest 
    static void tomarPropiedad_Test() {

        Group colaSupervisores = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PteSupervisor' LIMIT 1];
        User usuarioGeneral = [SELECT Id, UserName FROM User WHERE UserName = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral) {
            Case reclamacion = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId(),
                                    OwnerId = colaSupervisores.Id, Status = 'Alta', SAC_StatusAuxiliar__c = 'Alta', Subject = 'Reclamacion');
            Database.insert(reclamacion);
            reclamacion = [SELECT id FROM Case WHERE Subject = 'Reclamacion'];
            SAC_Case_Operativas_Controller.tomarPropiedadCaso(reclamacion.id, usuarioGeneral.id);            
        }

        Case reclamacion = [SELECT id, OwnerId FROM Case WHERE Subject = 'Reclamacion'];

        System.assertEquals(usuarioGeneral.Id, reclamacion.OwnerId, 'No ha tomado la propiedad correctamente');
    }

    @istest
    static void tomarPropiedadCasoConsulta_Test(){
        
        CC_Grupo_Colaborador__c grupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE name = 'grupoColaboradorTest'];
        User usuarioGeneral = [SELECT Id, UserName FROM User WHERE UserName = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        System.runAs(usuarioGeneral) {
            Case casoConsulta1 = new Case(Status = 'Alta',SAC_StatusAuxiliar__c ='Alta' ,SEG_Grupo__c = grupoColaborador.Id, Subject = 'consultaSAC',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId(),OwnerId = usuarioGeneral.Id);

            Database.insert(casoConsulta1);
            casoConsulta1 = [SELECT id FROM Case WHERE Subject = 'consultaSAC'];
            SAC_Case_Operativas_Controller.tomarPropiedadCasoConsulta(casoConsulta1.Id, usuarioGeneral.id);
        }

        Case casoConsulta1 = [SELECT id, OwnerId FROM Case WHERE Subject = 'consultaSAC'];

        System.assertEquals(usuarioGeneral.Id, casoConsulta1.OwnerId, 'No ha tomado la propiedad correctamente');
    }

    @istest
    static void tomarPropiedadPretensionesApex_Test(){

        Group colaSupervisores = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PteSupervisor' LIMIT 1];
        User usuarioGeneral = [SELECT Id, UserName FROM User WHERE UserName = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuarioGeneral) {
            Case reclamacion = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId(),
                                    OwnerId = colaSupervisores.Id, Status = 'Alta', SAC_StatusAuxiliar__c = 'Alta', Subject = 'Pretension');
            Database.insert(reclamacion);

            Case pretension = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId(),
                                    OwnerId = colaSupervisores.Id, Status = 'Alta', SAC_StatusAuxiliar__c = 'Alta', SuppliedCompany = 'Pretension' , SAC_Reclamacion__c = reclamacion.Id);
            Database.insert(pretension);
            pretension = [SELECT id FROM Case WHERE SuppliedCompany = 'Pretension'];
            SAC_Case_Operativas_Controller.tomarPropiedadPretensionesApex(pretension.id, usuarioGeneral.id);            
        }

        Case pretension = [SELECT id, OwnerId FROM Case WHERE Subject = 'Pretension'];

        System.assertNotEquals(null, pretension.OwnerId, 'No ha tomado la propiedad correctamente');
    }
   /* @istest
    static void elevarCasoSupervisorPre_Test(){

        User usuarioGeneral = [SELECT id, name FROM user WHERE Alias = 'alias' limit 1];
        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);
        insert psa;  

        System.runAs(usuarioGeneral) {
            Case reclamacion = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId(),
                                    Status = 'Alta', SAC_StatusAuxiliar__c = 'Alta', Subject = 'Reclamacion');
            insert reclamacion;
            reclamacion = [SELECT id FROM Case WHERE Subject = 'Reclamacion'];

            Case pretension = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId(),
                                    Status = 'Alta', SAC_StatusAuxiliar__c = 'Alta', Subject = 'Pretension', SAC_Reclamacion__c = reclamacion.Id);
            insert pretension;
            pretension = [SELECT id FROM Case WHERE Subject = 'Pretension'];
            Test.startTest();
            SAC_Case_Operativas_Controller.elevarCasoSupervisorPre(pretension.id, 'test');            
            SAC_Case_Operativas_Controller.devolverPropietarioAnteriorPre(pretension.Id, 'test');
            Test.stopTest();
        }

        Case pretension = [SELECT id, OwnerId FROM Case WHERE Subject = 'Pretension'];

        System.assertEquals(usuarioGeneral.Id, pretension.OwnerId, 'No se ha cambiado de owner correctamente');

    }*/
    @istest
    static void devolverPretensiones_Test(){
        User usuarioGeneral = [SELECT Id, UserName FROM User WHERE UserName = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuarioGeneral) {
            Case reclamacion = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId(),
                                    Status = 'Alta', SAC_StatusAuxiliar__c = 'Alta', Subject = 'Reclamacion');
            Database.insert(reclamacion);
            reclamacion = [SELECT id FROM Case WHERE Subject = 'Reclamacion'];

            Case pretension = new Case(RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId(),
                                    Status = 'Alta', SAC_StatusAuxiliar__c = 'Alta', Subject = 'Pretension', SAC_Reclamacion__c = reclamacion.Id);
            Database.insert(pretension);
            pretension = [SELECT id FROM Case WHERE Subject = 'Pretension'];
            SAC_Case_Operativas_Controller.devolverPretensionesSupervisores(pretension.Id, 'test');
        }
        Case pretension = [SELECT id, OwnerId FROM Case WHERE Subject = 'Pretension'];
        Group colaSupervisores = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PteSupervisor' LIMIT 1];
        System.assertEquals(pretension.OwnerId, colaSupervisores.Id, 'No se ha cambiado de owner correctamente');
    }

    @istest
    static void devolverPropietarioAnteriorPre_Test(){

        User usuarioGeneral = [SELECT Id, UserName FROM User WHERE UserName = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        //Reclamacion
		Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('SAC_UserElevoASupervisor__c', usuarioGeneral.Id);
        camposRecl.put('OwnerId', usuarioGeneral.Id);
        
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(reclamacion);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'TestPret');
        camposPret.put('SAC_Reclamacion__c', reclamacion.id);

        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        Database.insert(pretension);

        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Case pret = [SELECT Id, SAC_ObservacionesSupervisor__c FROM Case WHERE SuppliedCompany = 'TestPret' AND SAC_Reclamacion__c =: caso.id LIMIT 1];

        System.runAs(usuarioGeneral) {
            SAC_Case_Operativas_Controller.devolverPropietarioAnteriorPre(caso.id, 'comentario test');
        }

        Case pretUpd = [SELECT Id, SAC_ObservacionesSupervisor__c FROM Case WHERE SuppliedCompany = 'TestPret' AND SAC_Reclamacion__c =: caso.id LIMIT 1];
        System.assertEquals(pret.SAC_ObservacionesSupervisor__c, pretUpd.SAC_ObservacionesSupervisor__c, 'No se han modificado los comentarios.');
    }

}