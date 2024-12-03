@isTest
private class CBK_NotificationBar_Controller_Test {

	@isTest
	private static void getNotiMessage() {
		string app = 'SAC;CC';
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name = 'Administrador de sistema' limit 1];
		Test.startTest();
		CBK_Notification__c noti = createObjects();
		List<CBK_NotificationBar_Controller.MessageItems> lstMsgItems = CBK_NotificationBar_Controller.getNotificationMessages(app, String.valueOf(adminUser[0]));
		Test.stopTest();
	}

	@isTest
	private static void registerCache() {
		string app = 'SAC;CC';
		Test.startTest();
		CBK_Notification__c noti = createObjects();
		CBK_NotificationBar_Controller.registerCache(app, noti.Id);
		Test.stopTest();
	}

	@isTest
	private static void registerMessageByOwner() {
		string app = 'SAC;CC';
		CBK_Notification__c noti = createObjects();
		Id userId = userinfo.getUserId();
		CBK_Notification_History__c setting = new CBK_Notification_History__c();
		setting.SetupOwnerId = userId;
		setting.Alert__c = '0';
		upsert setting;

		Test.startTest();
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE  Id =: userId limit 1];
		System.runAs(adminUser[0]) {

			List<CBK_NotificationBar_Controller.MessageItems> lstmsgItems = new List<CBK_NotificationBar_Controller.MessageItems> ();
			CBK_NotificationBar_Controller.MessageItems msgItems = new CBK_NotificationBar_Controller.MessageItems();
			msgItems.title = noti.Title__c;
			msgItems.autor = 'Administrador';
			msgItems.msg = noti.Message__c;
			msgItems.alertType = noti.AlertType__c;
			msgItems.name = '1';
			msgItems.dateMessage = String.valueOf(noti.CreatedDate);
			msgItems.createdbyId = noti.CreatedById;
			lstmsgItems.add(msgItems);
			CBK_NotificationBar_Controller.registerMessageByOwner(JSON.serialize(lstmsgItems), String.valueOf(userId), msgItems.name);

		}
		Test.stopTest();
	}

	@isTest
	private static void triggerUpdate() {
		CBK_Notification__c noti = createObjects();

		Test.startTest();
		noti.App__c = 'SAC;CC;Cops';
		update noti;
		Test.stopTest();
	}


	private static CBK_Notification__c createObjects() {
		Datetime initDate = system.now();
		Datetime finishDate = system.now().addDays(3);

		CBK_Notification__c noti = new CBK_Notification__c();
		noti.Title__c = 'Notif Test';
		noti.Autor__c = 'Administrador';
		noti.Message__c = 'Body test';
		noti.App__c = 'SAC;CC';
		noti.AppStr__c = 'SAC;CC';
		noti.AlertType__c = 'info';
		noti.InitDate__c = Date.valueOf(initDate.format('yyyy-MM-dd'));
		noti.FinishDate__c = Date.valueOf(finishDate.format('yyyy-MM-dd'));
		insert noti;
		return noti;
	}


}