public with sharing class SPV_CaseAITRHan extends CC_TriggerHandlerBase{
    
    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap);
    }

    private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj) {

        //Llamada al método que filtra los casos de SPV
        List<Case> listCasosSPV = SPV_CaseHelper.filtrarCasosSPV(listNewObj);

        if(!listCasosSPV.isEmpty()){

            List<Case> lstReclamaciones = new List<Case>();
            List<Case> lstPretensiones = new List<Case>();
            
            for(Case caso :listCasosSPV){
                if(caso.RecordTypeId == RECTYPERECLAMACION){
                    lstReclamaciones.add(caso);
                }else if(caso.RecordTypeId == RECTYPEPRETENSION){
                    lstPretensiones.add(caso);
                }
            }
            
            if(!lstReclamaciones.isEmpty()){
                //Si se cambia el account o el contact
                SPV_CaseHelper.createReclamanteRecord(lstReclamaciones, null);
            }

            if(!lstPretensiones.isEmpty()){
                SPV_CaseHelper.insertarPermisosPretension(lstPretensiones);
                SPV_CaseHelper.asignarIdPretension(lstPretensiones);
            }  
     
            SPV_CaseHelper.creacionCaseExtension(listCasosSPV); //Al añadir un case, se crea un registro asociado del CBK_Case_Extension__c

        }     
    }
}