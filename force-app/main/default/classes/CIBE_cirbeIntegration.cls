/**********************************************************************************************************************
Name:	  CIBE_cirbeIntegration
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración hacia CIRBE y generación de la PEA. Esta clase será llamada se usa para pintar los datos en el 
LWC virtualizado cibe_cirbeView
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US559793         Alexandre Perez                19-07-2023     Created
    *****************************************************************/
public with sharing class CIBE_cirbeIntegration {
    
    
    public class ResponseData{
        @AuraEnabled
        public String noticeTextOut;	//Reports error code: OK or NOK from ADS
        @AuraEnabled
        public GeneralData GeneralData;
        @AuraEnabled
        public DirectRiskData DirectRiskData;
        @AuraEnabled
        public IndirectRiskData IndirectRiskData;
        @AuraEnabled
        public DetailDataOthers DetailDataOthers;
        @AuraEnabled
        public EvolutionDataCLI EvolutionDataCLI;
        @AuraEnabled
        public String reposit;	//S
        @AuraEnabled
        public String indReqExternalRisk;	//E
        @AuraEnabled
        public String indPerRequestExternRisk;	//AD111111111
        @AuraEnabled
        public Integer executionOfi;	//9712
        @AuraEnabled
        public String executionDate;	//2020-10-26T00:00:00.000Z
        @AuraEnabled
        public Integer executionState;	//1
        @AuraEnabled
        public String hourRequest;	//091003
        @AuraEnabled
        public String applicationDateRequest;//2022-10-24T00:00:00.000Z
    }

        
    public   class GeneralData {
        @AuraEnabled
        public List<NoticeList> NoticeList;
        @AuraEnabled
        public String dataHolderName;	//CAJA BARRERA GARCIA
        @AuraEnabled
        public String organizationName;	//Grupo CaixaBank
        @AuraEnabled
        public String customerIdType;	//NVVMNGECQPJ
        @AuraEnabled
        public Integer customerInternalId;	//25188118
        @AuraEnabled
        public String CIRBEcode;	//AD111111111
        @AuraEnabled
        public String holderIdentifier;	//AD111111111
        @AuraEnabled
        public String dateDataRequest;	//2020-10-24T00:00:00.000Z
        @AuraEnabled
        public String statementDate;	//2018-08-01T00:00:00.000Z
        @AuraEnabled
        public String returnDate;	//2018-07-01T00:00:00.000Z
        }
        public   class NoticeList {
            @AuraEnabled
            public String noticeItem;	//Other entities: data retained due to NIF error
    }
     public class DirectRiskData {
        @AuraEnabled
        public String typeRisk;	//Riesgo directo
        @AuraEnabled
        public String indShowTable;	//S
        @AuraEnabled
        public List<dataTableDirectRisk> dataTableDirectRisk;
    }
    public class DataTableDirectRisk {
        @AuraEnabled
        public String litDirectRisk;	//Comercial
        @AuraEnabled
        public String processOption;	//CO
        @AuraEnabled
        public String amountAvailableCom;	//20
        @AuraEnabled
        public String amountArrangedCom;	//20
        @AuraEnabled
        public String amountNPLrateCom;	//10
        @AuraEnabled
        public String ownArrangedPercentage;	//2
        @AuraEnabled
        public String NPLrateCom;	//8
        @AuraEnabled
        public String amountArrangedGroup;	//5
        @AuraEnabled
        public String amountAvailableGroup;	//3
        @AuraEnabled
        public String amountNPLGroup;	//10
        @AuraEnabled
        public String NPLGroup;	//2
        @AuraEnabled
        public String amountArrangedEntities;	//303
        @AuraEnabled
        public String amountAvailableEntities;	//309
        @AuraEnabled
        public String percentageArrangedEntities;	//49
        @AuraEnabled
        public String NPLothers;	//SI
        @AuraEnabled
        public String indAvailableQuota;	//S
        @AuraEnabled
        public String arrangedFeeCaixa;	//1
        @AuraEnabled
        public String indTotalQuota;	//S
        @AuraEnabled
        public String totalFee;	//10
        @AuraEnabled
        public String indActions;	//NNNNN
    }
    public class IndirectRiskData {
        @AuraEnabled
        public String indShowTable;	//S
        @AuraEnabled
        public List<DataTableIndirectRisk> DataTableIndirectRisk;
    }
    public class DataTableIndirectRisk {
        @AuraEnabled
        public String litIndirectRisk;	//Avalistas
        @AuraEnabled
        public String processOption;	//CO
        @AuraEnabled
        public String amountArrangedIndirectRisk;	//12
        @AuraEnabled
        public String amountAvailableIndirectRisk;	//3
        @AuraEnabled
        public String amountNPLindirectRisk;	//10
        @AuraEnabled
        public String NPLindIndirectRisk;	//4
        @AuraEnabled
        public String amountArrangedIndirectRiskGroup;	//10
        @AuraEnabled
        public String amountAvailableIndirectRiskOtherCom;	//5
        @AuraEnabled
        public String amountNPLndirectRiskOtherCom;	//15
        @AuraEnabled
        public String amountNPLIndirectRiskGroup;	//30
        @AuraEnabled
        public String amountArrangedIndirectRiskOtherEnt;	//12
        @AuraEnabled
        public String amountAvailableIndirectRiskOtherEnt;	//3
        @AuraEnabled
        public String amountNPLIndirectRiskOtherEnt;	//1
        @AuraEnabled
        public String indNPLIndirectRiskGroup;	//SSNNN
        @AuraEnabled
        public String indTotalQuota;	//S
        @AuraEnabled
        public String totalFee;	//10
        @AuraEnabled
        public String indActions;	//NNNNN
    }
    public    class DetailDataOthers {
        @AuraEnabled
        public String indShowTableValues;	//S
        @AuraEnabled
        public String indShowTableOthers;	//S
        @AuraEnabled
        public List<TableRiskDataOthers> TableRiskDataOthers;
    }
    public class TableRiskDataOthers {
        @AuraEnabled
        public String litRiskOthers;	//Avalistas
        @AuraEnabled
        public String optionProcess;	//PA
        @AuraEnabled
        public String amountArragedCom;	//12
        @AuraEnabled
        public String amountAvailableCom;	//4
        @AuraEnabled
        public String amountNPLCom;	//0
        @AuraEnabled
        public String ownArrangedPercentage;	//5
        @AuraEnabled
        public String indNPLCom;	//3
        @AuraEnabled
        public String amountArrangedGroup;	//0
        @AuraEnabled
        public String amountAvailableGroup;	//2
        @AuraEnabled
        public String amountNPLGroup;	//10
        @AuraEnabled
        public String indNPLGroup;	//1
        @AuraEnabled
        public String amountArrangedOtherEnt;	//6
        @AuraEnabled
        public String amountAvailableOtherEnt;	//10
        @AuraEnabled
        public String amountNPLOtherEnt;	//15
        @AuraEnabled
        public String percentageArrangedOthersEnt;	//0
        @AuraEnabled
        public String indNPLOtherEnt;	//10
        @AuraEnabled
        public String indArrangedFeeData;	//N
        @AuraEnabled
        public String arrangedFeeCaixa;	//2
        @AuraEnabled
        public String indTotalQuota;	//S
        @AuraEnabled
        public String totalFeeCaixa;	//0
        @AuraEnabled
        public String indActions;	//SSNNN
    }
    public class EvolutionDataCLI {
        @AuraEnabled
        public String indEvolutionAvailableData;	//S
        @AuraEnabled
        public String indIndirectRiskData;	//S
        @AuraEnabled
        public List<EvolutionDataTableDirectRisk> EvolutionDataTableDirectRisk;
        @AuraEnabled
        public List<EvolutionDataTableIndirectRisk> EvolutionDataTableIndirectRisk;
    }
    public class EvolutionDataTableDirectRisk {
        @AuraEnabled
        public String declarationDate;	//2020-10-24T00:00:00.000Z
        @AuraEnabled
        public Integer requestData;	//201808
        @AuraEnabled
        public String arrangedOwnRisk;	//1.516
        @AuraEnabled
        public String arrangedOwnRiskGroup;	//4
        @AuraEnabled
        public String arrangedOtherEnt;	//10
        @AuraEnabled
        public String availableOwnRisk;	//323
        @AuraEnabled
        public String availableGroup;	//100
        @AuraEnabled
        public String availableOtherEnt;	//10
        @AuraEnabled
        public String amountOwnDefaulter;	//15
        @AuraEnabled
        public String amountOwnDefaulterGroup;	//5
        @AuraEnabled
        public String amountOwnDefaulterOtherEnt;	//200
    }
    public class EvolutionDataTableIndirectRisk {
        @AuraEnabled
        public String declarationDate;	//2020-10-24T00:00:00.000Z
        @AuraEnabled
        public Integer requestData;	//50
        @AuraEnabled
        public String amountOwnIndirect;	//30
        @AuraEnabled
        public String amountIndirectRiskGroup;	//5
        @AuraEnabled
        public String amountIndirectRiskOtherEnt;	//2
        @AuraEnabled
        public String amountOwnNPL;	//1
        @AuraEnabled
        public String amountNPLGroup;	//10
        @AuraEnabled
        public String amountNPLOtherEnt;	//15
    }

       // @AuraEnabled
    /*****************************************************************   
    * Proposito:  Obtención del Record Id desde el componente LWC y preparación de la llamada                                                           
    Parameters: [Id recordId]   
    Returns: [ public class ResponseData]   
    Throws [Exceptions]: [optional] en caso de error de llamada, código o falta de datos                                                        
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US559793         Alexandre Perez                19-07-2023     Created
    *****************************************************************/
	@AuraEnabled
	public static ResponseData getCirbeRisk(Id recordId) {

        Account acc = new Account();
        map<string, object> fieldsToUpdate = new map<string, object>();
        ResponseData respData;
        string sError = '';
       
		if (recordId != null) {
            try {
                acc = [SELECT CC_Numero_Documento__c, CIBE_FechaRefrescoCirbe__c, CIBE_JsonCIRBE__c
                                FROM Account Where Id = :recordId LIMIT 1];

                if(acc.CC_Numero_Documento__c != null) {

                    if(acc.CIBE_FechaRefrescoCirbe__c == null || CIBE_APPUtilities.calculateTimeDifferences(acc.CIBE_FechaRefrescoCirbe__c, dateTime.now()) > 24){

                        Map<String,string> mHeaders =  new  Map<String,string>();
                        CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues('CIBE_getCirbe');
                        //si detecta que usamos la name credential del camaleon le metemos su cabecera
                        if(wsc?.NamedCredential__c.contains('CAMALEON')){
                            mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
                        }
                        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                        string body = '{"accessType":1,"customerId":"[DOCUMENTO]","riskType":"DI","language":"02","customerInternalId":null,"CIRBEcode":null,"applicationDate":null,"outputType":"CL","terminalId":""}';
                        body = body.replace('[DOCUMENTO]', acc.CC_Numero_Documento__c);

                        system.debug(body);
                        HttpRequest req = CBK_HttpServiceIntegration.getRequest(body, 'CIBE_getCirbe', 'POST', mHeaders);
                        HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req);
                        system.debug(res);
                        system.debug(res.getBody());
                        if(res.getStatusCode() == 200) {
                            respData = (ResponseData)JSON.deserialize(res.getBody(),ResponseData.class);
                            system.debug(respData);
                            if(res.getBody().length() <= 131072 && string.isBlank(respData.noticeTextOut)){
                                fieldsToUpdate.put('Id',recordId);
                                if(res.getBody().length() <= 131072){
                                    fieldsToUpdate.put('CIBE_FechaRefrescoCirbe__c',dateTime.now());
                                    fieldsToUpdate.put('CIBE_JSONCIRBE__c', res.getBody());
                                    
                                }
                                integer cirbe = 0;
                                for(DataTableDirectRisk dtdr : respData.directRiskData.dataTableDirectRisk) {
                                    if(dtdr.litDirectRisk == 'Total directos') {
                                        cirbe = integer.valueOf(dtdr.arrangedFeeCaixa);
                                    }
                                }
                                fieldsToUpdate.put('CIBE_CIRBE__c',cirbe);
                                sError = CIBE_IntegrationUtilities.updateObject(fieldsToUpdate, 'Account');
                                if(!string.isBlank(sError)){
                                    cbk_log.error(sError);
                                }
                            } else if(!string.isBlank(respData.noticeTextOut)) {
                                sError = respData.noticeTextOut;
                            }
                        } else {
                            sError = 'AccountId: ' + recordId + '. Response Error: ' + res.getStatusCode() + ' ' + res.getBody();
                            //quitar el cbk log cuando el tratamiento de errores por status code funcione correctamente a nivel de fwk
                            cbk_log.error(sError);
                            sError = 'Fallo conexión CIRBE';

                        }
                    } else {
                        respData = (ResponseData)JSON.deserialize(acc.CIBE_JsonCIRBE__c,ResponseData.class);
                    }
                } else {
                    sError = 'El cliente no tiene documento';
                }
                
            }catch(Exception e){
                sError = 'Error al procesar los datos de la integración. Contacte con el administrador';
                cbk_log.error(e);
                system.debug(e.getMessage() + ' ' + e.getLineNumber());
            }
            system.debug('sError ' + string.isBlank(sError) );
            if(!string.isBlank(sError)){
                system.debug('sError ' + sError);
                throw new AuraHandledException(sError);
            }
        }
        return RespData;
    }

     /*****************************************************************   
    * Proposito:  Creación de PEA para CIRBE                                                        
    Parameters: [Id recordId]   
    Returns: [ string ]: url con la PEA   
    Throws [Exceptions]: [optional] en caso de error de llamada, código o falta de datos                                                        
    Historial
    --------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0             US559793          Alexandre Perez                02-08-2023     Created
    *****************************************************************/
    @AuraEnabled (cacheable=true)
    public static String getUrl(String recordId){
        //Inicializamos la variable
        CIBE_Link__mdt resultadoCMDT = CIBE_Link__mdt.getInstance('CIBE_Cirbe');
        String urlVacia = resultadoCMDT.CIBE_URL__c;
        String url = '';
        Account acc = new Account();
        try{    

            acc = [SELECT Id,Name,AV_NumPerso__c,CC_Numero_Documento__c, AV_OficinaPrincipal__r.CC_Numero_Empresa__c FROM Account WHERE Id = :recordId LIMIT 1];
            url = resultadoCMDT.CIBE_URL__C;
            url = url.replace('{numPersona}',acc.AV_NumPerso__c ).replace('{dni}',acc.CC_Numero_Documento__c).replace('{codEmpresa}', acc.AV_OficinaPrincipal__r.CC_Numero_Empresa__c);
                
        }
         catch(Exception e){
            System.debug('Error al intentar obtener los datos para generar la url' + e.getMessage());
            url = urlVacia;
         } 

        System.debug('URL a devolver: ' + url);

        return url;
    }  
}