/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoria_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_PKChunkUtils del framework de enmascaramiento.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	20/04/2021			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_PKChunkUtils_Test {
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 14/06/2021 
    **/
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
    }
    /**
    * @description Método de test para validar la invocación de la funcionalidad de segmentación
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testChunkGroup() {
        List<Account> lstAcc= [SELECT id FROM Account ORDER BY id ASC];
        List<Map<String, String>> lstMapIntervalos= CBK_PKChunkUtils.chunkIdRange(String.valueOf(lstAcc[0].Id), String.valueOf(lstAcc[lstAcc.size()-1].Id), 1);
        System.assertEquals(2, lstMapIntervalos.size(),'No coincide el número de registros esperados');
        List<Map<String, String>> lstMapIntervalos2= CBK_PKChunkUtils.chunkIdRange(String.valueOf(lstAcc[0].Id), String.valueOf(lstAcc[lstAcc.size()-1].Id), 50);
        System.assertEquals(1, lstMapIntervalos2.size(),'No coincide el número de registros esperados');
    }
    /**
    * @description Método de test para validar la invocación de la funcionalidad de segmentación
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testFuncionesBase() {  
        //Long valor =  0;
        //string strValorBase62 = CBK_PKChunkUtils.encodeBase62(valor);
        //System.assertEquals('0',strValorBase62,'No coincide recuperado con el valor esperado');
        System.assertEquals('1',CBK_PKChunkUtils.removeLeadZeroes('00001'),'No coincide recuperado con el valor esperado');
        System.assertEquals(null,CBK_PKChunkUtils.removeLeadZeroes('00000'),'No coincide recuperado con el valor esperado');
        System.assertEquals(null,CBK_PKChunkUtils.removeLeadZeroes('a'),'No coincide recuperado con el valor esperado');
        System.assertEquals('00005',CBK_PKChunkUtils.prefixLongWithZeros(5,5),'No coincide recuperado con el valor esperado'); 
    }
}