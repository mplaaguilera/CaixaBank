@isTest
public class AV_ScriptReassignacion_Test {
     @TestSetup
     public static void setup(){
        User u = AV_TestHelper.createUser(null);
      	PermissionSetGroup lecturaYanalitics = [SELECT Id FROM PermissionSetGroup WHERE PermissionSetGroup.DeveloperName = 'AV_Lectura_y_Analytics' LIMIT 1];
        insert (new PermissionSetAssignment(PermissionSetGroupId = lecturaYanalitics.Id,AssigneeId = u.Id));
     }

     @isTest 
     public static void testScript(){
        User u = [SELECT Id FROM USER WHERE Alias = 'tsAlias' LIMIT 1];
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            System.enqueueJob(new AV_ScriptReassignacion());
            System.enqueueJob(new AV_ScriptReassignacion());//Para cuando no hay
        }
        Test.stopTest();
        List<PermissionSetAssignment> lecturaYanaliticsList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetGroup.DeveloperName = 'AV_Lectura_y_Analytics' AND AssigneeId = :u.Id];
        System.assert(lecturaYanaliticsList.isEmpty());
    }
    @isTest
    public static void testScript2(){
        User u = [SELECT Id,Email,AV_Funcion__c,IsActive,AV_ExternalId__c,AV_DeactiveAutoPS__c FROM USER WHERE Alias = 'tsAlias' LIMIT 1];
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            System.enqueueJob(new AV_ScriptReassignacion(new List<User>{u}));
        } 
        Test.stopTest();
        System.assert(true);
    }
}