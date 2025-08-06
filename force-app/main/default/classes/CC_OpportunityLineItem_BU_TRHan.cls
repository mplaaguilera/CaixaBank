public with sharing class CC_OpportunityLineItem_BU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<OpportunityLineItem>)tp.newList, (Map<Id, OpportunityLineItem>)tp.newMap);
    }
    
    private void process(List<OpportunityLineItem> listNewObj, Map<Id, OpportunityLineItem> mapNewObj) {
        filtroCSBD(listNewObj);
    }

    private void filtroCSBD(List<OpportunityLineItem> listNewObj) {
        //Crea un nuevo set en el que incluye todas las Oportunidad ID's del objeto OportunidadLineItem mediante iterar el objeto principal de la función.
        Set<Id> idOportunidadEnLineItems = new Set<Id>();
        for(OpportunityLineItem cadaOportunidadLineItem : listNewObj){
            idOportunidadEnLineItems.add(cadaOportunidadLineItem.OpportunityId);
        }

        //Guarda en una lista de objetos Oportunidad toda una Query en la que filtra su DeveloperName = CSBD_ y que su ID sea igual a la de las ID's del anterior set
        //Volvemos a iterar y guardamos las ID's del objeto Oportunidad en otro nuevo set que hemos creado, ahora tenemos las ID's tanto de las Oportunidades como 
        //de las OportunidadesLineItems, aparte de los objetos completos de Oportunidad, todos filtrados con las condiciones pedidas.
        List<Opportunity> soloOportunidadesCSBD = new List<Opportunity>([SELECT RecordTypeId, Name, Id, CSBD_Importe_Producto_Principal__c FROM Opportunity WHERE Id IN :idOportunidadEnLineItems AND RecordType.DeveloperName LIKE 'CSBD_%']);
        Set<Id> idOportunidadEnOportunidades = new Set<Id>();
        for(Opportunity cadaOportunidadDeLaQuery : soloOportunidadesCSBD){
            idOportunidadEnOportunidades.add(cadaOportunidadDeLaQuery.Id);
        }

        //Creamos un map y una lista de objetos OportunidadLineItem, ambos vacíos, los usaremos en el siguiente paso.
        Map<Id, List<OpportunityLineItem>> MapdeIdDeOportunidadYLineItems = new Map<Id, List<OpportunityLineItem>>();
        List<OpportunityLineItem> todosLosLineItemsDeUnaIdDeOportunidad = new List<OpportunityLineItem>();

        //Iteramos sobre el objeto que nos dió la función y por cada una de sus posiciones buscaremos si nuestro set de ID's del objeto Oportunidad contiene la ID
        //de cada LineItem, si es así verificaremos si nuestro map del paso anterior ya contenia un key con esa ID. Si es asi obtendremos la lista con un get y con 
        //un add añadiremos otro objeto más a su lista, en caso de que no usaremos un put para añadir una lista vacía y su nueva ID.
        for(OpportunityLineItem cadaOportunidadLineItem : listNewObj){
            if(idOportunidadEnOportunidades.contains(cadaOportunidadLineItem.OpportunityId)){
                if(!MapdeIdDeOportunidadYLineItems.containsKey(cadaOportunidadLineItem.OpportunityId)){
                    MapdeIdDeOportunidadYLineItems.put(cadaOportunidadLineItem.OpportunityId, new List<OpportunityLineItem>());
                }
                todosLosLineItemsDeUnaIdDeOportunidad = MapdeIdDeOportunidadYLineItems.get(cadaOportunidadLineItem.OpportunityId);
                todosLosLineItemsDeUnaIdDeOportunidad.add(cadaOportunidadLineItem);
            }
        }

        //Confirmamos que el map tenga contenido para enviarlo de la mano de la lista de objetos Oportunidad,
        //asi tendremos ambos objetos filtrados para su próximo tratamiento.
        if(!MapdeIdDeOportunidadYLineItems.isEmpty()) {
            actualizaImporteProductoPrincipal(MapdeIdDeOportunidadYLineItems, soloOportunidadesCSBD);
        }
    }

    private void actualizaImporteProductoPrincipal(Map<Id, List<OpportunityLineItem>> MapdeIdDeOportunidadYLineItems, List<Opportunity> soloOportunidadesCSBD) {
        //Iteraremos la lista de objetos Oportunidad y con esas ID's usaremos el método get del map, este nos consigue la información mediante su key,
        //que es justo la que tenemos con la ID de Oportunidad, confirmaremos que CSBD_Producto_Principal__c de Oportunidad sea TRUE y entonces
        //sobreescribimos el campo CSBD_Importe_Producto_Principal__c de Oportunidad por el TotalPrice de su LineItem. 
        //Enviaremos todas las oportunidades que van a ser actualizadas a la nueva lista oportunidadesParaActualizar y con su update se actualizará correctamente.
        List<Opportunity> oportunidadesParaActualizar = new List<Opportunity>();
        for (Opportunity cadaOportunidadCSBD : soloOportunidadesCSBD){
            List<OpportunityLineItem> soloOportunidadesCSBDEnlineItems = MapdeIdDeOportunidadYLineItems.get(cadaOportunidadCSBD.Id);
            for (OpportunityLineItem cadaOportunidadCSBDEnLineItem: soloOportunidadesCSBDEnlineItems){
                if (cadaOportunidadCSBDEnLineItem.CSBD_Producto_Principal__c == true){
                    cadaOportunidadCSBD.CSBD_Importe_Producto_Principal__c = cadaOportunidadCSBDEnLineItem.Subtotal;
                    oportunidadesParaActualizar.add(cadaOportunidadCSBD);
                }
            }
        }
        update oportunidadesParaActualizar;
    }
}