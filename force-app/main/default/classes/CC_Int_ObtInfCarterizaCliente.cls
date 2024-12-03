public with sharing class CC_Int_ObtInfCarterizaCliente {
    public class RespuestaClienteDigital {
        public String empleado1;
        public String gestorOEAP1;
        public String oficina1;
        public String clienteDigital;
        public String muroAbierto;
        public String resultado;
        public String pilotoAppNow1;
        public String indSexo1;
    }

    public static Map<Object, Object> esClienteDigital(String recordId, String tipoActividad) {
        Map<Object, Object> respuestaClienteDigital = new Map<Object, Object>();
        String numperso;
        Decimal numpersoDecimal;
        String endpoint;
        String statusCode;
        String entrada;
        String error;
        String salida;
        Boolean finOk = false;

        Case[] caso = [SELECT Account.CC_Numperso__c, Account.AV_EAPGestor__r.CC_Matricula__c, Account.AV_EAPGestor__r.Name, OwnerId FROM Case WHERE Id =: recordId];
        if(!caso.isEmpty() && caso[0].Account.CC_Numperso__c != null) {
            numperso = caso[0].Account.CC_Numperso__c;
            numpersoDecimal = Decimal.valueOf(numperso);

            CC_InterfaceSettings__mdt configClienteDigitalMdt = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_ClienteDigital');

            HttpRequest req = new HttpRequest();
            req.setEndpoint(configClienteDigitalMdt.CC_EndPoint__c);
            endpoint = String.valueOf(req.getEndpoint()).right(94);
            req.setClientCertificateName(configClienteDigitalMdt.CC_Certificado__c);
            req.setMethod(configClienteDigitalMdt.CC_TipoPeticion__c);
            req.setHeader('x-absis-customerInternalId', CC_MetodosUtiles.decimalToHex(numpersoDecimal));
            entrada = 'CC_Numperso__c : ' + numpersoDecimal + ' Hexa: ' + CC_MetodosUtiles.decimalToHex(numpersoDecimal);

            try {
                User[] gestorCliente;
                Http http = new Http();
                HTTPResponse respuesta = http.send(req);
                statusCode = String.valueOf(respuesta.getStatusCode());
                salida = String.valueOf(respuesta.getBody());
                if(String.isNotBlank(respuesta.getBody()) && respuesta.getStatusCode() == 200) {
                    RespuestaClienteDigital valoresCliente = (RespuestaClienteDigital) System.JSON.deserialize(respuesta.getBody(), RespuestaClienteDigital.class);
                       if(valoresCliente.empleado1 != null) {  
                        while (valoresCliente.empleado1.length() < 5) {
                            valoresCliente.empleado1 = '0' +  valoresCliente.empleado1;
                        }
                        respuestaClienteDigital.put('empleado1', valoresCliente.empleado1);
                        respuestaClienteDigital.put('oficina1', valoresCliente.oficina1);
                        String matriculaGestor = 'U01' + valoresCliente.empleado1;
                        gestorCliente = [SELECT Id, Name FROM User WHERE AV_ExternalID__c =: matriculaGestor];
                        if(!gestorCliente.isEmpty()) {
                            respuestaClienteDigital.put('gestorClienteName', gestorCliente[0].Name);
                            respuestaClienteDigital.put('gestorClienteId', gestorCliente[0].Id);
                            /////// EVALUAR SI EL GESTOR OBTENIDO ES EL MISMO QUE EL ASIGNADO EN EL REGISTRO DEL CLIENTE. SI NO COINCIDEN AVISAR
                            if(caso[0].Account.AV_EAPGestor__r.CC_Matricula__c != null && matriculaGestor != caso[0].Account.AV_EAPGestor__r.CC_Matricula__c) {
                                respuestaClienteDigital.put('gestorAsignadoCoincide', 'false');
                                if(caso[0].Account.AV_EAPGestor__r.Name != null) {
                                    respuestaClienteDigital.put('nombreGestorAsignado', caso[0].Account.AV_EAPGestor__r.Name);
                                } else {
                                    respuestaClienteDigital.put('nombreGestorAsignado', 'Gestor no asignado');
                                }
                            } else if(caso[0].Account.AV_EAPGestor__r.CC_Matricula__c == null) {
                                respuestaClienteDigital.put('gestorAsignadoCoincide', 'false');
                                respuestaClienteDigital.put('nombreGestorAsignado', 'Gestor no asignado');
                            }
                        }
                    }
                    if(valoresCliente.empleado1 == null || gestorCliente.isEmpty()) {
                        String nameGestor;
                        String externalID;
                        List<CC_Lista_Valores__c> listaLOV = [SELECT CC_Valor__c, Name FROM CC_Lista_Valores__c  WHERE CC_Lista__r.name = 'Gestor por defecto CC'];
                        for(CC_Lista_Valores__c valor: listaLOV) {
                            if(valor.Name == 'ExternalID') {
                                externalID = valor.CC_Valor__c;
                            }
                        }
                        gestorCliente = [SELECT Id, Name FROM User WHERE AV_ExternalID__c = :externalID LIMIT 1];
                        respuestaClienteDigital.put('gestorAsignadoCoincide', 'false');
                        respuestaClienteDigital.put('gestorClienteName', gestorCliente[0].Name);
                        respuestaClienteDigital.put('gestorClienteId', gestorCliente[0].Id);
                        respuestaClienteDigital.put('nombreGestorAsignado', gestorCliente[0].Name);
                        // YA NO APLICA TRAS US588861
                        /*Task tarea = new Task();
                        tarea.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
                        tarea.Subject = tipoActividad + ' no disponible';
                        tarea.Description = 'El cliente no tiene gestor asignado.';
                        tarea.Status = 'Completed';
                        tarea.Priority = 'Normal';
                        tarea.ActivityDate = date.today();
                        tarea.WhatId = recordId;
                        tarea.OwnerId = caso[0].OwnerId;
                        tarea.Type = tipoActividad;
                        insert tarea;*/
                    }
                    if(valoresCliente.clienteDigital == 'S' || valoresCliente.clienteDigital == 'O' ) {
                        respuestaClienteDigital.put('clienteDigital', true);
                    }
                    else if(valoresCliente.clienteDigital == 'N') {
                        respuestaClienteDigital.put('clienteDigital', false);
                    }
                    respuestaClienteDigital.put('resultado', 'OK');
                   
                    finOk = true;
                } else {
                    //Respuesta distinta de 200
                    respuestaClienteDigital.put('resultado', 'KO');
                    respuestaClienteDigital.put('mensajeError', ' El proceso de consulta del gestor ha funcionado pero no se ha obtenido una respuesta válida. Por favor, vuelva a intentarlo o póngase en contacto con su administrador. ');
                    error = ' El proceso de consulta del gestor ha funcionado pero no se ha obtenido una respuesta válida.';
                    finOk = false;
                }
            } catch (Exception e) {
                respuestaClienteDigital.put('resultado', 'KO');
                salida = String.valueOf(respuestaClienteDigital.get('resultado'));
                respuestaClienteDigital.put('mensajeError', ' El proceso de consulta del gestor ha fallado. Por favor, vuelva a intentarlo o póngase en contacto con su administrador. ');
                finOk = false;
            }
        }
        CC_TrazaInt__c traza = CC_TrazaInt.generarTraza('CC_Int_ObtInfCarterizaCliente', endpoint, statusCode, entrada, error, salida, finOK);
        if(traza != null) {
            insert traza;
        }
        return respuestaClienteDigital;
    }
}