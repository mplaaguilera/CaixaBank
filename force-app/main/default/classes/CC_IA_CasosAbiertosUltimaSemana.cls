public with sharing class CC_IA_CasosAbiertosUltimaSemana {
    @InvocableMethod(
        label = 'Obtener Casos Cerrados Cliente'
        description = 'Obtiene el conteo de los casos cerrados del cliente filtrados por último mes y semana con el record type CC_Empleado'
        CapabilityType = 'PromptTemplateType://einstein_gpt__recordSummary'
    )
    public static List<Response> obtenerCasosAbiertos(List<Request> requests) {  
        Case caso = requests[0].objectToSummarize;
        String responseData = '';
        Id clienteId = caso.AccountId;
        String estado;
        Decimal dias;
        DateTime  diasAntiguedad;

        // Obtener la configuración del Custom Metadata
        CC_IA_UltimosCasos__mdt config = CC_IA_UltimosCasos__mdt.getInstance('Config');
        // Verificar que la configuración no sea nula y que el campo requerido esté presente
        if (config != null && !String.isBlank(config.CC_IA_Estado__c) && config.CC_IA_Dias_Antiguedad__c != 0) {
            estado = config.CC_IA_Estado__c;
            dias = config.CC_IA_Dias_Antiguedad__c;
            diasAntiguedad = System.now().addDays(-dias.intValue());
        } else {
            responseData = 'No se encontró la configuración necesaria para mostrar Resumen de casos';
        }

        if (clienteId != null) {
            // Realizar la consulta usando QueryWithBinds
            Map<String, Object> queryBinds = new Map<String, Object>{
                'accountId' => clienteId,
                'caseStatus' => estado,
                'days' => diasAntiguedad,
                'excludeId' => caso.Id
            };
             
            String query = 'SELECT ID, CC_MCC_Tematica__r.Name, CaseNumber, Subject ' +
                           'FROM Case ' +
                           'WHERE AccountId = :accountId ' +
                           'AND Status = :caseStatus ' +
                           'AND CreatedDate >= :days ' +
                           'AND ID != :excludeId' +
                           ' Limit 3';

            List<Case> casosCerradosSemana = Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE);
 
            // Construir el resumen de los casos cerrados
            responseData = 'Resumen de casos cerrados del cliente:\n';
 
            // Comprobar si hay casos cerrados en la última semana
            if (!casosCerradosSemana.isEmpty()) {
                for (Case c : casosCerradosSemana) {
                    responseData += 'ID: ' + c.Id + '\n';
                    responseData += 'Número de caso: ' + c.CaseNumber + '\n';
                    responseData += 'Temática: ' + c.CC_MCC_Tematica__r.Name + '\n';
                    responseData += 'Asunto: ' + c.Subject + '\n';
                    responseData += 'URL del caso: ' + c.Id + '\n';
                }
            } else {
                responseData += 'El cliente no tiene casos abiertos en la última semana.\n';
            }
        } else {
            responseData += 'El caso proporcionado no tiene un cliente asociado.\n';
        }
 
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.Prompt = responseData;
        responses.add(res);
        return responses;
    }
    public class Request {
        @InvocableVariable
        public Case objectToSummarize;
    }
    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}