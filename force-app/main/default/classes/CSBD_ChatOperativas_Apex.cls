public with sharing class CSBD_ChatOperativas_Apex {

    @AuraEnabled
    public static Map<String, Object> init(Id recordId) {
        return new Map<String, Object>{
            'admin' => [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name == 'System Administrator'
        };
    }
}