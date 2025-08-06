@isTest
public with sharing class SAC_LCMP_GetOwnerCases_Test {

    @TestSetup
    static void makeData() {
        //RT Centro CaixaBank
		Id cuentaRecordTypeOF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        //Oficina CaixaBank
		Account oficina = new Account(
            RecordTypeId = cuentaRecordTypeOF,
            Name = 'Cuenta CentroCaixaBank Test 1',
            CC_Email__c = 'test@test.com',
            CC_Tipo_Centro__c = 'DT'
        );        
        SAC_DatabaseDML.insertDML(oficina, false);
        //Database.insert(oficina);
        
        //Usuario SAC General
        User usuarioGeneral;
        System.runAs(new User(Id = UserInfo.getUserId())) {
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

        //Cuenta a utilizar tipo test
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        SAC_DatabaseDML.insertDML(cuenta, false);
        //Database.insert(cuenta);

        //RECLAMACION 1 - NECESITO SU ID PARA EJECUTAR EL METODO 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('AccountId', cuenta.Id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //RECLAMACION 2 - NECESITO QUE HAYA OTRO CASO EN LA BBDD PARA QUE EL METODO 1 TENGA INFORMACION CON LA QUE TRATAR
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_001');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl2.put('AccountId', cuenta.Id);

        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

        //RECLAMACION 3 - NECESITO QUE HAYA OTRO CASO EN LA BBDD PARA QUE EL METODO 1 TENGA INFORMACION CON LA QUE TRATAR
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('Status', 'SAC_002');
        camposRecl3.put('SAC_StatusAuxiliar__c', 'SAC_002');
        camposRecl3.put('AccountId', cuenta.Id);

        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);

        //RECLAMACION 4
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestRec4');
        camposRecl4.put('Origin', 'Backoffice');
        camposRecl4.put('Status', 'SAC_003');
        camposRecl4.put('SAC_StatusAuxiliar__c', 'SAC_003');
        camposRecl4.put('AccountId', cuenta.Id);

        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl4);

        //RECLAMACION 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'TestRec5');
        camposRecl5.put('Origin', 'Backoffice');
        camposRecl5.put('Status', 'SAC_004');
        camposRecl5.put('SAC_StatusAuxiliar__c', 'SAC_004');
        camposRecl5.put('AccountId', cuenta.Id);

        Case casoReclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl5);

        //RECLAMACION 6
        Map<String, Object> camposRecl6 = new Map<String, Object>();
        camposRecl6.put('Subject', 'TestRec6');
        camposRecl6.put('Origin', 'Backoffice');
        camposRecl6.put('Status', 'SAC_005');
        camposRecl6.put('SAC_StatusAuxiliar__c', 'SAC_005');
        camposRecl6.put('AccountId', cuenta.Id);

        Case casoReclamacion6 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl6);

        //RECLAMACION 7
        Map<String, Object> camposRecl7 = new Map<String, Object>();
        camposRecl7.put('Subject', 'TestRec7');
        camposRecl7.put('Origin', 'Backoffice');
        camposRecl7.put('Status', 'SAC_006');
        camposRecl7.put('SAC_StatusAuxiliar__c', 'SAC_006');
        camposRecl7.put('AccountId', cuenta.Id);

        Case casoReclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl7);

        //RECLAMACION 8
        Map<String, Object> camposRecl8 = new Map<String, Object>();
        camposRecl8.put('Subject', 'TestRec8');
        camposRecl8.put('Origin', 'Backoffice');
        camposRecl8.put('Status', 'SAC_007');
        camposRecl8.put('SAC_StatusAuxiliar__c', 'SAC_007');
        camposRecl8.put('AccountId', cuenta.Id);

        Case casoReclamacion8 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl8);

        //RECLAMACION 9
        Map<String, Object> camposRecl9 = new Map<String, Object>();
        camposRecl9.put('Subject', 'TestRec9');
        camposRecl9.put('Origin', 'Backoffice');
        camposRecl9.put('Status', 'SAC_001');
        camposRecl9.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl9.put('AccountId', cuenta.Id);

        Case casoReclamacion9 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl9);

        //RECLAMACION 10
        Map<String, Object> camposRecl10 = new Map<String, Object>();
        camposRecl10.put('Subject', 'TestRec10');
        camposRecl10.put('Origin', 'Backoffice');
        camposRecl10.put('Status', 'SAC_001');
        camposRecl10.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl10.put('AccountId', cuenta.Id);

        Case casoReclamacion10 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl10);

        Map<String, Object> camposReclVinc = new Map<String, Object>();
        camposReclVinc.clear();
        camposReclVinc.put('Subject', 'ComplementariaVinculada');
        camposReclVinc.put('Origin', 'Otros');
        camposReclVinc.put('Status', 'SAC_003');
        camposReclVinc.put('SAC_TipoConsumidor__c', 'No');
        camposReclVinc.put('SAC_Naturaleza__c', 'SAC_007');
        camposReclVinc.put('CC_Importe_Abonado__c', 5.0);
        camposReclVinc.put('OwnerId', usuarioGeneral.id);
        Case casoReclamacion11 = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclVinc);
    
        
        //CONSULTA
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('Subject', 'Consulta');
        camposCons.put('Origin', 'Backoffice');
        camposCons.put('Status', 'SAC_010');
        camposCons.put('SAC_StatusAuxiliar__c', 'SAC_010');
        camposCons.put('AccountId', cuenta.Id);

        Case consulta = SAC_TestDataFactory.crearCaso('Consulta',camposCons);
    
        //CONSULTA 2
        Map<String, Object> camposCons2 = new Map<String, Object>();
        camposCons2.put('Subject', 'Consulta2');
        camposCons2.put('Origin', 'Backoffice');
        camposCons2.put('Status', 'SAC_010');
        camposCons2.put('SAC_StatusAuxiliar__c', 'SAC_010');
        camposCons2.put('AccountId', cuenta.Id);

        Case consulta2 = SAC_TestDataFactory.crearCaso('Consulta',camposCons2);

        //INSERTAMOS
        List<Case> reclamacionesAInsertar = new List<Case>();
        reclamacionesAInsertar.add(casoReclamacion);
        reclamacionesAInsertar.add(casoReclamacion2);
        reclamacionesAInsertar.add(casoReclamacion3);
        reclamacionesAInsertar.add(casoReclamacion4);
        reclamacionesAInsertar.add(casoReclamacion5);
        reclamacionesAInsertar.add(casoReclamacion6);
        reclamacionesAInsertar.add(casoReclamacion7);
        reclamacionesAInsertar.add(casoReclamacion8);
        reclamacionesAInsertar.add(casoReclamacion9);
        reclamacionesAInsertar.add(casoReclamacion10);
        reclamacionesAInsertar.add(casoReclamacion11);
        reclamacionesAInsertar.add(consulta);
        reclamacionesAInsertar.add(consulta2);
		
        SAC_DatabaseDML.insertListDML(reclamacionesAInsertar, false); 
        //Database.insert(reclamacionesAInsertar);
		
        consulta2.CC_CasoRelacionado__c = casoReclamacion10.Id;
        SAC_DatabaseDML.updateDML(consulta2, false); 
        //Database.update(consulta2);
        
        Test.startTest();
        //reclamantes
        SAC_CaseReclamante__c reclamante = SAC_TestDataFactory.crearReclamante(false,casoReclamacion,cuenta.Id);
        
        SAC_CaseReclamante__c reclamante2 = SAC_TestDataFactory.crearReclamante(false,casoReclamacion,cuenta.Id);

        SAC_CaseReclamante__c reclamante3 = SAC_TestDataFactory.crearReclamante(false,casoReclamacion,cuenta.Id);
    
        List<SAC_CaseReclamante__c> reclamantes = new List<SAC_CaseReclamante__c>();
        reclamantes.add(reclamante);
        reclamantes.add(reclamante2);
        reclamantes.add(reclamante3);
        SAC_DatabaseDML.insertListDML(reclamantes, false); 
        //Database.insert(reclamantes);

        //PRETENSION 1 - ESTA PRETENSION SE TIENE QUE MOSTRAR COMO PRETENSION ASOCIADA Y QUE SE PUEDA MANIPULAR EN EL METODO 1 bucle entra al else
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'prueba');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('Status', 'Alta');
        camposPret.put('SAC_StatusAuxiliar__c', 'Alta');
        camposPret.put('AccountId', cuenta.Id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion2.Id);

        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);

        //PRETENSION 2 - ESTA PRETENSION SE TIENE QUE MOSTRAR COMO PRETENSION ASOCIADA Y QUE SE PUEDA MANIPULAR EN EL METODO 1 bucle entra al if
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'prueba2');
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('Status', 'Alta');
        camposPret2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposPret2.put('AccountId', cuenta.Id);
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion2.Id);

        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);


        camposPret2.clear();
        camposPret2.put('SuppliedCompany', 'prueba3');
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('Status', 'Alta');
        camposPret2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposPret2.put('AccountId', cuenta.Id);
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion9.Id);
        camposPret2.put('OwnerId', usuarioGeneral.Id);
        
        Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);


        List<Case> pretensionesAInsertar = new List<Case>();
        pretensionesAInsertar.add(casoPretension);
        pretensionesAInsertar.add(casoPretension2);
        pretensionesAInsertar.add(casoPretension3);
        SAC_DatabaseDML.insertListDML(pretensionesAInsertar, false);
        //Database.insert(pretensionesAInsertar);

        casoReclamacion9.SAC_PretensionPrincipal__c = casoPretension3.Id;
        SAC_DatabaseDML.updateDML(casoReclamacion9, true);


        Test.stopTest();  
    }

    
    @isTest
    static void validarVincularDesvincularComplementariaTest(){
        Test.startTest(); 
        Case complementaria = [SELECT Id FROM Case WHERE subject = 'ComplementariaVinculada'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){        
            Boolean testResultado = SAC_LCMP_GetOwnerCases.validarVincularDesvincularComplementaria(complementaria.Id);  
            Assert.areEqual(true, testResultado, 'No se ha realizado la comprobación correctamente.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void methodGetSameOwnerCasesTest(){
        Test.startTest(); 
        Case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){        
            List<SAC_LCMP_GetOwnerCases.ReclamacionWrapper> testResultado = SAC_LCMP_GetOwnerCases.getSameOwnerCases(reclamacion.Id);  
            System.assertNotEquals(null, testResultado, 'La ejecucion no ha podido obtener la lista de reclamaciones asignadas al mismo propietario que la reclamacion actual');
        }
        Test.stopTest();
    }

    @isTest
    static void methodModifySameOwnerCasesTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec9'];
        Case reclamacion2 = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec8'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){   
            SAC_LCMP_GetOwnerCases.modifySameOwnerCases(reclamacion.Id, reclamacion2.Id);
        }
        Case reclamacion3 = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec8'];
        System.assertEquals(reclamacion.Id, reclamacion3.CC_CasoRelacionado__c, 'La ejecucion ha fallado a la hora de vincular reclamaciones');
        Test.stopTest();
    }


    @isTest
    static void methodGetSameOwnerCasesFailTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            try{
                List<SAC_LCMP_GetOwnerCases.ReclamacionWrapper> testResultado = SAC_LCMP_GetOwnerCases.getSameOwnerCases(reclamacion.Id);  
            }
            catch(AuraHandledException e){
                System.assertEquals(null, null, 'La ejecucion no ha podido obtener la lista de reclamaciones asignadas al mismo propietario que la reclamacion actual');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void methodModifySameOwnerCasesFailTest(){
        Test.startTest();
        Case reclamacion = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec'];
        Case reclamacion2 = [SELECT Id, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE subject = 'TestRec2'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){
            try{
                SAC_LCMP_GetOwnerCases.modifySameOwnerCases(reclamacion.Id, reclamacion2.Id);
                
            }catch(AuraHandledException e){
                System.assertEquals(null, null, 'La ejecucion ha fallado a la hora de vincular reclamaciones');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void methodGetSameOwnerCasesFailTest2(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec3'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){   
            try{
                List<SAC_LCMP_GetOwnerCases.ReclamacionWrapper> testResultado = SAC_LCMP_GetOwnerCases.getSameOwnerCases(reclamacion.Id);
                
            }
            catch(AuraHandledException e){
                System.assertEquals(null, null, 'No existe un cliente asociado en la reclamación actual');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void methodGetSameOwnerCasesConsulta(){
        Test.startTest();
        Case consulta = [SELECT Id FROM Case WHERE subject = 'Consulta'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){ 
            List<SAC_LCMP_GetOwnerCases.ReclamacionWrapper> testResultado = SAC_LCMP_GetOwnerCases.getSameOwnerCases(consulta.Id);
            System.assertNotEquals(null, testResultado, 'La ejecucion no ha podido obtener la lista de reclamaciones asignadas al mismo propietario que la reclamacion actual');
        }
        Test.stopTest();
    }

    @isTest
    static void methodDesvincular(){
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE subject = 'TestRec10'];
        Case consulta = [SELECT Id FROM Case WHERE subject = 'Consulta2'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){ 
            String testResultado = SAC_LCMP_GetOwnerCases.desvincular(reclamacion.Id, consulta.Id);
            System.assertNotEquals(null, testResultado, 'La ejecucion no ha podido obtener la lista de reclamaciones asignadas al mismo propietario que la reclamacion actual');
        }
        Test.stopTest();
    }

    @isTest
    static void  methodModifySameOwnerCasesConsulta(){
        Test.startTest();
		
        
        Case consulta = [SELECT Id FROM Case WHERE subject = 'Consulta'];
        Case reclamacion = [SELECT Id, Status, SAC_StatusAuxiliar__c  FROM Case WHERE subject = 'TestRec3'];
        Case reclamacion2 = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE subject = 'TestRec'];
        String testResultado;
        String testResultado2;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        Account oficina = [SELECT id FROM Account WHERE name = 'Cuenta CentroCaixaBank Test 1' Limit 1];
        
        reclamacion2.Status = 'Cerrado';
        reclamacion2.SAC_StatusAuxiliar__c = reclamacion2.Status;
        reclamacion2.CC_Oficina_Afectada_Lookup__c = oficina.Id;
        SAC_DatabaseDML.insertDML(reclamacion2, false);
        //Database.update(reclamacion2);

        System.runAs(usuario){ 
            testResultado = SAC_LCMP_GetOwnerCases.modifySameOwnerCases(reclamacion.id, consulta.id);
        }
            
        reclamacion2 = [SELECT Id, Status, SAC_StatusAuxiliar__c FROM Case WHERE subject = 'TestRec'];
        
        System.runAs(usuario){ 
            testResultado2 = SAC_LCMP_GetOwnerCases.modifySameOwnerCases(reclamacion2.id, consulta.id);
        }
        System.assertNotEquals(null, testResultado, 'No se ha vinculado la consulta');
        System.assertNotEquals(null, testResultado2, 'No se ha vinculado la consulta con una reclamación cerrada');
        Test.stopTest();
    }

    @isTest
    static void  methodModifySameOwnerCasesConsulta2(){
        Test.startTest();
		
        Case consulta = [SELECT Id FROM Case WHERE subject = 'Consulta'];
        Case reclamacion = [SELECT Id, Status, SAC_StatusAuxiliar__c  FROM Case WHERE subject = 'TestRec5'];
        String testResultado;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar'];

        System.runAs(usuario){ 
            reclamacion.OwnerId = cola[0].Id;
            SAC_DatabaseDML.updateDML(reclamacion, false);
        
            testResultado = SAC_LCMP_GetOwnerCases.modifySameOwnerCases(reclamacion.id, consulta.id);
        }

        System.assertNotEquals(null, testResultado, 'No se ha vinculado la consulta');
        Test.stopTest();
    }
}