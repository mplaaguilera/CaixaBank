@isTest
public with sharing class SAC_LCMP_MensajeComplementaria_Test {

    @TestSetup
    static void makeData(){
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        SAC_DatabaseDML.insertDML(usuarioGeneral, false); 
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);


        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaComplementarias = new List<Case>();
        System.runAs(usuarioGeneral){

            //Reclamacion 1
            Map<String, Object> camposRecl1 = new Map<String, Object>();
            camposRecl1.put('Subject', 'testRec');
            camposRecl1.put('Origin', 'Backoffice');
            camposRecl1.put('Status', 'SAC_005');
            camposRecl1.put('SAC_StatusAuxiliar__c', 'SAC_005');
            
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
            listaReclamaciones.add(casoReclamacion);
            SAC_DatabaseDML.insertListDML(listaReclamaciones, false); 


            Map<String, Object> camposReclVinc = new Map<String, Object>();
            camposReclVinc.clear();
            camposReclVinc.put('Subject', 'ComplementariaVinculada');
            camposReclVinc.put('Origin', 'Otros');
            camposReclVinc.put('Status', 'SAC_003');
            camposReclVinc.put('SAC_TipoConsumidor__c', 'No');
            camposReclVinc.put('SAC_Naturaleza__c', 'SAC_007');
            camposReclVinc.put('CC_Importe_Abonado__c', 5.0);
            camposReclVinc.put('CC_CasoRelacionado__c',casoReclamacion.Id);
            camposReclVinc.put('OwnerId', usuarioGeneral.id);
            Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclVinc);
            listaComplementarias.add(casoReclamacion2);

            SAC_DatabaseDML.insertListDML(listaComplementarias, false); 
        }
    }


    @isTest
    static void validarDesvincularComplementariaTest(){
        Test.startTest(); 
        Case complementaria = [SELECT Id FROM Case WHERE subject = 'ComplementariaVinculada'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Case reclamacionVinculada = new Case();
        System.runAs(usuario){
            reclamacionVinculada = SAC_LCMP_MensajeComplementaria.getReclamacionVinculada(complementaria.Id);
        }
        Assert.areNotEqual(null, reclamacionVinculada.Id);
        Test.stopTest();
    }


}