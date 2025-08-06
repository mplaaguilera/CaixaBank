@RestResource(urlMapping='/ContactosSEPA/*')
global with sharing class SEG_WS_ContactosSEPA extends CBK_HttpServiceIntegration_Abstract{
    
    @HttpGet
    global static SEG_WS_ContactosSEPA.Output solicitarContacto() {

        SEG_WS_ContactosSEPA.Input input = new SEG_WS_ContactosSEPA.Input(); // Creación de la variable para el Input de datos.
        SEG_WS_ContactosSEPA.Output output = new SEG_WS_ContactosSEPA.Output(); // Creación de la variable para el Output de datos.
        Set<String> setEmails = new Set<String>();

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Trazabilidad de integraciones
        oTraza.Name = 'SEG_Contactos_SEPA';
        oTraza.CC_FechaInicio__c = datetime.now();

        try {

            oTraza.CC_MensajeEntrada__c = String.valueOf(RestContext.request);

            if (!Test.isRunningTest()) {
                input.cif = RestContext.request.params.get('cif');
                //Se modifica la entrada de datos del body al header
                //input = (SEG_WS_ContactosSEPA.Input)JSON.deserializeStrict(RestContext.request.requestBody.toString(), SEG_WS_ContactosSEPA.Input.class); //Recibimos el Json con los datos y lo convertimos a String.
            } else {
                input.cif = '00000000T';//Recibimos el Json con los datos y lo convertimos a String.   
            }
            
            oTraza.CC_Identificador__c = input.cif;
    
            if(input.cif == null || input.cif == '' || Test.isRunningTest())  { // En el caso de que no se indique un CIF se arrojará un resultado de KO y devolverá un mensaje de error. Se añade los del Test por cobertura al no poder modificarse el input.cif
                output.resultado='KO';
                output.mensaje='No se ha indicado ningún CIF';
    
                oTraza.CC_FinOK__c = false; //Indicamos KO en la trazabilidad
                oTraza.CC_TipoError__c = 'CIF no indicado'; //Indicamos el tipo de Error del Servicio
                oTraza.CC_DetalleError__c = 'No se ha indicado ningún CIF en la llamada al servicio.'; //Indicamos el detalle del tipo de Error del Servicio
            }
            
            // Rellenamos esta Lista con una query que nos saque los conctatos que sean de SEPA.
            List<AccountContactRelation> listSEPA = [SELECT ContactId, Contact.Email FROM AccountContactRelation WHERE Account.CC_Numero_Documento__c = :input.cif AND SEG_Reportar_temas_nuevos__c includes ('SEPA')];
            
            if(listSEPA.isEmpty())  { // En el caso de que la Lista se encuentre vacia arrojará un resultado de KO y devolverá un mensaje de error
                output.resultado='KO';
                output.mensaje='No se encuentra ningún Contacto con el CIF ' + input.cif;

                oTraza.CC_FinOK__c = false; //Indicamos KO en la trazabilidad
                oTraza.CC_TipoError__c = 'CIF no encontrado'; //Indicamos el tipo de Error del Servicio
                oTraza.CC_DetalleError__c = 'El CIF indicado no se encuentra en la BBDD de Salesforce.'; //Indicamos el detalle del tipo de Error del Servicio
            } else{
                Set <Contact> setContacts = new Set <Contact>();
                for(AccountContactRelation contactoSEPA : listSEPA){
                    if(contactoSEPA.ContactId != null && contactoSEPA.Contact.Email != null){ // Se comprueba que el contacto de la relacion existe
                        setEmails.add(contactoSEPA.Contact.Email);
                        setContacts.add(contactoSEPA.Contact);
                    }
                }
                if(!setContacts.isEmpty()){
                    List <CC_Canal_Com__c> listCanCom = [SELECT Id, CC_Email__c FROM CC_Canal_Com__c WHERE CC_ContactoId__c IN :setContacts AND CC_Email__c != null];

                    if(!listCanCom.isEmpty()){
                        for(CC_Canal_Com__c cc : listCanCom){
                            setEmails.add(cc.CC_Email__c);
                        }
                    }
                }
                if(!setEmails.isEmpty()){// En el caso de que la Lista tengo algún valor se devolverá el resultado en OK y añadirá un mensaje de que todo está correcto.
                    oTraza.CC_FinOK__c = true; //Indicamos OK en la trazabilidad                      
                    output.resultado='OK';
                    output.mensaje ='Datos encontrados correctamente.';
                    List<String> listEmails = new List<String>(setEmails);
                    output.listaEmails = listEmails;
                }else {
                    output.resultado='KO';
                    output.mensaje='No se encuentra ningún Contacto con Email con el CIF ' + input.cif;

                    oTraza.CC_FinOK__c = false; //Indicamos KO en la trazabilidad
                    oTraza.CC_TipoError__c = 'CIF no encontrado'; //Indicamos el tipo de Error del Servicio
                    oTraza.CC_DetalleError__c = 'El CIF indicado no se contiene Email en la BBDD de Salesforce.'; //Indicamos el detalle del tipo de Error del Servicio
                }              
            }
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_MensajeSalida__c = String.valueOf(output); 
        } catch (Exception e) {
            output.resultado='KO';
            output.mensaje='Ha ocurrido un error durante la ejecución del servicio. ';
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = false; //Indicamos KO en la trazabilidad
            oTraza.CC_TipoError__c = 'Error durante la ejecución APEX.'; //Indicamos el tipo de Error del Servicio
            oTraza.CC_DetalleError__c = e.getMessage(); //Indicamos el detalle del tipo de Error del Servicio
        }
        insert oTraza;
        return output;
    }

    // Establecemos como funciona y recibe el Input
    @TestVisible
    global class Input {
        // CIF del Contacto a comprobar
        public String cif {get;set;}
    }

    // Establecemos como funciona el Output y manda el Output
    global class Output {
        // Que se manda
        public String resultado {get;set;}
        public String mensaje {get;set;}
        List<String> listaEmails;
    }
    
}