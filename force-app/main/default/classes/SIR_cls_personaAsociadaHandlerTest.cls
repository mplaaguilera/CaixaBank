/*****************************************************************
 Name:  SIR_cls_personaAsociadaHandlerTest
 Copyright © 2021  CaixaBank
  
 Proposito :   Clase Test de la clase SIR_cls_personaAsociadaHandlerTest                                                                                                                  
  
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         26/07/2021     	 Created    

*****************************************************************/
@isTest
public with sharing class SIR_cls_personaAsociadaHandlerTest {

    /*****************************************************************
        Proposito :  relacionarProcesoClienteTest sirve para comprobar la logica del metodo relacionarProcesoCliente se comporta correctamente                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US244057         atmira         26/07/2021	      Created   
        
	*****************************************************************/

    @isTest
    public static void relacionarProcesoClienteTest() {
        
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('ssmm', rol, SIR_Constantes.SSMM_PROFILE_NAME);
        User gestor = SIR_TestDataFactory.createTestUser('gestor', rol, SIR_Constantes.GESTOR_PROFILE_NAME);

        List<PermissionSetAssignment> listadoPermisos = new List<PermissionSetAssignment>(); 
        for (PermissionSetGroupComponent permisoUnitario : [select Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name from PermissionSetGroupComponent where PermissionSetGroup.DeveloperName  = :SIR_Constantes.PS_GROUP_AV_GESTOR_NAME])
        {
            PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
            nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
            nuevoPermiso.AssigneeId = gestor.Id;
            listadoPermisos.add(nuevoPermiso);
        }

        database.insert(listadoPermisos,false);

        List<SIREC__SIREC_obj_acciones__c> listAccion = new List<SIREC__SIREC_obj_acciones__c>();
        PermissionSet psSSMM = [SELECT Id FROM PermissionSet WHERE Name = :SIR_Constantes.PS_SSMM_NAME];
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = psSSMM.Id);


        Test.startTest();
        System.runAs(usuario){
        Account cliente = SIR_TestDataFactory.crearCuenta();
        cliente.OwnerId = [SELECT Id FROM User WHERE LastName = 'gestor'].Id;
        update cliente;     
        SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
                                                                                SIREC__SIREC_fld_fechaInicio__c  = date.today(),
                                                                                SIREC__SIREC_fld_fechaLimite__c  = date.today(),
                                                                                SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                                                                                RecordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId(),
                                                                                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1
                                                                            );
        insert proceso;      
        SIREC__SIREC_obj_personaAsociada__c personaAsociada = new SIREC__SIREC_obj_personaAsociada__c(
            SIREC__SIREC_fld_IndMasRiesgo__c = 'S',
            SIREC__SIREC_fld_persona__c = cliente.Id,
            SIREC__SIREC_fld_proceso__c = proceso.Id
        );
        insert personaAsociada;
            
        }
        Test.stopTest();
        Account beforecliente = [SELECT Id, OwnerId FROM Account];
        SIREC__SIREC_obj_proceso__c procesoNewStatus = [SELECT Id, SIREC__SIREC_fld_cliente__c, OwnerId
                                                            FROM SIREC__SIREC_obj_proceso__c ];
        System.assertEquals(beforecliente.Id, procesoNewStatus.SIREC__SIREC_fld_cliente__c, 'No coincide el Id de cliente');
        System.assertEquals(beforecliente.OwnerId, procesoNewStatus.OwnerId, 'No coincide el Owner');
    }

    @isTest
    public static void imaginTest(){
        //Crear usuario IMAGIN
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuarioSSMM = SIR_TestDataFactory.createTestUser('ssmm', rol, SIR_Constantes.SSMM_PROFILE_NAME);

        List<PermissionSetAssignment> listadoPermisos = new List<PermissionSetAssignment>(); 
        for (PermissionSetGroupComponent permisoUnitario : [select Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name from PermissionSetGroupComponent where PermissionSetGroup.DeveloperName  = :SIR_Constantes.PS_GROUP_AV_GESTOR_NAME])
        {
            PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
            nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
            nuevoPermiso.AssigneeId = usuarioSSMM.Id;
            listadoPermisos.add(nuevoPermiso);
        }

        database.insert(listadoPermisos,false);
        
        PermissionSet psSSMM = [SELECT Id FROM PermissionSet WHERE Name = :SIR_Constantes.PS_SSMM_NAME];
        insert new PermissionSetAssignment(AssigneeId = usuarioSSMM.id, PermissionSetId = psSSMM.Id);


        Test.startTest();
        System.runAs(usuarioSSMM){
        //Crear oficina IMAGIN
        Account oficinaImagin = SIR_TestDataFactory.crearOficinaIMAGIN();

        //Crear cliente con oficina principal IMAGIN
        Account cliente = SIR_TestDataFactory.crearCuenta();
        cliente.AV_OficinaPrincipal__c = oficinaImagin.Id;
        cliente.OwnerId = usuarioSSMM.Id;
        update cliente;
        //Crear proceso  
        SIREC__SIREC_obj_proceso__c proceso = new SIREC__SIREC_obj_proceso__c(
                                                                                SIREC__SIREC_fld_fechaInicio__c  = date.today(),
                                                                                SIREC__SIREC_fld_fechaLimite__c  = date.today(),
                                                                                SIREC__SIREC_fld_fechaSituacion__c = date.today(),
                                                                                RecordtypeId = Schema.SObjectType.SIREC__SIREC_obj_proceso__c.getRecordTypeInfosByName().get(SIR_Constantes.PROCESO_RECORDTYPE_NAME_PRESOL).getRecordTypeId(),
                                                                                SIREC__SIREC_fld_estrategia__c = SIR_Constantes.PROCESO_ESTRATEGIA_E1
                                                                            );
        insert proceso; 
        //Crear personaAsociada
        
        SIREC__SIREC_obj_personaAsociada__c personaAsociada = new SIREC__SIREC_obj_personaAsociada__c(
            SIREC__SIREC_fld_IndMasRiesgo__c = 'S',
            SIREC__SIREC_fld_persona__c = cliente.Id,
            SIREC__SIREC_fld_proceso__c = proceso.Id
        );
        
        insert personaAsociada;
        }
        Test.stopTest();
        System.assertEquals([SELECT Id, Name from User WHERE EmployeeNumber = :SIR_Variables__mdt.getInstance('IMAGINGestor').Valor__c].Id, [SELECT Id, OwnerId FROM SIREC__SIREC_obj_proceso__c LIMIT 1].OwnerId,  'SIR_cls_personaAsociadaHandlerTest.imaginTest no se ha asignado el usuario Imagin correctamente');      
    }
}