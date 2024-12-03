/**********************************************************************************************************************
Name:	  AV_CreateOpportunityCallMe
Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Crear Oportunidades CallMe
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE			Description
	1.0			US559834   			Elisabeth R	        14/03/2023		Init version
    1.1         US590780            Laura M             08/05/2023      Modified the createOpp method to add CSBD_Now_Origen__c 
    1.2         US633217            Elisabeth R.        20/06/2023      Error messages and indInTouch logic
    1.3         Fix                 Elisabeth R.        07/10/2023      Change numperso to NUMPERSO
    1.4         US602229            Elisabeth R.        08/08/2023      Added centerOpp parameter
***********************************************************************************************************************/

public with sharing class AV_CreateOpportunityCallMe {

    public static StatusResponse createOpp(String jsonOpp, String centerOpp) {
        String methodName = 'createOpp';
        String result = 'OK';

        StatusResponse  respWrapper = new StatusResponse();

        Map<String,Object> jsonOppMapRequests = (Map<String,Object>) JSON.deserializeUntyped(jsonOpp);
        Map<String, Object> jsonOppMap = new Map<String, Object>();

        for(Object  jsonElement : (List<Object>)jsonOppMapRequests.get('solicitudes')){
            jsonOppMap = (Map<String, Object>) jsonElement ;
        }

        Map<String, Object> fields = new Map<String, Object>();

        Id idRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'AV_CallMe');

        Opportunity opp = new Opportunity();

        Account client = getClientId(jsonOppMap);

        if(client != null){
            opp.AccountId = client.Id;
        
            opp.RecordTypeId = idRecordType;
            opp.StageName = getStage(jsonOppMap);
            opp.CloseDate = System.today().addDays(5);

            CC_Lista_Valores__c listOfValue = getProduct(String.valueOf(jsonOppMap.get('idProducto')));

            String productId;
            String productName;

            if(listOfValue != null){
                productId = listOfValue.CSBD_Product2__c;
                productName = listOfValue.CSBD_Product2__r.Name;
            }
            
            if(productId != null){
                opp.AV_PF__c =  productId;
                opp.AV_Producto__c =  productId;
            }
            
            getManager(jsonOppMap, client, fields, centerOpp);

            if(String.valueOf(jsonOppMap.get('indInTouch')) == 'S' && fields.get('AV_Gestor__c') == null){

                respWrapper.errorMessage = 'No existe EAP/Gestor relacionado a este cliente';

            }

            opp.AV_FechaAlta__c = System.today();
            opp.AV_FechaFinAccionComercial__c = System.today().addDays(5);
            opp.AV_FechaInicioVigencia__c = System.today();
            opp.AV_OrigenApp__c = 'AV_NowIn';
            opp.AV_Potencial__c = 'A';
            opp.AV_Comentarios__c = String.valueOf(jsonOppMap.get('descripcion')); 
            opp.CSBD_Canal__c = String.valueOf(jsonOppMap.get('canal'));
            opp.CSBD_Now_Boton__c = String.valueOf(jsonOppMap.get('boton'));
            opp.CSBD_Idioma_Solicitud__c = getLanguage(String.valueOf(jsonOppMap.get('canal')), String.valueOf(jsonOppMap.get('idioma')));
            opp.CSBD_Telefono_Solicitud__c = String.valueOf(jsonOppMap.get('telefono'));
            opp.CSBD_Email_Solicitud__c = String.valueOf(jsonOppMap.get('email1Tit'));
            opp.CSBD_Now_NIF__c = String.valueOf(jsonOppMap.get('nif'));
            opp.CSBD_Detalle_producto__c = String.valueOf(jsonOppMap.get('subproducto_1'));
            opp.CSBD_Now_Origen__c = String.valueOf(jsonOppMap.get('origen'));
            Datetime myDateTime = Datetime.now();
            opp.AV_ExternalID__c = 'CallMe-' +  myDateTime.getTime(); 
            getSchedule(String.valueOf(jsonOppMap.get('horaIni')), String.valueOf(jsonOppMap.get('minIni')), String.valueOf(jsonOppMap.get('horaFin')), String.valueOf(jsonOppMap.get('minFin')), fields);
            checkBlakList(jsonOppMap, fields); 
            for (String field : fields.keySet()) {
                opp.put(field, fields.get(field));
            }

            if(productName != null){
                opp.Name = 'CallMe - ' + productName + ' - ' + opp.CSBD_Turno_Contacto__c + ' - ' + opp.CSBD_Horario_Contacto__c; 

            }else{
                opp.Name = 'CallMe - ' + opp.CSBD_Turno_Contacto__c + ' - ' + opp.CSBD_Horario_Contacto__c; 
            }

            Database.SaveResult srOpp = Database.insert(opp, false);

            if(srOpp.isSuccess()){

                if(String.valueOf(jsonOppMap.get('indInTouch')) == 'S'){
                    AV_OpportunityTriggerHelperSharing.createTaskCallMeFromJSON(opp);
                }
                respWrapper.idOpp = srOpp.getId();
                respWrapper.isSuccess = String.valueOf(srOpp.isSuccess());
                respWrapper.errorMessage = '';
                return respWrapper;
            }else{
                for(Database.Error err : srOpp.getErrors()) {
                    CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
                    result =  err.getMessage();
                } 

                respWrapper.isSuccess = 'false';
                respWrapper.errorMessage = result;
                return respWrapper;
            }
        }
        else{
            respWrapper.isSuccess = 'false';
            respWrapper.errorMessage = 'No existe un cliente con ese Numper en Salesforce';
        }
        return respWrapper;  
    }

    public static String getStage(Map<String,Object> jsonOpp) {

        string stageName;

        if(String.valueOf(jsonOpp.get('indInTouch')) == 'N'){

            stageName = 'Potencial';

        }else if(String.valueOf(jsonOpp.get('indInTouch')) == 'S'){

            stageName = 'En gestión/insistir';

        }

        return stageName;
    }


    public static Account getClientId(Map<String,Object> jsonOpp) {

        Set<String> rtDevNames = new Set<String>{'CC_Cliente', 'CC_ClientePA'};

        String numperso = transformHexadecimal(String.valueOf(jsonOpp.get('NUMPERSO')));

        try{

            List<Account> clientAcc = [SELECT Id, AV_EAPGestor__c, AV_EAPGestor__r.AV_UsuarioAsociado__c, AV_EAPGestor__r.Account.CC_Numero_Oficina__c  FROM Account WHERE AV_NumPerso__c =:numperso  AND RecordType.DeveloperName IN : rtDevNames LIMIT 1];
            
            if(clientAcc != null && !clientAcc.isEmpty()){

                return clientAcc[0];

            }else{
                return null;
            }
            

        }catch(QueryException  e){
            return null;
        }
    }

    public static void getManager(Map<String,Object> jsonOpp, Account client, Map<String, Object> fields, String centerOpp) {

        String ownerId;
        String employee;
        String manager;
        String center;

        if(String.valueOf(jsonOpp.get('indInTouch')) == 'N'){

            List<Contact> withoutManager = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__r.Profile.Name = 'API Only' AND AV_UsuarioAsociado__r.Alias = 'AV-TF9' LIMIT 1];

            List<Account> c = new List<Account>();

            if(centerOpp == '04563' || centerOpp == '05202'){

                c = [SELECT CC_Numero_Oficina__c FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' AND CC_Numero_Oficina__c =: centerOpp];

            }

            if(withoutManager != null && !withoutManager.isEmpty()){

                ownerId = withoutManager[0].AV_UsuarioAsociado__c;
                employee = withoutManager[0].Id;
                manager = withoutManager[0].Id;
            }
            if(c != null && !c.isEmpty()){

                center = c[0].CC_Numero_Oficina__c;

            }


        }else if(String.valueOf(jsonOpp.get('indInTouch')) == 'S'){

            if(client.AV_EAPGestor__r.AV_UsuarioAsociado__c != null){

                ownerId = client.AV_EAPGestor__r.AV_UsuarioAsociado__c;
                employee = client.AV_EAPGestor__c;
                manager = client.AV_EAPGestor__c;
                center = client.AV_EAPGestor__r.Account.CC_Numero_Oficina__c;

            }else{
                List<Contact> withoutManager = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__r.Profile.Name = 'API Only' AND AV_UsuarioAsociado__r.Alias = 'AV-TF9' LIMIT 1];
                if(withoutManager != null && !withoutManager.isEmpty()){
                    ownerId = withoutManager[0].AV_UsuarioAsociado__c;
                }
            }

        }

        fields.put('OwnerId', ownerId);
        fields.put('AV_EmpleadoAlta__c', employee);
        fields.put('AV_Gestor__c', manager);
        fields.put('AV_Center__c', center);

    }

    public static CC_Lista_Valores__c getProduct(String idProduct) {

        List<CC_Lista_Valores__c> listOfValues = [SELECT CSBD_Product2__c, CSBD_Product2__r.Name, CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c, CSBD_Valor4__c FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor'
        AND CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto'
        AND Name = :idProduct AND CC_Activa__c = TRUE LIMIT 1];

        if(listOfValues != null && !listOfValues.isEmpty()){
            return listOfValues[0];
        }else{
            return null;
        }
        
    }


    public static String getLanguage(String canal, String idioma) {
        if(canal == 'portal'){
            switch on idioma {
                when '2', '02', 'CA', 'CAT', 'ca', 'cat', 'Català', 'Castellano' {
                    return 'Catalán';
                }
                when '03', '04', '05', '13', '14', '15', '16', '17', '18', '19', '20',
                        '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
                        '3', '4', '5', '99', 'ENG', 'eng' {
                    return 'Inglés';
                }
                when else {
                    return 'Castellano';
                }
            }
        } else {
            switch on idioma {
                when '1', '01', 'CA', 'CAT', 'ca', 'cat', 'Català', 'Castellano' {
                    return 'Catalán';
                }
                when '03', '04', '05', '13', '14', '15', '16', '17', '18', '19', '20',
                        '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
                        '3', '4', '5', '99', 'ENG', 'eng' {
                    return 'Inglés';
                }
                when else {
                    return 'Castellano';
                }
            }
        }
    }

    
    public static void getSchedule(String horaInicial, String minInicial, String horaFinal, String minFinal, Map<String, Object> fields) {

        if(String.isNotBlank(horaInicial)){
            if(horaInicial.length() == 1){
                horaInicial = '0' + horaInicial;
            }
        } else {
            horaInicial = '00';
        }

        if(String.isNotBlank(minInicial)){
            if(minInicial.length() == 1){
                minInicial = '0' + minInicial;
            }
        } else {
            minInicial = '00';
        }

        if(String.isNotBlank(horaFinal)){
            if(horaFinal.length() == 1){
                horaFinal = '0' + horaFinal;
            }
        } else {
            horaFinal ='00';
        }

        if(String.isNotBlank(minFinal)){
            if(minFinal.length() == 1){
                minFinal = '0' + minFinal;
            }
        } else {
            minFinal = '00';
        }

        integer turnoHora = integer.valueof(horaInicial);

        if(turnoHora >= 14){
            fields.put('CSBD_Turno_Contacto__c', 'Tarde');
        }else {
            fields.put('CSBD_Turno_Contacto__c', 'Mañana');
        }    

        fields.put('CSBD_Horario_Contacto__c', horaInicial + ':' + minInicial + ' - ' + horaFinal + ':' + minFinal);
    }


    public static void checkBlakList(Map<String,Object> jsonOpp, Map<String, Object> fields){

                    Map<String, String> fieldsBlackList = new Map<String, String>();

                    fieldsBlackList.put('CSBD_Email_Solicitud__c', String.valueOf(jsonOpp.get('email1Tit')));
                    fieldsBlackList.put('CSBD_Telefono_Solicitud__c', String.valueOf(jsonOpp.get('telefono')));
                    fieldsBlackList.put('CSBD_Now_NIF__c', String.valueOf(jsonOpp.get('nif')));


                    CSBD_Campos_blacklist__mdt[] camposComprobarMetadato = [SELECT MasterLabel, CSBD_Campo_API_Name__c FROM CSBD_Campos_blacklist__mdt];

                    Map<String, String> labelAPINameCamposBlacklistMap = new Map<String, String>();

                    for(CSBD_Campos_blacklist__mdt campoMetadato: camposComprobarMetadato){
                        labelAPINameCamposBlacklistMap.put(campoMetadato.MasterLabel, campoMetadato.CSBD_Campo_API_Name__c);
                    }

                    Set<String> valoresCamposBlacklist = new Set<String>();
                    for(String camposComprobar: labelAPINameCamposBlacklistMap.values()){
                        if(fieldsBlackList.containsKey(camposComprobar)){
                            valoresCamposBlacklist.add(String.valueOf(fieldsBlackList.get(camposComprobar)));
                        }
                    }

                    List<CC_Lista_Valores__c> blacklist = [SELECT Id, CC_Lista__c, Name, CC_Valor__c
                                                            FROM CC_Lista_Valores__c
                                                            WHERE RecordType.Name = 'Valor' AND CC_Activa__c = true
                                                            AND CC_Lista__r.Name = 'CSBD: Blacklist' AND Name = :valoresCamposBlacklist];
                    

                    for (CC_Lista_Valores__c listaValores: blacklist){
                        String valor = labelAPINameCamposBlacklistMap.get(listaValores.CC_Valor__c);

                        Object campoSolicitud;
                        if(fieldsBlackList.containsKey(valor)){
                            campoSolicitud = fieldsBlackList.get(valor);

                            if(listaValores.Name == campoSolicitud){
                                fields.put('StageName', 'Rechazada');
                                fields.put('CSBD_Resolucion__c', 'Pertenece a la blacklist');
                                break;
                            }
                        }                        
                    }

    }


    public class StatusResponse{
        public String idOpp {get;set;}
        public String isSuccess {get;set;}
        public String errorMessage {get;set;}
    }
    

     /**
	 * Transforma hexadecimal en number.
	 * @param text:  texto hexadecimal
     * @return String:  texto en number
	 */
    public static String transformHexadecimal(String hexadecimalNumber) {
        try {
            if (String.isBlank(hexadecimalNumber)) {
                return '';
            } else {
                Map<String, Integer> hexMap = new Map<String, Integer>();
                hexMap.put('0', 0);
                hexMap.put('1', 1);
                hexMap.put('2', 2);
                hexMap.put('3', 3);
                hexMap.put('4', 4);
                hexMap.put('5', 5);
                hexMap.put('6', 6);
                hexMap.put('7', 7);
                hexMap.put('8', 8);
                hexMap.put('9', 9);
                hexMap.put('A', 10);
                hexMap.put('B', 11);
                hexMap.put('C', 12);
                hexMap.put('D', 13);
                hexMap.put('E', 14);
                hexMap.put('F', 15);
                hexMap.put('a', 10);
                hexMap.put('b', 11);
                hexMap.put('c', 12);
                hexMap.put('d', 13);
                hexMap.put('e', 14);
                hexMap.put('f', 15);

                Double retDecimal = 0;
                for (Integer i = 0; i < hexadecimalNumber.length(); i++)  {
                    retDecimal += (hexMap.get(hexadecimalNumber.substring(i, i + 1)) * Math.pow(16, hexadecimalNumber.length() - (i + 1))) ;
                }
                return String.valueOf(Integer.valueOf(retDecimal));
            }
        } catch (Exception e) {
            return null;
        }
    }


}