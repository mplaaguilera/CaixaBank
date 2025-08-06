/**
 * @description       : Controller class for the 
 * @author            : fzaragoza
 * @group             : 
 * @last modified on  : 31-01-2022
 * @last modified by  : fzaragoza
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   11-01-2022   fzaragoza   Initial Version
**/

public with sharing class CBK_PublicGroupManageController {
    
    public class MatrixElement {
        @AuraEnabled public Integer key;
        @AuraEnabled public String id;
        @AuraEnabled public String idUser;
        @AuraEnabled public String idGroup;
        @AuraEnabled public String fullnameUser;
        @AuraEnabled public String nameGroup;        
 
        /**
        * @description Constructor method
        * @author fzaragoza | 11-01-2022 
        * @param Integer key 
        * @param String id 
        * @param String idUser 
        * @param String fullnameUser 
        * @param String idGroup 
        * @param String nameGroup 
        **/
        public MatrixElement(Integer key, String id, String idUser, String fullnameUser, String idGroup, String nameGroup){
            this.key = key;
            this.id = id;
            this.idUser = idUser;
            this.idGroup = idGroup;
            this.fullnameUser = fullnameUser;
            this.nameGroup = nameGroup;
        }
    }

    /**
    * @description 
    * @author fzaragoza | 11-01-2022 
    * @return List<CBK_PublicGroupManageController.MatrixElement> 
    **/
    @AuraEnabled(cacheable=false)
    public static List<CBK_PublicGroupManageController.MatrixElement> getPublicGroupMatrix(){
        try {
            List<CBK_PublicGroupManageController.MatrixElement> result = new List<CBK_PublicGroupManageController.MatrixElement>();
            List <Group> lstGroups = CBK_PublicGroupManageController.getPublicGroupList(false);
            List<User>  lstUsers = CBK_PublicGroupManageController.getManagedUserList();
            List<String> lstStrGroups = new List<String>();
            List<String> lstStrUsers = new List<String>();
            Map<String,Group> mapGroups = new Map<String,Group>();
            Map<String,User> mapUsers = new Map<String,User>();
            List <GroupMember> lstGroupMembers = new List <GroupMember>();
            Map<String,String> mapPGU = new Map<String,String>();
            integer clave = 0;
            for (Group entry : lstGroups){
                lstStrGroups.add(entry.Id);
                mapGroups.put(entry.Id,entry);
            }
            for (User usr : lstUsers){
                lstStrUsers.add(usr.Id);
                mapUsers.put(usr.Id,usr);
            }
            lstGroupMembers = [SELECT Id, GroupId, UserOrGroupId, group.name from GroupMember WHERE GroupId IN :lstStrGroups AND UserOrGroupId IN :lstStrUsers ORDER BY group.name ASC, UserOrGroupId ASC];
            for (GroupMember gm : lstGroupMembers){
                String keyId = String.ValueOf(gm.GroupId) + String.ValueOf(gm.UserOrGroupId);
                mapPGU.put(keyId,gm.Id);
            }
            for(group g : lstGroups){
                for (User u : lstUsers){
                    String keyValue = String.ValueOf(g.Id)+String.ValueOf(u.Id);
                    String fullname = mapUsers.get(u.Id).lastname +', '+ mapUsers.get(u.Id).firstname;
                    if (mapPGU.containsKey(keyValue)){
                        result.add( new CBK_PublicGroupManageController.MatrixElement(clave++, mapPGU.get(keyValue),u.Id,fullname,g.Id,mapGroups.get(g.Id).name));
                    }
                    else{
                        result.add( new CBK_PublicGroupManageController.MatrixElement(clave++,null,u.Id,fullname,g.Id,mapGroups.get(g.Id).name));
                    }
                }
            }            
            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Group> getPublicGroupList(Boolean hierarchicalGroups){
        try {
            List<CBK_GestoresPGOperativosJerarquicos__c> lstGroup = CBK_GestoresPGOperativosJerarquicos__c.getAll().values();
            List<String> lstStrGroups = new List<String>();
            for (CBK_GestoresPGOperativosJerarquicos__c configEntry : lstGroup){
                if (((hierarchicalGroups && configEntry.CBK_PGJerarquico__c) || (!hierarchicalGroups && !configEntry.CBK_PGJerarquico__c)) && configEntry.CBK_Username__c == UserInfo.getUsername()){
                    lstStrGroups.add(configEntry.CBK_PublicGroupDevName__c);
                }
            } 
            List<Group> authPGList= new List<Group>();
            authPGList=[SELECT id,name,developername FROM group WHERE type='Regular' and developername in :lstStrGroups ORDER BY name ASC]; 
            return authPGList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=false)
    public static List<User> getManagedUserList(){
        try {
            List <Group> lstGroup = CBK_PublicGroupManageController.getPublicGroupList(true);
            List<String> lstStrHierarchyGroups = new List<String>();
            List<User> lstUsers = new List<User>();
            for (Group entry : lstGroup){
                lstStrHierarchyGroups.add(entry.Id);
            }
            lstUsers = [SELECT id,Username,firstname,lastname FROM User WHERE Id IN (select UserOrGroupId from groupmember where GroupId in :lstStrHierarchyGroups) ORDER BY id ASC];
            return lstUsers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static void deleteUserGroupMembership(string strID){
        try {
            ID deleteId = strId;
            GroupMember gm = new GroupMember();
            gm.Id = deleteId;
            delete gm;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static Id createUserGroupMembership(string idGroup,string idUser){
        try {
            GroupMember gm = new GroupMember();
            gm.GroupId = idGroup;
            gm.UserOrGroupId = idUser;
            insert gm;
            return gm.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}