public class CC_Task_BI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap);
    }
    
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj) {
        //Obtener las tareas CC_Task
        List<Task> listCCTask = new List<Task>();
        Id ccTaskRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');

        //Obtención de RT CC_
        Schema.DescribeSObjectResult R = task.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> lstRT = R.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        Set<Id> idRecordtypeOSSet = new Set<Id>();
        
        for (Schema.RecordTypeInfo rt: lstRT){
            if ((rt.getDeveloperName().left(3)=='CC_') || (rt.getDeveloperName().left(3)=='OS_')) {
                setIdsRt.add(rt.getRecordTypeId());
            }
            //Aislo Record Type Task COPS
            if(rt.getDeveloperName().left(3)=='OS_'){
                idRecordtypeOSSet.add(rt.getRecordTypeId());
            }
        }
           
        List<Task> listNewObjCC= New List<Task>();
        Map<Id, Task> mapNewObjCC = New Map<Id, Task>();
        
        //Aislo Tareas COPS
        List<Task> listNewObjOS= New List<Task>();
        
        for (Task tk: listNewObj){
            if(((setIdsRt).contains(tk.RecordTypeId))||(tk.RecordTypeId == null)){
                listNewObjCC.add(tk);
                mapNewObjCC.put(tk.Id,tk);                
            }
            //Tasks COPS
            if(idRecordtypeOSSet.contains(tk.RecordTypeId)){
                listNewObjOS.add(tk);
            }
            //CC_Task
            if (tk.RecordTypeId == ccTaskRTId){
                listCCTask.add(tk);
            }
        }
        
		if ((mapNewObjCC.size() != 0) || (listNewObjCC.size() != 0)){
            //marcarComoTareaAutomatica(listNewObj);
            //validarCreacionTarea(listNewObj);
            //enmascararPANs(listNewObj);
            enmascararPANs(listNewObjCC);
            //informarRecordType(listNewObj);
            informarRecordType(listNewObjCC);
        }
        if(!listNewObjOS.isEmpty()){
            copiarTaskType(listNewObjOS);
        }
        //Funciones Task con RT CC_Task
        if (!listCCTask.isEmpty()) {
            //Metodo para la US983197
            listCCTask = CC_MetodosUtiles.volcarValorTipo(listCCTask);
            completarTask(listCCTask); //Si la task que se esta insertando lo está haciendo con type Actividad manual y subject Otros, debe pasar su status a Completed.
            tareasNoTiempo(lisTCCTask);
        }
    }
    
    private void informarRecordType(List<Task> listNewObj) {
        Id cc_Task_RTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');  
        
    	for (Task tarea : listNewObj) {
            //Creación tarea traslado a incidencia
            tarea.CC_Ultima_Actualizacion__c = system.now();
        	if (tarea.type=='Traslado Incidencia' && tarea.RecordTypeId == null && tarea.Priority == 'Normal' && tarea.Agrupador__c != null && tarea.Status == 'Open')	
            {
            	tarea.RecordTypeId = cc_Task_RTId;
            }//Creación tarea de reasignación del caso
            else if(tarea.type=='Reasignación' && tarea.RecordTypeId == null && tarea.Priority == 'Normal' && tarea.Status == 'Completed'){
            	tarea.RecordTypeId = cc_Task_RTId;    
            }//Creación tarea de reactivación del caso
            else if(tarea.type=='Reactivación' && tarea.Subject=='Reactivación' && tarea.RecordTypeId == null && tarea.Priority == 'Normal' && tarea.Status == 'Completed'){
            	tarea.RecordTypeId = cc_Task_RTId;    
            }//Creación tarea de cierre del caso
            else if(tarea.type=='Cerrado' && tarea.Subject=='Cerrado' && tarea.RecordTypeId == null && tarea.Priority == 'Normal' && tarea.Status == 'Completed'){
            	tarea.RecordTypeId = cc_Task_RTId;    
            }//Creación tarea de correo entrante del caso
            else if(tarea.type=='Correo no identificado' && tarea.RecordTypeId == null){
            	tarea.RecordTypeId = cc_Task_RTId;        
            }
            else if(tarea.type=='Fax entrante' && tarea.RecordTypeId == null && tarea.Priority == 'Normal' && tarea.Status == 'Completed'){
            	tarea.RecordTypeId = cc_Task_RTId;        
            }
            
        }
    }
    
    private void enmascararPANs(List<Task> listNewObj) {
        Id cc_Task_RTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');  
		for (Task tarea : listNewObj) {
            
            if (tarea.type=='Automática' && (tarea.RecordTypeId == cc_Task_RTId)){

        		// Se establece un patrón para el PAN
				String panRegex = '[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}';
				Pattern myPattern = Pattern.compile(panRegex);

    			// Campo "Descripcion"
				if (!String.isEmpty(tarea.Description)) {
    				Matcher asuntoMatcher = myPattern.matcher(tarea.Description);
    				while (asuntoMatcher.find()) {
        				String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
        				tarea.Description = tarea.Description.replaceFirst(panRegex, encryptedPan);
    				}
				}
            
            	// Campo "Subject"
            	if (!String.isEmpty(tarea.Subject)) {
    				Matcher asuntoMatcher = myPattern.matcher(tarea.Subject);
    				while (asuntoMatcher.find()) {
        				String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
        				tarea.Subject = tarea.Subject.replaceFirst(panRegex, encryptedPan);
    				}
				}
             }
		}
            
    }
    private void copiarTaskType(List<Task> listNewObjOS){
        for(Task tarea: listNewObjOS){
            if(tarea.Type != null){
                tarea.OS_Tipo__c = tarea.Type;
            }
        }
    }

    /*****************************************************************
     * Si la task que se esta insertando lo está haciendo con type Actividad manual y subject Otros,
     * debe pasar su status a Completed.
    *****************************************************************/
    private void completarTask(List<Task> listNewTask) {
        for (Task newTask : listNewTask) {
            if (newTask.Type == 'Actividad manual' && newTask.Subject == 'Otros') {
                newTask.Status = 'Completed';
            }
        }
    }

    private void tareasNoTiempo(List<Task> listNewObjCC){
        //Actualizar la fecha de fin de las tareas que se han cerrado
        for (Task newTask : listNewObjCC) {
            if(String.isNotBlank(newTask.WhatId) && newTask.WhatId.getSObjectType().getDescribe().getName() == 'Case'){
                if(newTask.Status == 'Completed' || newTask.Status == 'Rechazada'){
                    newTask.CC_Fecha_Fin__c = CBK_UtilsDate.nowSYS();

                }
            }
        }

    }
}