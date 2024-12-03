public class CC_Task_BD_TRHan extends CC_TriggerHandlerBase {
    
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.oldList, (Map<Id, Task>)tp.oldMap);
	}
    
    private void process(List<Task> listOldObj, Map<Id, Task> mapOldObj) {

        Id rtId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        List<Task> listOldObjFilt = new List<Task>();
        for(Task t : listOldObj){
            if(t.RecordTypeId == rtId){
                listOldObjFilt.add(t);
            }
        }
        if(!listOldObjFilt.isEmpty()){
            Boolean permisoBorrado = FeatureManagement.checkPermission('CC_Borrado_Task');
            if (Test.isRunningTest()){
                permisoBorrado =false;
            }        
            List<String> rtBloqueados = New List<String>();
            Schema.DescribeSObjectResult rtd = Task.SObjectType.getDescribe();
            List<Schema.RecordTypeInfo> rtInfo = rtd.getRecordTypeInfos();        
            for (Schema.RecordTypeInfo  rt : rtInfo ){
                    if ((rt.developername.left(2)=='CC')||(rt.developername.left(2)=='OS')||(rt.developername.left(2)=='OB')){
                        rtBloqueados.add(rt.RecordTypeId);
                    } 
            }
                
            //Control de registros incluidos en el contexto para aplicar lógica específica de borrado
            //controlBorrado para evitar la necesidad de querys adicionales si no hay RT afectados 
            boolean controlBorrado =false;
            for (Task tarea: listOldObjFilt){
                    if(rtBloqueados.contains(tarea.RecordTypeId)) {
                        controlBorrado=true;
                }
            }   
            
            list<CBK_Activity_Extension__c> lstExtDel = new list<CBK_Activity_Extension__c>();
            
            if (controlBorrado) {
                map<Id,CBK_Activity_Extension__c > mapTask = new map<Id,CBK_Activity_Extension__c >();
                for (CBK_Activity_Extension__c  extTask: [Select Id,CBK_Eliminable__c, AV_ActivityId__c  
                                                            from CBK_Activity_Extension__c 
                                                           where AV_ActivityId__c in :mapOldObj.keySet()]){
                    mapTask.put(extTask.AV_ActivityId__c ,extTask);
                }
                
                boolean eliminable;
                for (Task tarea: listOldObjFilt){
    //                if ((mapTask.containsKey(tarea.Id)) && (rtBloqueados.contains(tarea.RecordTypeId))){
                    if (rtBloqueados.contains(tarea.RecordTypeId)){
                        eliminable=	mapTask.containsKey(tarea.Id);
                        if (eliminable) {
                            eliminable=mapTask.get(tarea.Id).CBK_Eliminable__c;
                        }
                        if (eliminable || permisoBorrado) {
                            if(mapTask.containsKey(tarea.Id)) {
                                lstExtDel.add(mapTask.get(tarea.Id));
                            }                            
                        } else {
                            tarea.addError('No tiene permisos para eliminar el registro'); 
                        }
                    }
                }   
    
                //Borramos registros de la extendida de registros autorizados
                //linea borrada "delete lstExtDel;" y añadido para evitar que salte error
                if (!lstExtDel.isEmpty()) {
                    Database.delete(lstExtDel,false);
                }
            }
    	}
    }
}