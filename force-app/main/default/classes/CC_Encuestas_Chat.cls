public class CC_Encuestas_Chat {
    
    public static void generarEncuesta(List<Case> casosList) {
        List<Case> casosValidos = new List<Case>();
        
        // Obtener los casos relacionados con el chat para saber el canal de procedencia        
        Map <Id, Id> mapChatsCaso = new Map<Id, Id>();
        Map <Id, String> mapCasoProcedencia = new Map<Id, String>();
        Set<Id> idCasos = new Set<Id>();
        
        for (Case caso : casosList) {
            //mapChatsCaso.put(chat.Id, chat.CaseId);
            idCasos.add(caso.Id);
        }
        
        // Obtener procedencias de los casos (controlar que el caso no tenga ya una encuesta generada)
        
        List<Case> casos = [SELECT CaseNumber, CC_Canal_Procedencia__c, ContactId, CC_URL_Encuesta_3N__c, RecordType.DeveloperName FROM Case WHERE Id IN :idCasos AND CC_URL_Encuesta_3N__c = NULL AND CC_Tipo_ChatTranscript__c = 'Agente'];    
        
        if (!casos.isEmpty()) {
            // Recuperamos las procedencia disponibles 
            List<CC_Lista_Valores__c> listaCanalProcedencia = [SELECT CC_Valor__c, CC_Valor2__c, CC_Activa__c, CC_Lista__r.CC_Activa__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.CC_Activa__c = true and CC_Lista__r.Name in('CC_Encuestas_Satisfaccion_Chat_Empleados','CC_Encuestas_Satisfaccion_Chat_Clientes')];
            
            if(!listaCanalProcedencia.isEmpty()){
                Set<String> valoresProcedencia = new Set<String>();
                Set<String> valoresProcedenciaClientes = new Set<String>();
                for (CC_Lista_Valores__c procedencia : listaCanalProcedencia) {
                    if(procedencia.CC_Activa__c && procedencia.CC_Valor2__c == 'Empleado'){
                        valoresProcedencia.add(procedencia.CC_Valor__c);
                    }else if(procedencia.CC_Activa__c && procedencia.CC_Valor2__c == 'Cliente'){
                        valoresProcedenciaClientes.add(procedencia.CC_Valor__c);
                    }
                }
                
                for (Case caso : casos) {
                    if (((valoresProcedencia?.contains(caso?.CC_Canal_Procedencia__c)) && (caso.RecordType.DeveloperName == 'CC_Empleado')) || ((valoresProcedenciaClientes?.contains(caso?.CC_Canal_Procedencia__c)) && (caso.RecordType.DeveloperName == 'CC_Cliente'))){        
                        casosValidos.add(caso);
                    }        
                }
                
                if (!casosValidos.isEmpty()) {
                    Id idComunidad = [SELECT Id FROM Network WHERE Name = 'Encuestas Contact Center' LIMIT 1].Id;
                    Id idSurvey = [SELECT Id, Name FROM Survey WHERE Name = 'Encuesta satisfacción chat empleados' LIMIT 1].Id;
                    Id idSurveyClientes = [SELECT Id, Name FROM Survey WHERE Name = 'Encuesta satisfacción chat clientes' LIMIT 1].Id;
                    
                    //Crear SurveyInvitation
                    List<SurveyInvitation> surveysInvitation = new List<SurveyInvitation>();
                    
                    for(Case caso : casosValidos){
                        
                        if (caso.RecordType.DeveloperName == 'CC_Empleado') {                        
                            
                            SurveyInvitation surveyInvitation = new SurveyInvitation();
                            surveyInvitation.CommunityId = idComunidad;
                            surveyInvitation.SurveyId = idSurvey;
                            surveyInvitation.Name = 'Encuesta para el caso ' + caso?.CaseNumber;
                            surveyInvitation.OptionsAllowGuestUserResponse = true;
                            surveyInvitation.ParticipantId = caso?.ContactId;
                            surveysInvitation.add(surveyInvitation);                        
                            
                        }else if (caso.RecordType.DeveloperName == 'CC_Cliente'){
                            SurveyInvitation surveyInvitation = new SurveyInvitation();
                            surveyInvitation.CommunityId = idComunidad;
                            surveyInvitation.SurveyId = idSurveyClientes;
                            surveyInvitation.Name = 'Encuesta para el caso ' + caso?.CaseNumber;
                            surveyInvitation.OptionsAllowGuestUserResponse = true;
                            surveyInvitation.ParticipantId = caso?.ContactId;
                            surveysInvitation.add(surveyInvitation);
                            
                        }
                    }
                    //Comprobamos que la lista tiene resgistros
                    if (!surveysInvitation.isEmpty()) {
                        
                        insert surveysInvitation; 
                        
                        
                        //Obtener lista de invitaciones con el link de la invitación generada
                        Set<Id> setIdInvitaciones = new Set<Id>();
                        for(SurveyInvitation invitacion : surveysInvitation){
                            setIdInvitaciones.add(invitacion.Id);
                        }
                        surveysInvitation = [SELECT ParticipantId, InvitationLink FROM SurveyInvitation WHERE Id IN :setIdInvitaciones];
                        Map<Id, String> mapInvitationLink = new Map<Id, String> ();
                        
                        //Crear SurveySubject
                        List<SurveySubject> surveysSubject = new List<SurveySubject>();
                        for(Integer i = 0; i< casosValidos.size(); i++){
                            SurveySubject surveySubject = new SurveySubject();
                            surveySubject.SubjectId = casosValidos[i].Id;         
                            surveySubject.ParentId = surveysInvitation[i].Id;
                            surveySubject.Name = 'Encuesta para el caso ' + casosValidos[i].CaseNumber;
                            surveysSubject.add(surveySubject);
                            mapInvitationLink.put(casosValidos[i].Id, surveysInvitation[i].InvitationLink);    
                        }
                        insert surveysSubject;
                        
                        //Actualizar URL de la encuesta en el chat
                        for(Case caso : casosValidos){
                            caso.CC_URL_Encuesta_3N__c = mapInvitationLink.get(caso.Id);   
                            
                        }
                        //Comprobamos que la lista tiene resgistros
                        if (!casosValidos.isEmpty()){
                            update casosValidos;
                        }
                        
                    }
                }
            }
        }
        
    }
}