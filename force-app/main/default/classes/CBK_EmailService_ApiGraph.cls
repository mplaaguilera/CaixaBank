public with sharing class CBK_EmailService_ApiGraph implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try {

            if (!Test.isRunningTest()) {CBK_log.auditemail(email,envelope);}

            String nuevoHtmlBody = email.htmlBody;
            if (!String.isBlank(nuevoHtmlBody) && nuevoHtmlBody.length() > 131000) { 
                nuevoHtmlBody = nuevoHtmlBody.left(131000);
            }

            
            EmailMessage correo = new EmailMessage();
            String subjectAcortado = '';
            //US829509: Correos - Limitación caracteres asunto
            if(email.subject.length() > 3000){
                subjectAcortado = email.subject.left(3000);
            }else{
                subjectAcortado = email.subject;
            }  
                
            correo.Subject = subjectAcortado;
            correo.Status = '1';
            if (email.ccAddresses != null) {
                correo.CcAddress = String.join(email.ccAddresses, ',');
            }

            correo.FromAddress = email.fromAddress;
            correo.FromName = email.fromName;

            CBK_InboundEmailUtils.PriorityHeaderPetition petition = new CBK_InboundEmailUtils.PriorityHeaderPetition();
            petition.app = 'CBK';
            petition.header = email.headers;
            petition.limitCharacters = 31999;

            CBK_InboundEmailUtils.PriorityHeaderResult headerResult = CBK_InboundEmailUtils.getPriorityHeader(petition);

            if(headerResult.priorityHeaders != null){
                correo.Headers = JSON.serialize(headerResult.priorityHeaders);
                if(headerResult.secondPriorityHeaders != null){
                    correo.CBK_Second_Priority_Headers__c = JSON.serialize(headerResult.secondPriorityHeaders);
                }
            }

            Datetime parsedDatetime;
            for(Messaging.InboundEmail.Header header : email.headers){
                if(header.Name.equalsIgnoreCase('Date')){
                    try {
                        if(header.value != null){
                            parsedDatetime = parseoDatetime(header.value);
                        }
                        CBK_log.debug('Parseo temporal CBK_EmailService correcto - Subject : ' + subjectAcortado + ' MessageDate: ' + parsedDatetime + ' DateTime.Now(): ' + DateTime.now());
                    } catch (Exception e) {
                        CBK_log.debug('Parseo temporal CBK_EmailService incorrecto - Subject : ' + subjectAcortado + ' header.value: ' + header?.value);
                    }
                }
            }  

            correo.MessageIdentifier = email.messageId;
            correo.CBK_sfdcMessageId__c = email.messageId?.left(255);
            correo.ThreadIdentifier = email.inReplyTo;
            correo.HtmlBody = nuevoHtmlBody.left(131000);
            correo.Incoming = true;
            correo.MessageDate = parsedDatetime;

            if (email.toAddresses != null && !email.toAddresses.isEmpty()) {
                List<String> contDir = new List<String>();  
                List<String> contDirIncluidas = new List<String>();
                List<String> contDirExcluidas = new List<String>();
                Boolean limiteCaracteres = false;               
                
                if(String.join(email.toAddresses, ',').length() >= 3501 || Test.isRunningTest()) {
                    for (String varDir : email.toAddresses) {
                        contDir.add(varDir);
                        if (!limiteCaracteres && String.join(contDir, ',').length() < 3500) {
                            contDirIncluidas.add(varDir);
                        } else  {
                            contDirExcluidas.add(varDir);
                            limiteCaracteres = true;
                        }
                    }
                    correo.ToAddress = String.join(contDirIncluidas, ',');
                } else {
                    correo.ToAddress = String.join(email.toAddresses, ',');
                }
            }
            correo.CC_Aplicacion__c = 'SEG';
            
            if(Schema.sObjectType.EmailMessage.fields.ToAddress.isCreateable()){
                insert correo;
            }
            result.success=true;
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'OK';
            wResult.Detail = 'Envio correcto';
            wResult.EmailMessageId = correo.Id;
            CBK_Log.auditemailResult(wResult, email);

        } catch(Exception e){
            result.success=false;
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'KO';
            wResult.Detail = 'Error procesando el correo';
            CBK_Log.auditemailResult(wResult, email);
        }
        return result;
    }

    public static Datetime parseoDatetime(String fechaEmail){

        Map<String, Integer> monthMap = new Map<String, Integer>{
            'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4,
            'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8,
            'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
        };
        
        List<String> parts = fechaEmail.split(' ');
        
        Integer year = Integer.valueOf(parts[3]);
        Integer month = monthMap.get(parts[2]);
        Integer day = Integer.valueOf(parts[1]);
		Integer gmtEmail = Integer.valueOf(fechaEmail.right(4).left(2));
       
        List<String> timeParts = parts[4].split(':');
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        Integer second = Integer.valueOf(timeParts[2]);
        
        Datetime parsedDatetime = Datetime.newInstanceGMT(year, month, day, hour, minute, second);
        Integer horaSumar = 0;
		if(fechaEmail.contains('+')){
            horaSumar = horaSumar - gmtEmail;
		} else {
			horaSumar = horaSumar + gmtEmail;
		}
        parsedDatetime = parsedDatetime.addHours(horaSumar);
        return parsedDatetime;
    }
}