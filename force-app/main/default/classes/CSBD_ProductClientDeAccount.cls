/*****************************************************************
 * Name: CSBD_ProductClientDeAccount
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Buscar los Objetos que contienen la información de los productos contratados por el cliente
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       01/08/24     Creación
*****************************************************************/
/**
 * @description     clase invocable para Buscar los Objetos que contienen la información de los productos contratados por el cliente
 */
public with sharing class CSBD_ProductClientDeAccount {
    @InvocableMethod(label='Buscar los AV_ProductClient de un Account'
    description='Buscar los Objetos que contienen la información de los productos contratados por el cliente'
    CapabilityType='PromptTemplateType://einstein_gpt__recordSummary')
    public static List<Response> buscarProductClient(List<Request> requests) {
        // validate the expected number of requests as an input
        if (requests.size() != 1){
            throw new ListException('The requests list must contain one entry only');
        }
        Opportunity opo = requests[0].objectToSummarize;
        string responseData = '';
        Id clienteOpo = opo.AccountId;
        if (clienteOpo != null){
            List<AV_ProductClient__c> listaProductosCliente = [SELECT AV_Cliente__c, AV_PFName__c, tolabel(AV_TenenciaProducto__c), AV_MyBox__c
                                                    FROM AV_ProductClient__c  WHERE AV_Cliente__c = :clienteOpo WITH SECURITY_ENFORCED];
                                                    
            if(listaProductosCliente.isEmpty()) {
                responseData += 'No se han encontrado productos relacionados con el cliente.';
            } else {
                ProductosCliente conjuntoPC = new ProductosCliente();
                conjuntoPC.productos = new list<DatosProductoCliente>();
                for(AV_ProductClient__c pc : listaProductosCliente) {
                    DatosProductoCliente datosPC = new DatosProductoCliente();
                    datosPC.nombreProducto = pc.AV_PFName__c;
                    datosPC.tenenciaProducto = pc.AV_TenenciaProducto__c;
                    //si es MyBox, AV_MyBox__c contiene el codigo para crear una imagen, mejor que solo ponga 'Si'
                    String esMyBox = (pc.AV_MyBox__c == 'No') ? 'No' : 'Si';
                    datosPC.myBox = esMyBox;

                    conjuntoPC.productos.add(datosPC);

                    // responseData += 'Datos del cliente con el producto ' + pc.AV_PFName__c + ':/n';
                    // responseData += pc.AV_TenenciaProducto__c + '/n';
                    // //si es MyBox, AV_MyBox__c contiene el codigo para crear una imagen, mejor que solo ponga 'Si'
                    // String esMyBox = (pc.AV_MyBox__c == 'No') ? 'No' : 'Si';
                    // responseData += '¿Producto MyBox?: ' + esMyBox + '/n';
                }
                responseData += JSON.serialize(conjuntoPC);
            }
        }
        else {
            responseData += 'No hay un Account en la oportunidad.';
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

    public class ProductosCliente {
        list<DatosProductoCliente> productos;
    }

    public class DatosProductoCliente {
        string nombreProducto;
        string tenenciaProducto;
        string myBox;
    }
}