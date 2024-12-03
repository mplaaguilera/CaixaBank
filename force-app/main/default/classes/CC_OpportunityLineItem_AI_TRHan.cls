public class CC_OpportunityLineItem_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<OpportunityLineItem>)tp.newList, (Map<Id, OpportunityLineItem>)tp.newMap);
    }

    public void process(List<OpportunityLineItem> listNewObj, Map<Id, OpportunityLineItem> mapNewObj) {
        filtroCSBD(listNewObj);
    }

    public static void filtroCSBD(List<OpportunityLineItem> listNewObj) {
        //Creamos un nuevo set e iteramos en toda la lista que nos trae la función, con su objeto OportunidadLineItem sacamos las OportunidadID's y las introducimos en el set.
        Set<Id> idOportunidadEnLineItems = new Set<Id>();
        Set<Id> idEnLineItemsFiltrados = new Set<Id>();
        for(OpportunityLineItem cadaOportunidadLineItem : listNewObj){
            if(cadaOportunidadLineItem.ServiceDate == null){
                idOportunidadEnLineItems.add(cadaOportunidadLineItem.OpportunityId);
                idEnLineItemsFiltrados.add(cadaOportunidadLineItem.Id);
            }
        }

        //Hacemos una Query en el Objeto Oportunidad en el que las ID's sean igual a las OportunidadID's del set anterior y verificamos que el DeveloperName
        //empiece por CSBD. Nos guardaremos solo las ID's de Oportunidad y las pondremos en un nuevo set.
        List<Opportunity> totalOportunidadesCSBD =  new List<Opportunity>([SELECT Id FROM Opportunity WHERE Id IN :idOportunidadEnLineItems AND RecordType.DeveloperName LIKE 'CSBD_%']);
        Set<Id> totalIdOportunidadesCSBD = new Set<Id>();
        for(Opportunity cadaOportunidadCSBD : totalOportunidadesCSBD){
            totalIdOportunidadesCSBD.add(cadaOportunidadCSBD.Id);
        }
        if(!totalIdOportunidadesCSBD.isEmpty()) {
            inicializarCamposOportunidad(totalIdOportunidadesCSBD, idEnLineItemsFiltrados);
        }
    }

    public static void inicializarCamposOportunidad(Set<Id> totalIdOportunidadesCSBD, Set<Id> idEnLineItemsFiltrados) {
        //Iteraremos sobre la lista de todas las OportunidadLineItems y compararemos sus ID's con las ID's de Oportunidad filtradas en el set.
        //Así podremos encontrar las coincidencias de los LineItems que empiezan por CSBD. Seguidamente actualizamos el campo ServiceDate con la fecha actual.
        List<OpportunityLineItem> totalOportunidadesLineItemCSBD = new List<OpportunityLineItem>([SELECT Id, ServiceDate, Name, OpportunityId FROM OpportunityLineItem WHERE Id IN :idEnLineItemsFiltrados]);
        for (OpportunityLineItem cadaOportunidadLineItem : totalOportunidadesLineItemCSBD) {
            for(Id cadaIdDeOportunidadCSBD : totalIdOportunidadesCSBD){
                if(cadaOportunidadLineItem.OpportunityId == cadaIdDeOportunidadCSBD){
                    cadaOportunidadLineItem.ServiceDate = System.today();
                }
            }
        }
        update totalOportunidadesLineItemCSBD;
    }
}