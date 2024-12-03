/*
Name:	  CIBE_Contacts_ControllerDelete
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for CIBE_Contacts
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0                         Alex Campos         27/10/2022      Init Version
*/
public with sharing class CIBE_Contacts_ControllerDelete {

    @AuraEnabled
    public static void deleteContact() {

        System.debug('Esta clase se borra.');
    }

}