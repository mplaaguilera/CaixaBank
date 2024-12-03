public inherited sharing class CSBD_EmailMessage {

    public static Id vincularCorreoAOportunidad(Id idEmailMessage, Id idOpportunity) {
        Opportunity oportunidad = [SELECT IsClosed FROM Opportunity WHERE Id = :idOpportunity];
        
        //Clonar correo
        EmailMessage correoOrigen = Database.query(
            'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('EmailMessage').getDescribe().fields.getMap().keySet()), ',') + ' FROM EmailMessage WHERE Id = \'' + idEmailMessage + '\''
        );
        EmailMessage correoDestino = correoOrigen.clone(false, true, true, false);
        correoDestino.RelatedToId = idOpportunity;
        correoDestino.CSBD_Oportunidad_Id__c = idOpportunity;
        correoDestino.ActivityId = null;
        correoDestino.ValidatedFromAddress = null;
        insert correoDestino;

        //Clonar adjuntos
        List<Attachment> adjuntosOrigen = Database.query(
            'SELECT ' + String.join(new List<String>(Schema.getGlobalDescribe().get('Attachment').getDescribe().fields.getMap().keySet()), ',') + ' FROM Attachment WHERE ParentId = \'' + idEmailMessage + '\''
        );
        List<Attachment> adjuntosDestino = new List<Attachment>();
        for (Attachment adjuntoOrigen : adjuntosOrigen) {
            Attachment adjuntoDestino = adjuntoOrigen.clone(false, true, true, false);
            adjuntoDestino.ParentId = correoDestino.Id;
            adjuntosDestino.add(adjuntoDestino);
        }
        insert adjuntosDestino;

        //Eliminar correo y adjuntos originales
        delete adjuntosOrigen;
        delete correoOrigen;

        //Reactivar oportunidad
        if (oportunidad.IsClosed) {
            CSBD_Opportunity.reactivarOportunidad(idOpportunity, true);
        }

        return oportunidad.Id;
    }

    public static String historicoCorreosOportunidad(Id idOportunidad) {
        String historicoCorreos = '';
        List<EmailMessage> correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody
                                        FROM EmailMessage WHERE RelatedToId = :idOportunidad ORDER BY CreatedDate DESC];
        for (Integer i = 0; i < correos.size(); i++) {
            EmailMessage correo = correos[i];
            if (String.isNotBlank(correo.HtmlBody)) {
                //historicoCorreos += '<font color="gray">';
                historicoCorreos += '<div style="font-family: \'Arial\'; font-size: 12px; color: gray;">';
                historicoCorreos += 'De: ' + correo.FromAddress + '<br/>';
                historicoCorreos += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
                historicoCorreos += 'Para: ' + correo.ToAddress + '<br/>';
                if (correo.CcAddress != null) {
                    historicoCorreos += 'Con copia a:' + correo.CcAddress + '<br/>';
                }
                historicoCorreos += 'Asunto: ' + correo.Subject;
                historicoCorreos += '</div><br/>' + correo.HtmlBody;
                if (i < correos.size() - 1) {
                    //Si no es el último correo incluye un separador
                    historicoCorreos += '____________________<br/>';
                }
            }
        }
        if (String.isNotBlank(historicoCorreos)) {
            historicoCorreos = '<br/>____________________<br/><br/>' + historicoCorreos.left(25000);
        }
        return historicoCorreos;
    }

    private static String formatearFecha(Datetime fecha) {
        List<String> diasEN = new List<String>{'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
        List<String> diasES = new List<String>{'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'};

        List<String> mesesEN = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
        List<String> mesesES = new List<String>{'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};

        String retorno = diasES.get(diasEN.indexOf(fecha.format('EEE'))) + ', ' + fecha.day() + ' de ';
        retorno += mesesES.get(mesesEN.indexOf(fecha.format('MMM'))) + ' de ' + fecha.year() + ' ' + fecha.format('HH:mm');

        return retorno;
    }

    public static Id plantillaOperativaId(String operativa, String idioma) {
        try {
            idioma = String.isBlank(idioma) ? 'Castellano' : idioma;            
            String nombrePlantilla = [SELECT CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt
                                        WHERE MasterLabel = :operativa AND CSBD_Idioma__c = :idioma LIMIT 1].CSBD_Nombre_Plantilla__c;
            return [SELECT Id FROM EmailTemplate WHERE Name = :nombrePlantilla LIMIT 1].Id;
        } catch (Exception e) {
            throw new PlantillaOperativaException('La plantilla indicada no existe.');
        }
    }

    public static String plantillaOperativaNombre(String operativa, String idioma) {
        idioma = String.isBlank(idioma) ? 'Castellano' : idioma;
        List<CSBD_Plantillas_Correo__mdt> plantillas = [SELECT CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt
                                                        WHERE MasterLabel = :operativa AND CSBD_Idioma__c = :idioma LIMIT 1];
        if (!plantillas.isEmpty()) {
            return plantillas[0].CSBD_Nombre_Plantilla__c;
        } else {
            throw new PlantillaOperativaException('La plantilla indicada no existe.');
        }
    }

    public static List<EmailMessage> descartarCorreosNoCsbd(List<EmailMessage> correos) {
        List<EmailMessage> correosCsbd = new List<EmailMessage>();
        Boolean comprobarCorreosSalientes = false;
        //Si no hay correos salientes no es necesario recuperar los buzones
        for (EmailMessage correo : correos) {
            if (!correo.Incoming) {
                comprobarCorreosSalientes = true;
                break;
            }
        }
        List<String> buzonesSalidaCsbd = new List<String>();
        if (comprobarCorreosSalientes) {
            buzonesSalidaCsbd = CC_MetodosUtiles.listaCampo(
                [SELECT Address FROM OrgWideEmailAddress WHERE DisplayName LIKE 'CSBD - %' OR DisplayName LIKE 'Now In Sales - %'],
                'Address'
            );
        }
        for (EmailMessage correo : correos) {
            if (correo.Incoming && correo.CC_Aplicacion__c == 'CSBD'
            || !correo.Incoming && buzonesSalidaCsbd.contains(correo.FromAddress)) {
                correosCsbd.add(correo);
            }
        }
        return correosCsbd;
    }

   /* public static String renderPlantillaTexto(Map<String, Object> params) {
        //Parametros
        String developerName = (String) params.get('developerName');
        String templateId = (String) params.get('templateId');
        Boolean convertirATextoPlano = (Boolean) params.get('convertirATextoPlano');
        Id sObjectId = (Id) params.get('sObjectId');
        Id whoId = (Id) params.get('whoId');

        //plantilla en texto plano
        String cuerpo;

        if((developerName == null && templateId == null) || sObjectId == null){
            throw new PlantillaOperativaException('Falta la plantilla y/o el record relacionado');
        }
        //Devuelve el cuerpo de la plantilla indicada
       
        cuerpo = [
            SELECT HtmlValue 
            FROM EmailTemplate 
            WHERE DeveloperName = :developerName 
            OR Id =: templateId 
            ORDER BY Name 
            LIMIT 1
        ]?.HtmlValue;

        if(cuerpo == null){
            throw new PlantillaOperativaException('La plantilla especificada no existe');
        }
        //Si se ha indicado que se devuelva en texto plano se quitan los tags HTMLp
        if (convertirATextoPlano) {
            cuerpo = cuerpo.stripHtmlTags();
        }
        //Convertir campos parametrizados del template       
        Id whatId = sObjectId;
        List<String> emailTemplateBody = new List<String>{cuerpo};
        try{
            List<Messaging.RenderEmailTemplateBodyResult> renderedEmailTemplateLista = Messaging.renderEmailTemplate(
                whoId != null? whoId : UserInfo.getUserId(), 
                whatId, 
                emailTemplateBody
            );

            if(!renderedEmailTemplateLista.isEmpty()){
                cuerpo = renderedEmailTemplateLista[0].getMergedBody();
            } 
        }catch(Exception ex){
            throw new PlantillaOperativaException('La plantilla especificada no existe');
        }
      
        return cuerpo;
    }*/

    public static Map<String, String> renderPlantillaSubjectTexto(Map<String, Object> params) {
        //Parametros       
        String templateId = (String) params.get('templateId');
        String developerName = (String) params.get('developerName');
        Boolean convertirATextoPlano = (Boolean) params.get('convertirATextoPlano');
        Id sObjectId = (Id) params.get('sObjectId');
        Id whoId = (Id) params.get('whoId');

        //plantilla en texto plano
        String body;
        String subject;

        if((developerName == null && templateId == null) || sObjectId == null){
            throw new PlantillaOperativaException('Falta la plantilla y/o el record relacionado');
        }
        //Devuelve el cuerpo de la plantilla indicada
       
        EmailTemplate temp = [
            SELECT Id 
            FROM EmailTemplate 
            WHERE DeveloperName = :developerName 
            OR Id =: templateId 
            ORDER BY Name 
            LIMIT 1
        ];
        
        //Convertir campos parametrizados del template       
        Id whatId = sObjectId;     
        try{
            Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(
                temp?.Id, 
                whoId != null? whoId : UserInfo.getUserId(), 
                whatId
            );

            if (convertirATextoPlano) {
                body = renderedEmail.getHtmlBody().stripHtmlTags().unescapeHtml4();
            }else{
                body = renderedEmail.getHtmlBody();
            }
          
            subject = renderedEmail.getSubject();

        }catch(Exception ex){
            throw new PlantillaOperativaException('La plantilla especificada no existe');
        }
      
        return new Map<String, String> {
            'body' => body,
            'subject' => subject
        };
    }

    //Exception manejada internamente en esta clase
    public class PlantillaOperativaException extends Exception {}
}