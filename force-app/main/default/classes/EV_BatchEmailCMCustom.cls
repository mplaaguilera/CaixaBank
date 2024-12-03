/*****************************************************************************************
 * Name: EV_BatchEmailCMCustom
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Lanzar un batch 24h antes del evento que mande un recordatorio vía email.
 * 
 * -------
 * VERSION        USER_STORY         AUTHOR                                 DATE         Description
 * 1.0            US635293           Carolina Lopez / Humberto Vilchez      23/06/2023   Init Version
 * 1.1            US661500           Carolina Lopez                         25/07/2023   Include new field EV_TechSummit__c and remove RT TechSummit
 * 1.2			  US680535			 Daniel Rodriguez						31/7/2023	 Remove html code and change principal query
 * 1.3            US680535           Mamen Arias                            10/08/2023   Change the reminder from 2 days to 1
 * 1.4		      US680535           Daniel Rodriguez                       18/08/2023   Manage error in send email
 * 1.5            TechSummit         Carolina Lopez                         05/06/2024   modify the logic of email sending.
 * 1.6            TechSummit         Carolina Lopez                         11/06/2024   modify the sending with SingleEmailMessage.
 * 1.7            TechSummit         Carolina Lopez                         06/08/2024   Add translation parameter.
 * 1.8            TechSummit         Carolina Lopez                         04/09/2024   Modify the query to limit the states.
 * 1.9            TechSummit         Carolina Lopez                         06/09/2024   Modify query order by EV_DiaHoraInicio _c and control the loop to include the campaign member name correctly.
******************************************************************************************/
public without sharing class EV_BatchEmailCMCustom implements Database.Batchable<sObject>, Schedulable{
    private static final String LANG_CODE_CA  = '001';
	private static final String LANG_CODE_ES  = '002';
    
    public Database.QueryLocator start(Database.BatchableContext dbc) {
        Date currentDate   = System.today();
        Date afterOneDayDate = currentDate.addDays(1);

        return Database.getQueryLocator([SELECT id, EV_Idioma__c, EV_CampaignId__r.EV_DiaHoraInicio__c, EV_CampaignId__r.EV_ExternalID__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_CampaignId__r.RecordType.DeveloperName, EV_CampaignId__r.Name,EV_LeadId__c, EV_Status__c, EV_CodigoQR__c,EV_FirstName__c,EV_LastName__c, EV_CampaignId__r.StartDate, EV_CampaignId__r.EV_HoraInicio__c, EV_CampaignId__r.EV_HoraFin__c, EV_CampaignId__r.EV_Description__c,EV_CampaignId__r.EV_Duracion__c, EV_CampaignId__r.EV_LugarDeCelebracion__c, EV_CampaignId__r.EV_City__c, EV_CampaignId__r.EV_Street__c, EV_CampaignId__r.EV_CP__c, EV_LeadId__r.Email, RecordTypeId, EV_CampaignId__r.EV_URLDelEventoVirtual__c, EV_CampaignId__c, EV_CampaignId__r.EV_TechSummit__c 
                                FROM EV_CampaignMemberC__c 
                                WHERE EV_CampaignId__r.StartDate = : afterOneDayDate AND EV_CampaignId__r.EV_TechSummit__c = true AND EV_CampaignId__r.EV_NewArchitecture__c = true AND EV_Status__c = 'Registro confirmado' AND (EV_CampaignId__r.RecordType.DeveloperName =: Label.EV_CampTechSummitFisico OR EV_CampaignId__r.RecordType.DeveloperName =: Label.EV_CampTechSummitVirtual OR EV_CampaignId__r.RecordType.DeveloperName =: Label.EV_CampTechSummitHibrido) ORDER BY EV_CampaignId__r.EV_DiaHoraInicio__c asc]);
    }

    public void execute(Database.BatchableContext dbc, List<EV_CampaignMemberC__c> lstCampaignsMC){
        EV_LogDebug.printLogDebug('EV_BatchEmailCMCustom ::lstCampaignsMC::',String.valueof(lstCampaignsMC));
		Map<String, EmailTemplate> emailTemplatesMap = new Map<String, EmailTemplate>();
        List<EV_CampaignMemberC__c> campaignMemUpdList = new List<EV_CampaignMemberC__c>();
        Set<Id> campaignIds = new Set<Id>();
        Map<Id,Map<String,EV_TraduccionDeEvento__c>> eventoTraduccionesMap = new Map<Id,Map<String,EV_TraduccionDeEvento__c>>();
        Map<String, String> msjsError = new Map<String, String>();
        if(!lstCampaignsMC.isEmpty()){
            List<OrgWideEmailAddress> orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress where Address = 'invitation@event.caixabank.com' LIMIT 1];
            List<EmailTemplate> emailTemplateOficina = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body, Name FROM EmailTemplate WHERE Name in ('EmailTemplateTechSummitES','EmailTemplateTechSummitCA') limit 2];
            for (EmailTemplate template : emailTemplateOficina) {
                emailTemplatesMap.put(template.Name, template);
            }
            Map<String, List<EV_CampaignMemberC__c>> emailToCampaignMembersMap = new Map<String, List<EV_CampaignMemberC__c>>();
            for (EV_CampaignMemberC__c cm : lstCampaignsMC) {
                if (!emailToCampaignMembersMap.containsKey(cm.EV_LeadId__r.Email)) {
                    emailToCampaignMembersMap.put(cm.EV_LeadId__r.Email, new List<EV_CampaignMemberC__c>());
                }
                emailToCampaignMembersMap.get(cm.EV_LeadId__r.Email).add(cm);
                campaignIds.add(cm.EV_CampaignId__c);
            }

            Map<Integer, String> monthNamesSpanish = new Map<Integer, String>{
            1 => 'Enero', 2 => 'Febrero', 3 => 'Marzo', 4 => 'Abril', 
            5 => 'Mayo', 6 => 'Junio', 7 => 'Julio', 8 => 'Agosto', 
            9 => 'Septiembre', 10 => 'Octubre', 11 => 'Noviembre', 12 => 'Diciembre'
            };
            Map<Integer, String> monthNamesCatalan = new Map<Integer, String>{
            1 => 'Gener', 2 => 'Febrer', 3 => 'Març', 4 => 'Abril', 
            5 => 'Maig', 6 => 'Juny', 7 => 'Juliol', 8 => 'Agost', 
            9 => 'Setembre', 10 => 'Octubre', 11 => 'Novembre', 12 => 'Desembre'
            };

            eventoTraduccionesMap = EV_Utilities.getEventoTraducciones(campaignIds);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{};
            for (String email : emailToCampaignMembersMap.keySet()) {
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                String html;
                String asunto;
                String eventoName;
                String eventoDescripcion;
                String emailTemplateId;
                String finalHtml = '';
                Integer startIdx;
                Integer endIdx;
                for (EV_CampaignMemberC__c cmc : emailToCampaignMembersMap.get(email)) {
                    cmc.EV_Status__c = 'QR enviado';
                    campaignMemUpdList.add(cmc);
                    if(cmc.EV_Idioma__c == 'Castellano'){
                            html = emailTemplatesMap.get('EmailTemplateTechSummitES').HtmlValue;
                            html = html.replace('Hola', 'Hola ' + Label.EV_RecordatorioTemplateES);
                            asunto =  Label.EV_SubjectTechES;
                            emailTemplateId = emailTemplatesMap.get('EmailTemplateTechSummitES').Id; 
                            eventoName = eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_ES) == null ? cmc.EV_CampaignId__r.Name : eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_ES).Name;
							eventoDescripcion = eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_ES) == null ? cmc.EV_CampaignId__r.EV_Description__c : eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_ES).EV_Descripcion__c;
                    }else{
                        html = emailTemplatesMap.get('EmailTemplateTechSummitCA').HtmlValue;
                        html = html.replace('Hola', 'Hola ' + Label.EV_RecordatorioTemplateCA);
                        asunto = Label.EV_SubjectTechCA;
                        emailTemplateId = emailTemplatesMap.get('EmailTemplateTechSummitCA').Id;
                        eventoName = eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_CA) == null ? cmc.EV_CampaignId__r.Name : eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_CA).Name;
                        eventoDescripcion = eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_CA) == null ? cmc.EV_CampaignId__r.EV_Description__c : eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_CA).EV_Descripcion__c;
                    }
                    Datetime fecha = datetime.newInstance(cmc.EV_CampaignId__r.StartDate.year(), cmc.EV_CampaignId__r.StartDate.month(), cmc.EV_CampaignId__r.StartDate.day());
                    String hora = String.valueof(cmc.EV_CampaignId__r.EV_HoraInicio__c);
                    String sectionToDuplicate = '';
                    startIdx = html.indexOf('[[BEGINMEMBER]]');
                    endIdx = html.indexOf('[[ENDMEMBER]]');
                    if (startIdx != -1 && endIdx != -1) {
                        sectionToDuplicate = html.substring(startIdx + 19, endIdx);
                    }
                    String memberHtml = sectionToDuplicate;
                    memberHtml = memberHtml.replace('[DATESTART]', String.valueOf(cmc.EV_CampaignId__r.StartDate.day()));
					memberHtml = memberHtml.replace('[MONTHSTART]', (cmc.EV_Idioma__c == 'Castellano' ? String.valueOf(monthNamesSpanish.get(fecha.month())) : String.valueOf(monthNamesCatalan.get(fecha.month()))));
                    memberHtml = memberHtml.replace('[ExternalIdEvento]', String.valueOf(cmc.EV_CampaignId__r.EV_ExternalID__c));
                    memberHtml = memberHtml.replace('[ExternalidInvitacion]', String.valueOf(cmc.EV_ExternalID__c));
                    memberHtml = memberHtml.replace('{{{Campaign.EV_HoraInicio__c}}}', hora.substring(0, 5));
                    memberHtml = memberHtml.replace('{{{CampTranslation.Name}}}', eventoName);
                    String auxLocation = '';
                    if(cmc.EV_FormatoDeAsistencias__c == '001'){
                        memberHtml = memberHtml.replace('{{{Campaign.EV_LugarDeCelebracion__c}}}', !String.isEmpty(cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c) ? cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c : '');
                        memberHtml = memberHtml.replace('{{{Campaign.EV_Street__c}}}', !String.isEmpty(cmc.EV_CampaignId__r.EV_Street__c) ? cmc.EV_CampaignId__r.EV_Street__c : '');
                        memberHtml = memberHtml.replace('{{{Campaign.EV_CP__c}}}', !String.isEmpty(cmc.EV_CampaignId__r.EV_CP__c) ? (cmc.EV_CampaignId__r.EV_CP__c + ', ') : '');
                        memberHtml = memberHtml.replace('{{{Campaign.EV_City__c}}}', !String.isEmpty(cmc.EV_CampaignId__r.EV_City__c) ? cmc.EV_CampaignId__r.EV_City__c : '');
                        auxLocation = (!String.isEmpty(cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c) ? cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c : '') + ' ' + (!String.isEmpty(cmc.EV_CampaignId__r.EV_Street__c) ? cmc.EV_CampaignId__r.EV_Street__c : '') + ' ' +  (!String.isEmpty(cmc.EV_CampaignId__r.EV_CP__c) ? (cmc.EV_CampaignId__r.EV_CP__c + ' ') : '') + (!String.isEmpty(cmc.EV_CampaignId__r.EV_City__c) ? cmc.EV_CampaignId__r.EV_City__c : '');
                    }else{
                        memberHtml = memberHtml.replace('{{{Campaign.EV_LugarDeCelebracion__c}}}', 'Online');
                        memberHtml = memberHtml.replace('{{{Campaign.EV_Street__c}}}', '');
                        memberHtml = memberHtml.replace('{{{Campaign.EV_CP__c}}}', '');
                        memberHtml = memberHtml.replace('{{{Campaign.EV_City__c}}}', '');
                        auxLocation = 'Online';
                    }
                    finalHtml += memberHtml;

                    Blob icsFile = Blob.valueOf(generateICSFile(cmc.EV_FormatoDeAsistencias__c, cmc.EV_CampaignId__r.StartDate, cmc.EV_CampaignId__r.EV_HoraInicio__c,cmc.EV_CampaignId__r.EV_HoraFin__c, eventoDescripcion, eventoName, auxLocation, cmc.EV_CampaignId__r.EV_URLDelEventoVirtual__c));
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(cmc.EV_CampaignId__r.Name + '.ics');
                    attachment.setContentType('text/calendar');
                    attachment.setInline(false);
                    attachment.setBody(icsFile); 
                    attachments.add(attachment);

                    if (startIdx != -1 && endIdx != -1) {
                        String before = html.substring(0, startIdx + 19);
                        String after = html.substring(endIdx);
                        html = before + finalHtml + after;
                    }

                    html = html.replace('[[BEGINMEMBER]]', '');
                    html = html.replace('[[ENDMEMBER]]', '');
                    html = html.replace('[[FirstName]]', (cmc.EV_FirstName__c != null ? cmc.EV_FirstName__c : cmc.EV_LastName__c));

                }


                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(new String[]{email});
                message.setTemplateId(emailTemplateId);
                message.setSubject(asunto);
                message.setHtmlBody(html);
                message.optOutPolicy = 'FILTER'; 
                message.setSaveAsActivity(true); 
                message.setUseSignature(true);
                message.setOrgWideEmailAddressId(orgwideaddress.get(0).Id);
                message.setFileAttachments(attachments);
                messages.add(message);
            }
            
            EV_LogDebug.printLogDebug('messages ',String.valueof(messages));
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            for (Messaging.SendEmailResult result : results) {
				if (result.isSuccess()) {
						EV_LogDebug.printLogDebug('result.isSuccess()',String.valueof(result));
				} else {
					String errorMessage = 'Error al enviar el correo electrónico: ';
					if (result.getErrors() != null && !result.getErrors().isEmpty()) {
							for (Messaging.SendEmailError error : result.getErrors()) {
									errorMessage += error.getMessage() + '\n';
									msjsError.put(error.getMessage(), String.valueof(error));
							}
					}
					CBK_Log.error(msjsError);
				}
			}
            EV_LogDebug.printLogDebug('results SendEmailResult:',String.valueof(results));
            EV_LogDebug.printLogDebug('campaignMemUpdList:',String.valueof(campaignMemUpdList));
            if(!results.isEmpty()){
                if(results[0].success && !campaignMemUpdList.isEmpty()){
                    update campaignMemUpdList;
                }
            }
        }  
    }
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EV_BatchEmailCMCustom());
    }
    public void finish(Database.BatchableContext dbc){
        EV_LogDebug.printLogDebug('FINISH ',String.valueof(dbc));

    }

	public static String generateICSFile(String evtFormato, Date evStartDate, Time evHoraInicio, Time evHoraFin, String evDescription, String evName, String evLocation, String evCode) {
		String icsContent = 'BEGIN:VCALENDAR\n';
		icsContent += 'VERSION:2.0\n';
		icsContent += 'PRODID:-//Salesforce//Calendar//EN\n'; 
		icsContent += 'BEGIN:VEVENT\n'; 
		icsContent += 'UID:' + String.valueOf(System.currentTimeMillis()) + '\n';
		icsContent += 'DTSTAMP:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraInicio.hour(), evHoraInicio.minute(), evHoraInicio.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + '\n';
		icsContent += 'DTSTART:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraInicio.hour(), evHoraInicio.minute(), evHoraInicio.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + '\n';
		icsContent += 'DTEND:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraFin.hour(), evHoraFin.minute(), evHoraFin.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'')+ '\n'; 
		icsContent += 'SUMMARY:' + evName + '\n';
		if(evtFormato == '001'){
			icsContent += 'DESCRIPTION:' +  evDescription + '\n';    
		}else{
			icsContent += 'DESCRIPTION:' +  evDescription + '\\n' + '\\n'+ (evCode != null ? evCode : '') + '\n';   
		}
		icsContent += 'LOCATION:' + evLocation + '\n';      
		icsContent += 'END:VEVENT\n';
		icsContent += 'END:VCALENDAR'; 
		return icsContent;
	}  
}