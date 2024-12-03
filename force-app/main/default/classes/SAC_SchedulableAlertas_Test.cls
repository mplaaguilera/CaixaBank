@isTest
public with sharing class SAC_SchedulableAlertas_Test {
    @TestSetup
    static void makeData(){
        Id recordTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        Id recTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recTypeGrupoLetradosDT = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoLetradosDT').getRecordTypeId();
        Id recTypeLetradosDT = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SAC_LetradosDT').getRecordTypeId();
        Id rectypeCentroCaixabank = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        Id profile = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];
        User usuarioTest = new User();
        usuarioTest.Username = 'usergeneral@test.com';
        usuarioTest.Email = 'testsac@test.com';
        usuarioTest.LastName = 'usuarioTest Test';
        usuarioTest.ProfileId = profile;
        usuarioTest.Alias = 'testSac';
        usuarioTest.TimeZoneSidKey = 'GMT';
        usuarioTest.LocaleSidKey = 'es_ES';
        usuarioTest.EmailEncodingKey = 'ISO-8859-1';
        usuarioTest.LanguageLocaleKey = 'en_US';
        usuarioTest.isActive = true;
        usuarioTest.UserRole = uRole;
        insert usuarioTest;

        //Oficinas (Accounts)
        List<Account> listaOfisInsertar = new List<Account>();
        Account ofi = new Account();
        ofi.RecordTypeId = rectypeCentroCaixabank;
        ofi.CC_Tipo_Centro__c = 'OF';
        ofi.Name = 'OfiTest';
        ofi.CC_Email__c = 'testsac@testsac.testsac';
        //ofi.ParentId = ofi2.Id;
        listaOfisInsertar.add(ofi);

        Account ofi2 = new Account();
        ofi2.RecordTypeId = rectypeCentroCaixabank;
        ofi2.CC_Tipo_Centro__c = 'OF';
        ofi2.Name = 'OfiTest2';
        ofi2.CC_Email__c = 'testsac2@testsac.testsac';
        //ofi2.ParentId = ofi3.Id;
        listaOfisInsertar.add(ofi2);

        Account ofi3 = new Account();
        ofi3.RecordTypeId = rectypeCentroCaixabank;
        ofi3.CC_Tipo_Centro__c = 'GC';
        ofi3.Name = 'OfiTest3';
        ofi3.CC_Email__c = 'testsac3@testsac.testsac';
        //ofi3.ParentId = ofi4.Id;
        listaOfisInsertar.add(ofi3);

        Account ofi4 = new Account();
        ofi4.RecordTypeId = rectypeCentroCaixabank;
        ofi4.CC_Tipo_Centro__c = 'DC';
        ofi4.Name = 'OfiTest4';
        ofi4.CC_Email__c = 'testsac4@testsac.testsac';
        listaOfisInsertar.add(ofi4);

        Account ofi5 = new Account();
        ofi5.RecordTypeId = rectypeCentroCaixabank;
        ofi5.CC_Tipo_Centro__c = 'DT';
        ofi5.Name = 'OfiTest5';
        ofi5.CC_Email__c = 'testsac5@testsac.testsac';
        listaOfisInsertar.add(ofi5);
        insert listaOfisInsertar;

        //Update gerarquía
        List<Account> listaOfisUpdatear = new List<Account>();
        ofi.ParentId = ofi2.Id;
        ofi2.ParentId = ofi3.Id;
        ofi3.ParentId = ofi4.Id;
        ofi4.ParentId = ofi5.Id;
        listaOfisUpdatear.add(ofi);
        listaOfisUpdatear.add(ofi2);
        listaOfisUpdatear.add(ofi3);
        listaOfisUpdatear.add(ofi4);
        update listaOfisUpdatear;

        Case reclamacion = new Case();
        reclamacion.RecordTypeId = recordTypeReclamacion;
        reclamacion.Subject = 'testRec1';
        //reclamacion.CC_Oficina_Afectada_Lookup__c = ofi.Id;
        insert reclamacion;

        //Grupos
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.name = 'Oficinas test';
        grupoColaborador.SAC_PermiteConsultas__c = true;
        grupoColaborador.SAC_Externo__c = false;
        grupoColaborador.RecordTypeId = recTypeGrupoColaborador;
        grupoColaborador.SAC_Email__c = 'test@email.com';
        grupoColaborador.SAC_Email2__c = 'test@email.com';
        grupoColaborador.SAC_Email3__c = 'test@email.com';
        listaGrupos.add(grupoColaborador);

        //Grupo letrados DT
        CC_Grupo_Colaborador__c grupoLetradoDT = new CC_Grupo_Colaborador__c();
        grupoLetradoDT.RecordTypeId = recTypeGrupoLetradosDT;
        grupoLetradoDT.Name = 'Grupo letrados DT';
        grupoLetradoDT.SAC_DeveloperName__c = 'LetradosDT';
        listaGrupos.add(grupoLetradoDT);
        insert listaGrupos;

        //Grupo colaborador contact
        CC_Grupo_Colaborador_Contact__c contactTest = new CC_Grupo_Colaborador_Contact__c();
        contactTest.CC_Grupo_Colaborador__c = grupoColaborador.id;
        contactTest.CC_Usuario__c = usuarioTest.id;
        contactTest.SAC_Administrador__c = true;
        insert contactTest;

        SAC_Interaccion__c consulta = new SAC_Interaccion__c();
        consulta.RecordTypeId = recTypeConsulta;
        consulta.SAC_Reclamacion__c = reclamacion.Id;
        consulta.SAC_GrupoColaborador__c = grupoColaborador.Id;
        consulta.SAC_Estado__c = 'SAC_PendienteRespuesta';
        consulta.SAC_Oficina__c = ofi.Id;

        SAC_Interaccion__c consulta2 = new SAC_Interaccion__c();
        consulta2.RecordTypeId = recTypeConsulta;
        consulta2.SAC_Reclamacion__c = reclamacion.Id;
        consulta2.SAC_GrupoColaborador__c = grupoColaborador.Id;
        consulta2.SAC_Estado__c = 'SAC_PendienteRespuesta';
        consulta2.SAC_Oficina__c = ofi2.Id;

        SAC_Interaccion__c consulta3 = new SAC_Interaccion__c();
        consulta3.RecordTypeId = recTypeConsulta;
        consulta3.SAC_Reclamacion__c = reclamacion.Id;
        consulta3.SAC_GrupoColaborador__c = grupoColaborador.Id;
        consulta3.SAC_Estado__c = 'SAC_PendienteRespuesta';
        consulta3.SAC_Oficina__c = ofi3.Id;

        SAC_Interaccion__c consulta4 = new SAC_Interaccion__c();
        consulta4.RecordTypeId = recTypeConsulta;
        consulta4.SAC_Reclamacion__c = reclamacion.Id;
        consulta4.SAC_GrupoColaborador__c = grupoColaborador.Id;
        consulta4.SAC_Estado__c = 'SAC_PendienteRespuesta';
        consulta4.SAC_Oficina__c = ofi4.Id;

        SAC_Interaccion__c consulta5 = new SAC_Interaccion__c();
        consulta5.RecordTypeId = recTypeConsulta;
        consulta5.SAC_Reclamacion__c = reclamacion.Id;
        consulta5.SAC_GrupoColaborador__c = grupoColaborador.Id;
        consulta5.SAC_Estado__c = 'SAC_PendienteRespuesta';
        consulta5.SAC_Oficina__c = ofi5.Id;
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();
        listaconsultas.add(consulta);
        listaconsultas.add(consulta2);
        listaconsultas.add(consulta3);
        listaconsultas.add(consulta4);
        listaconsultas.add(consulta5);
        insert listaConsultas;

        //Update oficinas de las consultas, ya que se pisan y quedan vacias
        consulta.SAC_Oficina__c = ofi.Id;
        consulta2.SAC_Oficina__c = ofi2.Id;
        consulta3.SAC_Oficina__c = ofi3.Id;
        consulta4.SAC_Oficina__c = ofi4.Id;
        List<SAC_Interaccion__c> listaConsultasUpdatear = new List<SAC_Interaccion__c>();
        listaConsultasUpdatear.add(consulta);
        listaConsultasUpdatear.add(consulta2);
        listaConsultasUpdatear.add(consulta3);
        listaConsultasUpdatear.add(consulta4);
        update listaConsultasUpdatear;

        //letrados dt (maestro temas)
        SAC_MaestroTemas__c letradoDT = new SAC_MaestroTemas__c();
        letradoDT.SAC_GrupoLetradoDT__c = grupoLetradoDT.Id;
        letradoDT.SAC_Oficina__c = ofi5.Id;
        letradoDT.SAC_CorreoLetradoDT__c = 'correotestsac@testsac.testsac';
        letradoDT.RecordTypeId = recTypeLetradosDT;
        insert letradoDT;

    }

    @isTest
    static void test() {
        Test.startTest();
        User usuario = [SELECT id FROM user WHERE Username = 'usergeneral@test.com' limit 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        List<SAC_Interaccion__c> consulta = [SELECT Id, SAC_GrupoColaborador__r.SAC_Email__c, SAC_Oficina__c FROM SAC_Interaccion__c WHERE SAC_Reclamacion__c = :reclamacion.Id];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        insert permiSetAssi;

        //PendingProcess
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
        CBK_SCH_PendingProcess__c pendingProcessCaso = new CBK_SCH_PendingProcess__c();
        pendingProcessCaso.recordId__c = consulta[0].Id;
        pendingProcessCaso.Param1__c = '72';
        pendingProcessCaso.Schedule_Time__c = system.now().addHours(24);
        pendingProcessCaso.className__c = 'SAC_SchedulableAlertas';

        CBK_SCH_PendingProcess__c pendingProcessCaso2 = new CBK_SCH_PendingProcess__c();
        pendingProcessCaso2.recordId__c = consulta[1].Id;
        pendingProcessCaso2.Param1__c = '72';
        pendingProcessCaso2.Schedule_Time__c = system.now().addHours(24);
        pendingProcessCaso2.className__c = 'SAC_SchedulableAlertas';

        CBK_SCH_PendingProcess__c pendingProcessCaso3 = new CBK_SCH_PendingProcess__c();
        pendingProcessCaso3.recordId__c = consulta[2].Id;
        pendingProcessCaso3.Param1__c = '72';
        pendingProcessCaso3.Schedule_Time__c = system.now().addHours(24);
        pendingProcessCaso3.className__c = 'SAC_SchedulableAlertas';
        
        CBK_SCH_PendingProcess__c pendingProcessCaso4 = new CBK_SCH_PendingProcess__c();
        pendingProcessCaso4.recordId__c = consulta[3].Id;
        pendingProcessCaso4.Param1__c = '72';
        pendingProcessCaso4.Schedule_Time__c = system.now().addHours(24);
        pendingProcessCaso4.className__c = 'SAC_SchedulableAlertas';

        CBK_SCH_PendingProcess__c pendingProcessCaso5 = new CBK_SCH_PendingProcess__c();
        pendingProcessCaso5.recordId__c = consulta[4].Id;
        pendingProcessCaso5.Param1__c = '72';
        pendingProcessCaso5.Schedule_Time__c = system.now().addHours(24);
        pendingProcessCaso5.className__c = 'SAC_SchedulableAlertas';

        listaPendingProcess.add(pendingProcessCaso);
        listaPendingProcess.add(pendingProcessCaso2);
        listaPendingProcess.add(pendingProcessCaso3);
        listaPendingProcess.add(pendingProcessCaso4);
        listaPendingProcess.add(pendingProcessCaso5);

        SAC_SchedulableAlertas sca = new SAC_SchedulableAlertas();

        System.runAs(usuario) {
            sca.work(listaPendingProcess);
        }
        Test.stopTest();

        System.assertNotEquals(null, sca, 'No se ha podido lanzar la alerta');
    }
}