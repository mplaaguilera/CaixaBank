public with sharing class CC_PushTopic {

    @AuraEnabled
    public static void sendEvent(String message, String type) {
        // Publish messages as notifications
        Notification__e notificacion = new Notification__e(
            Message__c = message,
            Type__c = type
        );
        EventBus.publish(notificacion);
    }

    @AuraEnabled(cacheable=true)
    public static String CurrentUserProfile() {
        return [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
    }
    
    @AuraEnabled
    public static Boolean notificacionCSBD(String mensaje) {        
        Boolean mostrarAviso = false;
        List <GroupMember> members = [SELECT Id, Group.Name, UserOrGroupId, SystemModstamp FROM GroupMember WHERE Group.Type = 'Queue' 
            AND Group.DeveloperName = 'Cola_3N_CSBD' AND UserOrGroupId =: UserInfo.getUserId()];
                                      
        if(members.size() > 0){
            List<CC_Historial_Notificacion__c> notificacionesHist = new List<CC_Historial_Notificacion__c>();
            notificacionesHist.add(new CC_Historial_Notificacion__c(CC_Mensaje__c = mensaje, CC_Tipo__c = 'warning'));
            
            if (!notificacionesHist.isEmpty()) {
                Database.SaveResult[] ResultNH = Database.insert(notificacionesHist);
            }
            
            mostrarAviso = true;    
        }
        return mostrarAviso;
    }    

    @AuraEnabled(cacheable=true)
    public static Boolean tienePermisoNotificacion() {
        return FeatureManagement.checkPermission('CC_Creacion_avisos');
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean get3NUser() {
        //UserInfo.getUserId() 
        
        Boolean user3N =false;
        /*List<Group> idCola = new List<Group>();
        idCola =[SELECT Id FROM Group WHERE type= 'Queue' AND DeveloperName = 'Cola_3N_CSBD'];
		if (!idCola.isEmpty()){*/
			List<GroupMember> usuarios = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Cola_3N_CSBD' AND  Group.Type= 'Queue' and UserOrGroupId =:UserInfo.getUserId()];
            if (!usuarios.isEmpty()){
                user3N = true;
            }
        //}
        return user3N;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getCCUser() {

        Boolean userCC =false;
			List<User> usuarios = [SELECT Id, UserRole.name FROM User WHERE (UserRole.name= 'Contact Center' OR UserRole.name = 'Contact Center sin acceso a Directorio') AND Id =:UserInfo.getUserId()];
            if (!usuarios.isEmpty()){
                userCC = true;
            }
        return userCC;
    }
    
    @AuraEnabled
    public static void saveNotification(String message, String type) {
        CC_Historial_Notificacion__c notification = new CC_Historial_Notificacion__c(
            CC_Mensaje__c = message,
            CC_Tipo__c = type
        );
        insert notification;
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistItem> getTypePicklistItems() {
        List<PicklistItem> typePicklistItems = new List<PicklistItem>();
        Schema.DescribeSObjectResult objDescribe = CC_Historial_Notificacion__c.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get('CC_Tipo__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry value : values) {
            typePicklistItems.add(new PicklistItem(value.getLabel(), value.getValue()));
        }
        return typePicklistItems;
    }

    @AuraEnabled
    public static List<NotificationHHmm> getVisibleNotifications() {
        List<NotificationHHmm> notificationHHmmList = new List<NotificationHHmm>();
        List<CC_Historial_Notificacion__c> lstNotificaciones = new List<CC_Historial_Notificacion__c>([SELECT CC_Mensaje__c, CreatedDate FROM CC_Historial_Notificacion__c
                                                            WHERE CC_Visible__c = true ORDER BY CreatedDate DESC]);
        List <GroupMember> members = new List<GroupMember>([SELECT Id, Group.Name, UserOrGroupId, SystemModstamp FROM GroupMember WHERE Group.Type = 'Queue' 
                                              AND Group.DeveloperName = 'Cola_3N_CSBD' AND UserOrGroupId =: UserInfo.getUserId()]);
        
        for (CC_Historial_Notificacion__c notification : lstNotificaciones) {
            String mensaje = notification.CC_Mensaje__c;
        	if(mensaje.contains('Ha llegado un nuevo caso a la cola 3N_CSBD')){
                if(members.size() > 0){
                	notificationHHmmList.add(new NotificationHHmm(notification));
                }
            }else{
                notificationHHmmList.add(new NotificationHHmm(notification));
            }
        }
        return notificationHHmmList;
    }
    
    public with sharing class NotificationHHmm {
        public NotificationHHmm(CC_Historial_Notificacion__c notification) {
            this.message = notification.CC_Mensaje__c;
            this.createdTime = notification.CreatedDate.format('HH:mm');
        }

        @AuraEnabled
        public String message {get; set;}

        @AuraEnabled
        public String createdTime {get; set;}
    }

    public with sharing class PicklistItem {
        public PicklistItem(String label, String value) {
            this.label = label;
            this.value = value;
        }

        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}
    }
}