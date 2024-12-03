@isTest
public with sharing class AV_DeletePSQueuableTest {
  @TestSetup
  static void makeData(){
    AV_LogDebug.printLogDebug('test', 'test');
  }

  @isTest
  public static void testQueuable(){
    Test.startTest();
    User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
    System.runAs(userGcf){
        System.enqueueJob(new AV_DeletePSQueuable(null));
    }
    User us = AV_TestHelper.createUser(null);
    List<PermissionSetAssignment> result = [SELECT ID FROM PermissionSetAssignment WHERE AssigneeId = :us.Id];
    Test.stopTest();
    System.assert(!result.isEmpty());
  }
}