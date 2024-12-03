/**********************************************************************************************************************
Name:      AV_CallAssignment_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente av_callAssignment 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0                             Ali / Bea        30/07/2024          Init version
***********************************************************************************************************************/
public with sharing class AV_CallAssignment_Controller {

    public static final Map<String,List<Integer>> DURATION_TO_TIME_RANGE = getDurationRanges();

	public static final Map<String,String> DURATION_TO_SUBJECT_MAP = new Map<String,String>{
        'Corta' => 'Llamada',
        'Media' => 'Cita Telefónica',
        'Larga' => 'Cita Telefónica'
    };

	// public static Map<String,String> durationToTypeMap = new Map<String,String>{
    //     'Corta' => 'LMD',
    //     'Media' => 'CTF',
    //     'Larga' => 'CTF'
    // };

    public class CallInfoWrapper{
        @AuraEnabled 
        public string clientName;
        @AuraEnabled 
        public string clientId;
        @AuraEnabled 
        public string typeAppointment;
        @AuraEnabled 
        public string dateCall;
        @AuraEnabled 
        public string initTime;
        @AuraEnabled 
        public string duration;
        @AuraEnabled 
        public string assignedEmployeeId;
        @AuraEnabled 
        public string assignedEmployeeName;
        @AuraEnabled 
        public string origin;
        @AuraEnabled 
        public string phone;
        @AuraEnabled 
        public string subject;
        @AuraEnabled 
        public Datetime startTimeFull;
    }

	@AuraEnabled
	public static String updateCall(String callId, String accountId) {

        List<CC_Llamada__c> callRecord = [SELECT Id, AV_Account__c
                                                FROM  CC_Llamada__c WHERE Id = :callId LIMIT 1];
        
        if(callRecord != null && !callRecord.isEmpty()){
            callRecord[0].AV_Account__c = accountId;
            update callRecord;
            return 'true';
        }else{
            return 'error';
        }
    }    

    @AuraEnabled
	public static CallInfoWrapper getCallInfo(String callId) {

        CallInfoWrapper response = new CallInfoWrapper();
        List<CC_Llamada__c> callRecord = [SELECT Id, AV_Account__c,OwnerId,Owner.Name,AV_Account__r.Name,CC_Fecha_Inicio__c,AV_Duration__c,AV_FirstEmployee__c,AV_FirstEmployee__r.Name,OB_Telefono__c,CC_Tipo__c 
                                            FROM  CC_Llamada__c WHERE Id = :callId];
        
        if(callRecord != null && !callRecord.isEmpty()){

            response.clientName = callRecord[0].AV_Account__r.Name;
            response.clientId = callRecord[0].AV_Account__c;
            response.typeAppointment = getTypeDuration(Integer.valueOf(callRecord[0].AV_Duration__c));
            response.dateCall = callRecord[0].CC_Fecha_Inicio__c.format('dd-MM-YYYY');
            response.initTime = callRecord[0].CC_Fecha_Inicio__c.format('hh:mm');
            response.duration = callRecord[0].AV_Duration__c + ' s';
            response.assignedEmployeeId = callRecord[0].OwnerId;
            response.assignedEmployeeName = callRecord[0].Owner.Name;
            response.origin = callRecord[0].CC_Tipo__c;
            response.phone = callRecord[0].OB_Telefono__c;
            response.subject = DURATION_TO_SUBJECT_MAP.get(response.typeAppointment);
            response.startTimeFull = callRecord[0].CC_Fecha_Inicio__c;
            return response;
        }else{
            return null;
        }
    }

    private static string getTypeDuration(Integer duration){
        String currentType;
        for(String type : DURATION_TO_TIME_RANGE.keySet()){
            List<Integer> rangePair = DURATION_TO_TIME_RANGE.get(type);
            if(duration >= rangePair[0] && duration < rangePair[1] || (type.equals('Larga') && duration > rangePair[0])){
                currentType = type;
                break;
            }
        }
        return currentType;
    }

	private static Map<String,List<Integer>> getDurationRanges(){
		Map<String,List<Integer>> response = new Map<String,List<Integer>>();
		List<AV_CallDurationType__c> durationCs = [SELECT Name,MinDuration__c,MaxDuration__c FROM AV_CallDurationType__c];
		for(AV_CallDurationType__c cs : durationCs){
			response.put(cs.Name,new List<Integer>{Integer.valueOf(cs.MinDuration__c),Integer.valueOf(cs.MaxDuration__c)});
		}
		return response;
	}
    
}