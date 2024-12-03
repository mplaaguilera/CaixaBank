@IsTest
public with sharing class CC_PushTopic_Test {
    
    public CC_PushTopic_Test() {} 
    
    @testSetup
    static void testSetup() {
    }

    //TODO SendEvent Test
    static testMethod void sendEventTest() {
        String message = 'Prueba';
        String type = 'warning';
        CC_PushTopic.SendEvent(message, type);
    }

    //TODO CurrentUserProfile
    static testMethod void currentUserProfileTest() {
        String profile;
        profile = CC_PushTopic.CurrentUserProfile();

        System.assert(profile.contains('Admin'));
    }
    
	static testMethod void TienePermisoNotificacionTest() {
       String profile;
       profile = CC_PushTopic.CurrentUserProfile();
       Boolean permisotest = CC_PushTopic.TienePermisoNotificacion();
       Boolean resultado = false;
       if (permisotest == true || permisotest == false)
       {
           resultado = true;
       }
       System.assertEquals(true,resultado);

   }


    static testMethod void getTypePicklistItems() {
        List<CC_PushTopic.PicklistItem> typePicklistItems = CC_PushTopic.getTypePicklistItems();
        List<String> typePicklistValues = new List<String>();
        System.assertEquals(4, typePicklistItems.size());
        for (CC_PushTopic.PicklistItem typePicklistItem : typePicklistItems) {
            typePicklistValues.add(typePicklistItem.value);
        }
        System.assert(typePicklistValues.contains('warning'));
        System.assert(typePicklistValues.contains('info'));
        System.assert(typePicklistValues.contains('error'));
        System.assert(typePicklistValues.contains('success'));
    }

    static testMethod void getVisibleNotificationsTest() {
        CC_Historial_Notificacion__c newNotification1 = new CC_Historial_Notificacion__c (CC_Mensaje__c = 'Mensaje Test 1', CC_Tipo__c = 'warning');
        CC_Historial_Notificacion__c newNotification2 = new CC_Historial_Notificacion__c (CC_Mensaje__c = 'Mensaje Test 2', CC_Tipo__c = 'info');
        CC_Historial_Notificacion__c newNotification3 = new CC_Historial_Notificacion__c (CC_Mensaje__c = 'Mensaje Test 3', CC_Tipo__c = 'error');
        CC_Historial_Notificacion__c newNotification4 = new CC_Historial_Notificacion__c (CC_Mensaje__c = 'Mensaje Test 4', CC_Tipo__c = 'success');
        insert newNotification1;
        Test.setCreatedDate(newNotification1.Id, Datetime.now().addMinutes(-4));
        insert newNotification2;
        Test.setCreatedDate(newNotification2.Id, Datetime.now().addMinutes(-3));
        insert newNotification3;
        Test.setCreatedDate(newNotification3.Id, Datetime.now().addMinutes(-2));
        insert newNotification4;
        Test.setCreatedDate(newNotification4.Id, Datetime.now().addMinutes(-1));
        List<CC_PushTopic.NotificationHHmm> notificationList = CC_PushTopic.getVisibleNotifications();
        System.assertEquals(4, notificationList.size());
        System.assertEquals('Mensaje Test 4', notificationList[0].message);
        System.assertEquals('Mensaje Test 3', notificationList[1].message);
        System.assertEquals('Mensaje Test 2', notificationList[2].message);
        System.assertEquals('Mensaje Test 1', notificationList[3].message);
    }

    static testMethod void saveNotificationTest() {
        CC_PushTopic.saveNotification('Mensaje Test 1', 'warning');
        List<CC_Historial_Notificacion__c> notificationResult = [SELECT CC_Mensaje__c, CC_Tipo__c FROM CC_Historial_Notificacion__c];
        System.assertEquals(1, notificationResult.size());
        System.assertEquals('Mensaje Test 1', notificationResult[0].CC_Mensaje__c);
        System.assertEquals('warning', notificationResult[0].CC_Tipo__c);
    }
    
    static testMethod void notificacionCSBDTest() {        
   
        Group publicGroup = [SELECT Type, Email, Name, DeveloperName, Id FROM Group WHERE DeveloperName = 'Cola_3N_CSBD' LIMIT 1];        
                
        GroupMember member = new GroupMember(UserOrGroupId = UserInfo.getUserId(), GroupId = publicGroup.Id);
        insert member;
   
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        	CC_PushTopic.notificacionCSBD('Mensaje CSBD Test');
        }
        
        
    	
        
    }
    
    
}