public with sharing class demo_Timeline_Apex {

    @AuraEnabled
    public static List<demo_Timeline_Item> getData(String objectApiName, Id recordId, Map<String, Object> opcionesObjetos) {

        Map<String, Map<String, Schema.SObjectField>> definicionCampos = new Map<String, Map<String, Schema.SObjectField>>();

        List<demo_Timeline_Item> data = new List<demo_Timeline_Item>();
        Map<String, Object> opcionesTask = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(opcionesObjetos.get('Tarea')));
        Map<String, Object> opcionesEvento = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(opcionesObjetos.get('Evento')));
        Map<String, Object> opcionesLlamada = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(opcionesObjetos.get('Llamada')));
        Map<String, Object> opcionesCorreo = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(opcionesObjetos.get('Correo')));
        Map<String, Object> opcionesChat = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(opcionesObjetos.get('Chat')));
        Map<String, Object> opcionesWhatsapp = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(opcionesObjetos.get('Whatsapp')));
        Map<String, Object> opcionesCaso = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(opcionesObjetos.get('Caso')));

        List<String> idsCasos = new List<String>();
        if (objectApiName == 'Account') {
            idsCasos.addAll(CC_MetodosUtiles.listaCampo([SELECT Id FROM Case WHERE AccountId = :recordId], 'Id'));
        } else if (objectApiName == 'Opportunity') {
            idsCasos.add(recordId);
            // Id idAccount = [SELECT AccountId FROM Opportunity WHERE Id = :recordId].AccountId;
            // if (String.isNotBlank(idAccount)) {
            //     idsCasos.addAll(CC_MetodosUtiles.listaCampo([SELECT Id FROM Case WHERE AccountId = :idAccount], 'Id'));
            // }
        } else if (objectApiName == 'Case') {
            idsCasos.add(recordId);
        }

        List<String> idPadres = new List<String>(idsCasos);
        //idPadres.addAll(demo_Utils.listaCampo([SELECT demo_Interaccion__c FROM demo_CaseToCase__c WHERE demo_Caso__c IN :idsCasos], 'demo_Interaccion__c', true));
        if (!idPadres.isEmpty()) {
            Map<String, Object> queryBinds = new Map<String, Object>{'idPadres' => idPadres};

            //Task
            String query = 'SELECT WhatId, TYPEOF What WHEN Opportunity THEN RecordType.DeveloperName, Name END, ' + camposSelect(opcionesTask) + ' FROM Task ';
            query += 'WHERE WhatId IN :idPadres ORDER BY ' + String.valueOf(opcionesTask.get('campoFecha')) + ' DESC LIMIT 10';
            for (Task tarea : (List<Task>)Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE)) {
                data.add(demo_Timeline_Item.nuevoItem(definicionCampos, tarea, nombreCampos(opcionesTask), tarea.WhatId, tarea.What.RecordType.DeveloperName, String.valueOf(tarea.What.get('Name'))));
            }

            //Event
            query = 'SELECT WhatId, TYPEOF What WHEN Opportunity THEN RecordType.DeveloperName, Name END, ' + camposSelect(opcionesEvento) + ' FROM Event ';
            query += 'WHERE WhatId IN :idPadres ORDER BY ' + String.valueOf(opcionesEvento.get('campoFecha')) + ' DESC LIMIT 10';
            for (Event evento : (List<Event>)Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE)) {
                data.add(demo_Timeline_Item.nuevoItem(definicionCampos, evento, nombreCampos(opcionesEvento), evento.WhatId, evento.What.RecordType.DeveloperName, String.valueOf(evento.What.get('Name'))));
            }

            /*
            //Llamada
            query = 'SELECT RelatedRecordId, TYPEOF RelatedRecord WHEN Opportunity THEN RecordType.DeveloperName, Name END, ' + camposSelect(opcionesLlamada) + ' FROM VoiceCall ';
            query += 'WHERE RelatedRecordId IN :idPadres ORDER BY ' + String.valueOf(opcionesLlamada.get('campoFecha')) + ' DESC LIMIT 10';
            for (VoiceCall llamada : (List<VoiceCall>)Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE)) {
                data.add(demo_Timeline_Item.nuevoItem(definicionCampos, llamada, nombreCampos(opcionesLlamada), llamada.RelatedRecordId, llamada.RelatedRecord.RecordType.DeveloperName, String.valueOf(llamada.RelatedRecord.get('Name'))));
            }
            */

            //EmailMessage
            query = 'SELECT CSBD_Oportunidad_Id__c, CSBD_Oportunidad_Id__r.RecordType.DeveloperName, CSBD_Oportunidad_Id__r.Name, Incoming, ' + camposSelect(opcionesCorreo) + ' FROM EmailMessage ';
            query += 'WHERE CSBD_Oportunidad_Id__c IN :idPadres ORDER BY ' + String.valueOf(opcionesCorreo.get('campoFecha')) + ' DESC LIMIT 10';
            for (EmailMessage correo : (List<EmailMessage>)Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE)) {
                data.add(demo_Timeline_Item.nuevoItem(definicionCampos, correo, nombreCampos(opcionesCorreo), correo.CSBD_Oportunidad_Id__c, correo.CSBD_Oportunidad_Id__r.RecordType.DeveloperName, correo.CSBD_Oportunidad_Id__r.Name));
            }

            //LiveChatTranscript
            query = 'SELECT CSBD_Oportunidad_Id__c, CSBD_Oportunidad_Id__r.RecordType.DeveloperName, CSBD_Oportunidad_Id__r.Name, ' + camposSelect(opcionesChat) + ' FROM LiveChatTranscript ';
            query += 'WHERE CSBD_Oportunidad_Id__c IN :idPadres ORDER BY ' + String.valueOf(opcionesChat.get('campoFecha')) + ' DESC LIMIT 10';
            for (LiveChatTranscript chat : (List<LiveChatTranscript>)Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE)) {
                    data.add(demo_Timeline_Item.nuevoItem(definicionCampos, chat, nombreCampos(opcionesChat), chat.CSBD_Oportunidad_Id__c, chat.CSBD_Oportunidad_Id__r.RecordType.DeveloperName, chat.CSBD_Oportunidad_Id__r.Name));
            }

            /*
            //MessagingSession
            query = 'SELECT CaseId, Case.RecordType.DeveloperName, Case.CaseNumber, ' + camposSelect(opcionesWhatsapp) + ' FROM MessagingSession ';
            query += 'WHERE CaseId IN :idPadres ORDER BY ' + String.valueOf(opcionesWhatsapp.get('campoFecha')) + ' DESC LIMIT 10';
            for (MessagingSession whatsapp : (List<MessagingSession>)Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE)) {
                data.add(demo_Timeline_Item.nuevoItem(definicionCampos, whatsapp, nombreCampos(opcionesWhatsapp), whatsapp.CaseId, whatsapp.Case.RecordType.DeveloperName, whatsapp.Case.CaseNumber));
            }
            */
        }

        return data;
    }

    /*
    @AuraEnabled
    public static List<demo_Timeline_Item> getDataEmails(String objectApiName, Id recordId, Map<String, Object> opcionesObjetos) {

    Map<String, Map<String, Schema.SObjectField>> definicionCampos = new Map<String, Map<String, Schema.SObjectField>>();

    List<demo_Timeline_Item> data = new List<demo_Timeline_Item>();
    Map<String, Object> opcionesCorreo = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(opcionesObjetos.get('Correo')));

    List<String> idsCasos = new List<String>();
    if (objectApiName == 'Account') {
    idsCasos.addAll(demo_Utils.listaCampo([SELECT Id FROM Case WHERE AccountId = :recordId], 'Id'));
    } else if (objectApiName == 'Case') {
    idsCasos.add(recordId);
    }

    List<String> idPadres = new List<String>(idsCasos);
    //idPadres.addAll(demo_Utils.listaCampo([SELECT demo_Interaccion__c FROM demo_CaseToCase__c WHERE demo_Caso__c IN :idsCasos], 'demo_Interaccion__c', true));
    if (!idPadres.isEmpty()) {
    Map<String, Object> queryBinds = new Map<String, Object>{'idPadres' => idPadres,'taskSubtypeNotEmailCall' => new Set<String>{'Email', 'Call'}, 'taskSubtypeCall' => 'Call'};

    //EmailMessage
    String query = 'SELECT ParentId, Parent.RecordType.DeveloperName, Parent.CaseNumber, ' + camposSelect(opcionesCorreo) + ' FROM EmailMessage ';
    query += 'WHERE ParentId IN :idPadres ORDER BY ' + String.valueOf(opcionesCorreo.get('campoFecha')) + ' DESC LIMIT 20';
    for (EmailMessage correo : (List<EmailMessage>)Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE)) {
    data.add(demo_Timeline_Item.nuevoItem(definicionCampos, correo, nombreCampos(opcionesCorreo), correo.ParentId, correo.Parent.RecordType.DeveloperName, correo.Parent.CaseNumber));
    }
    }

    return data;
    }
    */

    private static String camposSelect(Map<String, Object> opcionesObjeto) {
        Set<String> campos = new Set<String>{
            String.valueOf(opcionesObjeto.get('campoTitulo')),
            String.valueOf(opcionesObjeto.get('campoSubtitulo')),
            String.valueOf(opcionesObjeto.get('campoFecha')),
            String.valueOf(opcionesObjeto.get('campo1')),
            String.valueOf(opcionesObjeto.get('campo2')),
            String.valueOf(opcionesObjeto.get('campo3'))
        };
        if (opcionesObjeto.get('campoIncoming') != null) {
            campos.add(String.valueOf(opcionesObjeto.get('campoIncoming')));
        }
        if (opcionesObjeto.get('campoCc') != null) {
            campos.add(String.valueOf(opcionesObjeto.get('campoCc')));
        }
        campos.remove(null);
        return String.join(new List<String>(campos), ', ');
    }

    private static Map<String, String> nombreCampos(Map<String, Object> opcionesObjeto) {
        Map<String, String> nombreCampos = new Map<String, String>{
            'campoTitulo' => String.valueOf(opcionesObjeto.get('campoTitulo')),
            'campoSubtitulo' => String.valueOf(opcionesObjeto.get('campoSubtitulo')),
            'campoFecha' => String.valueOf(opcionesObjeto.get('campoFecha')),
            'campo1' => String.valueOf(opcionesObjeto.get('campo1')),
            'campo2' => String.valueOf(opcionesObjeto.get('campo2')),
            'campo3' => String.valueOf(opcionesObjeto.get('campo3'))
        };
        if (opcionesObjeto.get('campoIncoming') != null) {
            nombreCampos.put('campoIncoming', String.valueOf(opcionesObjeto.get('campoIncoming')));
        }
        if (opcionesObjeto.get('campoCc') != null) {
            nombreCampos.put('campoCc', String.valueOf(opcionesObjeto.get('campoCc')));
        }
        return nombreCampos;
    }
}