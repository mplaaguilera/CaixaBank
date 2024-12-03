public without sharing class SAC_TMECaso_AI_TRHan extends CC_TriggerHandlerBase {

    private static final Id RECTYPETMOGLOBAL = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SAC_TMEGlobal').getRecordTypeId();
    private static final Id RECTYPETMETAREA = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SAC_TMETarea').getRecordTypeId();

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SAC_TMECaso__c>)tp.newList, (Map<Id, SAC_TMECaso__c>)tp.newMap);
	}    
    private void process(List<SAC_TMECaso__c> listNewObj, Map<Id, SAC_TMECaso__c> mapNewObj){
        List<SAC_TiempoEstados__c> listaTPEs = new List<SAC_TiempoEstados__c>();
        SAC_Accion__c tarea = new SAC_Accion__c();

        for (SAC_TMECaso__c tme :listNewObj) {
            if(tme.RecordTypeId == RECTYPETMOGLOBAL){
                SAC_TiempoEstados__c tpeGlobalAux = new SAC_TiempoEstados__c(SAC_TMECaso__c = tme.id, 
                                                            SAC_Inicio__c = tme.SAC_FechaInicioTMEGlobal__c, SAC_Estado__c = 'Global');
 
                listaTPEs.add(tpeGlobalAux);
            }       
 
            //Entramos en aquellos casos de tme tarea. Creamos una instancia de una accion, y le asignamos el id que trae el tme en su campo SAC_Accion__c
            if(tme.RecordTypeId == RECTYPETMETAREA){
                //Si se trata de una nueva tarea, cargamos el campo TMECaso
                if(tme.name.contains('Ejecución de la tarea')){
                    tarea.id = tme.SAC_Accion__c;
                    tarea.SAC_TMECaso__c = tme.id;
                }
                //Si se trata de una prorroga, cargamos el campo TMEProrroga
                if(tme.name.contains('Prorroga de la tarea')){
                    tarea.id = tme.SAC_Accion__c;
                    tarea.SAC_TMEProrroga__c = tme.id;
                }
            }         
        }

        if (!listaTPEs.isEmpty()) { 
            SAC_DatabaseDML.insertListDML(listaTPEs, false); 
        }
        if (String.isNotBlank(tarea.id) && (String.isNotBlank(tarea.SAC_TMECaso__c) || String.isNotBlank(tarea.SAC_TMEProrroga__c))) { 
        //if (String.isNotBlank(tarea.id) && String.isNotBlank(tarea.SAC_TMECaso__c)) { 
        	SAC_DatabaseDML.updateDML(tarea, false); 
        }

               
    }
}