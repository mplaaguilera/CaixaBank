public with sharing class CIBE_AttendeesTask_Controller {
    
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(cacheable=true)
    public static List<Attendee> getAttendees(String recordId) {
        List<TaskRelation> taskRelations = new List<TaskRelation>();
        if(TaskRelation.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.TaskRelation.fields.Id.isAccessible() 
            && Schema.SObjectType.TaskRelation.fields.RelationId.isAccessible()) {
            taskRelations = [SELECT Id, RelationId FROM TaskRelation WHERE TaskId = :recordId AND IsWhat = false];
        }

        List<Attendee> result = new List<Attendee>();
        if(!taskRelations.isEmpty()) {
            Set<Id> relationIds = new Set<Id>();
            for(TaskRelation tr : taskRelations) {
                relationIds.add(tr.RelationId);
            }

            Map<Id, Contact> contacts = new Map<Id, Contact>();
            if(Contact.SObjectType.getDescribe().isAccessible()
                && Schema.SObjectType.Contact.fields.Id.isAccessible() 
                && Schema.SObjectType.Contact.fields.Name.isAccessible()) {
                contacts = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :relationIds AND RecordType.DeveloperName = 'CC_Empleado']);
            }

            if(!contacts.isEmpty()){
                for(TaskRelation tr : taskRelations) {
                    if(contacts.containsKey(tr.RelationId)) {
                        Attendee a = new Attendee();
                        a.id = tr.Id;
                        a.name = contacts.get(tr.RelationId).Name;
                        a.url = contacts.get(tr.RelationId).Id;
                        result.add(a);
                    }
                }
            }
        }
        return result;
    }

    @AuraEnabled
    public static void createAttendees(String recordId, String relationId){
        Map<Id, TaskRelation> relations = new Map<Id, TaskRelation>();
        if(TaskRelation.SObjectType.getDescribe().isAccessible()
            && Schema.SObjectType.TaskRelation.fields.Id.isAccessible() 
            && Schema.SObjectType.TaskRelation.fields.TaskId.isAccessible()
            && Schema.SObjectType.TaskRelation.fields.RelationId.isAccessible()) {
            relations = new Map<Id, TaskRelation>([SELECT Id FROM TaskRelation WHERE TaskId = :recordId AND RelationId = :relationId]);
        }

        if(!relations.isEmpty()) {
            throw new IllegalArgumentException('El participante ya existe en esta tarea.');
        }

        if(TaskRelation.SObjectType.getDescribe().isCreateable()
            && Schema.SObjectType.TaskRelation.fields.TaskId.isAccessible()
            && Schema.SObjectType.TaskRelation.fields.IsWhat.isAccessible()
            && Schema.SObjectType.TaskRelation.fields.RelationId.isAccessible()) {
            insert new TaskRelation(
                TaskId = recordId,
                RelationId = relationId,
                IsWhat = false
            );
        } else {           
            throw new IllegalArgumentException('createParticipante - El usuario no tiene permisos para crear el participante de la tarea.');
        }
    }

    @AuraEnabled
    public static void deleteAttendees(String recordId){
        if(TaskRelation.SObjectType.getDescribe().isDeletable() 
            && Schema.SObjectType.TaskRelation.fields.Id.isAccessible()) {
            delete new TaskRelation(
                Id = recordId
            );
        } else {           
            throw new IllegalArgumentException('deleteParticipante - El usuario no tiene permisos para eliminar el participante de la tarea.');
        }
    }

    @AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchUser(String searchTerm, List<String> selectedIds) {
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Contact(Id, Name, CC_Matricula__c WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName = 'CC_Empleado')
				LIMIT :MAX_RESULTS
			];
		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
                    Contact(Id, Name, CC_Matricula__c WHERE RecordType.DeveloperName = 'CC_Empleado')
				LIMIT :MAX_RESULTS
			];
		}

		String contactIcon = 'standard:contact';
		Contact[] listContacts = (List<Contact>) searchResults[0];
		for (Contact c : listContacts) {
			results.add(
				new AV_LookupSearchResult(
					c.Id,
					'Contact',
					contactIcon,
					c.Name,
					'Matrícula • ' + c.CC_Matricula__c
				)
			);
		}
		results.sort();
		return results;
	}

    public class Attendee {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String url;
    }

}