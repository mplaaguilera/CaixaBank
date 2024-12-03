/**********************************************************************************************************************
 Name:	  CBK_MaskUtilities_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_MaskUtilities del framework de registro de enmascaramiento.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	26/05/2021			Init version
***********************************************************************************************************************/
@IsTest private class CBK_MaskUtilities_Test {
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
    * @description Método de test para validar la invocación de la funcionalidad de getMaskObjectConfig
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testGetMaskObjectConfig() {
		CBK_MaskObject__mdt a;
		CBK_MaskObject__mdt b;
		a = CBK_MaskUtilities.getMaskObjectConfig('Account');
		b = CBK_MaskUtilities.getMaskObjectConfig('NoExiste');
		System.assertEquals('Account', a.CBK_Objeto__c,'No coincide recuperado con el valor esperado');
		System.assertEquals(null,b,'No coincide recuperado con el valor esperado');
	}
	/**
    * @description Método de test para validar la invocación de la funcionalidad de getNextMaskObject
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testGetNextMaskObject() {
		CBK_MaskObject__mdt a;
		CBK_MaskObject__mdt b;
		a = CBK_MaskUtilities.getMaskObjectConfig(null);
		b = CBK_MaskUtilities.getNextMaskObject(a);
		System.assertNotEquals(null, a,'No coincide recuperado con el valor esperado');
	}	
	/**
    * @description Método de test para validar la invocación de la funcionalidad de getMaskFieldsConfig
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testGetMaskFieldsConfig() {
		CBK_MaskObject__mdt a = CBK_MaskUtilities.getMaskObjectConfig(null);
		List<CBK_MaskField__mdt> lst = CBK_MaskUtilities.getMaskFieldsConfig(a.Id);
		System.assertNotEquals(null, lst,'No coincide recuperado con el valor esperado');
		if (lst != null){
			System.assertNotEquals(0, lst.size(),'No coincide recuperado con el valor esperado');
		}
	}
	/**
    * @description Método de test para validar la invocación de la funcionalidad de getObjectRTs
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testGetObjectRTs() {
		Map<Id,String> mapRTs = CBK_MaskUtilities.getObjectRTs('Account');
		System.assertNotEquals(0, mapRTs.keyset().size(),'No coincide recuperado con el valor esperado');
	}
	/**
    * @description Método de test para validar la invocación de la funcionalidad de getFirstId
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testGetFirstId() {
		List <Account> accounts = [SELECT Id FROM Account ORDER BY Id ASC LIMIT 1];
		System.assertEquals(accounts[0].Id,CBK_MaskUtilities.getFirstId('Account'),'No coincide recuperado con el valor esperado');
	}
	/**
    * @description Método de test para validar la invocación de la funcionalidad de getLastId
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testGetLastId() {
		List <Account> accounts = [SELECT Id FROM Account ORDER BY Id DESC LIMIT 1];
		System.assertEquals(accounts[0].Id,CBK_MaskUtilities.getLastId('Account'),'No coincide recuperado con el valor esperado');
	}
	/**
    * @description Método de test para validar la invocación de la funcionalidad de chunkIDRange
    * @author   fzaragoza | 14/06/2021 
    **/
	@SuppressWarnings('PMD.AvoidHardcodingId')
    @IsTest static void testChunkIDRange() {
		List<Map<String, String>> chunkList = CBK_MaskUtilities.chunkIDRange('00Q5r000001BX2JEAW', '00Q5r000001Iv0LEAS', 10000);
		System.assertEquals(177,chunkList.size(),'No coincide recuperado con el valor esperado');
	}
	/**
    * @description Método de test para validar la invocación de la funcionalidad de queryString
    * @author   fzaragoza | 14/06/2021 
    **/
	@SuppressWarnings('PMD.AvoidHardcodingId')
    @IsTest static void testQueryString() {
		CBK_MaskObject__mdt a = CBK_MaskUtilities.getMaskObjectConfig(null);
		CBK_MaskObject__mdt b = CBK_MaskUtilities.getMaskObjectConfig('Account');
		String strQuery = CBK_MaskUtilities.queryString(a, 0 );
		String strQuery2 = CBK_MaskUtilities.queryString('00Q5r000001BX2JEAW', '00Q5r000001Iv0LEAS', b, 100);
		System.assertNotEquals(null,strQuery,'No coincide recuperado con el valor esperado');
		System.assertNotEquals(null,strQuery2,'No coincide recuperado con el valor esperado');
	}
	/**
    * @description Método de test para validar la invocación de la funcionalidad de valorEnmascarado
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void testValorEnmascarado() {
		Object valor;
		valor = CBK_MaskUtilities.valorEnmascarado('Nombre');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.Assert(((String)valor).length()>0,'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Apellido');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Apellidos');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.Assert(((String)valor).length()>0,'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Nombre completo');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.Assert(((String)valor).length()>0,'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Fecha pasada');
		System.Assert(valor instanceof Date,'No coincide el tipo recuperado con el tipo esperado');
		System.Assert(((Date)valor)<Date.Today(),'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Fecha futura');
		System.Assert(valor instanceof Date,'No coincide el tipo recuperado con el tipo esperado');
		System.Assert(((Date)valor)>Date.Today(),'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Correo electrónico');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.Assert(((String)valor).length()>0,'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Nif');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.AssertEquals(9,((String)valor).length(),'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Cif');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.AssertEquals(0,((String)valor).length(),'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Ocultar texto');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.Assert(((String)valor).length()>0,'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Teléfono móvil');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.AssertEquals(9,((String)valor).length(),'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Teléfono fijo');
		System.Assert(valor instanceof String,'No coincide el tipo recuperado con el tipo esperado');
		System.AssertEquals(9,((String)valor).length(),'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Valor nulo');
		System.AssertEquals(null,valor,'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('Texto vacío');
		System.AssertEquals('',valor,'No coincide el valor recuperado con el valor esperado');
		valor = CBK_MaskUtilities.valorEnmascarado('NO EXISTENTE');
		System.AssertEquals(null,valor,'No coincide el valor recuperado con el valor esperado');

	}
	/**
    * @description Método de test para validar la invocación de la funcionalidad de valorMaximoId
    * @author   fzaragoza | 14/06/2021 
    **/
	@SuppressWarnings('PMD.AvoidHardcodingId')
    @IsTest static void testValorMaximoId() {
		List<Map<String, String>> chunkList = CBK_MaskUtilities.chunkIDRange('00Q5r000001BX2JEAW', '00Q5r000001Iv0LEAS', 1000000);
		System.Assert(!CBK_MaskUtilities.valorMaximoId('00Q5r000001BX2JEAW',chunkList),'No coincide con resultado esperado');
		System.Assert(CBK_MaskUtilities.valorMaximoId('00Q5r000001FjBLEA0',chunkList),'No coincide con resultado esperado');
	}

	/**
    * @description Método de test para validar la invocación de la funcionalidad de valorIdSiguiente
    * @author   fzaragoza | 14/06/2021 
    **/
	@SuppressWarnings('PMD.AvoidHardcodingId')
    @IsTest static void testValorIdSiguiente() {
		List<Map<String, String>> chunkList = CBK_MaskUtilities.chunkIDRange('00Q5r000001BX2JEAW', '00Q5r000001Iv0LEAS', 1000000);
		Id nextId = CBK_MaskUtilities.valorIdSiguiente('00Q5r000001BX2JEAW',chunkList);
		System.AssertEquals('00Q5r000001FjBLEA0',nextId,'No coincide con resultado esperado');
	}

	/**
    * @description Método de test para validar la invocación de la funcionalidad de checkCharMod
    * @author   fzaragoza | 19/07/2021 
    **/
    @IsTest static void testCheckCharMod() {
		System.AssertEquals(false,CBK_MaskUtilities.checkCharMod('a',0,5),'No coincide con resultado esperado');
		System.AssertEquals(true,CBK_MaskUtilities.checkCharMod('e',0,5),'No coincide con resultado esperado');
	}
}