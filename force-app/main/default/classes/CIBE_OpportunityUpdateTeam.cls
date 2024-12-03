/**********************************************************************************************************************
 Name:      CIBE_OpportunityUpdateTeam
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for CIBE_OpportunityUpdateTeam LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY			AUTHOR				DATE            Description
	1.0         US379981			Lucía		    	25/04/2023      Init version
***********************************************************************************************************************/
public without sharing class CIBE_OpportunityUpdateTeam {

@AuraEnabled(cacheable=true)
public static Map<Id, Contact> getAccountTeamMember(String recordId){

    Set<Id> acc = new Set<Id>();
    Set<Id> eapGestor = new Set<Id>();
    if(Opportunity.SObjectType.getDescribe().isAccessible()
    && Schema.SObjectType.Opportunity.fields.Id.isAccessible() 
    && Schema.SObjectType.Opportunity.fields.AccountId.isAccessible()) {

    List<Opportunity> listOpp = [SELECT Id, AccountId, Account.AV_EAPGestor__c  FROM Opportunity WHERE Id =: recordId];
    for (Opportunity opp : listOpp) {
        acc.add(opp.AccountId);
        eapGestor.add(opp.Account.AV_EAPGestor__c);
    }
    }

    List<AccountTeamMember> listAccMembers = new List<AccountTeamMember>();
    if(AccountTeamMember.SObjectType.getDescribe().isAccessible()
        && Schema.SObjectType.AccountTeamMember.fields.Id.isAccessible() 
        && Schema.SObjectType.AccountTeamMember.fields.AccountId.isAccessible()
        && Schema.SObjectType.AccountTeamMember.fields.UserId.isAccessible()
        && Schema.SObjectType.AccountTeamMember.fields.TeamMemberRole.isAccessible()) {
        listAccMembers = [SELECT Id, AccountId, UserId, User.Name, TeamMemberRole, User.IsActive FROM AccountTeamMember WHERE AccountId IN: acc AND User.IsActive =: true];
    }

    Map<Id, Contact> mapContact = new Map<Id, Contact>();
    if(!listAccMembers.isEmpty()){
        List<Id> listUserId=new List<Id>();
        for(AccountTeamMember accMember : listAccMembers){
            listUserId.add(accMember.UserId);
        }
    
        if(!listUserId.isEmpty() && Contact.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.Contact.fields.Id.isAccessible() 
            && Schema.SObjectType.Contact.fields.Name.isAccessible()
            && Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
            && Schema.SObjectType.Contact.fields.CC_Numero_Oficina__c.isAccessible() 
            && Schema.SObjectType.Contact.fields.AV_DescFuncion__c.isAccessible()
            && Schema.SObjectType.Contact.fields.AV_Responsabilidad__c.isAccessible()){
            mapContact = new Map<Id, Contact>([SELECT Id, Name, AV_UsuarioAsociado__c,  CC_Numero_Oficina__c, AV_DescFuncion__c, AV_Responsabilidad__c FROM Contact WHERE AV_UsuarioAsociado__c = :listUserId AND RecordType.DeveloperName = 'CC_Empleado' AND Id != :eapGestor]);

        }
    }

    return mapContact;

}


@AuraEnabled
public static List<OpportunityTeamMember> updateOpportunityTeamMember (String recordId, List<OpportunityTeamMember> lista){

    List<Id> userIdList = new List<Id>();
    if(OpportunityTeamMember.SObjectType.getDescribe().isCreateable()
        && Schema.SObjectType.OpportunityTeamMember.fields.Id.isAccessible()
        && Schema.SObjectType.OpportunityTeamMember.fields.OpportunityId.isAccessible()
        && Schema.SObjectType.OpportunityTeamMember.fields.OpportunityId.isAccessible()
        && Schema.SObjectType.OpportunityTeamMember.fields.UserId.isAccessible()
        && Schema.SObjectType.OpportunityTeamMember.fields.TeamMemberRole.isAccessible()
        && Schema.SObjectType.OpportunityTeamMember.fields.OpportunityAccessLevel.isAccessible()) { 
            for (OpportunityTeamMember opp : lista) {
                userIdList.add(opp.UserId);
            }            

            List<OpportunityTeamMember> userList = [SELECT Id, OpportunityId, UserId  FROM OpportunityTeamMember WHERE OpportunityId =: recordId AND UserId IN : userIdList];
            if(!userList.isEmpty()) {
                throw new IllegalArgumentException('El miembro ya existe en el equipo.');
            }

            if(!lista.isEmpty() && lista != null){
                Database.insert(lista, false);
            }else{
                throw new IllegalArgumentException ('No has elegido usuario');
            }
        }
        return lista;
}

@AuraEnabled(cacheable=true)
    public static List<Wrapper> getOpportunityTeamMembers(String recordId){
        

        String aux = null;
        String auxName = null;

    List<OpportunityTeamMember> oppList = new  List<OpportunityTeamMember>();
        List<Wrapper> listReturn = new List<Wrapper>();
        Map<Id, Contact> mapGrupoComercial = new Map<Id, Contact>();
    if(OpportunityTeamMember.SObjectType.getDescribe().isAccessible() 
        && Schema.SObjectType.OpportunityTeamMember.fields.Id.isAccessible()
        && Schema.SObjectType.OpportunityTeamMember.fields.UserId.isAccessible()
        && Schema.SObjectType.OpportunityTeamMember.fields.CIBE_Funcion__c.isAccessible()
        && Schema.SObjectType.OpportunityTeamMember.fields.CIBE_Centro__c.isAccessible()
        ) {
            oppList = [SELECT Id, UserId, User.Name, CIBE_Funcion__c, CIBE_Centro__c, OpportunityAccessLevel, Opportunity.CloseDate, Opportunity.RecordType.DeveloperName FROM OpportunityTeamMember WHERE OpportunityId  =: recordId];
        }

        List<Contact> contactList = new  List<Contact>();
        if(Contact.SObjectType.getDescribe().isUpdateable() 
        && Schema.SObjectType.Contact.fields.Id.isAccessible()
        && !oppList.isEmpty()) {
            Set<Id> userIds = new Set<Id>();
            for (OpportunityTeamMember oppMember : oppList) {
                userIds.add(oppMember.UserId);
            }
            contactList = [SELECT Id, AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.Name FROM Contact WHERE AV_UsuarioAsociado__c  IN :userIds];
        }

        for(Contact fs :contactList){
            mapGrupoComercial.put(fs.AV_UsuarioAsociado__c, fs);
        }

    
        for(OpportunityTeamMember oTM : oppList){

            if(mapGrupoComercial.containsKey(oTM.UserId) ){
                aux = mapGrupoComercial.get(oTM.UserId).Id;
                auxName = mapGrupoComercial.get(oTM.UserId).AV_UsuarioAsociado__r.Name;
            }

             aux = aux != null ? aux : '';

            listReturn.add(
                new Wrapper(
                    auxName,
                    aux,
                    oTM.CIBE_Funcion__c,
                    oTM.CIBE_Centro__c,
                    oTM.Opportunity.RecordType.DeveloperName,
                    oTM.Opportunity.CloseDate,
                    oTM.Id,
                    oTM.OpportunityAccessLevel
                ));
                aux = null;
                auxName = null;
        }

        return  listReturn;
}

@AuraEnabled(cacheable = true)
    public static Boolean showAddMemberButton(String recordId){
        List<OpportunityTeamMember> teamMembers = new  List<OpportunityTeamMember>();
        Boolean prueba = false;
        List<Opportunity> opp = new List<Opportunity>();
        if(OpportunityTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.OpportunityTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.OpportunityTeamMember.fields.OpportunityId.isAccessible()
            && Schema.SObjectType.OpportunityTeamMember.fields.UserId.isAccessible()) {

            opp = [SELECT id FROM Opportunity WHERE Id =: recordId AND OwnerId =: UserInfo.getUserId()];
            if(!opp.isEmpty()){
                //eres el owner de la oportunidad
                prueba = true;
            }else{
                teamMembers = [SELECT Id, UserId, Opportunity.OwnerId FROM OpportunityTeamMember WHERE OpportunityId = :recordId AND (UserId = :UserInfo.getUserId() OR Opportunity.OwnerId = :UserInfo.getUserId() ) ];
                if(!teamMembers.isEmpty()){
                    //eres participante
                    prueba = true;
                }else{
                    throw new IllegalArgumentException('showAddMemberButton - El usuario no tiene permisos para acceder a los miembros.');
                }
            }
    }
    return prueba;
}


@AuraEnabled
public static void deleteTeamMember(String memberId) {
    if(OpportunityTeamMember.SObjectType.getDescribe().isDeletable() 
        && Schema.SObjectType.OpportunityTeamMember.fields.Id.isAccessible()) {
        delete new OpportunityTeamMember(
            Id = memberId
        );
    } else {           
        throw new IllegalArgumentException('deleteTeamMember - El usuario no tiene permisos para eliminar el miembro.');
    }
}    

@AuraEnabled
    public static void updateTeamMember(String memberId, String acces) {
        List<OpportunityTeamMember> updateAcces = new  List<OpportunityTeamMember>();
        if(OpportunityTeamMember.SObjectType.getDescribe().isAccessible() 
            && Schema.SObjectType.OpportunityTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.OpportunityTeamMember.fields.OpportunityId.isAccessible()
            && Schema.SObjectType.OpportunityTeamMember.fields.UserId.isAccessible()
            && Schema.SObjectType.OpportunityTeamMember.fields.OpportunityAccessLevel.isAccessible()
            ) {
                updateAcces = [SELECT Id, OpportunityAccessLevel  FROM OpportunityTeamMember WHERE OpportunityId = :memberId AND OpportunityAccessLevel =: acces];
        }

        if(OpportunityTeamMember.SObjectType.getDescribe().isUpdateable() 
            && Schema.SObjectType.OpportunityTeamMember.fields.Id.isAccessible()
            && Schema.SObjectType.OpportunityTeamMember.fields.OpportunityAccessLevel.isAccessible()) {
            update new OpportunityTeamMember(
                Id = memberId,
                OpportunityAccessLevel = acces
            );

            if(OpportunityTeamMember.SObjectType.getDescribe().isUpdateable() 
                && Schema.SObjectType.OpportunityTeamMember.fields.Id.isAccessible()
                && Schema.SObjectType.OpportunityTeamMember.fields.OpportunityAccessLevel.isAccessible()
                && !updateAcces.isEmpty()) {
                    for(OpportunityTeamMember aTM : updateAcces) {
                        aTM.OpportunityAccessLevel = acces;
                    }
                    update updateAcces;
            }
        } else {
            throw new IllegalArgumentException('updateTeamMember - El usuario no tiene permisos para actualizar el miembro.');
        }
    }

    
    @AuraEnabled(cacheable = true)
    public static Boolean validationCloseDate(String recordId){
        Boolean isCloseDate = true;
        List<Opportunity> oppList = new List<Opportunity>();
        List<String> oppRTList = new List<String>{  CIBE_AppConstants.OPP_ACCIONCIB_RT,
            CIBE_AppConstants.OPP_ALERTACIB_RT,
            CIBE_AppConstants.OPP_ALERTAEMP_RT,
            CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
            CIBE_AppConstants.OPP_INICIATIVACIB_RT,
            CIBE_AppConstants.OPP_ACCIONEMP_RT
            };
                List<String> oppRTSug = new List<String>{   CIBE_AppConstants.OPP_SUGERENCIACIB_RT,
                    CIBE_AppConstants.OPP_SUGERENCIAEMP_RT
                    };
                        if(Opportunity.SObjectType.getDescribe().isAccessible()) {
                            
                            oppList = [SELECT Id, CloseDate, RecordType.DeveloperName FROM Opportunity WHERE Id =: recordId];
                            
                            Date today = System.today();
                            Date fechaLimite = today.addDays(547);
                            if(!oppList.isEmpty()){
                                
                                for(Opportunity opp : oppList){
                                    if((oppRTList.contains(opp.RecordType.DeveloperName) && (opp.CloseDate >= today && opp.CloseDate <= fechaLimite) ) || 
                                       oppRTSug.contains(opp.RecordType.DeveloperName)){
                                           isCloseDate = false;
                                       }
                                }
                            }
                        }
        return isCloseDate;
    }
    
    
    public class Wrapper{


        @AuraEnabled 
        public String contactoName {get;set;}

        @AuraEnabled 
        public String contactoId {get;set;}
        
        @AuraEnabled 
        public String funcion {get;set;}

        @AuraEnabled 
        public String centro {get;set;}

        @AuraEnabled 
        public String recordType {get;set;}

        @AuraEnabled 
        public Date closeDate {get;set;}

        @AuraEnabled 
        public String Id {get;set;}

        @AuraEnabled 
        public String OpportunityAccessLevel {get;set;}

        
        public Wrapper(String contactoName, String contactoId, String funcion, String centro, String recordType, Date closeDate, String Id, String OpportunityAccessLevel) {
            this.contactoName = contactoName;
            this.contactoId = contactoId != '' ? '/' + contactoId : '';
            this.funcion = funcion;
            this.centro = centro;
            this.recordType = recordType;
            this.closeDate = closeDate;
            this.Id = Id;
            this.OpportunityAccessLevel = OpportunityAccessLevel;

        }

}
}