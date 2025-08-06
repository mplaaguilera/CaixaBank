public class CBK_MCC_Grupo_Colaborador_BI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_MCC_Grupo_Colaborador__c>) tp.newList);
	}
    
    private void process(List<CC_MCC_Grupo_Colaborador__c> listNewObj) {
        //Debug para ver que funciona bien el proceso, borrar cuando se añada la funcionalidad
        System.debug('Llega al CBK_MCC_Grupo_Colaborador_BI_TRHan');
    }

}