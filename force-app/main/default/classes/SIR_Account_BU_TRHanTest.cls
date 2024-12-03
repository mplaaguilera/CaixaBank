/*****************************************************************
 Name:  SIR_Account_BU_TRHanTest
 Copyright © 2021  CaixaBank

 Proposito:   Clase Test de la clase SIR_Account_BU_TRHan                                                                                                                   

 Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0            US244057         atmira         03/09/2021	      Created    
    1.2            USXXXXXX         atmira         16/06/2021	      Solo se asignan los procesos si estos tienen visibilidad sobre el recordtype correspondiente,desarrollo derivado de la apertura a PRESOL
*****************************************************************/


@istest
public with sharing class SIR_Account_BU_TRHanTest {
    @istest
    public static void updateGestorTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User primero = SIR_TestDataFactory.createTestUser('primero',rol,'System Administrator');
        PermissionSet psSSMM = [SELECT Id FROM PermissionSet WHERE Name = :SIR_Constantes.PS_SSMM_NAME];
        insert new PermissionSetAssignment(AssigneeId = primero.id, PermissionSetId = psSSMM.Id);
        User segundo = SIR_TestDataFactory.createTestUser('segundo',rol,'System Administrator');
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :SIR_Constantes.PS_GESTOR_NAME];
        insert new PermissionSetAssignment(AssigneeId = segundo.id, PermissionSetId = ps.Id);
        SIR_Constantes constantes = new SIR_Constantes();

        System.runAs(primero) {
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.CrearProceso(cuenta);
            SIREC__SIREC_obj_informacionCliente__c informacionCliente = SIR_TestDataFactory.CrearInfoCliente(cuenta);
            SIR_FormularioRefinanciacion__c formulario = SIR_TestDataFactory.CrearFormulario(proceso); 
            formulario.SIR_Persona__c = cuenta.Id;
            update formulario;
            test.startTest();
                cuenta.OwnerId = segundo.Id;
                update cuenta; 
            test.stopTest();
        }
        System.assertEquals(segundo.Id, [SELECT OwnerId FROM SIREC__SIREC_obj_proceso__c].OwnerId , constantes.STRING_TEST);
        System.assertEquals(segundo.Id, [SELECT OwnerId FROM SIR_FormularioRefinanciacion__c].OwnerId , constantes.STRING_TEST);
        System.assertEquals(segundo.Id, [SELECT OwnerId FROM SIREC__SIREC_obj_informacionCliente__c].OwnerId , constantes.STRING_TEST);

    }
}