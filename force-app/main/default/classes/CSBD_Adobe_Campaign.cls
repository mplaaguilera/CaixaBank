public with sharing class CSBD_Adobe_Campaign {

    public static void enviar(Opportunity oportunidad) {
        enviar(new List<Opportunity>{oportunidad});
    }

    public static void enviar(List<Opportunity> oportunidades) {
        List<CSBD_Parametro_Entorno_Adobe_Campaign__mdt> paramsEntorno = [SELECT CSBD_Envio_Activo__c, CSBD_FlowId__c, CSBD_DatasetId__c, CSBD_SchemaId__c
                                                                            FROM CSBD_Parametro_Entorno_Adobe_Campaign__mdt LIMIT 1];
        if (paramsEntorno.isEmpty()) {
            throw new CustomException('Parámetros de entorno de Adobe Campaign no configurados');
        } else if (paramsEntorno[0].CSBD_Envio_Activo__c) {
            List<Task> tareas = new List<Task>();
            for (Opportunity oportunidad : oportunidades) {
                Map<String, Object> retorno = postRequest(oportunidad, paramsEntorno[0]);

                String httpRequestBody = ((HttpRequest)retorno.get('httpRequest')).getBody();
                String httpRequestBodyPretty = JSON.serializePretty(JSON.deserializeUntyped(httpRequestBody));
                String cuerpoTarea = 'Solicitud: \n\n' + httpRequestBodyPretty;

                HttpResponse httpResponse = (HttpResponse)retorno.get('httpResponse');
                cuerpoTarea += '\n\n\n Respuesta (' + httpResponse.getStatusCode();
                cuerpoTarea += (String.isBlank(httpResponse.getStatus()) ? '' : ': ' + httpResponse.getStatus()) + '):';

                String httpResponseBody = httpResponse.getBody();
                if (String.isNotBlank(httpResponseBody)) {
                    String httpResponseBodyPretty = JSON.serializePretty(JSON.deserializeUntyped(httpResponseBody));
                    cuerpoTarea += '\n\n' + httpResponseBodyPretty;
                }

                String asuntoTarea;
                if (httpResponse.getStatusCode() == 200) {
                    // asuntoTarea = 'Actualización de estado en Adobe Campaign (' + oportunidad.CSBD_Estado__c + ')';
                    asuntoTarea = 'Actualización de estado en Adobe Campaign (' + oportunidad.StageName + ')';
                } else {
                    asuntoTarea = 'Error al actualizar estado en Adobe Campaign';
                }

                tareas.addAll(CSBD_Activity.crearActividad(new Set<Id>{oportunidad.Id}, asuntoTarea, 'Completed', asuntoTarea, cuerpoTarea?.right(32000)));
            }
            insert tareas;
        }
    }

    @future(callout=true)
    public static void enviarFuture(String jsonOportunidad) {
        enviar((Opportunity)JSON.deserialize(jsonOportunidad, Opportunity.class));
    }

    private static Map<String, Object> postRequest(Opportunity oportunidad, CSBD_Parametro_Entorno_Adobe_Campaign__mdt params) {
        Map<String, Object> retorno = new Map<String, Object>();
        CBK_HttpServiceIntegration.RequestWapper httpRequestWrapper = crearHttpRequestWrapper(oportunidad, params);
        HttpRequest httpRequest = CBK_HttpServiceIntegration.getRequest(httpRequestWrapper);
        retorno.put('httpRequest', httpRequest);
        HttpResponse httpResponse = CBK_HttpServiceIntegration.callHttpService(httpRequest, 'CSBD_WS_ADOBE_CAMPAIGN', httpRequestWrapper.intSetting);
        retorno.put('httpResponse', httpResponse);
        return retorno;
    }

    private static CBK_HttpServiceIntegration.RequestWapper crearHttpRequestWrapper(Opportunity oportunidad, CSBD_Parametro_Entorno_Adobe_Campaign__mdt params) {
        Datetime now = System.now();
        String agencyFeedback = '';
        String feedbackStatus = '';

        switch on (oportunidad.StageName) {
            when 'Perdida' {
                feedbackStatus = oportunidad.CSBD_Resolucion__c == 'Cliente no localizado' ? 'Bounce' : 'Sent';
            }
            when 'Solicitud' {
                feedbackStatus = 'Delivered';
            }
            when 'Formalizada' {
                feedbackStatus = 'Sent';
            }
        }

        agencyFeedback = oportunidad.CSBD_Resolucion__c != null ? oportunidad.StageName + ' - ' + oportunidad.CSBD_Resolucion__c : oportunidad.StageName ;
        

        CSBD_CALL_WS_Adobe_DTO.RequestDTO req = new CSBD_CALL_WS_Adobe_DTO.RequestDTO(
            new CSBD_CALL_WS_Adobe_DTO.HeaderDTO(
                new CSBD_CALL_WS_Adobe_DTO.SchemaRefDTO(
                    params.CSBD_SchemaId__c, //'https://ns.adobe.com/caixa/schemas/9d44c838acb12141b81e0d3d994181914201e9db84a452d6',
                    'application/vnd.adobe.xed-full-notext+json; version=1.0'
                ),
                params.CSBD_FlowId__c, //'d7b6ce5d-5a92-4bf8-a066-08ac9a4d1bfb',
                params.CSBD_DatasetId__c //'65004b08e7157828d3a3b33b'
            ),
            new CSBD_CALL_WS_Adobe_DTO.BodyDTO(
                new CSBD_CALL_WS_Adobe_DTO.XdmMetaDTO(
                    new CSBD_CALL_WS_Adobe_DTO.SchemaRefDTO(
                        params.CSBD_SchemaId__c, //'https://ns.adobe.com/caixa/schemas/9d44c838acb12141b81e0d3d994181914201e9db84a452d6',
                        'application/vnd.adobe.xed-full-notext+json; version=1.0'
                    )
                ),
                new CSBD_CALL_WS_Adobe_DTO.XdmEntityDTO(
                    new CSBD_CALL_WS_Adobe_DTO.CaixaDTO(
                        new CSBD_CALL_WS_Adobe_DTO.MessageDeliveryFeedbackObjDTO(
                            agencyFeedback,
                            oportunidad.CSBD_DeliveryInternalName__c,
                            now.format('yyyy-MM-dd\'T\'HH:mm:ss') + '+00:00',
                            'SalesforceNIS',
                            feedbackStatus , //oportunidad.CSBD_Estado__c,
                            'AEP'
                        ),
                        new CSBD_CALL_WS_Adobe_DTO.MessageExclusionObjDTO(
                            '',
                            ''
                        ),
                        new CSBD_CALL_WS_Adobe_DTO.MessageExecutionObjDTO(
                            '',
                            '',
                            oportunidad.CSBD_CampaignId__c,
                            '',
                            oportunidad.CSBD_JourneyActionId__c,
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            'marketing'
                        ),
                        new CSBD_CALL_WS_Adobe_DTO.MessageFailureObjDTO(
                            'sync',
                            '',
                            ''
                        ),
                        new CSBD_CALL_WS_Adobe_DTO.MessageProfileObjDTO(
                            '',
                            false,
                            false,
                            false,
                            oportunidad.CSBD_MessageProfileId__c,
                            oportunidad.CSBD_Now_NUMPERSO__c
                        )
                    ),
                    oportunidad.Id + '_' + System.currentTimeMillis(),
                    '',
                    'delivery.feedback',
                    new CSBD_CALL_WS_Adobe_DTO.NumperDTO(
                        new List<CSBD_CALL_WS_Adobe_DTO.NumperInfoDTO>{
                            new CSBD_CALL_WS_Adobe_DTO.NumperInfoDTO(
                                'authenticated',
                                oportunidad.CSBD_Now_NUMPERSO__c,
                                true
                            )
                        }
                    ),
                    'self',
                    now.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
                )
            )
        );

        //Wrapper FWK Integraciones
        CBK_HttpServiceIntegration.RequestWapper httpRequestWrapper = new CBK_HttpServiceIntegration.RequestWapper();
        httpRequestWrapper.body = JSON.serialize(req).replace('v_caixa', '_caixa').replace('v_id', '_id');
        httpRequestWrapper.intSetting = 'CSBD_WS_Adobe';
        httpRequestWrapper.mHeaders = new Map<String, String>{ //URI params de la llamada
            'x-absis-auto-profile' => 'CBK;OFFICE',
            //'x-api-actor-simulated' => 'CBCCSF',
            'x-absis-customer-context' => '{"customerInternalId":"43242342"}'
        };
        httpRequestWrapper.mUriParams = new Map<String, String>{ //URI params de la llamada
            'PARAMS_1' => 'tech',
            'PARAMS_2' => 'adocdp',
            'PARAMS_3' => 'collection',
            'PARAMS_4' => '970ddfea277bc1b1f534b79d5b8fa8bcdf73be80a2a20471df0360d565894e1e'
        };
        httpRequestWrapper.mQueryParams = new Map<String, String>();
        System.debug('httpRequestWrapper.mQueryParams:::: '+httpRequestWrapper.mQueryParams);

        return httpRequestWrapper;
    }

    private class CustomException extends Exception {}
}