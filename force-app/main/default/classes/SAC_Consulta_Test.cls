@isTest
public class SAC_Consulta_Test {
    
	@TestSetup
	static void makeData() {

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
        
        CC_Grupo_Colaborador__c grupoDXC = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
        grupoDXC.name = 'DXC Zaragoza';
        grupoDXC.SAC_DeveloperName__c = 'DXC Zaragoza';
        grupoDXC.SAC_MaximoCasosDiarios__c = 30;
        Database.insert(grupoDXC);
        
        SAC_EmailService__c emailService = new SAC_EmailService__c();
        emailService.Name = 'SAC_Consulta';
        emailService.SAC_GroupName__c = 'DXC Zaragoza';
        emailService.SAC_Naturaleza__c = 'SAC_005';
        emailService.SAC_RecordTypeDeveloperName__c = 'SAC_Consulta';
        emailService.SAC_EmailEntrante__c = 'test@test.com';
        Database.insert(emailService);
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'reclamacion');
        camposRecl.put('OwnerId', usuarioGeneral.id);
    
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
 
        //Consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('Subject', 'Consulta2');
        camposCons.put('OwnerId', usuarioGeneral.id);

        Case consulta = SAC_TestDataFactory.crearCaso('Consulta',camposCons);
        consulta.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_ConsultaSAC').getRecordTypeId();                           
                            
        //Insertamos casos
        List<Case> listaCasos = new List<Case>();
        listaCasos.add(reclamacion);
        listaCasos.add(consulta);
        Database.insert(listaCasos);
    }
    
    @isTest
    public static void rellenarDatosEmailServiceTest(){
        
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            Case consulta = new Case();
            consulta.Subject = 'Consulta';
            consulta.Origin = 'Backoffice';
            consulta.Status = 'SAC_010';
            consulta.OwnerId = usuario.Id;
            consulta.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
            Database.insert(consulta);
            Test.stopTest();

            Case consulta2 = [SELECT Id, Status, OwnerId FROM Case WHERE Subject = 'Consulta'];

            System.assertNotEquals(consulta, consulta2, 'rellenarDatosEmailService no ha funcionado correctamente');
        }  
    }

    @IsTest
    static void desmarcarCheckTest(){
        Integer prueba = 5;
        Case consulta = [SELECT id FROM Case WHERE Subject = 'Consulta2'];
        Case reclamacion = [SELECT id FROM Case WHERE Subject='reclamacion'];
        consulta.CC_CasoRelacionado__c = reclamacion.id;
        consulta.Status = 'SAC_011';

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
    
        System.runAs(usuario){
            Test.startTest();
            Database.update(consulta);
            Test.stopTest();
        }
        
        Boolean respuesta  = [SELECT id, SAC_NuevaConsulta__c FROM Case WHERE Subject='reclamacion' ].SAC_NuevaConsulta__c;
        System.assertEquals(True, respuesta,  'No se ha marcado el check'); 
    }
}