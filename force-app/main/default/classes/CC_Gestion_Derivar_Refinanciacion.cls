public with sharing class CC_Gestion_Derivar_Refinanciacion {

    private static String textoReemplazado = '(No hay contratos informados)';

    @AuraEnabled
    public static void guardarContratos(Id recordId, String numerosContratos) {
        Case caso = [SELECT Id, CBK_Case_Extension_Id__c FROM Case WHERE Id = :recordId LIMIT 1];
        if (caso.CBK_Case_Extension_Id__c != null) {
            CBK_Case_Extension__c caseExtension = [SELECT Id, CC_Numeros_Contratos__c FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c];
            caseExtension.CC_Numeros_Contratos__c = numerosContratos;
            update caseExtension;
        } else {
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
                Case_Id__c = caso.Id,
                CC_Numeros_Contratos__c = numerosContratos
            );
            insert caseExtension;
            caso.CBK_Case_Extension_Id__c = caseExtension.Id;
        }
        update caso;
    }

    @TestVisible
    private static String reemplazarNumerosContratos(String texto1, CBK_Case_Extension__c caseExtension) {
        if (texto1 == null || caseExtension == null) {
            return texto1;
        }
        
        String resultado = texto1;
        
        // Verificar si el campo "numerosContratos" existe en el objeto
        if (caseExtension.get('CC_Numeros_Contratos__c') != null) {
            String valorNumerosContratos = String.valueOf(caseExtension.get('CC_Numeros_Contratos__c'));
            
            // Reemplazar el patrón [[[xxxxxxxxxxx]]] con el valor del campo "numerosContratos"
            resultado = resultado.replace('[[[xxxxxxxxxxx]]]', valorNumerosContratos);
        }
        return resultado;
    }

    @AuraEnabled
    public static Map<String, Object> crearTareaMGT(String recordId, String asunto, String fechaActividad, String comentarios, Boolean crearTareaCitaGestor, Id oficinaDestino, Boolean enviarTareaOficinaCliente, Contact gestorSeleccionadoBuscador, Boolean otpDerivar) {

        Case caso = [SELECT Id, Subject, Account.AV_EAPGestor__r.AV_Pool__c, OwnerId, ContactId, Contact.AccountId, 
        Account.AV_EAPGestor__r.OwnerId, Account.AV_EAPGestor__r.CC_Numero_Oficina__c, Account.AV_OfficeManager__c, Origin,
        CBK_Case_Extension_Id__c
        FROM Case 
        WHERE Id = :recordId 
        LIMIT 1];

        CBK_Case_Extension__c caseExtensionMGT = [SELECT Id, CC_Numeros_Contratos__c FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c];

        String resultado = '';

        if (caso.Account.AV_EAPGestor__r.AV_Pool__c == false) {
            List<CC_Lista_Valores__c> listaValores = [SELECT CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = 'Texto tarea AV Pool = False' LIMIT 1];
            if(!listaValores.isEmpty()){
                resultado = listaValores[0].CC_Mensajes_Mostrar__c;
            }
        } else {
            List<CC_Lista_Valores__c> listaValores = [SELECT CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = 'Texto tarea AV Pool = True' LIMIT 1];
            if(!listaValores.isEmpty()){
                resultado = listaValores[0].CC_Mensajes_Mostrar__c;
            }
        }

        if (caso.CBK_Case_Extension_Id__c != null) {
            textoReemplazado = reemplazarNumerosContratos(resultado, caseExtensionMGT);
        }
      
       Map<String, Object> retorno = new Map<String, Object>();
       Map<String, Object> datos = new Map<String, Object>();
       datos.put('recordId', recordId);
       datos.put('asunto', asunto);
       datos.put('fechaActividad', fechaActividad);
       datos.put('comentarios', textoReemplazado);
       datos.put('crearTareaCitaGestor', crearTareaCitaGestor);

       datos.put('oficinaDestino', oficinaDestino);
       datos.put('enviarTareaOficinaCliente', enviarTareaOficinaCliente);
       datos.put('gestorSeleccionadoBuscador', gestorSeleccionadoBuscador);
       datos.put('otpDerivar', otpDerivar);

       CC_Gestion_Derivar_Tarea gestionDerivarTarea = new CC_Gestion_Derivar_Tarea(datos);
       retorno = gestionDerivarTarea.crearTarea();

       return retorno;
    }

    @AuraEnabled
    public static String procesarOrigin(Id recordId) {
        Case caso = [SELECT Id, Origin, Contact.Name, Contact.Email, CC_Idioma__c
        FROM Case 
        WHERE Id = :recordId 
        LIMIT 1];

        String finalOperativa = '';
        List<CC_Lista_Valores__c> listaValores = [SELECT CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = 'Final Operativa' LIMIT 1];
        if(!listaValores.isEmpty()){
            finalOperativa = listaValores[0].CC_Mensajes_Mostrar__c;
        }

        String finalOperativa2 = '';
        List<CC_Lista_Valores__c> listaValores3 = [SELECT CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = 'Final Operativa email' LIMIT 1];
        if(!listaValores3.isEmpty()){
            List<EmailTemplate> plantilla = obtenerPlantillaEmail(caso.CC_Idioma__c);
            finalOperativa2 = listaValores3[0].CC_Mensajes_Mostrar__c;
            if (caso.Contact.Email != null && caso.Contact.Email != '') {
                finalOperativa2 = finalOperativa2.replace('[CORREO]', caso.Contact.Email);
            }
            finalOperativa2 = finalOperativa2.replace('[NOMBRE CLIENTE]', caso.Contact.Name);
            finalOperativa2 = finalOperativa2.replace('[PLANTILLA]', plantilla[0].Name);
        }

        if (caso.Origin == 'Phone') {
            return finalOperativa;
        } else if (caso.Origin == 'Email') {
            if (caso.Contact.Email != null && caso.Contact.Email != '') {
                enviarRespuestaAutomatica(recordId);
                return finalOperativa2;
            } else {
                return 'El cliente no tiene informada una dirección de email, por lo que no ha sido posible enviar una respuesta automática a su dirección de email';
            }
        } else {
            return 'El canal de entrada del caso no es Teléfono ni Email';
        }
    }

    @AuraEnabled
    public static void enviarRespuestaAutomatica(Id recordId) {
        List<Case> caso = [SELECT Status,CC_Idioma__c, Contact.Email, ContactId, CBK_Case_Extension_Id__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c FROM Case WHERE Id = :recordId];
        if (!caso.isEmpty()) {
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Map<String,OrgWideEmailAddress> owasMap = new Map<String,OrgWideEmailAddress>();
            for (OrgWideEmailAddress owa : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                    owasMap.put(String.valueOf(owa.Address), owa);
            }
            List<CC_Buzones_Por_Defecto__mdt> owaPorDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano' AND CC_Activo__c = true LIMIT 1];
            String emailCorreoEntrante = owaPorDefecto[0].CC_Direccion_Correo__c;
            List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
            owa.add(owasMap.get(emailCorreoEntrante));

            String htmlBody = '';
            String subject = '';
            List<EmailTemplate> plantilla = obtenerPlantillaEmail(caso[0].CC_Idioma__c);
            if (plantilla != null) {
                htmlBody = plantilla[0].HtmlValue;
                subject = plantilla[0].Subject;
            }
            String toAddress = caso[0].Contact.Email;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setHtmlBody(htmlBody);
            email.setSaveAsActivity(true);
            email.setTreatBodiesAsTemplate(true);
            email.setWhatId(caso[0].Id);
            email.setTargetObjectId(caso[0].ContactId);
            email.setTreatTargetObjectAsRecipient(false);
            email.setOrgWideEmailAddressId(owa[0].Id);
            email.setToAddresses(new List<String>{toAddress});
            email.subject = subject;
            allmsg.add(email);

            if(!allmsg.isEmpty()) {
                try {
                    Messaging.SendEmailResult [] result = Messaging.sendEmail(allmsg, false); // Enviamos el correo
                } catch(exception e) {
                    String exc = e.getMessage();
                }
            }
        }
    }

    public static List<EmailTemplate> obtenerPlantillaEmail(String idioma) {
        String plantillaElegida;
        if (idioma == 'ca') {
            plantillaElegida = 'Solicitud_refinanciaci_n_deuda_CAT_1705910702927';
        } else if (idioma == 'en') {
            plantillaElegida = 'Solicitud_refinanciaci_n_deuda_ENG_1705910754277';
        } else {
            plantillaElegida = 'Solicitud_refinanciaci_n_deuda_CAS_1705910638903';
        }
        List<EmailTemplate> plantilla = [SELECT Name, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = :plantillaElegida LIMIT 1];
        return plantilla;
    }
}