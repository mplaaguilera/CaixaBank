public class SEG_Fotosdefacturacion_BU_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_Fotosdefacturacion__c>)tp.newList, (Map<Id, SEG_Fotosdefacturacion__c>)tp.newMap, (List<SEG_Fotosdefacturacion__c>)tp.oldList, (Map<Id, SEG_Fotosdefacturacion__c>)tp.oldMap);
	}
	private void process(List<SEG_Fotosdefacturacion__c> listNewObj, Map<Id, SEG_Fotosdefacturacion__c> mapNewObj, List<SEG_Fotosdefacturacion__c> listOldObj, Map<Id, SEG_Fotosdefacturacion__c> mapOldObj) {
		updateFF(listNewObj,mapOldObj);
    }
	private void updateFF(List<SEG_Fotosdefacturacion__c> listNewObj,Map<Id, SEG_Fotosdefacturacion__c> mapOldObj)
	{
		List<Id> lstFFMCC = new List<Id>();
		List<Id> lstFFGrupo = new List<Id>();
		List<Id> lstFFMarca = new List<Id>();
		for(SEG_Fotosdefacturacion__c ff : listNewObj){
			if(ff.SEG_Actualizar__c && !mapOldObj.get(ff.Id).SEG_Actualizar__c){
				ff.SEG_Actualizar__c = false;
				if(ff.SEG_Operativa__c == SEG_FotoFacturacionHandler.Operativa.MCC.name()){
					lstFFMCC.add(ff.Id);
				}else if(ff.SEG_Operativa__c == SEG_FotoFacturacionHandler.Operativa.Marca.name()){
					lstFFMarca.add(ff.Id);
				}else{
					lstFFGrupo.add(ff.Id);
				}
			}
		}
		
		if(lstFFMCC.size()>0){
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.MCC, lstFFMCC);
			System.enqueueJob(ffHandler);
		}
		if(lstFFGrupo.size()>0){
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.Grupo, lstFFGrupo);
			System.enqueueJob(ffHandler);
		}
		if(lstFFMarca.size()>0){
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.Marca, lstFFMarca);
			System.enqueueJob(ffHandler);
		}
	}
}