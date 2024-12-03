/**********************************************************************************************************************
 Name:	  CC_AccountTriggerHelper
 Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase auxiliar de los Triggers de Account.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App COPS		Juan Antequera		04/02/2022			Init version

***********************************************************************************************************************/
public with sharing class CC_AccountTriggerHelper {

	/**
	 * @description		 Actualización de teléfonos de los casos asociados a la cuenta
	 * @param  listNewObj  list of Users
	 */
	public static void actualizacionTelefonos(List<Account> listNewObj) {

        Set<Id> setIdAcc = new Set<Id>();
        List<Case> listCasosActualizar = new List<Case>();

        for (Account cuenta: listNewObj){
            setIdAcc.add(cuenta.Id);
        }
        if (!setIdAcc.isEmpty()){
            List<Case> listCase = [SELECT OS_Account_Phone__c, OS_Account_Mobile__c, Account.Phone, Account.PersonMobilePhone FROM Case 
                                                WHERE AccountId IN :setIdAcc 
                                                AND (RecordType.DeveloperName = 'OS_Cliente' OR RecordType.DeveloperName = 'OS_Empleado')
                                                AND Status != 'Rechazado'
                                                AND Status != 'Cerrado' LIMIT 100];

            if(!listCase.isEmpty()){
                
                for (Case caso: listCase){
                    caso.OS_Account_Phone__c = caso.Account.Phone;
                    caso.OS_Account_Mobile__c = caso.Account.PersonMobilePhone;
                    listCasosActualizar.add(caso);
                }
            }
            
        }
        if (!listCasosActualizar.isEmpty()){
            Database.update(listCasosActualizar, false);
        }
	}
}