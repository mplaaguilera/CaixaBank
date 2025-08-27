@isTest
public with sharing class SAC_LCMP_InfoSubsanacionesTest {
 @TestSetup
    static void makeData(){

        Test.startTest();
        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);     
        //Database.insert(usuarioAdmin);

        User usuario;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com';  
            usuario.UserRoleId = uRole.id;    
            SAC_DatabaseDML.insertDML(usuario, false);   
            //Database.insert(usuario);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);  
            //Database.insert(permiSetAssi);
        }
        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];
        grupoColaborador.Name = 'Grupo Proveedores Test';
        grupoColaborador.SAC_NivelGrupo__c = 'SAC_Nivel2';
        grupoColaborador.SAC_PermiteEscalado__c = true;
        grupoColaborador.SAC_PermiteTareas__c = true;
        grupoColaborador.SAC_Email__c = 'mneira@viewnext.com';
        SAC_DatabaseDML.insertDML(grupoColaborador, false);

        //Creación de un caso de reclamación
        //Reclamacion 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('Origin', 'SAC_Manual');
        camposRecl.put('CC_Canal_Respuesta__c', 'Carta');
        camposRecl.put('SEG_Grupo__c', grupoColaborador.id);
        camposRecl.put('SAC_Entidad_Afectada__c', 'SAC_007');
      
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false);

        Test.stopTest();
    }

    @isTest
    static void getSubsanacionesTest(){        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true LIMIT 1];

        System.runAs(usuarioGeneral) {
            // Simular que el usuario tiene acceso a la clase
            System.runAs(usuarioGeneral) {
                // Aquí se puede llamar al método que se quiere probar
                Test.startTest();

                List<SPV_Formulario__c> subsanaciones = SAC_LCMP_InfoSubsanaciones.getSubsanaciones(caso.Id);
                
                System.assertEquals(0, subsanaciones.size(), 'No debe haber subsanaciones para el caso creado');
                Test.stopTest();

            }
        }
    }
    
}