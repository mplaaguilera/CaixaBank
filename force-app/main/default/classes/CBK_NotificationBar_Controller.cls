public with sharing class CBK_NotificationBar_Controller {

	@AuraEnabled(cacheable = true)
	public static List<MessageItems> getNotificationMessages(string app, string ownerId){
		List<CBK_Notification__c> lstNotibar = new List<CBK_Notification__c> ();
		Set<CBK_Notification__c> setNotibar = new Set<CBK_Notification__c> ();
		List<String> lstApp = String.isNotBlank(app) ? app.split(';') : new List<string> ();
		String filterApp = '';
		Integer i = 1;

		CBK_log.debug('CBK_NotificationBar_Controller Apps: ' + lstApp, LoggingLevel.INFO);
		string rep = '';
		for (String iter : lstApp) {
			if (i == 1) {
				filterApp = ' AppStr__c LIKE ' + '\'%' + iter + '%\''; }
			else { filterApp += ' OR AppStr__c LIKE ' + '\'%' + iter + '%\''; }
			i++;
		}
		System.debug(filterApp);
		Set<CBK_Notification__c> cc = new Set<CBK_Notification__c> ();
		if (String.isNotBlank(app)) {
			for (string str : lstApp) {
				if (cache.Org.contains(str.replace(' ',''))) {
					setNotibar.addAll((List<CBK_Notification__c>) cache.Org.get(str.replace(' ', '')));
				}
			}

			if (lstApp.size() > 1) {
				if (cache.Org.contains(app.replace(';', '').replace(' ',''))) {
					setNotibar.addAll((List<CBK_Notification__c>) cache.Org.get(app.replace(';', '').replace(' ', '')));
				}
			}
			lstNotibar.addAll(setNotibar);

			CBK_log.debug('CBK_NotificationBar_Controller Get Cache: ' + lstNotibar, LoggingLevel.INFO);

		}
		Datetime dateNow = system.now();
		if (lstNotibar.isEmpty()) {

			if (String.isNotBlank(filterApp)) {
				String query = 'SELECT Id, Message__c, CreatedDate, AlertType__c, App__c, AppStr__c, Autor__c, Name, Title__c, createdbyId, InitDate__c, FinishDate__c' +
				' FROM  CBK_Notification__c' +
				' WHERE (' + filterApp + ') AND (InitDate__c <= ' + dateNow.format('yyyy-MM-dd') + ' AND  FinishDate__c > ' + dateNow.format('yyyy-MM-dd') + ') AND AlertType__c <> \'banner\' order by CreatedDate desc limit 20';

				CBK_log.debug('getNotificationMessages - CBK_NotificationBar_Controller query: ' + query, LoggingLevel.INFO);

				lstNotibar = (List<CBK_Notification__c>) Database.query(query);

				cache.OrgPartition cachePart = cache.Org.getPartition('CBKNotification');
				for (string str : lstApp) {
					cachePart.put(str.replace(' ', ''), lstNotibar);
				}

				if (lstApp.size() > 1) {
					cachePart.put(app.replace(';', '').replace(' ', ''), lstNotibar);
				}
			}
		}
		List<MessageItems> lstMsgItem = new List<MessageItems> ();
		MessageItems msgItem;

		for (CBK_Notification__c nn : lstNotibar) {
			string strName = nn.Id + ownerId;
			msgItem = new MessageItems();
			msgItem.id = nn.Id;
			msgItem.autor = nn.Autor__c;
			msgItem.title = nn.Title__c;
			msgItem.msg = nn.Message__c;
			msgItem.name = nn.Name;
			msgItem.alertType = nn.AlertType__c;
			msgItem.createdbyId = nn.CreatedById;
			msgItem.dateMessage = nn.CreatedDate.format('dd/MM/yyyy HH:mm:ss');
			lstMsgItem.add(msgItem);	
		}
		CBK_log.debug('CBK_NotificationBar_Controller Notificaciones LWC: ' + JSON.serialize(lstMsgItem), LoggingLevel.INFO);
		return lstMsgItem;
	}

	@AuraEnabled(Cacheable = false)
	public static void registerCache(string app, string idNew) {
		List<CBK_Notification__c> lstNotibar = new List<CBK_Notification__c> ();
		Set<CBK_Notification__c> setNotibar = new Set<CBK_Notification__c> ();
		List<String> lstApp = String.isNotBlank(app) ? app.split(';') : new List<string> ();
		String filterApp = '';

		CBK_log.debug('CBK_NotificationBar_Controller - registerCache lstApp: ' + lstApp, LoggingLevel.INFO);

		integer i = 1;
		for (String iter : lstApp) {
			if (i == 1) {
				filterApp = ' AppStr__c LIKE ' + '\'%' + iter + '%\''; }
			else { filterApp += ' OR AppStr__c LIKE ' + '\'%' + iter + '%\''; }
			i++;
		}
		Datetime dateNow = system.now();
		if (String.isNotBlank(filterApp)) {
			String query = 'SELECT Id, Message__c, CreatedDate, App__c, AlertType__c, AppStr__c, Autor__c, Name, Title__c, createdbyId, InitDate__c, FinishDate__c' +
			' FROM  CBK_Notification__c' +
			' WHERE (' + filterApp + ') AND (InitDate__c <=' + + dateNow.format('yyyy-MM-dd') + ' AND  FinishDate__c >' + dateNow.format('yyyy-MM-dd') + ') order by CreatedDate desc limit 20';

			CBK_log.debug('CBK_NotificationBar_Controller - registerCache query: ' + query, LoggingLevel.INFO);

			lstNotibar = (List<CBK_Notification__c>) Database.query(query);

			cache.OrgPartition cachePart = cache.Org.getPartition('CBKNotification');
			for (string str : lstApp) {
				cachePart.put(str.replace(' ', ''), lstNotibar);
			}

			if (lstApp.size() > 1) {
				cachePart.put(app.replace(';', '').replace(' ', ''), lstNotibar);
			}
		}
	}

	@AuraEnabled(Cacheable = false)
	public static List<MessageItems> registerMessageByOwner(string messagesJson, string ownerId, string LastNoti) {
	CBK_log.debug('registerMessageByOwner ownerId: ' + ownerId + ' LastNoti' + LastNoti, LoggingLevel.INFO);

		List<MessageItems> lmsgItem = (List<MessageItems>) JSON.deserialize(messagesJson, List<MessageItems>.class);
		CBK_log.debug('registerMessageByOwner lmsgItem: ' + JSON.serialize(lmsgItem), LoggingLevel.INFO);

		List<MessageItems> lstItems = new List<MessageItems> ();
		Map<String,MessageItems> mapItem = new Map<String,MessageItems>();

		if (String.isNotBlank(ownerId)) {
			CBK_Notification_History__c vre = CBK_Notification_History__c.getInstance(ownerId);
			vre.Alert__c = String.isBlank(vre.Alert__c) ? '0' : vre.Alert__c;

			for (MessageItems item : lmsgItem) {
				if (Integer.valueOf(item.name) > Integer.valueOf(vre.Alert__c)) {
					lstItems.add(item);
					mapItem.put(item.name, item);
				}
			}

			if (lstItems.size() > 0) {
				vre.SetupOwnerId = ownerId;
				vre.NotificationId__c = mapItem.get(LastNoti).Id;
				vre.Alert__c = LastNoti;
				upsert vre;
			} 
		}
		CBK_log.debug('registerMessageByOwner return: ' + lstItems, LoggingLevel.INFO);
		return lstItems;
	}

	//Response
	public class MessageItems
	{
		@AuraEnabled
		public String id { get; set; }

		@AuraEnabled
		public String autor { get; set; }

		@AuraEnabled
		public String title { get; set; }

		@AuraEnabled
		public string msg { get; set; }

		@AuraEnabled
		public string name { get; set; }

		@AuraEnabled
		public string dateMessage { get; set; }

		@AuraEnabled
		public string createdbyId { get; set; }

		@AuraEnabled
		public string alertType { get; set; }
	}
}