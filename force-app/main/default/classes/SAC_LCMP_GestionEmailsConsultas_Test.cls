@isTest
public with sharing class SAC_LCMP_GestionEmailsConsultas_Test {
    
    @TestSetup
    static void makeData(){
        
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        usuarioGeneral.SAC_PerteneceCOPSAJ__c = true;
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);      
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);    
        //Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Grupos
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor', 2);
            listaGrupos[0].name = 'grupoA';
            listaGrupos[0].SAC_PermiteConsultas__c = true;
            listaGrupos[0].SAC_PorcentajeAsignacion__c = 80;
            listaGrupos[0].SAC_MaximoCasosDiarios__c = 1;
            listaGrupos[0].SAC_Externo__c = true;
            listaGrupos[0].SAC_Email__c = 'test@test.com'; 
            listaGrupos[0].SAC_Email2__c = 'test2@test.com';  
            listaGrupos[0].SAC_Email3__c = 'test3@test.com'; 
            listaGrupos[1].name = 'grupoB';
            listaGrupos[1].SAC_PorcentajeAsignacion__c = 20;
            listaGrupos[1].SAC_MaximoCasosDiarios__c = 1;
            SAC_DatabaseDML.insertListDML(listaGrupos, false);    
            //Database.insert(listaGrupos);

            //Cuenta
            Account ac = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            SAC_DatabaseDML.insertDML(ac, false);    
            //Database.insert(ac);

            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('AccountId', ac.Id);

            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(casoReclamacion, false);  
            //Database.insert(casoReclamacion);

            //Interaccion consulta
            Map<String, Object> camposInt = new Map<String, Object>();
            camposInt.put('SAC_Reclamacion__c', casoReclamacion.Id);
            camposInt.put('SAC_DNI__c', '76588338V');
            camposInt.put('SAC_Email1__c', 'testEmail@t.t');
            camposInt.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);

            SAC_Interaccion__c interaccion = SAC_TestDataFactory.crearInteraccion('Consulta',camposInt);
            SAC_DatabaseDML.insertDML(interaccion, false);
            //Database.insert(interaccion); 

            //Template
            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'nombreTest',
                DeveloperName = 'SAC_PlantillaReclamacionConsulta',
                TemplateType = 'text', 
                HtmlValue = '<p>htmlValue<p>', 
                Body = 'Texted', 
                FolderId = UserInfo.getUserId()
            );
            SAC_DatabaseDML.insertDML(validEmailTemplate, false);
            //Database.insert(validEmailTemplate);
        }
    }

    @isTest
    static void obtenerInformacionTest(){
        SAC_Interaccion__c interaccion = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Email1__c = 'testEmail@t.t' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];  

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_GestionEmailsConsultas.WrappedInfo resultado = SAC_LCMP_GestionEmailsConsultas.obtenerInformacion(interaccion.Id);
            Test.stopTest();

            System.assertNotEquals(null, resultado, 'La obtención de datos ha fallado');
        }
    }
}