public class EV_EmailMessageWrapper {
    
    public final String FromName;
    public final String FromAddress;
    public final String ToAddress;
    public final Id ToAddressId;
    public final String BccAddress;
    public final String Subject;
    public final Map<String, String> ParameterSubjectMap;
    public final String Body;
    public final Map<String, String> ParameterBodyMap;
    
    public EV_EmailMessageWrapper(String fromName, String fromAddr, Id toAddrId, String sub, Map<String, String> mapSubjectParams, Map<String, String> mapBodyParams) {
        this(fromName, fromAddr, null, toAddrId, null, sub, mapSubjectParams, null, mapBodyParams );
    }
    
    public EV_EmailMessageWrapper(String fromName, String fromAddr, String toAddr, Id toAddrId, String bccAddr, String sub, Map<String, String>  mapSubjectParams, String body, Map<String, String> mapBodyParams) {
        this.FromName = fromName;
        this.FromAddress = fromAddr;
        this.ToAddress = toAddr;
        this.ToAddressId = toAddrId;
        this.BccAddress = bccAddr;
        this.Subject = sub;
        this.ParameterSubjectMap = mapSubjectParams;
        this.Body = body;
        this.ParameterBodyMap = mapBodyParams;
    }
    
    public Messaging.SingleEmailMessage sendEmail(EV_EmailMessageWrapper emailMessageWrapper, Id emailTemplateId) {
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Id = :emailTemplateId];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Eventos Marketing'];
        if (!owea.isEmpty()) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }else{
            mail.setSenderDisplayName(emailMessageWrapper.FromName);
            
            if(emailMessageWrapper.FromAddress != null && emailMessageWrapper.FromAddress.length() > 0)            
                mail.setReplyTo(emailMessageWrapper.FromAddress);            
        }
                
        if(emailMessageWrapper.ToAddress != null && emailMessageWrapper.ToAddress.length() > 0)
        {
            mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
        }else{
            mail.setTargetObjectId(emailMessageWrapper.ToAddressId);
        }
        
        String subject = null;
        if(emailMessageWrapper.Subject != null && emailMessageWrapper.Subject.length() > 0) {
            mail.setSubject(emailMessageWrapper.Subject);
            subject = emailMessageWrapper.Subject;
        }else{
            subject = emailTemplate.Subject;
        }
        
        for(String key: emailMessageWrapper.ParameterSubjectMap.keySet())
        {
            subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));
        }
        
        mail.setSubject(subject);
        String htmlBody = emailTemplate.HtmlValue;
        String plainBody = emailTemplate.Body;
        for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) 
        {
            htmlBody = htmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
        }
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
        
        return mail;
    }    
    
    public static Map<String, String> remplazarCampos(CampaignMember member, List<EV_RemplazoCamposEmail__mdt> remplazosList, Boolean cuerpoCheck, Boolean asuntoCheck)
    {
        String fieldValue, encodedFieldValue;
        Map<String, String> mapParams = new Map<String, String>();
        for(EV_RemplazoCamposEmail__mdt remplazo : remplazosList)
        {
            if(remplazo.Cuerpo__c && cuerpoCheck)
            {
                if(remplazo.EV_Nuevo_valor__c.contains('.'))
                {
                    List<String> parts = remplazo.EV_Nuevo_valor__c.split('\\.');
                    fieldValue = String.valueOf(member.getSObject(parts[parts.size()-2]).get(parts[parts.size()-1]));         
                }else{
                    fieldValue = String.valueOf(member.get(remplazo.EV_Nuevo_valor__c));          
                }   
                
                if(remplazo.EsURL__c)
                {
                    if(fieldValue != null)
                        encodedFieldValue = EncodingUtil.urlEncode(fieldValue, 'UTF-8');
                    else
                        encodedFieldValue = '';
                    
                    if(encodedFieldValue != null)
                        mapParams.put(remplazo.EV_Valor_a_remplazar__c, encodedFieldValue);
                    else
                        mapParams.put(remplazo.EV_Valor_a_remplazar__c, '');
                }else{
                    mapParams.put(remplazo.EV_Valor_a_remplazar__c, fieldValue);
                }
                
            }else if(remplazo.Asunto__c && asuntoCheck){
                if(remplazo.EV_Nuevo_valor__c.contains('.'))
                {
                    List<String> parts = remplazo.EV_Nuevo_valor__c.split('\\.');
                    fieldValue = String.valueOf(member.getSObject(parts[parts.size()-2]).get(parts[parts.size()-1]));                   
                }else{
                    fieldValue = String.valueOf(member.get(remplazo.EV_Nuevo_valor__c));                    
                }                  
                
                if(remplazo.EsURL__c)
                {
                    if(fieldValue != null)
                        encodedFieldValue = EncodingUtil.urlEncode(fieldValue, 'UTF-8');
                    else
                        encodedFieldValue = '';
                    
                    if(encodedFieldValue != null)
                        mapParams.put(remplazo.EV_Valor_a_remplazar__c, encodedFieldValue);
                    else
                        mapParams.put(remplazo.EV_Valor_a_remplazar__c, '');
                }else{
                    mapParams.put(remplazo.EV_Valor_a_remplazar__c, fieldValue);
                }
            }
        }
        return mapParams;
    }
    
}