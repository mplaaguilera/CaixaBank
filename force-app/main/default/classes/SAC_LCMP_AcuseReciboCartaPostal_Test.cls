@isTest
public with sharing class SAC_LCMP_AcuseReciboCartaPostal_Test {
    
    @TestSetup
    static void makeData(){
        
        Account cuentaA = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
        SAC_DatabaseDML.insertDML(cuentaA, false);
        //Database.insert(cuentaA);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testRec1');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('Origin', 'Email');
        camposRecl.put('SuppliedEmail', 'sactest@sactest.sactest');
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);
        //Database.insert(casoReclamacion);

        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
        usuarios[0].Username = 'sacacuserecibo@test.com';
        usuarios[1].Username = 'ustestesteo@test.com';
        SAC_DatabaseDML.insertListDML(usuarios, false);
        //Database.insert(usuarios);
        
        System.runAs(usuarios[0]){
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'nombreTest';
            validEmailTemplate.DeveloperName = 'SAC_Test';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.HtmlValue = '<p><p>';
            validEmailTemplate.Body = 'Texted';
            validEmailTemplate.FolderId = usuarios[0].Id;

            SAC_DatabaseDML.insertDML(validEmailTemplate, false);
            //Database.insert(validEmailTemplate);
        }
    }

    @isTest
    static void getInfoInitTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_LCMP_AcuseReciboCartaPostal.ObjWrapper myInfo;

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
			//Database.insert(psa);
		}
        
        System.RunAs((usuario)){   
            Test.startTest();
            //Reclamacion
            Case casoReclamacion = new Case();
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'testRecnew');
            camposRecl.put('Status', 'SAC_001');
            
            casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(casoReclamacion, false);
            //Database.insert(casoReclamacion);
            myInfo = SAC_LCMP_AcuseReciboCartaPostal.getInfoInit(casoReclamacion.Id);
            Test.stopTest();
        }
        
        Case casoResult = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'testRecnew'];
        System.assertEquals(myInfo.caso.CaseNumber, casoResult.CaseNumber, 'La búsqueda previa ha fallado.');
    }

    @isTest
    static void envioCartaPostalTest(){
        Case c = [SELECT Id, CaseNumber, CreatedDate, Status, SAC_RedaccionFinal__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, 
            SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, Origin, CC_AcuseRecibo__c
                FROM Case WHERE Subject = 'testRec1'];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
			//Database.insert(psa);
		}

        System.RunAs((usuario)){   
            Test.startTest();
            SAC_LCMP_AcuseReciboCartaPostal.envioCartaPostal(c, 'direccion', 'codigoPostal', 'poblacion', 'provincia', '011');
            Test.stopTest();
        }
        
        SAC_DocumentoEnvio__c documento = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :c.Id];
        
        System.assertNotEquals(null, documento.Id, 'La búsqueda previa ha fallado.');
    }

    @isTest
    static void envioEmailTest(){
        Case c = [SELECT Id, CaseNumber, CreatedDate, Status, SAC_RedaccionFinal__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, 
            SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, Origin, CC_AcuseRecibo__c
                FROM Case WHERE Subject = 'testRec1'];


        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
			//Database.insert(psa);
		}

        System.RunAs((usuario)){   
            Test.startTest();
            SAC_LCMP_AcuseReciboCartaPostal.envioEmail(c);
            Test.stopTest();
        }
        
        Case c2 = [SELECT Id, CaseNumber, CreatedDate, Status, SAC_RedaccionFinal__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, 
            SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, CC_AcuseRecibo__c
                FROM Case WHERE Subject = 'testRec1'];
        
        System.assertEquals(c2.CC_AcuseRecibo__c, '2', 'La búsqueda previa ha fallado.');
    }
    @isTest
    static void envioEmailTestManual(){
        Case c = [SELECT Id, CaseNumber, CreatedDate, Status, SAC_RedaccionFinal__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, 
            SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, Origin, CC_AcuseRecibo__c
                FROM Case WHERE Subject = 'testRec1'];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
		List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
		if(psas.isEmpty()){
			PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            SAC_DatabaseDML.insertDML(psa, false);
			//Database.insert(psa);
		}

        System.RunAs((usuario)){   
            Test.startTest();
            SAC_LCMP_AcuseReciboCartaPostal.envioEmailManual(c, 'webEmail');
            Test.stopTest();
        }
        
        Case c2 = [SELECT Id, CaseNumber, CreatedDate, Status, SAC_RedaccionFinal__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, 
            SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, CC_AcuseRecibo__c
                FROM Case WHERE Subject = 'testRec1'];
        
        System.assertEquals(c2.CC_AcuseRecibo__c, '2', 'La búsqueda previa ha fallado.'); 
    }
}