/**********************************************************************************************************************
Name:	  CIBE_Oportunidades_Vinculadas_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "CIBE_Oportunidades_Vinculadas"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY       AUTHOR			DATE			Description
    1.0			US410036         Jose Maria     14/07/2022		Init Version
    2.0         US618099         Ali            12/06/2023      Edit linkOpp() para que la primera oportunidad vinculada sea favorita.
    3.0         US584194         Lucía          21/06/2023      Nuevo metodo roleCIB() y modificado el metodo updateEvent() para añadir el usuario cib.
    4.0         US584194         Luis          	12/06/2024      Nuevo metodo updateCommentEvent() para actualizar el comentario y al cierre del evento.


		
***********************************************************************************************************************/
public with sharing class CIBE_Oportunidades_Vinculadas_Controller {
  
    /**
     * Get the picklist values for the field "StageName" from custom metadata
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getStatusValues(String objectName, String fieldName) {
        
        
        AV_PicklistListValuesByRecordType__mdt picklistValues = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_ListSalesProcess__c, AV_ObjectLabel__c, AV_RecordTypeLabel__c 
        From AV_PicklistListValuesByRecordType__mdt where AV_RecordTypeLabel__c = 'Component' and AV_ObjectLabel__c = :objectName limit 1];
        
		
		List<String> pickValues = new List<String>();
		pickValues = picklistValues.AV_ListSalesProcess__c.split(';');
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		// loop to Schema picklist 
        for(String val:pickValues){
			for(Schema.PicklistEntry pickListVal : ple){
				if (val == String.valueOf(pickListVal.getValue())) {
					listPicklist.add(new Map<String, String>{'label' => String.valueOf(pickListVal.getLabel()), 
                                                                'value' => String.valueOf(pickListVal.getValue())});
				}
			}
        }
        return listPicklist;
    }

    @AuraEnabled
    public static List<AV_CustomActivityOpportunity__c> getRecordInfo(String recordId, String objectName) {
        Event evt = null;
        Task tsk = null;
        switch on objectName {
            when 'Event' {
                evt = [SELECT AV_Task__c FROM Event WHERE Id = :recordId LIMIT 1];
            }
            when 'Task' {
                tsk = [SELECT AV_Task__c FROM Task WHERE Id = :recordId LIMIT 1];
            }
        }
        String avTaskString = null;
        List<AV_CustomActivityOpportunity__c> listTareaOpp;
        if(evt != null){
            avTaskString = evt.AV_Task__c;
        }else{
            avTaskString = tsk.AV_Task__c;
        }
        if(avTaskString != null){
            listTareaOpp = [SELECT Id, AV_LicensePlate__c, Name, AV_IsMain__c, AV_Opportunity__c, AV_Task__c, AV_Product__c, AV_Product__r.Name, AV_Gestor__c,AV_Gestor__r.Name, RecordTypeId, AV_Opportunity__r.RecordTypeId, 
            AV_Opportunity__r.RecordType.Name, AV_Priority__c, AV_ReviewDate__c, AV_Stage__c, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, 
            AV_Concepto5__c, AV_HoldingAnotherEntity__c, AV_Entity__c, AV_DueDate__c, 
            AV_FeeAmount__c, AV_Amount__c, AV_TypeOfInterest__c, AV_Commentary__c, AV_Opportunity__r.AV_Tenencia__c,AV_IncludeInPrioritizingCustomers__c
            FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :avTaskString ORDER BY AV_IsMain__c DESC];
        }
        if(listTareaOpp!= null && !listTareaOpp.isEmpty()){
            List<AV_CustomActivityOpportunity__c> listOppTaskRes = new List<AV_CustomActivityOpportunity__c>();
            for(AV_CustomActivityOpportunity__c oppTask :listTareaOpp) {
                AV_CustomActivityOpportunity__c oppTaskRes = new AV_CustomActivityOpportunity__c();
                oppTaskRes = oppTask;
                listOppTaskRes.add(oppTaskRes);
            }
            return listOppTaskRes;
        } else {
            return new List<AV_CustomActivityOpportunity__c>();
        }
    }


    @AuraEnabled(cacheable=true)
    public static Opportunity getOppFields(String oppoId) {
        List<Opportunity> opps = new List<Opportunity>();
        if(String.isNotBlank(oppoId) && Opportunity.SObjectType.getDescribe().isAccessible()) {
            opps = [SELECT Id, Name, StageName, CIBE_CerradoNegativo__c, CIBE_ProbabilidadExito__c, Amount,
                    CloseDate, AV_Comentarios__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaProximoRecordatorio__c
                    FROM Opportunity WHERE Id = :oppoId];
        }
        if(!opps.isEmpty()) {
            return opps.get(0);
        }
        
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Task getTaskFields(String taskId) {
        List<Task> tasks = new List<Task>();
        if(String.isNotBlank(taskId) && Task.SObjectType.getDescribe().isAccessible()) {
            tasks = [SELECT Id, AccountId FROM Task WHERE Id = :taskId];
        }
        if(!tasks.isEmpty()) {
            return tasks.get(0);
        }
        
        return null;
    }


    @AuraEnabled(cacheable=true)
    public static String getTaskRecordTypeName(String taskId) {
        List<Task> tasks = new List<Task>();
        if(String.isNotBlank(taskId) && Task.SObjectType.getDescribe().isAccessible()) {
            tasks = [SELECT Id, RecordType.DeveloperName FROM Task WHERE Id = :taskId];
        }
        if(!tasks.isEmpty()) {
            return tasks.get(0).RecordType.DeveloperName;
        }
        
        return null;
    }
    
    

    /**
	* Method that delete the opp-task record when user unlink the oppoportunity from task
	*
	*/
	@AuraEnabled
	public static void unlinkOpp(String oppTask, String recordId ) {
        String methodName = 'unlinkOpp';
        String objectName = (String.isNotBlank(recordId) && recordId.startsWith('00T')) ? 'Task' : ((String.isNotBlank(recordId) && recordId.startsWith('00U')) ? 'Event' : '');

        String avTask = null;
        switch on objectName {
            when 'Event' {
                avTask = [Select AV_Task__c From Event Where Id = :recordId limit 1].AV_Task__c;
            }
            when 'Task' {
                avTask = [Select AV_Task__c From Task where Id = :recordId limit 1].AV_Task__c;
            }
        }

        if(String.isNotBlank(avTask)){
            List<AV_CustomActivityOpportunity__c> listToDelete = new List<AV_CustomActivityOpportunity__c>();
            if(AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible()) {
                listToDelete = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c=:avTask AND AV_Opportunity__c = :oppTask];
            }
            if(!listToDelete.isEmpty()){
                User user = AV_AppUtilities.getUserInfo();
                AV_CustomActivityOpportunity__c oppTask2 = new AV_CustomActivityOpportunity__c(Id=listToDelete.get(0).id, OwnerId=user.Id);
                
                if(AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isUpdateable()) {
                    Database.update(oppTask2, false);
                }

                AV_LogDebug.printLogDebug(methodName, 'oppTask: ' + oppTask2);
                
                Database.DeleteResult deleteResult = Database.delete(oppTask2, false);
                List<Database.DeleteResult> listDeleteResult = new List<Database.DeleteResult>();
                listDeleteResult.add(deleteResult);
                AV_AppUtilities.displayErrors(methodName, listDeleteResult);
            }
        }
	}


    /**
     * Retrieve the list of the opp's no related with task or event but is related with the customer
     */
    @AuraEnabled
    public static List<Opportunity> retrieveListWithOutTask(List<AV_CustomActivityOpportunity__c> listTareaOpp,String recordId, String objectName){
        String methodName = 'retrieveListWithOutTask';
        List<Opportunity> listOpp;
        Set<String> setStatusOpen = new Set<String>{'Potencial', 
                                                    'En curso',
                                                    'CIBE_Pendiente_Firma'};
        List<String> listStatusOpen = AV_AppUtilities.getListFromSet(setStatusOpen);
        String roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;
        String vencida = 'CIBE_Vencido';
        
        
        String idAccount = null;
        switch on objectName {
            when 'Event' {
                idAccount = [SELECT AccountId FROM Event WHERE Id = :recordId LIMIT 1].AccountId;
            }
            when 'Task' {
                idAccount = [SELECT AccountId FROM Task WHERE Id = :recordId LIMIT 1].AccountId;
            }
        }

        if(listTareaOpp != null) {   
            Set<String> setOpp = new Set<String>();
            String listOppId = '';
            
            if(!listTareaOpp.isEmpty()){
                for(AV_CustomActivityOpportunity__c tareaOpp : listTareaOpp){
                    if(tareaOpp.AV_Opportunity__c !=null){
                        setOpp.add(tareaOpp.AV_Opportunity__c);
                    }
                } 
            }
            if(setOpp != null && !setOpp.isEmpty()) {
                listOppId = AV_AppUtilities.setToStringIn(setOpp); 
            }                   
            //Get the opp's no related
            
            if(idAccount != null){
                String queryAll = '';
                String queryWhere = '';
                String queryOpp = '';
                queryOpp = 'Select Id, Name, AV_PF__c, AV_PF__r.Name, AV_Gestor__c, AV_Gestor__r.Name, RecordTypeId, RecordType.Name, AV_Potencial__c, AV_FechaProximoRecordatorio__c, StageName, AV_Valor1__c,'+ 
                'AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c,'+
                'AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Tenencia__c, AV_Entidad__c, CloseDate, AV_Cuota__c, Amount, AV_TipoInteres__c, AV_Comentarios__c,AV_IncludeInPrioritizingCustomers__c'+
                ' From Opportunity ';

                if(roleUser == 'CIB' || roleUser == 'CIBE_CIBEmpresas'){
                    queryWhere = ' WHERE AccountId = \''+ idAccount +'\' and ( StageName in '+ listStatusOpen + ' OR (StageName = \''+ vencida +'\' AND CloseDate  = LAST_N_MONTHS:4 ))';                         

                }else{
                    queryWhere = ' WHERE AccountId = \''+ idAccount +'\' and StageName in '+ listStatusOpen +' ';                         
                }
                                
                if (setOpp!=null && !setOpp.isEmpty()){
                    queryWhere = queryWhere + 'and Id not in '+ listOppId;
                    //queryWhere = queryWhere + 'and Id not in '+ listOppId; 
                }
                queryAll = queryOpp + queryWhere + ' Order by AV_FechaProximoRecordatorio__c ASC';
                listOpp = database.query(queryAll);
            }
        } 
        
        if(listOpp != null && !listOpp.isEmpty()){
            List<Opportunity> listOppRes = new List<Opportunity>();
            for(Opportunity opp : listOpp) {
                Opportunity oppRes = new Opportunity();
                oppRes = opp;
                listOppRes.add(oppRes);
            }
            
            return listOppRes;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String linkOpp(String recordId, String opp){
        String objectName = (String.isNotBlank(recordId) && recordId.startsWith('00T')) ? 'Task' : ((String.isNotBlank(recordId) && recordId.startsWith('00U')) ? 'Event' : '');

        String avTask = null;
        switch on objectName {
            when 'Event' {
                avTask = [SELECT AV_Task__c FROM Event WHERE Id = :recordId LIMIT 1].AV_Task__c;
            }
            when 'Task' {
                avTask = [SELECT AV_Task__c FROM Task WHERE Id = :recordId LIMIT 1].AV_Task__c;
            }
        }
        
        if(recordId != null && opp != null && avTask != null) {
            List<AV_CustomActivityOpportunity__c> listTareaOpp;
            listTareaOpp = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :avTask];
            

            List<AV_CustomActivityOpportunity__c> listOppTask = new List<AV_CustomActivityOpportunity__c>();
            if(AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible()) {
                listOppTask = [SELECT Id  FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :avTask AND AV_Opportunity__c = :opp LIMIT 1];
            }

            if(!listOppTask.isEmpty()) {
                return 'KO';
            }
            
            Id rt = Schema.SObjectType.AV_CustomActivityOpportunity__c.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.OPPTASK_RT).getRecordTypeId();
            AV_CustomActivityOpportunity__c taskOpp = new AV_CustomActivityOpportunity__c();
            taskOpp.RecordTypeId = rt;
            taskOpp.AV_Opportunity__c = opp;
            taskOpp.AV_Task__c = avTask;

            if(listTareaOpp.size() == 0){
                taskOpp.AV_IsMain__c = true;
            }
                
            if(AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isCreateable()) {
                insert taskOpp;
            }
            return 'OK';
        } else {
            return 'KO';
        }
    }


    /**
	* Method that update the opp-task main check
	*
	* @param oppTask AV_CustomActivityOpportunity__c record to update
	* @return void
	*/
	@AuraEnabled
	public static void updateMainRecord(String event, String opp) {
        String objectName = (String.isNotBlank(event) && event.startsWith('00T')) ? 'Task' : ((String.isNotBlank(event) && event.startsWith('00U')) ? 'Event' : '');

        String avTask = null;
        switch on objectName {
            when 'Event' {
                avTask = [SELECT AV_Task__c FROM Event WHERE Id = :event LIMIT 1].AV_Task__c;
            }
            when 'Task' {
                avTask = [SELECT AV_Task__c FROM Task WHERE Id = :event LIMIT 1].AV_Task__c;
            }
        }

        if(String.isNotBlank(avTask) && String.isNotBlank(event) && String.isNotBlank(opp)){
            List<AV_CustomActivityOpportunity__c> listOppTask = new List<AV_CustomActivityOpportunity__c>();
            if(AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible()) {
                listOppTask = [SELECT Id, AV_IsMain__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :avTask];
            }
            
            List<AV_CustomActivityOpportunity__c> listToUpd = new List<AV_CustomActivityOpportunity__c>();                                 
            for(AV_CustomActivityOpportunity__c optyTask : listOppTask) {
                if(optyTask.AV_Opportunity__c == opp) {
                    optyTask.AV_IsMain__c = true;
                } else{
                    optyTask.AV_IsMain__c = false;
                }
                listToUpd.add(optyTask);
            }
            
            if(AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isUpdateable()) {
                update listToUpd;
            }
        }
	}


    /**
	* Method that update the opportunity
	*
	* @param listOppRecords opportunities record to update
	* @return void
	*/
	@AuraEnabled
	public static void updateRecords( List<Map<String, Object>> listOppRecords) {
        String validateDecimal = '[0-9]+(,){0,1}[0-9]*$';
		Pattern validatePattern =Pattern.compile(validateDecimal);

        List<Opportunity> listOpp = new List<Opportunity>();
        
        for(Map<String, Object> obj : listOppRecords) {
            Opportunity opp=new Opportunity();
            if( obj.get('id')!=null){
                opp.id=(String) obj.get('id'); 
            }
            if( obj.get('cerradonegativo')!=null){
                opp.CIBE_CerradoNegativo__c=(String) obj.get('cerradonegativo');
            }
            if( obj.get('status')!=null){
                opp.StageName=(String) obj.get('status');
            }
            if( obj.get('exito')!=null){
                opp.CIBE_ProbabilidadExito__c=(String) obj.get('exito');
            }
            if( obj.get('amount')!=null &&
                obj.get('amount')!=''){
                String importe = (String) obj.get('amount');
                if(importe.contains('.')){
                    importe = importe.replace('.', '');
                }
                opp.CIBE_AmountDivisa__c = String.isBlank(importe) || importe == ' ' ? 0 : Decimal.valueOf(importe);
            }
            if( obj.get('closedate')!=null){
                opp.closedate= obj.get('closedate') != null ? Date.valueOf(String.valueOf(obj.get('closedate'))) : null;
            }
            if( obj.get('lastcoment')!=null){
                opp.AV_Comentarios__c=(String) obj.get('lastcoment');
            }
            if( obj.get('includePrior')!=null){
                opp.AV_IncludeInPrioritizingCustomers__c= (Boolean) obj.get('includePrior');
            }
            if( obj.get('proximoRecord')!=null){
                opp.AV_FechaProximoRecordatorio__c = (String) obj.get('proximoRecord') != null ? Date.valueOf(String.valueOf(obj.get('proximoRecord'))) : null;
            }

            listOpp.add(opp);
        }

        update listOpp;
    }    


    @AuraEnabled(cacheable=true)
    public static Boolean roleEMP(){
        Boolean emp = false;
        String roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;
        if(roleUser == 'EMP'){
            emp = true;
        }
        return emp;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean roleCIB(){
        Boolean cib = false;
        String roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;
        if(roleUser == 'CIB'){
            cib = true;
        }

        return cib;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean roleCIB2(){
        Boolean cibemp = false;
        String roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;
        if(roleUser == 'CIBE_CIBEmpresas' || roleUser == 'CIB'){
            cibemp = true;
        }

        return cibemp;
    }

    /**
     * @description     Updates the event by closing it and adding the comment.
     * @param recordId        Id of the event about to be closed
     * @param comentario   Comment added when the event was managed
     */
    @AuraEnabled
    public static void updateCommentEvent(String recordId, String comentario ) {

        if(recordId != null){
            Event eventoUpdate = new Event();
            eventoUpdate.Id = recordId;
            eventoUpdate.description = comentario;
            eventoUpdate.CSBD_Evento_Estado__c = 'Gestionada Positiva';
            if(eventoUpdate != null && Schema.sObjectType.Event.isUpdateable()){
            	Database.update(eventoUpdate, false);
        	}
        }
    }
    

    /**
     * @description     Updates the event by closing it and adding the comment.
     * @param recordId        Id of the event about to be closed
     * @param comentario   Comment added when the event was managed
     */
    @AuraEnabled
    public static void updateEvent(String recordId) {
        String methodName = 'updateEvent';
        List<Event> event = [select Id, CSBD_Evento_Estado__c from Event where id=:recordId];
       //actualizar el evento
        for(Event e : event){
            e.CSBD_Evento_Estado__c = 'Gestionada Positiva'; 
        }

        if(!event.isEmpty() && Schema.sObjectType.Event.isUpdateable()){
            Database.SaveResult[] updateEvent = Database.update(event, false);
                boolean hasError = false;
                List<Object> objs = new List<Object>();
                Map<String, String> msjs = new Map<String, String>();
                for (Integer i = 0; i < event.size(); i++) {
                    Database.SaveResult dr = updateEvent[i];
                    if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                        msjs.put(event[i].Id, ((String)dr.getErrors()[0].getMessage()));
                        objs.add(event[i]);
                        hasError = true;
                    }
                }
                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }
        }
    }

    /**
     * @description     Determine if a user is part of a opportunity team member
     * @param opportunityId   Id of opportunity
     * @param currentUser     CurrentUser Id
     */
    @AuraEnabled
    public static Boolean getOppTeamMember(String opportunityId, String currentUser){
        Boolean result = true;
        List<OpportunityTeamMember> oppTeamMemberList = [SELECT ID FROM OpportunityTeamMember 
                                                        WHERE OpportunityId = :opportunityId AND
                                                        (UserId = :currentUser OR Opportunity.OwnerId = :currentUser)];

        List<Opportunity> oppList = [SELECT Id from Opportunity WHERE Id =:opportunityId AND OwnerId = :currentUser];
        if(!oppTeamMemberList.isEmpty() || !oppList.isEmpty()){
            result = false;
        }
        return result;
    }


    /**
     * @description     Updates the event by closing it and adding the comment.
     * @param recordId        Id of the event about to be closed
     * @param comentario   Comment added when the event was managed
     */
    @AuraEnabled
    public static void updateTask(String recordId, String comentario, String estado, String tipo ) {
        String methodName = 'updateTask';
            Task tsk = [select Id, status, Description,AV_Tipo__c from Task where id=:recordId];
        
            tsk.status = !string.isBlank(estado) ? estado : CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO; 
            if(!String.isBlank(comentario) && !String.isBlank(tsk.Description) ){
                tsk.Description +=  '\n'+ comentario;
            }else if(!String.isBlank(comentario)){
                tsk.Description = comentario;
            }           
            String roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;
            if(roleUser == 'EMP'){
                tsk.AV_Tipo__c =  !string.isBlank(tipo) ? tipo : CIBE_AppConstants.LLAMADA_TIPO; 
            }else{
                tsk.AV_Tipo__c =  !string.isBlank(tipo) ? tipo : CIBE_AppConstants.LLAMADA_TLF_TIPO;
            }
            update tsk;
            //Database.SaveResult sr = Database.update(tsk, false);
        
    }

    /**
     * @description     Updates the event by closing it and adding the comment.
     * @param recordId        Id of the event about to be closed
     * @param comentario   Comment added when the event was managed
     */
    @AuraEnabled
    public static void insertManagementHistory(String recordId, String comentario, String estado, String tipo) {
        String methodName = 'insertManagementHistory';
            AV_ManagementHistory__c managementH = new AV_ManagementHistory__c();
            managementH.AV_ActivityId__c = recordId;
            managementH.AV_Date__c  = System.today();
            managementH.AV_Status__c = !string.isBlank(estado) ? estado : CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO; 
            String roleUser = [SELECT UserRole.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()].UserRole.DeveloperName;
            if(roleUser == 'EMP'){
                managementH.AV_Type__c =  !string.isBlank(tipo) ? tipo : CIBE_AppConstants.LLAMADA_TIPO; 
            }else{
                managementH.AV_Type__c =  !string.isBlank(tipo) ? tipo : CIBE_AppConstants.LLAMADA_TLF_TIPO;
            }
            managementH.AV_Comment__c = comentario;

        insert managementH;
        
    }

    /**
     * @description     Metodo que devuelve la lista de Actions
     * @param actionSetting 
     */
    @AuraEnabled(cacheable=true)
	public static List<Action> getActions(String actionSetting) {
		List<CIBE_FlowActions__mdt> actions = [SELECT Id, Label, CIBE_FlowName__c, CIBE_Output__c, CIBE_Order__c 
                                                FROM CIBE_FlowActions__mdt 
                                                WHERE CIBE_FlowName__c = :actionSetting LIMIT 1];
		if(actions.isEmpty()) {
			throw new IllegalArgumentException('getActions - No se ha encontrado ninguna flow action con ese setting. '+actionSetting);
		}
		List<String> translationNames = new List<String>();
		for(CIBE_FlowActions__mdt action : actions) {
			translationNames.add(action.label);
		}
		Map<String, String> translations = CIBE_TranslationUtilities.getInstance()
			.addTranslationNames(translationNames)
			.queryTranslations()
			.getTranslations();
		List<Action> result = new List<Action>();
		for(CIBE_FlowActions__mdt action : actions) {
			Action a = new Action();
			a.id = action.Id;
			a.name = action.CIBE_FlowName__c;
			a.output = action.CIBE_Output__c;
			a.label = translations.containsKey(action.Label) ? translations.get(action.Label) : '';			
			result.add(a);
		}
        return result;
    }

    @AuraEnabled
    public static void updateOpportunity(OpportunityWrapper wrap){
        try {
            Opportunity oppToUpdate = new Opportunity();
            oppToUpdate.id = wrap.id;
            oppToUpdate.StageName = wrap.status;
            oppToUpdate.CIBE_CerradoNegativo__c = wrap.cerradonegativo;
            oppToUpdate.CIBE_ProbabilidadExito__c = wrap.exito;
            oppToUpdate.CIBE_AmountDivisa__c = wrap.amount;
            oppToUpdate.CloseDate = wrap.closeDate;
            oppToUpdate.AV_Comentarios__c = wrap.lastcoment;
        
            update oppToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class OpportunityWrapper {
        @AuraEnabled public String id{get; set;}
        /*@AuraEnabled public String encurso;
        @AuraEnabled public String aprobado;
        @AuraEnabled public String riesgos;*/
        @AuraEnabled public String cerradonegativo{get; set;}
        @AuraEnabled public String status{get; set;}
        @AuraEnabled public String exito{get; set;}
        @AuraEnabled public Double amount{get; set;}
        @AuraEnabled public Date closedate{get; set;}
        @AuraEnabled public String lastcoment{get; set;}
    }


    public class Action {
		@AuraEnabled public String id;
		@AuraEnabled public String label;
		@AuraEnabled public String name;
		@AuraEnabled public String output;
	}
}