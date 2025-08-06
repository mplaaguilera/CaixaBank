/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoria
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase wrapper con los datos de registro de auditoría del framework de registro de auditoría.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	20/04/2021			Init version
***********************************************************************************************************************/
@IsTest
private class CBK_RegistroAuditoriaEntry_Test {
    
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 20/04/2021 
    **/
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<3;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
    }
    /**
    * @description Método de test para validar la asignación/recuperación de valores
    * @author   fzaragoza | 20/04/2021 
    **/
    @IsTest static void asignacionTest() {

        CBK_RegistroAuditoriaEntry instanciaAsignacion = new CBK_RegistroAuditoriaEntry();
        instanciaAsignacion.aplicacion = 'Aplicacion';
        instanciaAsignacion.tipo = 'Tipo';
        instanciaAsignacion.operacion = 'Operacion';
        instanciaAsignacion.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        System.assertEquals('Aplicacion', instanciaAsignacion.aplicacion,'No coincide el valor con el esperado');
        System.assertEquals('Tipo', instanciaAsignacion.tipo,'No coincide el valor con el esperado');
        System.assertEquals('Operacion', instanciaAsignacion.operacion,'No coincide el valor con el esperado');
        System.assertEquals(3, instanciaAsignacion.registrosAuditados.size(),'No coincide el número de registros esperados');
    }
}