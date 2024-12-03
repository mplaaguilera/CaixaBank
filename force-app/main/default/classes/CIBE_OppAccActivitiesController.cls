/**********************************************************************************************************************
 Name:      CIBE_OppAccActivitiesController
 Copyright © 2023  CaixaBank
=======================================================================================================================
Proposito: Clase controladora del lwc de cibe_OppAccActivities
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
   1.0            US470406     Alexandre Pérez      22/02/2023          Init version

***********************************************************************************************************************/


public with sharing class CIBE_OppAccActivitiesController {
    
    public class ActivitiesWrapper{
        @AuraEnabled
        public list<task> taskList{get;set;}
        @AuraEnabled
        public List<event> eventList{get;set;}
        @AuraEnabled
        public List<ActivitiesLabelWrapper> taskLabels{get;set;}
        @AuraEnabled
        public List<ActivitiesLabelWrapper> eventLabels{get;set;}

    }

    public class ActivitiesLabelWrapper{
        @AuraEnabled
        public string name{get;set;}
        @AuraEnabled
        public string value{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static ActivitiesWrapper getActivities(Id oppId){
        final string PENDIENTE = 'Pendiente';
        //cabeceras de task
        list<Id> cabTask = new list<Id>();
        list<Id> taskIdList = new list<Id>();
        ActivitiesWrapper actiWrapper = new ActivitiesWrapper();
       
        try {
            for(AV_CustomActivityOpportunity__c customActi : [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = : oppId]) {
                if(customActi.AV_Task__c != null) {
                    cabTask.add(customActi.AV_Task__c);
                }
            }

            list<task> tasklist = [SELECT Id, subject, tolabel(status), ActivityDate, Owner.Name FROM Task WHERE isClosed = false AND (WhatId = : oppId OR AV_Task__c IN : cabTask) ORDER BY ActivityDate ASC];
            tasklist.addAll([SELECT Id, subject, tolabel(status), ActivityDate, Owner.Name FROM Task WHERE isClosed = true AND (WhatId = : oppId OR AV_Task__c IN : cabTask) ORDER BY ActivityDate DESC]);

            list<event> eventlist = [SELECT Id, CSBD_Evento_Estado__c, tolabel(CSBD_Evento_Estado__c) status, subject, ActivityDate, Owner.Name FROM Event WHERE (WhatId = : oppId OR AV_Task__c IN : cabTask) AND IsChild = false];

            //Algoritmo de ordenación debido a que no hay diferenciación en el evento que nos diga que es un evento cerrado o abierto
            //y no es posible crear un campo calculado en activity ya que se ha alcanzado el límite de campos
            for(integer intj=0; intj < eventlist.size(); intj++) {
                for(integer inti=0; inti < eventlist.size()-1; inti++){
                    event middEvent;
                    if(eventlist[inti].CSBD_Evento_Estado__c != PENDIENTE && eventlist[inti+1].CSBD_Evento_Estado__c == PENDIENTE){
                        middEvent = eventlist[inti];
                    } else if (((eventlist[inti].CSBD_Evento_Estado__c == PENDIENTE && eventlist[inti+1].CSBD_Evento_Estado__c == PENDIENTE) &&
                    (eventlist[inti].ActivityDate > eventlist[inti+1].ActivityDate)) || ((eventlist[inti].CSBD_Evento_Estado__c != PENDIENTE && eventlist[inti+1].CSBD_Evento_Estado__c != PENDIENTE) &&
                    (eventlist[inti].ActivityDate < eventlist[inti+1].ActivityDate))){
                        system.debug(eventlist[inti].CSBD_Evento_Estado__c);
                        system.debug(eventlist[inti].ActivityDate + '<' + eventlist[inti+1].ActivityDate);
                        middEvent = eventlist[inti];
                    }

                    if(middEvent != null) {
                        eventlist[inti] = eventlist[inti+1];
                        eventlist[inti+1] = middEvent;
                    }
                }
            }
            actiWrapper.taskList = tasklist;
            actiWrapper.eventlist = eventlist;
            actiWrapper.taskLabels = getLabels(new list<string>{'subject','status','ActivityDate'}, new list<string>{'Owner'}, 'task');
            actiWrapper.eventLabels = getLabels(new list<string>{'subject','CSBD_Evento_Estado__c','ActivityDate'}, new list<string>{'Owner'}, 'event');
            return actiWrapper;
        } catch (Exception e) {
            CBK_Log.error(e);
            throw new AuraHandledException(e.getMessage()); 
        }
    }

    /*****************************************************************   
    * Purpose: Obtener los labels de los campos a mostrar en el lwc                                                        
    Parameters: [list<string> fields, -->developer name de los campos
                list<string> relations, --> hay algunos campos standard que el 
                label es diferente el que se obtiene por el getLabel al que se
                muestra en los layout. Se necesita hacer una query al fieldDefinition
                con el nombre de la relación para obtener el label a mostrar 
                string objectname
                string objectname --> Nombre del objeto]   
    Returns: [ActivitiesLabelWrapper]   
    Throws [Exceptions]: --                                                         
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                 DATE           Description      
    1.0            US470406        Alexandre Pérez         27/2/2023      creación
    *****************************************************************/
    public static list<ActivitiesLabelWrapper> getLabels(list<string> fields, list<string> relations, string objectname){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectname);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        list<ActivitiesLabelWrapper> labelWrapperList = new list<ActivitiesLabelWrapper>();
        ActivitiesLabelWrapper labelWrapper;
        //el orden de la lista será el mismo que se pone en la lista de la entrada
        for(string field : fields) {
            labelWrapper = new ActivitiesLabelWrapper();
            labelWrapper.name = field;
            labelWrapper.value = fieldMap.get(field).getDescribe().getLabel();
            labelWrapperList.add(labelWrapper);
        }

        if(relations != null) {
            for(FieldDefinition rel : [SELECT DeveloperName, Label FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = : objectname AND DeveloperName IN : relations]){
                labelWrapper = new ActivitiesLabelWrapper();
                labelWrapper.name = rel.DeveloperName;
                labelWrapper.value = rel.Label;
                labelWrapperList.add(labelWrapper);
            }
        }
        return labelWrapperList;
    }
}