/**********************************************************************************************************************
Name:	  CIBE_RAR_Integration
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integracion hacia el sistema de simulaciones RAR. Contiene la integración a dos diferentes endpoints para 
obtener una simulación concreta o un grupo de simulaciones.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US372933         Alexandre Perez                23-08-2023     Created
    *****************************************************************/
public with sharing class CIBE_RAR_Integration {

    public class SimulationResponse{
        @AuraEnabled   
        public RARResponse empresaResponse;
        @AuraEnabled   
        public RARGroupResponse grupoResponse;

    }
    
    public class ErrorResponse {
        @AuraEnabled 
        public string detail;
        @AuraEnabled 
        public string type;
        @AuraEnabled 
        public string title;
        @AuraEnabled 
        public integer status;
    }

    public class RARResponse{
        @AuraEnabled
        public integer simulationId;
        @AuraEnabled
        public SimulationOperationsProfitabilities simulationOperationsProfitabilities;//1,5
        @AuraEnabled
        public CustomerProfitability customerProfitability;//2
        @AuraEnabled
        public decimal pd;//3 por simulacion
        @AuraEnabled
        public decimal lgd;//4 por simulacion
        @AuraEnabled
        public list<Operations> operations;//7-18
        @AuraEnabled
        public PriceNote priceNote;//6
        @AuraEnabled
        public string operationNumber;//memoria operación elegida
        @AuraEnabled
        public string customerId;
        @AuraEnabled
        public string customerName;
        @AuraEnabled 
        public string ratingInt;//pd calculado (1)
    }

    public class RARGroupResponse{
        @AuraEnabled
        public integer groupSimulationId;
        @AuraEnabled
        public SimulationOperationsProfitabilities groupSimulationOperationsProfitabilities;//1
        @AuraEnabled
        public CustomerProfitability postGroupSimulationProfitability;//2
        @AuraEnabled
        public list<RARResponse> simulations;
        @AuraEnabled
        public string operationNumber;
        @AuraEnabled
        public integer simulationId;
    }

    public class SimulationOperationsProfitabilities {
        @AuraEnabled
        public decimal rar;//1
        @AuraEnabled
        public decimal netProfitability;//5
    }

    public class CustomerProfitability {
        @AuraEnabled
        public decimal groupPostRar;//2
    }

    public class PriceNote {
        @AuraEnabled
        public decimal commissions;//6
    }

    public class OperationsList {
        public list<Operations> operations;
    }

    public class Operations {
        @AuraEnabled
        public string operationNumber;//7
        @AuraEnabled
        public string productTypeName;//8
        @AuraEnabled
        public AmountPeriod amountPeriod; //9,10
        @AuraEnabled
        public Interest interest;//11,12
        @AuraEnabled
        public decimal studyCommission;//13
        @AuraEnabled
        public decimal openingCommission;//14
        @AuraEnabled
        public Profitability profitability;//15
        @AuraEnabled
        public list<Guarantees> guarantees;//16
        @AuraEnabled 
        public string description;
    }

    public class AmountPeriod {
        @AuraEnabled
        public decimal awardedAmount; //9
        @AuraEnabled
        public integer period; //10 si periodTypeCode = 2
        @AuraEnabled
        public date expirationDate; //10 si periodTypeCode = 1
        @AuraEnabled
        public integer periodTypeCode;
    }

    public class Interest {
        @AuraEnabled
        public decimal differential;//11
        @AuraEnabled
        public integer referenceIndex;//12
        @AuraEnabled
        public boolean hasWithoutFloorIndicator;//18
    }

    public class Profitability {
        @AuraEnabled
        public decimal rar;//15
        @AuraEnabled
        public decimal valueAdded;//17
    }

    public class Guarantees {
        @AuraEnabled
        public string guaranteeType;//16
        @AuraEnabled
        public string guaranteeName;//16
        @AuraEnabled
        public boolean isMainGuarantee;//16
    }

    /*****************************************************************   
    * Proposito:  Obtención del Record Id desde el componente LWC y preparación de la llamada                                                           
    Parameters: [Id recordId]   
    Returns: [ public class ResponseData]   
    Throws [Exceptions]: [optional] en caso de error de llamada, código o falta de datos                                                        
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US372933         Alexandre Perez                23/08/2023     Created
    1.1            IN1183650        Luis Martínez                  05/07/2024     Cambio body para llamar a la nueva version de la API.
    *****************************************************************/
	@AuraEnabled
	public static SimulationResponse getSimulation(string simulationId, string simulationType, Id recordId) {

        map<string, object> fieldsToUpdate = new map<string, object>();
        SimulationResponse simulationResponse = new SimulationResponse();

        string sError = '';
        string url;
        string body;

        try {

            Opportunity opp = [SELECT CIBE_RAROperationNumber__c, CIBE_JSONRAROperations__c, CIBE_Tipo_de_simulacion__c, CIBE_Numero_de_Simulador__c FROM Opportunity WHERE Id = : recordId];
            //si no hay json guardado, se pide refresco o hay cambios en el numero y el tipo de simulación, se hace el callout
            if(opp.CIBE_JSONRAROperations__c == null || simulationType == 'refrescar' || 
            string.valueOf(opp.CIBE_Numero_de_Simulador__c) != simulationId) {
                Map<String,string> mHeaders =  new  Map<String,string>();

                if (simulationType == 'refrescar' && opp.CIBE_Tipo_de_simulacion__c == 'Empresa'){
                        simulationType = 'CIBE_GetRARSimulation';
                    } else if (simulationType == 'refrescar' && opp.CIBE_Tipo_de_simulacion__c == 'Grupo'){
                        simulationType = 'CIBE_getRARSimuGroup';
                    }
                CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(simulationType);
                //si detecta que usamos la name credential del camaleon le metemos su cabecera
                if(wsc?.NamedCredential__c.contains('CAMALEON')){
                    mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
                }
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
                if(simulationType == 'CIBE_GetRARSimulation') {//Empresa
                    // body = '{"showPriceNote":true,"showOperations":true,"operationFilters":{"state":"ACTIVE"}}';
                    //cambio IN1183650 error calculadoras grupo
                    body = '{"showPriceNote":true,"showOperations":true,"operationFilters": {"isAssociate": true,"showStructuredOperations": true }}';

                } else {
                    // body = '{"showPriceNote":true,"showSimulations":true,"simulationFilters":{"showPriceNote":true,"showOperations":true}}';
                    //cambio IN1183650 error calculadoras grupo
                    body = '{"showPriceNote":true,"showSimulations":true,"simulationFilters":{"showPriceNote":true,"showOperations":true,"operationFilters": {"isAssociate": true,"showStructuredOperations": true }}}';
                }

                CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                        reqWrapper.body = body;
                        reqWrapper.intSetting = simulationType;
                        reqWrapper.method = 'POST';
                        reqWrapper.mHeaders =  mHeaders;
                        reqWrapper.mUriParams = new  Map<String,string>();
                        reqWrapper.mQueryParams = new  Map<String,string>();

                HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);
                url = req.getEndpoint().replace('{simulationId}', simulationId);
                req.setEndpoint(url);
                HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, simulationId, simulationType);

                if(res.getStatusCode() == 200) {
                    //limpiamos en caso de que hubiesen cambiado de simulacion
                    fieldsToUpdate.put('Id',recordId);
                    fieldsToUpdate.put('CIBE_Numero_de_Simulador__c', integer.valueOf(simulationId));
                    fieldsToUpdate.put('CIBE_RAROperationNumber__c', null);
                    fieldsToUpdate.put('CIBE_RARTipoOperacion__c', null);
                    fieldsToUpdate.put('CIBE_RARImporte__c', null);
                    fieldsToUpdate.put('CIBE_RARPlazoMeses__c', null);
                    fieldsToUpdate.put('CIBE_RARPlazoFecha__c', null);
                    fieldsToUpdate.put('CIBE_RARInteresDiferencial__c', null);
                    fieldsToUpdate.put('CIBE_RARIndiceReferencia__c', null);
                    fieldsToUpdate.put('CIBE_RARFloorindice__c', false);
                    fieldsToUpdate.put('CIBE_RARComisionApertura__c', null);
                    fieldsToUpdate.put('CIBE_ComisionSaldoMedio__c', null);
                    fieldsToUpdate.put('CIBE_RAROperacionRar__c', null);
                    fieldsToUpdate.put('CIBE_RARGarantias__c', null);
                    fieldsToUpdate.put('CIBE_VAOperacion__c', null);
                    fieldsToUpdate.put('CIBE_RARNomOperacion__c', null);
                    //INC RAR
                    fieldsToUpdate.put('CIBE_RARConjunto__c', null);
                    fieldsToUpdate.put('CIBE_RARPost__c', null);


                    //simulación empresa
                    if(simulationType == 'CIBE_GetRARSimulation'){
                        RARResponse respData = new RARResponse();
                        PriceNote pn = new PriceNote();
                        pn.commissions = null;
                        respData.priceNote = pn;
                        respData = (RARResponse)JSON.deserialize(res.getBody(),RARResponse.class);
                        list<RARResponse> rarlist = new list<RARResponse>();

                        rarlist.add(respData);
                        updateRatingPD(rarlist);
                        fieldsToUpdate.put('CIBE_Tipo_de_simulacion__c', 'Empresa');
                        fieldsToUpdate.put('CIBE_RARPD__c',respData.pd);
                        fieldsToUpdate.put('CIBE_RatingPD__c',respData.ratingInt);
                        fieldsToUpdate.put('CIBE_RARSeveridad__c',respData.lgd);

                        //comprobamos con los if que el objeto dentro de la jerarquía exista
                        if(respData.SimulationOperationsProfitabilities != null){
                            fieldsToUpdate.put('CIBE_RARConjunto__c',respData.SimulationOperationsProfitabilities.rar);
                        } else {
                            fieldsToUpdate.put('CIBE_RARConjunto__c',null);
                        }
                        if(respData.customerProfitability != null) {
                            fieldsToUpdate.put('CIBE_RARPost__c',respData.customerProfitability.groupPostRar);
                        } else {
                            fieldsToUpdate.put('CIBE_RARPost__c',null);
                        }
                        if(respData.SimulationOperationsProfitabilities != null){
                            fieldsToUpdate.put('CIBE_RARMargenDiario__c',respData.SimulationOperationsProfitabilities.netProfitability);
                        } else {
                            fieldsToUpdate.put('CIBE_RARMargenDiario__c',null);
                        }                
                        if(respData.priceNote != null) {
                            fieldsToUpdate.put('CIBE_RARComision12meses__c',respData.priceNote.commissions);
                        } else {
                            fieldsToUpdate.put('CIBE_RARComision12meses__c', null);
                        }    
                        string sResp = JSON.serialize(respData);
                        if(sResp.length() <= 131072){
                            fieldsToUpdate.put('CIBE_JSONRAROperations__c', sResp);
                        } else {
                            fieldsToUpdate.put('CIBE_JSONRAROperations__c', null);
                        }
                        
                        simulationResponse.empresaResponse = respData;
                    
                    } else {//simulacion grupo
                        RARGroupResponse respData = new RARGroupResponse();
                        respData = (RARGroupResponse)JSON.deserialize(res.getBody(),RARGroupResponse.class);
                        updateRatingPD(respData.simulations);
                        fieldsToUpdate.put('CIBE_Tipo_de_simulacion__c', 'Grupo');
                        if(respData.groupSimulationOperationsProfitabilities != null){
                            fieldsToUpdate.put('CIBE_RARConjunto__c',respData.groupSimulationOperationsProfitabilities.rar);
                        } else {
                            fieldsToUpdate.put('CIBE_RARConjunto__c',null);
                        }
                        if(respData.postGroupSimulationProfitability != null){
                            fieldsToUpdate.put('CIBE_RARPost__c',respData.postGroupSimulationProfitability.groupPostRar);
                        } else {
                            fieldsToUpdate.put('CIBE_RARPost__c',null); 
                        }
                        string sRespSimu = JSON.serialize(respData.simulations);
                        string sResp = JSON.serialize(respData);

                        if(sResp.length() <= 131072){
                            fieldsToUpdate.put('CIBE_JSONRAROperations__c', sResp);
                        } else {
                            fieldsToUpdate.put('CIBE_JSONRAROperations__c', null);
                        }
                        //limpiamos en caso de que hubiesen cambiado de simulación
                        fieldsToUpdate.put('CIBE_RARPD__c',null);
                        fieldsToUpdate.put('CIBE_RatingPD__c',null);
                        fieldsToUpdate.put('CIBE_RARSeveridad__c',null);
                        fieldsToUpdate.put('CIBE_RARMargenDiario__c',null);
                        fieldsToUpdate.put('CIBE_RARComision12meses__c',null);
                        simulationResponse.grupoResponse = respData;
                    }
                    
                    //versión en que borra los campos cuando se le pasan nulos
                    sError = CIBE_IntegrationUtilities.updateObjectNull(fieldsToUpdate, 'Opportunity');

                } else {

                    errorResponse respErr = (errorResponse)JSON.deserialize(res.getBody(),errorResponse.class);
                    sError = res.getStatusCode() + ' ' + respErr.detail;
                    //quitar el cbk log cuando el tratamiento de errores por status code funcione correctamente a nivel de fwk
                    cbk_log.error('SimulationId: ' + simulationId + '. Error: ' + sError);
                }
            //si la simulación ya fue cargada, se consulta el campo con el json que contiene las simulaciones/operaciones que se muestran en las tablas
            } else if(simulationType == 'CIBE_GetRARSimulation') {
                //empresa
                RARResponse empResponse = new RARResponse();
                empResponse = (RARResponse)JSON.deserialize(opp.CIBE_JSONRAROperations__c,RARResponse.class);
                list<RARResponse> paraRating = new list<RARResponse>();
                paraRating.add(empResponse);
                //S&P clasificación
                updateRatingPD(paraRating);
                simulationResponse.empresaResponse = empResponse;
                simulationResponse.empresaResponse.operationNumber = opp.CIBE_RAROperationNumber__c;

            } else {
                //grupo
                RARGroupResponse grupResponse = new RARGroupResponse();
                
                simulationResponse.grupoResponse = grupResponse;
                //Hacemos el cambio para pasar en el updateRatingPD solo la lista RARResponse
                list<RARResponse> simulationsList = new list<RARResponse>();
                RARGroupResponse respData = (RARGroupResponse)JSON.deserialize(opp.CIBE_JSONRAROperations__c,RARGroupResponse.class);

                simulationsList = respData.simulations;
                if(simulationsList!=null){
                    updateRatingPD(simulationsList);
                    for(RARResponse simulation : simulationsList){
                        for(operations operation : simulation.operations){
                            if(operation.operationNumber == opp.CIBE_RAROperationNumber__c){
                                simulationResponse.grupoResponse.operationNumber = opp.CIBE_RAROperationNumber__c;
                                break;
                            }
                        }
                        if(simulationResponse.grupoResponse.operationNumber != null){
                            simulationResponse.grupoResponse.simulationId = simulation.simulationId;
                            break;
                        }
                    }
                }
                if(simulationResponse!=null){
                    simulationResponse.grupoResponse.simulations = simulationsList;
                }               
            }
            

        }catch(Exception e){
            sError = label.CIBE_DefaultIntegrationError;
            cbk_log.error(e);
            system.debug(e.getMessage() + ' ' + e.getLineNumber());
        }
        if(!string.isBlank(sError)){
            throw new AuraHandledException(sError);
        }
        return SimulationResponse;
    }
    
    @AuraEnabled
    public static string saveOperation(string jSONop, Id recordId) {
        try{
        map<string, object> fieldsToUpdate = new map<string, object>();
        string sError;
        RARResponse operationData = new RARResponse();
        operationData = (RARResponse)JSON.deserialize(jSONop,RARResponse.class);
        fieldsToUpdate.put('CIBE_RAROperationNumber__c', operationData.operations[0].operationNumber);
        fieldsToUpdate.put('Id', recordId);
        fieldsToUpdate.put('CIBE_RARTipoOperacion__c', operationData.operations[0].productTypeName);
        fieldsToUpdate.put('CIBE_RARImporte__c', integer.valueof(operationData.operations[0].amountPeriod.awardedAmount));
        fieldsToUpdate.put('CIBE_RARPlazoMeses__c', operationData.operations[0].amountPeriod.period);
        fieldsToUpdate.put('CIBE_RARPlazoFecha__c', operationData.operations[0].amountPeriod.expirationDate);
        fieldsToUpdate.put('CIBE_RARInteresDiferencial__c', operationData.operations[0].interest.differential);
        fieldsToUpdate.put('CIBE_RARIndiceReferencia__c', operationData.operations[0].interest.referenceIndex);
        fieldsToUpdate.put('CIBE_RARFloorindice__c', operationData.operations[0].interest.hasWithoutFloorIndicator);
        fieldsToUpdate.put('CIBE_RARComisionApertura__c', operationData.operations[0].openingCommission);
        fieldsToUpdate.put('CIBE_ComisionSaldoMedio__c', operationData.operations[0].studyCommission);
        fieldsToUpdate.put('CIBE_RAROperacionRar__c', operationData.operations[0].profitability.rar);
        fieldsToUpdate.put('CIBE_RARGarantias__c', operationData.operations[0].guarantees[0].guaranteeName);
        fieldsToUpdate.put('CIBE_VAOperacion__c', operationData.operations[0].profitability.valueAdded);
        fieldsToUpdate.put('CIBE_RARNomOperacion__c', operationData.operations[0].description);
        if(operationData.simulationId != null){
            fieldsToUpdate.put('CIBE_RARPD__c',operationData.pd);
            fieldsToUpdate.put('CIBE_RatingPD__c',operationData.ratingInt);
            fieldsToUpdate.put('CIBE_RARSeveridad__c',operationData.lgd);
            fieldsToUpdate.put('CIBE_RARMargenDiario__c',operationData.SimulationOperationsProfitabilities.netProfitability);
            fieldsToUpdate.put('CIBE_RARComision12meses__c',operationData.priceNote.commissions);
        }
        sError = CIBE_IntegrationUtilities.updateObjectNull(fieldsToUpdate, 'Opportunity');
        return 'OK';
        }catch(DmlException e) {
            cbk_log.error(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static opportunity getSimulationId(Id recordId){
            Opportunity opp = [SELECT CIBE_Numero_de_Simulador__c, CIBE_RAROperationNumber__c, CIBE_Tipo_de_simulacion__c FROM Opportunity WHERE Id = : recordId];
            return opp;
    }

    /**
 * @param: recordId
 * @return: linkTf
 * @throws: AuraHandledException
 * 
*/
@AuraEnabled (cacheable=true)
public static String getUrl(String simulationId, string simulationType){
    //Inicializamos la variable
    CIBE_Link__mdt resultadoCMDT;
    if(simulationType == 'Empresa'){
        resultadoCMDT = CIBE_Link__mdt.getInstance('CIBE_RAREmpresa');
    } else if(simulationType == 'Grupo') {
        resultadoCMDT = CIBE_Link__mdt.getInstance('CIBE_RARGrupo');
    }

    String urlVacia = resultadoCMDT.CIBE_URL__c;
    String url = '';
    // Creamos un try catch para capturar los errores
    if(simulationId!=null){
        try{
            url = resultadoCMDT.CIBE_URL__C.replace('{simulationId}',simulationId );
            }
            catch(Exception e){
                System.debug('Error al intentar obtener los datos para generar la url' + e.getMessage());
                url = urlVacia;
            }
    }

        return url;
    }

/**
 * @param: List<RARResponse>
 * fucionalidad: devuelve la clasificación S&P según PD
 * 
 * 
*/
    public static void updateRatingPD(List<RARResponse> listNews) {
		//comprobar acceso a query
        decimal maxvalue = 0;
        decimal minvalue = 999.999;
		for(RARResponse ope : listNews){
            if(ope.pd != null){
                if(ope.pd < minvalue) {
                    minvalue = ope.pd;
                } 
                if (ope.pd > maxvalue) {
                    maxvalue = ope.pd;
                }
            }
		}
        List<CIBE_PD__c> listPD = new List<CIBE_PD__c>();
        if(
            CIBE_PD__c.SObjectType.getDescribe().isAccessible()&&
            Schema.SObjectType.CIBE_PD__c.fields.CIBE_PDRating__c.isAccessible()&&
            Schema.SObjectType.CIBE_PD__c.fields.CIBE_FechaCarga__c.isAccessible()&&
            Schema.SObjectType.CIBE_PD__c.fields.CIBE_PDMax__c.isAccessible()&&
            Schema.SObjectType.CIBE_PD__c.fields.CIBE_PDMin__c.isAccessible()
        ) {
            
            listPD = [select id, CIBE_PDRating__c,CIBE_FechaCarga__c, CIBE_PDMin__c, CIBE_PDMax__c from CIBE_PD__c where CIBE_PDMin__c <= :maxvalue and CIBE_PDMax__c>= :minvalue order by CIBE_PDMax__c desc];
        }
        if(!listPD.isEmpty()){
            for(RARResponse ope : listNews){
                if(ope.pd != null){
                    for(CIBE_PD__c pd : listPD){
                        if(ope.pd>=pd.CIBE_PDMin__c && ope.pd<=pd.CIBE_PDMax__c){
                            ope.ratingInt = '('+ pd.CIBE_PDRating__c + ')';
                            break;
                        }
                    }
                }else{
                    ope.ratingInt = null;
                }
            }
        }
	}
}