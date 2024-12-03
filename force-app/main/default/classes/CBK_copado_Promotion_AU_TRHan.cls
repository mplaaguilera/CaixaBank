public with sharing class CBK_copado_Promotion_AU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<copado__Promotion__c>)tp.newList);
	}
	
	private void process(List<copado__Promotion__c> listNewObj) {
        
        list<string> lstPromos = new list<string>();
		list<string> lstMetas = new list<string>();
        Map<Id,list<string>> mapMetas = new Map<Id,list<string>>();
        
        Set<Id> envSet = (new Map<Id, copado__Environment__c>([SELECT Id FROM copado__Environment__c where CBK_CheckMetadata__c	=true])).keySet();

        
        for(copado__Promotion__c promo : listNewObj) {
            //Si la promotion está Completed y está en el listado de entornos a auditar, lanzamos comprobación de colisiones
            if ((promo.copado__Status__c=='Completed') && (envSet.contains(promo.copado__Destination_Environment__c))){
                lstPromos.add(promo.Id);
            }
        }
        
        

        map<id,id> mapUs = new map<id,id>();

        if (lstPromos.size()>0){
            for (copado__Promoted_User_Story__c us :[select copado__User_Story__c,copado__Promotion__r.copado__Destination_Environment__c
                                                       from copado__Promoted_User_Story__c
                                                      where copado__Promotion__c in :lstPromos ]){
                mapUs.put(us.copado__User_Story__c,us.copado__Promotion__r.copado__Destination_Environment__c);
            }
        }
        
        if (mapUs.size()>0){
            for (copado__User_Story_Metadata__c meta : [select copado__Metadata_API_Name__c,copado__User_Story__c
                                                        from copado__User_Story_Metadata__c 
                                                         where copado__User_Story__c in :mapUs.keySet()]){
                                                                                         
                if (mapMetas.containsKey(mapUs.get(meta.copado__User_Story__c))){
                    lstMetas = mapMetas.get(mapUs.get(meta.copado__User_Story__c));
                } else {
                    lstMetas = new list<string>();
                } 
                lstMetas.add(meta.copado__Metadata_API_Name__c);   
                mapMetas.put(mapUs.get(meta.copado__User_Story__c),lstMetas);
            }
        }   






        
        for (Id key : mapMetas.keySet()) {
            CBK_Control_Metadata.controlObjetos(mapMetas.get(key),key);
        }                                                
	}
}