/*****************************************************************
 * Name: CSBD_ArticulosProducto
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Buscar los articulos del producto asociado a la oportunidad
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       01/08/24     Creación
*****************************************************************/
/**
 * @description     clase invocable para Obtener los articulos del producto asociado a la oportunidad
 */
public with sharing class CSBD_ArticulosProducto {
    @InvocableMethod(label='Buscar articulos producto'
      description='Buscar los articulos del producto asociado a la oportunidad '
      CapabilityType='PromptTemplateType://einstein_gpt__recordSummary')
    public static List<Response> buscarArticulos(List<Request> requests) {
        // validate the expected number of requests as an input
        if (requests.size() != 1){
            throw new ListException('The requests list must contain one entry only');
        }
        Opportunity opo = requests[0].objectToSummarize;
        string responseData = '';
        //segun CSBD_WS_AltaOportunidad_Campos.informarEmpresaFamiliaProducto se tendria que poner el nombre del producto 
        //en CSBD_Producto__c
        String casteoNombreProd = opo.CSBD_Producto__c;
        if (casteoNombreProd != null){
            // List<Knowledge__kav> acticulosProducto =
            //      [SELECT Id, Title, Question__c, Answer__c, CSBD_NombresProductos__c
            //          FROM Knowledge__kav
            //          WHERE Title Like :casteoNombreProd]; 
            List<Knowledge__kav> acticulosProducto =
                [SELECT Id, Title, Question__c, Answer__c, CSBD_NombresProductos__c
                    FROM Knowledge__kav
                    WHERE CSBD_NombresProductos__c INCLUDES (:casteoNombreProd) AND PublishStatus = 'Online' WITH SECURITY_ENFORCED]; 
            if(acticulosProducto.isEmpty()) {
                responseData = 'No se han encontrado articulos relacionados con ese producto.';
            } else {
                // TodosArticulosProducto conjuntoArt = new TodosArticulosProducto();
                // conjuntoArt.articulos = new list<DatosArticulo>();
                for(Knowledge__kav k : acticulosProducto) {
                    // DatosArticulo datosArt = new DatosArticulo();
                    // datosArt.title = k.Title;
                    // datosArt.question = k.Question__c.stripHtmlTags();
                    // datosArt.answer = k.Answer__c.stripHtmlTags();
                    // datosArt.productos = k.CSBD_NombresProductos__c;

                    // conjuntoArt.articulos.add(datosArt);

                        //responseData += 'Detalles MyBox Auto :/n';

						responseData += 'Detalles ' + k.Title + ':/n';
                        //que solo se añada contenido a la response si el campo no es nulo
                        responseData += k.Question__c != null ? k.Question__c.stripHtmlTags()+'/n' : '';
                        responseData += k.Answer__c != null ? k.Answer__c.stripHtmlTags()+'/n' : '';
                }
                // responseData += JSON.serialize(conjuntoArt);
            }
        }
        else {
            responseData = 'No hay un producto en CSBD_Producto__c.';
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

    public class TodosArticulosProducto {
        list<DatosArticulo> articulos;
    }

    public class DatosArticulo {
        string title;
        string question;
        string answer;
        string productos;
    }
}