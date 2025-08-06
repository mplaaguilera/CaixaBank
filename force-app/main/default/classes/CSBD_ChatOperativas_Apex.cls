public with sharing class CSBD_ChatOperativas_Apex {

    @AuraEnabled
    public static Map<String, Object> init(Id recordId) {        
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        return new Map<String, Object>{
            'admin' => profileName == 'System Administrator' || profileName == 'Administrador del sistema'
        };
    }
}