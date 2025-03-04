public with sharing class CC_IdentCliente_Future {

    // Funció auxiliar per dividir una llista d'ID en lots de mida específica.
    private static Map<Integer, List<ID>> splitIntoBatches(List<ID> ids, Integer batchSize) {
        Map<Integer, List<ID>> batches = new Map<Integer, List<ID>>();
        Integer batchIndex = 1;
        for (Integer i = 0; i < ids.size(); i++) {
            if (!batches.containsKey(batchIndex)) {
                batches.put(batchIndex, new List<ID>());
            }
            batches.get(batchIndex).add(ids[i]);
            if ((((i + 1) % batchSize)) == 0) {
                batchIndex++;
            }
        }
        return batches;
    }

    // Mètode future per processar la identificació de clients nous.
    @future(callout=true)
    public static void CallUpdateALF(List<ID> ids) {
        Map<String, SObject> recordMap = obtenerIdentifiers(ids, false);
        if(recordMap != null && !recordMap.isEmpty()){
            actualizarDatosALF(recordMap);
        }
        // Aquí també es podria volar a actualitzar els casos identificats.
        actualizarCasosIdentificats(new Set<String>());
    }

    // Mètode future per processar la identificació de clients existents.
    @future(callout=true)
    public static void CallUpdateALFExistentes(List<ID> ids) {
        Map<String, SObject> recordMap = obtenerIdentifiers(ids, true);
        if(recordMap != null && !recordMap.isEmpty()){
            actualizarDatosALF(recordMap);
        }
    }

    // Funció central per obtenir identificadors a partir dels objectes d'origen.
    // Per simplificar, només es treballa amb LiveChatTranscript i Case.
    private static Map<String, SObject> obtenerIdentifiers(List<ID> ids, Boolean existents) {
        Map<String, SObject> result = new Map<String, SObject>();
        // Processament de LiveChatTranscript
        List<LiveChatTranscript> chats = [SELECT Id, CC_NumPerso__c, CC_NumPerso2__c, CaseId, AccountId, ContactId
                                           FROM LiveChatTranscript WHERE Id IN :ids];
        for(LiveChatTranscript chat : chats) {
            if(String.isNotBlank(chat.CC_NumPerso__c)) {
                result.put(chat.CC_NumPerso__c + '_LCT', null);
            }
            if(String.isNotBlank(chat.CC_NumPerso2__c)) {
                result.put(chat.CC_NumPerso2__c + '_LCT2', null);
            }
        }
        // Processament dels casos
        List<Case> cases = [SELECT Id, CC_NumPerso__c, CC_Numero_Documento__c, CC_CuentaRRSS_CLI__c, AccountId, ContactId
                              FROM Case WHERE Id IN :ids];
        for(Case cs : cases) {
            if(String.isNotBlank(cs.CC_NumPerso__c)) {
                result.put(cs.CC_NumPerso__c + '_CASE', null);
            } else if(String.isNotBlank(cs.CC_Numero_Documento__c)) {
                result.put(cs.CC_Numero_Documento__c + '_DOC', null);
            } else if(String.isNotBlank(cs.CC_CuentaRRSS_CLI__c)) {
                result.put(cs.CC_CuentaRRSS_CLI__c + '_RRSS', null);
            }
        }
        return result;
    }

    // Mètode per identificar els clients de forma síncrona.
    public static Map<String, Object> IdentificarPersALFSync(String tipoBusqueda, String busqueda) {
        if(String.isBlank(tipoBusqueda) || String.isBlank(busqueda)) {
            return null;
        }
        // Per comprovacions de NumPerso, es comprova si cal actualitzar.
        if(tipoBusqueda == 'NP'){
            Set<String> toUpdate = getNumPerSinActualizar(new Set<String>{busqueda});
            if(!toUpdate.isEmpty()){
                CallUpdatePERSALFSync(new Map<String, String>{ busqueda => 'Cliente' });
            }
        } else {
            // Per DOC o TEL, definim un valor simple.
            String flag = (tipoBusqueda == 'DOC' ? 'DATADOC' : 'DATATEL');
            CallUpdatePERSALFSync(new Map<String, String>{ busqueda => flag });
        }
        // Simulem la cerca de Contact i Account.
        Map<String, Object> res = new Map<String, Object>();
        List<Contact> contacts = [SELECT Id, AccountId, Name FROM Contact WHERE CC_NumPerso__c = :busqueda];
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE CC_NumPerso__c = :busqueda];
        if(!contacts.isEmpty()){
            res.put('CONTACTOS', contacts);
        }
        res.put('CUENTAS', accounts);
        return res;
    }

    // Mètode future per actualitzar la identificació de documents/tels de forma asíncrona.
    @future(callout=true)
    public static void IdentificarPersALFASynchronous(String tipoBusqueda, String busqueda) {
        IdentificarPersALFSync(tipoBusqueda, busqueda);
    }

    // Mètode auxiliar per iniciar la crida síncrona d'actualització ALF.
    private static void CallUpdatePERSALFSync(Map<String, String> datos) {
        Map<String, SObject> dataMap = new Map<String, SObject>();
        for(String clave : datos.keySet()){
            if(String.isNotBlank(datos.get(clave))){
                // Format de la clau simplificat.
                String key = clave + '##' + datos.get(clave) + '##N/A##N/A##N/A##N/A##N/A##N/A';
                dataMap.put(key, null);
            }
        }
        if(!dataMap.isEmpty()){
            actualizarDatosALF(dataMap);
        }
    }

    // Mètode simplificat per processar l'actualització de la informació ALF.
    private static void actualizarDatosALF(Map<String, SObject> dataMap) {
        // Aquí s'integraria la trucada real al web service de ALF.
        // En aquest exemple només registrem el log i, si cal, s'executarien DML per actualitzar Account/Contact.
        System.debug('Actualització d''ALF amb dades: ' + dataMap.keySet());
        // Exemple: Database.upsert(accounts, Account.Fields.CC_NumPerso__c);
    }

    // Actualitza de forma simplificada els casos identificats.
    public static void actualizarCasosIdentificats(Set<String> casosKeys) {
        List<Case> casosToUpdate = new List<Case>();
        // Aquesta funció hauria de processar les claus per extreure detalls; en aquesta versió només és un placeholder.
        if(!casosToUpdate.isEmpty()){
            update casosToUpdate;
        }
    }

    // Comprova quins NumPerso requereixen actualització (per fecha de refresc).
    public static Set<String> getNumPerSinActualizar(Set<String> numPersos) {
        Set<String> toUpdate = new Set<String>();
        if(numPersos.isEmpty()){
            return toUpdate;
        }
        Integer diasRef = CC_WS_Methods_ALF.getDiasRefrescoALF('CC_Int_ALF');
        Date todayDate = Date.today();
        for(Account acc : [SELECT CC_NumPerso__c, CC_FechaRefresco__c FROM Account WHERE CC_NumPerso__c IN :numPersos]){
            if(acc.CC_FechaRefresco__c == null || acc.CC_FechaRefresco__c.addDays(diasRef) <= todayDate){
                toUpdate.add(acc.CC_NumPerso__c);
            }
        }
        for(Contact con : [SELECT CC_NumPerso__c, CC_FechaRefresco__c FROM Contact WHERE CC_NumPerso__c IN :numPersos]){
            if(con.CC_FechaRefresco__c == null || con.CC_FechaRefresco__c.addDays(diasRef) <= todayDate){
                toUpdate.add(con.CC_NumPerso__c);
            }
        }
        return toUpdate;
    }

    // Mètode invocable per processar la identificació de clients a partir del xat.
    @InvocableMethod(label='Procesar Identificación Clientes')
    public static void identificarClientesChat(List<ID> newObjIds) {
        if(newObjIds == null || newObjIds.isEmpty()){
            return;
        }
        Set<ID> idSet = new Set<ID>(newObjIds);
        List<ID> idList = new List<ID>(idSet);
        Map<Integer, List<ID>> batches = splitIntoBatches(idList, 50);
        for(List<ID> batchIds : batches.values()){
            CallUpdateALF(batchIds);
        }
    }

    // Versió asíncrona que reutilitza la lògica de xat.
    public static void identificarClientesAsync(List<ID> newObjIds) {
        identificarClientesChat(newObjIds);
    }

    // Mètode per posar inactius els representants legals d'un client.
    public static void inactivarRepresentants(Set<String> numPersos) {
        Id rtRep = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        List<Contact> repsToUpdate = [SELECT Id, CC_NumPersoAsoc__c FROM Contact
                                      WHERE CC_NumPersoAsoc__c IN :numPersos AND RecordTypeId = :rtRep];
        for(Contact rep : repsToUpdate){
            rep.CC_Inactivo__c = true;
        }
        if(!repsToUpdate.isEmpty()){
            update repsToUpdate;
        }
    }

    // Gestió simplificada dels casos per ajustar els representants segons el tipus de client.
    public static void gestionarRepresentantsCasos(Set<ID> casosIds) {
        List<Case> casosToUpdate = new List<Case>();
        for(Case cs : [SELECT Id, AccountId, ContactId, Account.CC_Tipo_Persona__c,
                        Contact.CC_Edad__c, Account.CC_MenorEmancipado__c, Account.CC_IncapacitadoLegal__c
                        FROM Case WHERE Id IN :casosIds]){
            if(cs.AccountId != null && cs.ContactId != null){
                if(cs.Account.CC_Tipo_Persona__c == 'J' ||
                   (cs.Account.CC_Tipo_Persona__c == 'F' && ((cs.Account.CC_MenorEmancipado__c == false && cs.Contact.CC_Edad__c < 18) ||
                                                          cs.Account.CC_IncapacitadoLegal__c == true))){
                    cs.ContactId = null;
                    casosToUpdate.add(cs);
                }
            }
        }
        if(!casosToUpdate.isEmpty()){
            update casosToUpdate;
        }
    }

    // Gestió de comptes duplicades basada en el camp NumPerso.
    public static void gestionarDuplicats(Set<String> numPersos) {
        List<Contact> contactsToDelete = [SELECT Id FROM Contact
                                          WHERE AccountId != null AND (Account.CC_NumPerso__c = NULL OR Account.CC_NumPerso__c = '')
                                          AND Account.CC_NumPersoOrig__c IN :numPersos];
        List<Account> accountsToDelete = [SELECT Id FROM Account
                                          WHERE (CC_NumPerso__c = NULL OR CC_NumPerso__c = '')
                                          AND CC_NumPersoOrig__c IN :numPersos];
        if(!contactsToDelete.isEmpty()){
            delete contactsToDelete;
        }
        if(!accountsToDelete.isEmpty()){
            delete accountsToDelete;
        }
    }

    // Mètode públic per obtenir la identificació d'ALF.
    public static Map<String, Object> getIdentificacionALF(String tipoBusqueda, String busqueda) {
        return IdentificarPersALFSync(tipoBusqueda, busqueda);
    }
}