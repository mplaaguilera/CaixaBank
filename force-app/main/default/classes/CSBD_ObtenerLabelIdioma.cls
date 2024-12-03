/*****************************************************************
 * Name: CSBD_ArticulosProducto
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Obtener el label con el nombre del idioma a partir del valor de la picklist que tiene el campo del cliente
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       01/08/24     Creación
*****************************************************************/
/**
 * @description     clase invocable para Obtener el label con el nombre del idioma a partir del valor de la picklist que tiene el campo del cliente
 */
public with sharing class CSBD_ObtenerLabelIdioma {
    @InvocableMethod(label='Obtener label del idioma del cliente'
      description='Obtener el label con el nombre del idioma a partir del valor de la picklist que tiene el campo del cliente'
      CapabilityType='PromptTemplateType://einstein_gpt__recordSummary')
    public static List<Response> obtenerLabelIdioma(List<Request> requests) {
        // validate the expected number of requests as an input
        if (requests.size() != 1){
            throw new ListException('The requests list must contain one entry only');
        }
        Opportunity opo = requests[0].objectToSummarize;
        string responseData = '';
        Id clienteOpo = opo.AccountId;
        if (clienteOpo != null){
            List<Account> datosCliente = [SELECT Id, toLabel(AV_Idioma__c)
                                            FROM Account
                                            WHERE Id = :clienteOpo  WITH SECURITY_ENFORCED
                                            LIMIT 1];
            if (datosCliente[0].AV_Idioma__c == null){
                responseData += '[Provide:{IDIOMA}]';
            }
            else{
                responseData += datosCliente[0].AV_Idioma__c;
            }
        }
        else{
            responseData += '[Provide:{CLIENTE}]';
        }
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.Prompt = responseData;
        responses.add(res);
        return responses;
    }

    public class Request {
        @InvocableVariable
        public Opportunity objectToSummarize;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}