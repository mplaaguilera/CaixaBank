@isTest 
private class CC_Lista_Valores_TRDisp_test {

	@isTest
	private static void testFWKTrigger() {
        CC_Lista_Valores__c objlistavalores = new CC_Lista_Valores__c();
        objlistavalores.CC_Activa__c  = true;
        insert objlistavalores;
        update objlistavalores;
	}
}