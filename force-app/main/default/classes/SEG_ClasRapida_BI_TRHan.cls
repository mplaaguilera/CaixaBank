public with sharing class SEG_ClasRapida_BI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_ClasificacionRapida__c>)tp.newList);
    }
    
    private void process(List<SEG_ClasificacionRapida__c> listNewObj) {
            concatenaCR(listNewObj);	       
	}   
    

    public static void concatenaCR(List<SEG_ClasificacionRapida__c> listNewObj) {
        


        for (SEG_ClasificacionRapida__c cRapida : listNewObj) {
                String tpmv = '';

                if(cRapida.SEG_Tematica__c != null ){
                    tpmv = tpmv + String.valueOf(cRapida.SEG_Tematica__c);
                }
                if(cRapida.SEG_Producto__c != null ){
                    tpmv = tpmv + String.valueOf(cRapida.SEG_Producto__c);
                }
                if(cRapida.SEG_Motivo__c != null ){
                    tpmv = tpmv + String.valueOf(cRapida.SEG_Motivo__c);
                }
                if(cRapida.SEG_Detalle__c != null ){
                    tpmv = tpmv + String.valueOf(cRapida.SEG_Detalle__c);
                }
                if(cRapida.OS_Causa__c != null ){
                    tpmv = tpmv + String.valueOf(cRapida.OS_Causa__c);
                }
                if(cRapida.OS_Solucion__c != null ){
                    tpmv = tpmv + String.valueOf(cRapida.OS_Solucion__c);
                }
                if(cRapida.OS_GrupoTrabajo__c != null ){
                    tpmv = tpmv + String.valueOf(cRapida.OS_GrupoTrabajo__c);
                }
               cRapida.SEG_TPMV__c = tpmv;           
        }
    }
}