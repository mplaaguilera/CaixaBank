public class SEG_Fotosdefacturacion_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_Fotosdefacturacion__c>)tp.newList, (Map<Id, SEG_Fotosdefacturacion__c>)tp.newMap, (List<SEG_Fotosdefacturacion__c>)tp.oldList, (Map<Id, SEG_Fotosdefacturacion__c>)tp.oldMap);
	}
	private void process(List<SEG_Fotosdefacturacion__c> listNewObj, Map<Id, SEG_Fotosdefacturacion__c> mapNewObj, List<SEG_Fotosdefacturacion__c> listOldObj, Map<Id, SEG_Fotosdefacturacion__c> mapOldObj) {

        informarOperacionFF(listNewObj);
    }

    private void informarOperacionFF(List<SEG_Fotosdefacturacion__c> listNewObj)
    {
        if(listNewObj[0].SEG_Operacion__c != null)
        {
            List<SEG_Operacion__c> lstOp = new List<SEG_Operacion__c>([SELECT id, SEG_Foto_de_Facturacion__c FROM SEG_Operacion__c WHERE id = :listNewObj[0].SEG_Operacion__c]);

            if(lstOp.size() > 0)
            {
                lstOp[0].SEG_Foto_de_Facturacion__c = listNewObj[0].id;
                update lstOp; 
            }
        }
    }
}