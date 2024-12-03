/**********************************************************************************************************************
 Name:	  CIBE_OverrideNewEventButtonController
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del aura CIBE_OverrideNewEventButtonController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
    1.0			DE79495				Lucía Muñoz 	    13/10/2023			Init version

***********************************************************************************************************************/

public with sharing class CIBE_OverrideNewEventButtonController {
    
    @AuraEnabled
    public static String getRoleUser(String recordType){
        String roleUser;
        String recordTypeDN;
        Boolean hasCustomPermission = getCustomPermission();
        List<String> lstPS = new List<String>{'CIB','CIBE_CIBEmpresas', 'EMP'};

        if(User.SObjectType.getDescribe().isAccessible() ){
            roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;
        }
        if(lstPS.contains(roleUser) || hasCustomPermission){
            if(roleUser == 'EMP'){
                recordTypeDN = [SELECT Id,DeveloperName, Name  FROM RecordType WHERE SobjectType = 'Event' AND  Id = :recordType].DeveloperName;
                if(recordTypeDN == 'CIBE_EventodelGestor'){
                    roleUser = 'altaEMP';
                }else if(recordTypeDN == 'CIBE_EventoCliente'){
                    roleUser = 'errorEMP';
                }
            }else{
                roleUser = 'CIBE';
            }
            
        } 
        return roleUser;
    }

    public static Boolean getCustomPermission(){
        Boolean hasCustomPermission = false;

        if(FeatureManagement.checkPermission(CIBE_AppConstants.EVENT_BUTTON_OVERRIDE)){
            hasCustomPermission=true;
        }

        return hasCustomPermission;
    }
}