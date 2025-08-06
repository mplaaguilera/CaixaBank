@isTest
public with sharing class SAC_ReasignacionGruposVF_Test {
    
    @TestSetup
    static void makeData(){
        Id recTypeGrupoGestor = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        Id recTypeGrupoLetrado = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();
        Id recTypeGrupoTareas = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recTypeRecla = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        Id profile = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;

        List<User> listaUsuarios = new List<User>();
        User usuarioPablo = new User();
        usuarioPablo.Username = 'usergeneral@test.com';
        usuarioPablo.Email = 'pablo@test.com';
        usuarioPablo.LastName = 'usuarioPablo Test';
        usuarioPablo.ProfileId = profile;
        usuarioPablo.Alias = 'pablo';
        usuarioPablo.TimeZoneSidKey = 'GMT';
        usuarioPablo.LocaleSidKey = 'es_ES';
        usuarioPablo.EmailEncodingKey = 'ISO-8859-1';
        usuarioPablo.LanguageLocaleKey = 'en_US';
        usuarioPablo.isActive = true; 
        listaUsuarios.add(usuarioPablo);


        User usuarioTere = new User();
        usuarioTere.Username = 'usergeneralTERE@test.com';
        usuarioTere.Email = 'tere@test.com';
        usuarioTere.LastName = 'usuarioTere Test';
        usuarioTere.ProfileId = profile;
        usuarioTere.Alias = 'tereeee';
        usuarioTere.TimeZoneSidKey = 'GMT';
        usuarioTere.LocaleSidKey = 'es_ES';
        usuarioTere.EmailEncodingKey = 'ISO-8859-1';
        usuarioTere.LanguageLocaleKey = 'en_US';
        usuarioTere.isActive = true; 
        listaUsuarios.add(usuarioTere);

        insert listaUsuarios;

        CC_Grupo_Colaborador__c grupoGestor = new CC_Grupo_Colaborador__c();
        grupoGestor.Name = 'grupo proveedor';
        grupoGestor.RecordTypeId = recTypeGrupoGestor;
        grupoGestor.SAC_PorcentajeAsignacion__c = 0;
        grupoGestor.SAC_MaximoCasosDiarios__c = 5;

        CC_Grupo_Colaborador__c grupoGestor2 = new CC_Grupo_Colaborador__c();
        grupoGestor2.Name = 'grupo proveedor2';
        grupoGestor2.RecordTypeId = recTypeGrupoGestor;
        grupoGestor2.SAC_PorcentajeAsignacion__c = 100;
        grupoGestor2.SAC_MaximoCasosDiarios__c = 5;

        CC_Grupo_Colaborador__c grupoLetrado = new CC_Grupo_Colaborador__c();
        grupoLetrado.Name = 'grupo letrado';
        grupoLetrado.RecordTypeId = recTypeGrupoLetrado;
        grupoLetrado.SAC_PorcentajeAsignacion__c = 0;

        CC_Grupo_Colaborador__c grupoLetrado2 = new CC_Grupo_Colaborador__c();
        grupoLetrado2.Name = 'grupo letrado2';
        grupoLetrado2.RecordTypeId = recTypeGrupoLetrado;
        grupoLetrado2.SAC_PorcentajeAsignacion__c = 100;

        CC_Grupo_Colaborador__c grupoTareas = new CC_Grupo_Colaborador__c();
        grupoTareas.Name = 'grupo tareas';
        grupoTareas.RecordTypeId = recTypeGrupoTareas;
        grupoTareas.SAC_DeveloperName__c = 'COPS';

        List<CC_Grupo_Colaborador__c> grupos = new List<CC_Grupo_Colaborador__c>();
        grupos.add(grupoGestor);
        grupos.add(grupoGestor2);
        
        grupos.add(grupoLetrado2);
        grupos.add(grupoTareas);

        Account ac = new Account(
            Name = 'cuentaTest'
        );
        insert ac;

        Case reclamacion = new Case(
            Status = 'SAC_001',
            SAC_StatusAuxiliar__c = 'SAC_001',
            Subject = 'TestRec',
            recordTypeId = recTypeRecla,
            AccountId = ac.Id,
            OwnerId = usuarioPablo.Id,
            SEG_Grupo__c = grupoLetrado2.Id
        ); 

        Case reclamacion2 = new Case(
            Status = 'SAC_001',
            SAC_StatusAuxiliar__c = 'SAC_001',
            Subject = 'TestRec2',
            recordTypeId = recTypeRecla,
            AccountId = ac.Id,
            OwnerId = usuarioPablo.Id,
            SEG_Grupo__c = grupoLetrado.Id
        );

        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(reclamacion);
        reclamaciones.add(reclamacion2);
        insert reclamaciones;

        Case pretension = new Case(
            Status = 'SAC_001',
            SAC_StatusAuxiliar__c = 'SAC_001',
            SuppliedCompany = 'TestPret',
            recordTypeId = recTypePret,
            SAC_Reclamacion__c = reclamacion.Id,
            AccountId = ac.Id,
            OwnerId = usuarioPablo.Id,
            SEG_Grupo__c = grupoGestor2.Id
        );

        Case pretension2 = new Case(
            Status = 'SAC_001',
            SAC_StatusAuxiliar__c = 'SAC_001',
            SuppliedCompany = 'TestPret2',
            recordTypeId = recTypePret,
            SAC_Reclamacion__c = reclamacion2.Id,
            AccountId = ac.Id,
            OwnerId = usuarioPablo.Id,
            SEG_Grupo__c = grupoGestor.Id
        );

        Case pretension3 = new Case(
            Status = 'SAC_006',
            SAC_StatusAuxiliar__c = 'SAC_006',
            SuppliedCompany = 'TestPret3',
            recordTypeId = recTypePret,
            SAC_Reclamacion__c = reclamacion2.Id,
            AccountId = ac.Id,
            OwnerId = usuarioTere.Id,
            SEG_Grupo__c = grupoLetrado.Id
        );

        List<Case> pretensiones = new List<Case>();
        pretensiones.add(pretension);
        pretensiones.add(pretension2);
        pretensiones.add(pretension3);
        insert pretensiones;

        System.runAs(usuarioPablo){
            insert grupos;

            List<CC_Grupo_Colaborador_Contact__c> gruposColaboradoresContact = new List<CC_Grupo_Colaborador_Contact__c>();
            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = new CC_Grupo_Colaborador_Contact__c();
            grupoColaboradorContact.CC_Grupo_Colaborador__c = grupoGestor.id;
            grupoColaboradorContact.CC_Usuario__c = usuarioPablo.id;
            grupoColaboradorContact.SAC_Administrador__c = true;
            gruposColaboradoresContact.add(grupoColaboradorContact);

            CC_Grupo_Colaborador_Contact__c gccTareas = new CC_Grupo_Colaborador_Contact__c();
            gccTareas.CC_Grupo_Colaborador__c = grupoTareas.Id;
            gccTareas.CC_Usuario__c = usuarioPablo.id;
            gruposColaboradoresContact.add(gccTareas);
            insert gruposColaboradoresContact;
        }

        System.runAs(usuarioTere){
            insert grupoLetrado;
            List<CC_Grupo_Colaborador_Contact__c> gruposColaboradoresContact = new List<CC_Grupo_Colaborador_Contact__c>();

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 =  new CC_Grupo_Colaborador_Contact__c();
            grupoColaboradorContact2.CC_Grupo_Colaborador__c = grupoLetrado.id;
            grupoColaboradorContact2.CC_Usuario__c = usuarioTere.id;
            grupoColaboradorContact2.SAC_Administrador__c = true;
            gruposColaboradoresContact.add(grupoColaboradorContact2);
            insert gruposColaboradoresContact;
        }
    }

    @isTest
    static void cambiarReclamaciones(){
        List<Case> reclamacion = [SELECT Id, SEG_Grupo__c, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'grupo proveedor2'];
        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        User usuario = [SELECT Id FROM  User WHERE Username = 'usergeneral@test.com'];
        List<selectOption> resultado = new List<selectOption>();

        Test.startTest();
        PageReference testPage = Page.SAC_ReasignacionGruposMasivo;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(reclamacion);
        stdSetController.setSelected(reclamacion);

        System.runAs(usuario){
            SAC_ReasignacionGruposVF ext = new SAC_ReasignacionGruposVF(stdSetController);
            ext.decision = 'Reclamaciones';
            ext.selectedValor1 = grupo.Id;
            resultado = ext.getGruposProveedores();
            ext.save();
        }
        
        Test.stopTest();

        Case reclamacionv2 = [SELECT Id, SEG_Grupo__c, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        System.assertEquals(reclamacionv2.SEG_Grupo__c, grupo.Id, 'La asignación del grupo ha fallado.');
    }
    @isTest
    static void cambiarReclamaciones_KO(){
        List<Case> reclamacion = [SELECT Id, SEG_Grupo__c, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1]; 
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'grupo proveedor2'];       
        List<selectOption> resultado = new List<selectOption>();

        Test.startTest();
        PageReference testPage = Page.SAC_ReasignacionGruposMasivo;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(reclamacion);
        stdSetController.setSelected(reclamacion);
        
        SAC_ReasignacionGruposVF ext = new SAC_ReasignacionGruposVF(stdSetController);
        ext.decision = 'Reclamaciones';
        ext.selectedValor1 = grupo.Id;
        resultado = ext.getGruposProveedores();
        ext.save();
        
        
        Test.stopTest();

        System.assertEquals(ext.mostrar, false, 'No ha saltado el mensaje de error.');
    }
    @isTest
    static void cambiarReclamaciones_KO2(){
        List<Case> reclamacion = new List<Case>(); 
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'grupo letrado'];     

        Test.startTest();
        PageReference testPage = Page.SAC_ReasignacionGruposMasivo;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(reclamacion);
        stdSetController.setSelected(reclamacion);
        SAC_ReasignacionGruposVF ext = new SAC_ReasignacionGruposVF(stdSetController);
        ext.decision = 'Pretensiones';
        ext.selectedValor2 = grupo.Id;
        List<selectOption> resultado = ext.getGruposLetrados();      
        
        Test.stopTest();

        System.assertEquals(ext.mostrar, false, 'No ha saltado el mensaje de error.');
    }

    @isTest
    static void cambiarPretensiones(){
        List<Case> pretension = [SELECT Id, SEG_Grupo__c, OwnerId FROM Case WHERE SuppliedCompany = 'TestPret' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'grupo letrado'];
        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        User usuario = [SELECT Id FROM  User WHERE Username = 'usergeneral@test.com'];

        Test.startTest();
        PageReference testPage = Page.SAC_ReasignacionGruposMasivo;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pretension);
        stdSetController.setSelected(pretension);
        System.runAs(usuario){
            SAC_ReasignacionGruposVF ext = new SAC_ReasignacionGruposVF(stdSetController);
            ext.decision = 'Pretensiones';
            ext.selectedValor2 = grupo.Id;
            List<selectOption> resultado = ext.getGruposLetrados();
            ext.save();
        }
        Test.stopTest();

        Case pretensionv2 = [SELECT Id, SEG_Grupo__c, OwnerId FROM Case WHERE SuppliedCompany = 'TestPret' LIMIT 1];
        System.assertEquals(pretensionv2.SEG_Grupo__c, grupo.Id, 'La asignación del grupo ha fallado.');
    }

    @isTest
    static void cambiarPretensiones_OK2(){
        List<Case> pretension = [SELECT Id, SEG_Grupo__c, OwnerId FROM Case WHERE SuppliedCompany = 'TestPret3' LIMIT 1];
        
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'grupo letrado2' OR Name = 'grupo letrado'];
        CC_Grupo_Colaborador__c grupoLetrado1;
        CC_Grupo_Colaborador__c grupoLetrado2;

        for (CC_Grupo_Colaborador__c gccAux : grupos) {
            if(gccAux.Name == 'grupo letrado'){
                grupoLetrado1 = gccAux;
            }else{
                grupoLetrado2 = gccAux;
            }
        }
        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];
        User usuario = [SELECT Id FROM  User WHERE Username = 'usergeneralTERE@test.com'];

        Test.startTest();
        PageReference testPage = Page.SAC_ReasignacionGruposMasivo;

        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(pretension);
        stdSetController.setSelected(pretension);
        System.runAs(usuario){
            pretension[0].SEG_Grupo__c = grupoLetrado1.Id;
            update pretension;

            SAC_ReasignacionGruposVF ext = new SAC_ReasignacionGruposVF(stdSetController);
            ext.decision = 'Pretensiones';
            ext.selectedValor2 = grupoLetrado2.Id;
            List<selectOption> resultado = ext.getGruposLetrados();
            ext.save();
        }
        Test.stopTest();

        Case pretensionv2 = [SELECT Id, SEG_Grupo__c, OwnerId FROM Case WHERE SuppliedCompany = 'TestPret3' LIMIT 1];
        System.assertEquals(pretensionv2.SEG_Grupo__c, grupoLetrado2.Id, 'La asignación del grupo ha fallado.');
    }
}