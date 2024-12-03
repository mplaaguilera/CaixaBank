global class CC_activityTimeline_Model implements Comparable {

    @AuraEnabled
    public Id RecordId {get;set;}

    @AuraEnabled
    public String ActivityTimelineType {get;set;}

    @AuraEnabled
    public String Subject {get;set;}

    @AuraEnabled
    public String Detail {get;set;}

    // Short event
    @AuraEnabled
    public String ShortDate {get;set;}

    // Text form of event duration
    @AuraEnabled
    public String EventTime {get;set;}

    // Task related to, Email "to", or list of attendees for events
    @AuraEnabled
    public String senders {get;set;}

    @AuraEnabled
    public String Recipients {get;set;}

    // Task/Event Asignee, or Email From
    @AuraEnabled
    public String Assigned {get;set;}

    @AuraEnabled
    public String AssignedId {get;set;}

    // For indicating task completion
    @AuraEnabled
    public boolean Complete {get;set;}

    public DateTime ActualDate {get;set;}

    @AuraEnabled
    public String Referencia {get;set;}

    @AuraEnabled
    public String CaseId {get;set;}

    @AuraEnabled
    public String CaseNumber {get;set;}

    @AuraEnabled
    public Boolean Entrante {get;set;}
    
    global Integer compareTo(Object objToCompare)
    {
        String a = ActualDate.format('yyyyMMdd HH:mm:ss');
        String  b= (objToCompare != null ?((CC_activityTimeline_Model)objToCompare).ActualDate : System.now()).format('yyyyMMdd HH:mm:ss');
        return b.compareTo(a);

    }

}