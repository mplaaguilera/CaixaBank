/*****************************************************************
 * Name: CSBD_OtrasOportunidadesSubset
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Buscar las otras oportunidades del cliente de una oportunidad, poniendo un limite de cantidad
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       01/08/24     Creación
*****************************************************************/
/**
 * @description     clase invocable para Buscar las otras oportunidades del cliente de una oportunidad, poniendo un limite de cantidad
 */
public with sharing class CSBD_OtrasOportunidadesSubset {
    @InvocableMethod(label='Buscar otras oportunidades de un cliente'
      description='Buscar las otras oportunidades del cliente de una oportunidad, poniendo un limite de cantidad'
      CapabilityType='PromptTemplateType://einstein_gpt__recordSummary')
    public static List<Response> buscarOportunidades(List<Request> requests) {
        // validate the expected number of requests as an input
        if (requests.size() != 1){
            throw new ListException('The requests list must contain one entry only');
        }
        Opportunity opo = requests[0].objectToSummarize;
        string responseData = '';
        Id clienteOpo = opo.AccountId;
        if (clienteOpo != null){
            Integer cantidadMax = 10;
            List<Opportunity> oportunidadesAccount = 
                [SELECT Id, Name, StageName, CloseDate, CSBD_Producto__c, Amount
                    FROM Opportunity
                    WHERE AccountId = :clienteOpo AND Id != :opo.Id WITH SECURITY_ENFORCED
                    ORDER BY CloseDate DESC 
                    LIMIT :cantidadMax];
            if(oportunidadesAccount.isEmpty()) {
                responseData += 'No se han encontrado otras oportunidades del cliente.';
            }
            else {
                OtrasOportunidades conjuntoOp = new OtrasOportunidades();
                conjuntoOp.oportunidades = new list<DatosOportunidad>();
                for(Opportunity op : oportunidadesAccount) {
                    DatosOportunidad datosOp = new DatosOportunidad();
                    datosOp.nombre = op.Name;
                    datosOp.etapa = op.StageName;
                    datosOp.fechaCierre = op.CloseDate;
                    datosOp.producto = op.CSBD_Producto__c;
                    datosOp.amount = op.Amount;

                    conjuntoOp.oportunidades.add(datosOp);
                }
                responseData += JSON.serialize(conjuntoOp);
            }
        }
        else{
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

    public class OtrasOportunidades {
        public list<DatosOportunidad> oportunidades;
    }

    public class DatosOportunidad {
        public string nombre;
        public string etapa;
        public Datetime fechaCierre;
        public string producto;
        public Decimal amount;
    }
}