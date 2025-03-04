@istest
public with sharing class SAC_RefreshView_Test {

    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC Admin
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);  
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false); 
            //Database.insert(permiSetAssi);   
        }

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Reclamación');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false); 
        //Database.insert(reclamacion);
    }

    @istest
    static void recuperarCasoTest() {
        Case caso = [SELECT id, Status FROM Case WHERE Subject = 'Reclamación'];

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            Case casoRecuperado = SAC_refreshView.recuperarCaso(caso.id);
            System.assertEquals(caso.Status, casoRecuperado.Status, 'No se recuperó el caso correctamente');
        }
    }   
}