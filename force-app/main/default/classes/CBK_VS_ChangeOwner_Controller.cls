public class CBK_VS_ChangeOwner_Controller {
    public List<CBK_Adoption_FWK__c> getIDs;
    public String updateIds{get;set;}    
    public CBK_VS_ChangeOwner_Controller(ApexPages.StandardSetController controller){
        getIDs = controller.getSelected();
        updateIds = '';  
        for(CBK_Adoption_FWK__c myIds : getIDs){
            updateIds += myIds.Id + ','; 
        }
        updateIds = updateIds.removeEnd(','); 
    } 
}