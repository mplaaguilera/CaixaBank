public with sharing class EV_CBK_SCH_Queueable extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {
        List<CBK_SCH_PendingProcess__c> lstInfoPp = this.lstInfoProcess; work(LstInfoPp); }
 
    @TestVisible
    private static void work(List<CBK_SCH_PendingProcess__c> lstInfoPp) {
        System.debug('EV_CBK_SCH_Queueable - Input list: ' + JSON.serialize(LstInfoPp));
        List<Campaign> updateLst = new List<Campaign>();
        for(CBK_SCH_PendingProcess__c pp : LstInfoPp){
            Campaign camp = new Campaign();
            camp.Id = pp.RecordId__c;
            camp.Status = pp.Param1__c;
            updateLst.add(camp);
        }
        
        Database.update(updateLst);
    }
}