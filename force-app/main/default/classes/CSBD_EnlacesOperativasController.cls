public with sharing class CSBD_EnlacesOperativasController {
    @AuraEnabled
    public static Account obtenerDatosCuenta (String accountId){
        Account acc= [SELECT AV_NumPerso__c,CC_Numero_Documento__c,FirstName,LastName  FROM Account WHERE id= :accountId limit 1];
        return acc;
    }

   @AuraEnabled
    public static User obtenerDatosUser (String userId){
        User user= [SELECT EmployeeNumber, AV_ExternalID__c FROM User WHERE id= :userId limit 1];
        return user;
    }
}