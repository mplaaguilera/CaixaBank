public with sharing class CC_UtilityClass {
    /*
    * Métodos helper.
    */
	
	/*
    * Obtener el nombre del tipo de un objeto SObject.
	*/
	public static String getSObjectTypeName(SObject so) {
		return so.getSObjectType().getDescribe().getName();
	}
}