/**********************************************************************************************************************
Name:	  AV_InterlocutionGroup_Controller
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Tareas y eventos asociados a la oportunidad
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.0			US352009	  Luis Fernández  	16/01/2023		  	Init version
                US517372
***********************************************************************************************************************/
public with sharing class AV_InterlocutionGroup_Controller {

    /**
     * Find the name field of the object AV_GrupoInterlocucion__c which matchs the AV_Numper__c field with the given id string
     * and return a list of all the objects who share the same name field value.
     * @param string clientId
     * @return List<AV_GrupoInterlocucion__c>
     */
    @AuraEnabled
    public static List<AV_GrupoInterlocucion__c>  retrieveGroupsList(String clientId){
    
    List<AV_GrupoInterlocucion__c> grp = [SELECT Id,Name FROM AV_GrupoInterlocucion__c WHERE AV_Numper__c = :clientId AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];
    if(grp.isEmpty()){
        return new List<AV_GrupoInterlocucion__c>();
    }
    return [SELECT AV_Numper__c,AV_Numper__r.Name,AV_IsInterlocutor__C,Name FROM AV_GrupoInterlocucion__C Where Name = :grp[0].Name AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];

    }

    /**
     * Return a map that relates the count of Opportunitys,Events and taks related to the members of interlocution group that matchs the given string name
     * @param String grpName
     * @return Map<String,Integer>
     */

    @AuraEnabled
    public static Map<String,Integer> countRecords(String grpName){


        Map<String,Integer> countRecords = new Map<String,Integer>();
        AggregateResult oppNumberRecords = [SELECT COUNT(Id) 
            FROM Opportunity 
            WHERE AccountId IN (SELECT AV_Numper__c FROM AV_GrupoInterlocucion__c WHERE Name = :grpName AND RecordType.DeveloperName = :AV_AppConstants.INTERLOC_GROUP_RT) 
            AND StageName IN (:AV_AppConstants.OPP_STATUS_POTENCIAL, :AV_AppConstants.OPP_STATUS_ENGESTION,:AV_AppConstants.OPP_STATUS_NOAPTO) 
            AND SystemModstamp = LAST_N_DAYS:730 and AV_ToDelete__c = false
            AND RecordType.DeveloperName IN (:AV_AppConstants.OPPINICIATIVA_RT, :AV_AppConstants.OPPALERTACOM_RT,:AV_AppConstants.OPPPROPUESTA_RT, :AV_AppConstants.OPPSUGERENCIA_RT,:AV_AppConstants.OPPLLAMADA_RT)];

        AggregateResult evNumberRecords = [SELECT COUNT(Id)
            FROM Event 
            WHERE AccountId IN (SELECT AV_Numper__c FROM AV_GrupoInterlocucion__c WHERE Name = :grpName AND RecordType.DeveloperName = :AV_AppConstants.INTERLOC_GROUP_RT)
            AND StartDateTime >= TODAY 
            AND CSBD_Evento_Estado__c =:AV_AppConstants.EVENT_STATUS_PENDIENTE
            AND RecordType.DeveloperName in (:AV_AppConstants.EVENTCLIENTE_RT) AND IsChild = false ];

        AggregateResult tskNumberRecords = [SELECT COUNT(Id) 
            FROM Task
            WHERE AccountId IN (SELECT AV_Numper__c FROM AV_GrupoInterlocucion__c WHERE Name = :grpName AND RecordType.DeveloperName = :AV_AppConstants.INTERLOC_GROUP_RT) 
            AND RecordType.DeveloperName IN (:AV_AppConstants.TASKINICIATIVA_RT,:AV_AppConstants.TASKALERTACOM_RT, :AV_AppConstants.TASKAVISOS_RT,:AV_AppConstants.TASKEXPCLIENT_RT, :AV_AppConstants.TASKONBOARDING_RT,:AV_AppConstants.TASKPRIORIZADOR_RT) 
            AND (ActivityDate=LAST_N_DAYS:3 OR ActivityDate>=TODAY) 
            AND Status in (:AV_AppConstants.TASK_STATUS_PENDIENTE,:AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL) AND AV_ToDelete__c = false];

        countRecords.put('oppos',Integer.valueOf(oppNumberRecords.get('expr0')));
        countRecords.put('events',Integer.valueOf(evNumberRecords.get('expr0')));
        countRecords.put('tasks',Integer.valueOf(tskNumberRecords.get('expr0')));

        return countRecords;

    }

    /**Decides what private query method execute whether the given object and group name 
     * in order to return a list of the records related to the members of the group
     * @param String grpName
     * @param String currentObject
     * @param String typeOfQueryOppo
     * @return List<Object>
     */

    @AuraEnabled
    public static List<Object> getRecordsCurrentObject(String grpName, String currentObject,String typeOfQueryOppo){
       if(currentObject.equals(AV_AppConstants.OBJECT_NAME_TASK)){
           return getRecordsTsk(grpName);
        }
        
        if(currentObject.equals(AV_AppConstants.OBJECT_NAME_EVENT)){

            return getRecordsEvt(grpName);
        }

        if(currentObject.equals(AV_AppConstants.OBJECT_NAME_OPPORTUNITY)){
            if(typeOfQueryOppo.equals('V')){
                return getRecordOppoVigentes(grpName);
            }else if(typeOfQueryOppo.equals('NV')){
                return getRecordOppoNoVigentes(grpName);

            }
        }
       return null;

    }
    /**
     * Given a group name returns the one group wich AV_IsInterlocutor is setted to true 
     * in order to identify the main Interlocutor for the component
     * @param String grpName
     * @return String
     */
    private static String getGrpInterlocutorId(String grpName){
    String interlocutorId;
    List<AV_GrupoInterlocucion__c> grpList = [SELECT AV_Numper__c, AV_IsInterlocutor__c FROM AV_GrupoInterlocucion__C WHERE Name = :grpName AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];
    for(AV_GrupoInterlocucion__c grp : grpList){
        if(grp.AV_IsInterlocutor__c ){
            interlocutorId = grp.AV_Numper__c;
            break;
        }
    }
    return interlocutorId;
    }   

    /**Given a group name, return a list of custom class (ActivityData) that contains the relevant info from tasks that matches the logic and are owned by the members of the group.
      * The custom objects are used to build the tables that displays the relevant information about the records in the component
     * @param String grpName
     * @return List<Object>
     */


    private static List<Object> getRecordsTsk(String grpName){
        List<ActivityData> recordsToSend = new List<ActivityData>();
        String interlocutorId = getGrpInterlocutorId(grpName);
        Map<String,String> statusMapLabel = getTaskStatusLabel();
        List<Task> tsks =  [SELECT Id,AV_Origen__c,AccountId,Account.Name,Subject,Status,ActivityDate, Owner.Name,OwnerId
        FROM Task
        WHERE AccountId IN (SELECT AV_Numper__c FROM AV_GrupoInterlocucion__c WHERE Name = :grpName AND RecordType.DeveloperName = :AV_AppConstants.INTERLOC_GROUP_RT) 
        AND RecordType.DeveloperName IN (:AV_AppConstants.TASKINICIATIVA_RT,:AV_AppConstants.TASKALERTACOM_RT, :AV_AppConstants.TASKAVISOS_RT,:AV_AppConstants.TASKEXPCLIENT_RT, :AV_AppConstants.TASKONBOARDING_RT,:AV_AppConstants.TASKPRIORIZADOR_RT)  
        AND (ActivityDate=LAST_N_DAYS:3 OR ActivityDate>=TODAY) 
        AND Status in (:AV_AppConstants.TASK_STATUS_PENDIENTE,:AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL) AND AV_ToDelete__c = false ORDER BY ActivityDate ASC];
        
        for(Task tsk : tsks){
            ActivityData input = new ActivityData();
            input.origin = tsk.AV_Origen__c;
            input.account  = tsk.Account.Name;
            input.subject = tsk.Subject;
            input.tskId= '/'+tsk.Id;
            input.status = statusMapLabel.get(tsk.Status);
            input.activityDate = tsk.ActivityDate;
            input.ownerName = tsk.Owner.Name;
            input.ownerUrlName = '/'+tsk.OwnerId;
            input.isInterloc = (tsk.AccountId == interlocutorId);
            
            recordsToSend.add(input);
        }
        return recordsToSend;
    }
     /**Given a group name, return a list of custom class (ActivityData) that contains the relevant info from events that matches the logic and are owned by the members of the group.
      * The custom objects are used to build the tables that displays the relevant information about the records in the component
     * @param String grpName
     * @return List<Object>
     */

    private static List<Object> getRecordsEvt(String grpName){
        
        List<ActivityData> recordsToSend = new List<ActivityData>();
        String interlocutorId = getGrpInterlocutorId(grpName);
        Map<String,String> typeLabels = getEventTypeLabel();
        List<Event> evts = [SELECT Id,AV_Tipo__c,AccountId,Account.Name,Subject,CSBD_Evento_Estado__c,StartDateTime,OwnerId,Owner.Name
            FROM Event 
            WHERE AccountId IN (SELECT AV_Numper__c FROM AV_GrupoInterlocucion__c WHERE Name = :grpName AND RecordType.DeveloperName = :AV_AppConstants.INTERLOC_GROUP_RT)
            AND StartDateTime >= TODAY 
            AND CSBD_Evento_Estado__c =:AV_AppConstants.EVENT_STATUS_PENDIENTE
            AND RecordType.DeveloperName in (:AV_AppConstants.EVENTCLIENTE_RT) AND IsChild = false ORDER BY StartDateTime ASC];
            for(Event evt :evts){
                ActivityData input = new ActivityData();
                input.origin = typeLabels.get(evt.AV_Tipo__c);
                input.account  = evt.Account.Name;
                input.subject = evt.Subject;
                input.tskId= '/'+evt.Id;
                input.status = evt.CSBD_Evento_Estado__c;
                input.startdatetime = evt.StartDateTime;
                input.ownerName = evt.Owner.Name;
                input.ownerUrlName = '/'+evt.OwnerId;
                input.isInterloc = (evt.AccountId == interlocutorId);

                recordsToSend.add(input);
            }

        return recordsToSend;
    }

/**Given a group name, return a list of custom class (OpportunityData) that contains the relevant info from opportunities that matches the logic and are owned by the members of the group.
      * The custom objects are used to build the tables that displays the relevant information about the records in the component
     * @param String grpName
     * @return List<Object>
     */
    private static List<Object> getRecordOppoVigentes(String grpName){
        List<Opportunity> oppos = [SELECT Id,Name,Account.Name,AV_PF__c,
            AV_PF__r.Name,StageName,AV_Tenencia__c,AV_FechaModificacion__c,
            AV_FechaProximoRecordatorio__c,AV_CentroOrigen__c,AV_Gestor__c,AV_Gestor__r.Name,CloseDate
            FROM Opportunity 
            WHERE AccountId IN (SELECT AV_Numper__c FROM AV_GrupoInterlocucion__c WHERE Name = :grpName AND RecordType.DeveloperName = :AV_AppConstants.INTERLOC_GROUP_RT)
            AND StageName in (:AV_AppConstants.OPP_STATUS_POTENCIAL, :AV_AppConstants.OPP_STATUS_ENGESTION, :AV_AppConstants.OPP_STATUS_NOAPTO) 
            AND SystemModstamp = LAST_N_DAYS:730 and AV_ToDelete__c = false
            AND RecordType.DeveloperName IN (:AV_AppConstants.OPPINICIATIVA_RT, :AV_AppConstants.OPPALERTACOM_RT,:AV_AppConstants.OPPPROPUESTA_RT, :AV_AppConstants.OPPSUGERENCIA_RT,:AV_AppConstants.OPPLLAMADA_RT) ORDER BY StageName ASC, CloseDate ASC];

            return fillOppoDataList(oppos,grpName);
    }
    
/**Given a group name, return a list of custom class (OpportunityData) that contains the relevant info from opportunities that matches the logic and are owned by the members of the group.
      * The custom objects are used to build the tables that displays the relevant information about the records in the component
     * @param String grpName
     * @return List<Object>
     */
    private static List<Object> getRecordOppoNoVigentes(String grpName){
        
        List<Opportunity> oppos = [SELECT Id,CloseDate,Name,Account.Name,AV_PF__c,AV_PF__r.Name,StageName,AV_Tenencia__c,AV_FechaModificacion__c,AV_FechaProximoRecordatorio__c,AV_CentroOrigen__c,AV_Gestor__c,AV_Gestor__r.Name
        FROM Opportunity 
        WHERE AccountId IN (SELECT AV_Numper__c FROM AV_GrupoInterlocucion__c WHERE Name = :grpName AND RecordType.DeveloperName = :AV_AppConstants.INTERLOC_GROUP_RT) AND
        ((StageName in (:AV_AppConstants.OPP_STATUS_VENCIDO, :AV_AppConstants.OPP_STATUS_CERRPOST,:AV_AppConstants.OPP_STAGE_NOT_INTERESTED,:AV_AppConstants.OPP_STAGE_SALES) 
        AND AV_ToDelete__c = false) 
        OR (StageName in ('Formalizada','Perdida') and RecordType.DeveloperName like 'CSBD_%')) and SystemModstamp = LAST_N_DAYS:730
        AND RecordType.DeveloperName IN (:AV_AppConstants.OPPINICIATIVA_RT, :AV_AppConstants.OPPALERTACOM_RT,:AV_AppConstants.OPPPROPUESTA_RT, :AV_AppConstants.OPPSUGERENCIA_RT,:AV_AppConstants.OPPLLAMADA_RT) ORDER BY StageName ASC, CloseDate ASC];
        
        return fillOppoDataList(oppos,grpName);
    }

    /**
     * Given a list of opportunities previosly ordered, builds a list of custom class OpportunityData with the relevant information and returns it 
     * @param List<Opportunity> oppos
     * @param String grpName
     * @return List<Object> 
     */
    private static List<Object> fillOppoDataList(List<Opportunity> oppos,String grpName){
        List<OpportunityData> resultToSend = new List<OpportunityData>();
        String interlocutorId = getGrpInterlocutorId(grpName);
        Map<String,String> oppTenenciaPicklist = getTenenciaLabel();


        for(Opportunity opp : oppos){
            OpportunityData input = new OpportunityData();
                input.oppoId = '/'+opp.Id;
                input.name = opp.Name;
                input.account = opp.Account.Name;
                input.product = opp.AV_PF__r.Name;
                input.productId = '/'+opp.AV_PF__c;
                input.stage = opp.StageName;
                input.otraEntidad = oppTenenciaPicklist.get(opp.AV_Tenencia__c);
                input.ultimaModi = opp.AV_FechaModificacion__c;
                input.proximaGest = opp.AV_FechaProximoRecordatorio__c;
                input.fechaCierre= opp.CloseDate;
                input.oficina = opp.AV_CentroOrigen__c;
                input.isInterloc = (opp.AccountId == interlocutorId);
                if(opp.AV_Gestor__c != null){
                    input.gestorId = '/'+opp.AV_Gestor__c;
                    input.gestorName = opp.AV_Gestor__r.Name;
                }
                resultToSend.add(input);

        }

        return resultToSend;
    }

    /**
     * Returns a map that relates the apiName and the label of the values from the picklist field AV_Tipo__c from event.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getEventTypeLabel(){
        List<Schema.PicklistEntry> typePicklist = Event.AV_Tipo__c.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry type : typePicklist){
			result.put(type.getValue(), type.getLabel());
		}

        return result;
    }

     /**
     * Returns a map that relates the apiName and the label of the values from the picklist field Status from Activity.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getTaskStatusLabel(){
        List<Schema.PicklistEntry> statusPicklist = Task.Status.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry status : statusPicklist){
			result.put(status.getValue(), status.getLabel());
		}

        return result;
    }

    /**
     * Returns a map that relates the apiName and the label of the values from the picklist field AV_Tenencia from Opportunity.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getTenenciaLabel(){
        List<Schema.PicklistEntry> oppPicklist = Opportunity.AV_Tenencia__c.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry oppT : oppPicklist){
			result.put(oppT.getValue(), oppT.getLabel());
		}

        return result;
    }
    /**
     * Inner class that contains the information of event and tasks. 
     * The attributes names match the fieldName of the datatable columns that will be displayed in the component
     */
    public class ActivityData{

        
        @AuraEnabled
        public String origin;
        @AuraEnabled
        public String account;
        @AuraEnabled
        public String tskId;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Date activityDate;
        @AuraEnabled 
        public String ownerName;
        @AuraEnabled 
        public String ownerUrlName;
        @AuraEnabled
        public DateTime startdatetime;
        @AuraEnabled 
        public Boolean isInterloc;
        
    }
    /**
     * Inner class that contains the information of opportunities. 
     * The attributes names match the fieldName of the datatable columns that will be displayed in the component
     */

    public class OpportunityData{
        @AuraEnabled 
        public String oppoId;
        @AuraEnabled 
        public String name;
        @AuraEnabled 
        public String account;
        @AuraEnabled 
        public String product;
        @AuraEnabled
        public String productId; 
        @AuraEnabled 
        public String stage;
        @AuraEnabled 
        public String otraEntidad;
        @AuraEnabled 
        public Date ultimaModi;
        @AuraEnabled 
        public Date proximaGest;
        @AuraEnabled 
        public Date fechaCierre;
        @AuraEnabled 
        public String oficina;
        @AuraEnabled
        public String gestorId; 
        @AuraEnabled 
        public String gestorName;
        @AuraEnabled 
        public Boolean isInterloc;
    }

   
}