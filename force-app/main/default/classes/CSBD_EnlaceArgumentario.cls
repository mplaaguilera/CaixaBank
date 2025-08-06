/*****************************************************************
 * Name: CSBD_EnlaceArgumentario
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Buscar los enlaces argumentario del producto asociado a la oportunidad
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       01/08/24     Creación
*****************************************************************/
/**
 * @description     clase invocable para Buscar los enlaces argumentario del producto asociado a la oportunidad
 */
public with sharing class CSBD_EnlaceArgumentario {
    @InvocableMethod(label='Buscar enlaces argumentario producto'
        description='Buscar los enlaces argumentario del producto asociado a la oportunidad '
        CapabilityType='PromptTemplateType://einstein_gpt__recordSummary')
    public static List<Response> buscarEnlaces(List<Request> requests) {
          // validate the expected number of requests as an input
        if (requests.size() != 1){
              throw new ListException('The requests list must contain one entry only');
        }
        Opportunity opo = requests[0].objectToSummarize;
        string responseData = '';
          //segun CSBD_WS_AltaOportunidad_Campos.informarEmpresaFamiliaProducto se tendria que poner el nombre del producto 
          //en CSBD_Producto__c
        String casteoNombreProd = opo.CSBD_Producto__c;
          //buscar enlace de argumentario 
          //simulando CSBD_Enlaces_Soporte_Digital_Controller
        if (casteoNombreProd != null){
          List<CC_Lista_Valores__c> valores = [SELECT Name, CSBD_Soporte_Digital_Ficha_Producto__c, CSBD_Soporte_Digital_Argumentario__c,
                                                    CSBD_Soporte_Digital_Campanyas__c, CSBD_Soporte_Digital_Material_Apoyo__c,
                                                    CSBD_Soporte_Digital_Origen__c
                                                    FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CSBD: Enlaces de soporte digital'
                                                    AND Name IN :(new List<String>{opo.CSBD_Producto__c, opo.CSBD_Now_Origen__c})
                                                    WITH SECURITY_ENFORCED];
          if(valores.isEmpty()) {
              responseData += 'No se han encontrado enlaces relacionados con ese producto.';
          } else {
              for(CC_Lista_Valores__c lv : valores) {
                  if (lv.CSBD_Soporte_Digital_Argumentario__c != null){
                      responseData += 'Enlace de argumentario de ' + lv.Name + ':/n';
                      responseData += lv.CSBD_Soporte_Digital_Argumentario__c + '/n';
                  }
              }
          }
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