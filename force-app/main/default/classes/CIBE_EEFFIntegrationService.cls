/**********************************************************************************************************************
Name:	  CIBE_EEFFIntegrationService
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración para obtener información de los Estados Financieros (EEFF). 
Esta clase completará información financiera dentro de la ficha del cliente.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------    
VERSION        USER_STORY       AUTHOR                         DATE           Description   
1.0            US454676         Borja Lavesiera                15-09-2023     Created
*****************************************************************/
public with sharing class CIBE_EEFFIntegrationService {
    
    public class ResponseData {
        
        public Summary summary;
        public SummaryRSE SummaryRSE;
        public List<Inconsistencies> Inconsistencies;
        public List<Inconsistencies> BalanceSheetInconsistencies;
        public List<Inconsistencies> IncomeStatementInconsistencies;
        public List<Inconsistencies> Warnings;
        public List<BalanceSheets> BalanceSheets;
        public List<Inconsistencies> SettlementSheets;
        public List<IncomeStatements> IncomeStatements;
        public List<Inconsistencies> Remnants;
        public List<Ratios> Ratios;
        public List<RatiosSE> RatiosSE;
        @AuraEnabled
        public String responseFromService;
    }
    public class summary {
        public FinancialStatement financialStatement; 
        public Integer nonCurrentAsset; 
        public Integer currentAsset; 
        public Integer totalAsset; 
        public Integer netWorth; 
        public Integer nonCurrentLiability; 
        public Integer currentLiability; 
        public Integer totalLiability; 
        public Integer sales; 
        public Integer balanceSheetResult; 
        public Integer resultIncomeStatement; 
        public Integer numberInhabitants;
    }
    public class FinancialStatement {
        public Integer stateId;
        public String personId;
        public Integer financialYear;
        public String type;
        public Integer numberDays;
        public Integer auditOpinion;
        public String units;
        public Integer numberEmployees;
        public String source;
        public Integer yearMonth;
        public String cnae;
        public String descriptionCnae;
        public String incoherent;
        public String balanceFlag;
        public String incomeStatementFlag;
        public Integer highDate;
        public String highHour;
        public Integer highOffice;
        public Integer highUser;
        public Integer modificationDate;
        public String modificationHour;
        public Integer modificationOffice;
        public Integer modificationUser;
        public String companyName;
        public String inactiveCompany;
        public String sourceCode;
    }
    public class SummaryRSE {
        public String year;
        public String size;
        public String cnaeDt;
        public String cnaeAlp;
        public String cnaeLit;
    }
    
    public class Ratios {
        public Integer financialYear;
        public String units;
        public List<RatioItems> RatioItems;
    }
    public class BalanceSheets {
        public Integer financialYear;
        public String inconsistencyFlag;
        public String units;
        public String cnae;
        public String descriptionCnae;
        public Integer numberDays;
        public Integer numberEmployees;
        public String source;
        public List<BalanceSheetItems> BalanceSheetItems;
    }
    
    public class Inconsistencies {
    }
    public class BalanceSheetItems {
        public String code;
        public Integer amount; 
        public String percentageFlag; 
        public Integer percentage;
    }
    public class IncomeStatements {
        public Integer financialYear;
        public String inconsistencyFlag;
        public String units;
        public List<BalanceSheetItems> IncomeStatementItems;
    }    
    public class RatioItems {
        public String code;
        public Integer amount;
        public String percentageFlag;
    }    
    public class RatiosSE {
    }
    
    public BalanceSheets BalanceSheets;
    
    @AuraEnabled
    public static ResponseData getCirbeEEFFdata(Id recordId) {
        ResponseData wrapper = new ResponseData();
        
        //Declaración variables 
        Account acc = new Account();
        ResponseData respData;
        Integer statementId = null;
        String tipoEeff = '';
        String tipoEeffDesc = '';
		Integer company = null;
        String sourceResp = '';
        String state = '';
        String classResp = '';
        String formatYearMonth = '';
        Integer personNumberId = null;
        String documentNumber = '';
        String documentType = '';
        string sError = '';
        List<Account> lstacc = new List<Account>();
        //Integer financialyear = FiscalYear();
        map<string, object> fieldsToUpdate = new map<string, object>();
        
        //Fechas
        Date fechaActual = Date.today();
        String stryear = string.valueOf(fechaActual.year());
        String strmonth = string.valueOf(fechaActual.month());
        String stryearmonth = stryear + strmonth;
        Integer yearmonth = integer.valueof(stryearmonth);
        Integer year = integer.valueof(stryear);
        
        
        
        if (recordId != null) {
            
            acc = [SELECT AV_Numperso__c, CC_Numero_Documento__c, CC_TipoDocumento__c, CIBE_FechaRefrescoEEFF__c, CIBE_JsonCIRBE__c
                   FROM account 
                   WHERE Id =:recordId LIMIT 1];
            
            if (acc.AV_Numperso__c!=null||acc.CC_Numero_Documento__c !=''||acc.CC_TipoDocumento__c!='') {
                personNumberId = Integer.valueOf(acc.AV_Numperso__c);
                documentNumber = acc.CC_Numero_Documento__c;
                documentType = acc.CC_TipoDocumento__c;
                if(acc.CIBE_FechaRefrescoEEFF__c == null || CIBE_APPUtilities.calculateTimeDifferences(acc.CIBE_FechaRefrescoEEFF__c, dateTime.now()) > 24) {
                    try {
                        Map<String,string> mHeaders =  new  Map<String,string>();
                        CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues('CIBE_getEeFF');
                        //CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues('CIBE_getEeFF_Mock');
                        //si detecta que usamos la name credential del camaleon le metemos su cabecera
                        if(wsc?.NamedCredential__c.contains('CAMALEON')){
                            mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
                        }
                        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
                        //Rellenamos el cuerpo de la petición para EEFF
                        string body = '{"action":"IN","numberRows":1,"customerId":"[CUSTOMERID]","customerIdType":"[DOCUMENTTYPE]","class":"LI","microBalance":"N"}';
                        body = body.replace('[CUSTOMERID]', documentNumber);
                        body = body.replace('[DOCUMENTTYPE]', documentType);
                        HttpRequest req = CBK_HttpServiceIntegration.getRequest(body, 'CIBE_getEeFF', 'POST', mHeaders);
                        HttpResponse res = CBK_HttpServiceIntegration.multiCallHttpService(req, recordId, 'CIBE_getEeFF');
                        //Log Response And Body
                        CBK_Log.debug('Respuesta' + res, logginglevel.DEBUG);
                        //Si nos da un 200 obtenemos los datos necesarios para solicitar la request "Details"
                        if (res.getStatusCode() == 200) {
                            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                            for(Object obj: (List<Object>)resBody.get('Settlements')) {
                                // the result of obj is JSON, so convert it to map
                                Map<String, Object> objMap = (Map<String, Object>) obj;
                                statementId = (Integer)objMap.get('stateId');
                                tipoEeff = (String)objMap.get('type');
                                company = (Integer)objMap.get('company');
                                sourceResp = (String)objMap.get('source');
                                state = (String)objMap.get('state');
                                classResp = (String)objMap.get('class');
                                
                            }
                            switch on tipoEeff {
                                    when 'AN' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Tipo_Auditado;
                                    }
                                    when 'AS' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Auditado_Salvedades;
                                    }
                                    when 'FI' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Tipo_Fiscal;
                                    }
                                    when 'RM' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Tipo_Registro_Mercantil;
                                    }
                                    when 'PR' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Tipo_Privado_Cerrado;
                                    }
                                    when 'EC' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Tipo_Privado_En_Curso;
                                    }
                                    when 'PV' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Tipo_Previsional;
                                    }
                                    when 'ND' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Liquidacion_Provisional;
                                    }
                                    when 'DF' {
                                        tipoEeffDesc = System.Label.CIBE_EEFF_Liquidacion_Definitiva;
                                    }
                                    when else {
                                        tipoEeffDesc = tipoEeff;
                                    }
        					}
                        }
                        else {
                            sError = 'Response Error EEFF: ' + res.getStatusCode() + ' ' + res.getBody();
                            //quitar el cbk log cuando el tratamiento de errores por status code funcione correctamente a nivel de fwk
                            cbk_log.error(sError);
                            sError = 'Fallo conexión al obtener información sobre Estados Financieros';
                        }
                        //Rellenamos el cuerpo de la petición para EEFF con Detalles
                        CBK_IntegrationSetting__c wsc2 = CBK_IntegrationSetting__c.getValues('CIBE_getEeFF_Details');
                        //CBK_IntegrationSetting__c wsc2 = CBK_IntegrationSetting__c.getValues('CIBE_getEeFF_Details_Mock');
                        //si detecta que usamos la name credential del camaleon le metemos su cabecera
                        if(wsc2?.NamedCredential__c.contains('CAMALEON')) {
                            mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
                        }
                        string body2 = '{"class":"[CLASSRESP]","company":'+company+',"customerId":"[CUSTOMERID]","customerIdType":"[DOCUMENTTYPE]","personNumber":'+personNumberId+',"queryType":"todos","source":"[SOURCERESP]","state":"[STATE]","stateId":'+statementId+',"type":"[TIPOEEFF]","yearMonth":'+yearmonth+',"financialYear":'+year+'}';
                        body2 = body2.replace('[CUSTOMERID]', documentNumber);
                        body2 = body2.replace('[DOCUMENTTYPE]', documentType);
                        body2 = body2.replace('[CLASSRESP]', classResp);
                        body2 = body2.replace('[SOURCERESP]', sourceResp);
                        body2 = body2.replace('[STATE]', state);
                        body2 = body2.replace('[TIPOEEFF]', tipoEeff);
                        HttpRequest req2 = CBK_HttpServiceIntegration.getRequest(body2, 'CIBE_getEeFF_Details', 'POST', mHeaders);
                        HttpResponse res2 = CBK_HttpServiceIntegration.multiCallHttpService(req2, recordId, 'CIBE_getEeFF_Details');
                        //Log Response And Body
                        CBK_Log.debug('Respuesta' + res2, logginglevel.DEBUG);
                        //Si nos da un 200 obtenemos los datos necesarios para solicitar la request "Details"
                        if (res2.getStatusCode() == 200) {
                            if(res2.getBody() != null) {
                                wrapper.responseFromService = res2.getBody();
                                //Mapas Json
                                Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res2.getBody());
                                Map<String, Object> summary = (Map<String, Object>)root.get('summary');
                                Map<String, Object> financialStatement = (Map<String, Object>)summary.get('financialStatement');
                                List<Object> BalanceSheets = (List<Object>)root.get('BalanceSheets');
                                List<Object> Ratios = (List<Object>)root.get('Ratios');
                                String jsonBSItems = JSON.serialize(BalanceSheets);
                                String jsonRatios = JSON.serialize(Ratios);                                
                                //Nº Empleados
                                String numeroEmpleados = String.valueOf(financialStatement.get('numberEmployees'));
                                //CNAE
                                String CNAE = String.valueOf(financialStatement.get('cnae'));
                                //CNAE Description
                                String cnaeDesc = String.valueOf(financialStatement.get('descriptionCnae'));
                                //YearMonth
                                Integer yearMonthJson = Integer.valueOf(financialStatement.get('yearMonth'));
                                string yearMonthString = string.ValueOf(yearMonthJson);
                                //netWorh
                                Integer netWorth = Integer.valueOf(summary.get('netWorth'));
                                if (yearMonthJson != null && yearMonthString.length() == 6 ) {
                                    String yearJson = yearMonthString.substring(0, 4);
                                    String monthJson = yearMonthString.substring(4, 6);
                                    yearMonthString = monthJson+'/'+ yearJson;
                                }
                                //Concatenate CNAE + Description
                                String fullCnae = CNAE+' '+cnaeDesc;
                                //Source
                                String source = tipoEeffDesc+' a '+yearMonthString;

                                fieldsToUpdate.put('Id',recordId);
                                fieldsToUpdate.put('CIBE_TipoEEFF__c', tipoEeffDesc);
                                fieldsToUpdate.put('CIBE_Source__c', source);
                                fieldsToUpdate.put('CIBE_Fecha_EEFF__c',yearMonthString);
                                fieldsToUpdate.put('CIBE_FechaRefrescoEEFF__c',dateTime.now());
                                fieldsToUpdate.put('CIBE_NumeroEmpleados__c',numeroEmpleados);
                                fieldsToUpdate.put('CIBE_CNAE__c', fullCnae);
                                fieldsToUpdate.put('CIBE_NetWorth__c', netWorth);
                                
                                List<Object> lstRatios = (List<Object>) JSON.deserializeUntyped(jsonRatios);
                                Integer amountratio = 0;
                                Integer NetFinDebtEbitdaValue = 0;
                                for (Object obj : lstRatios) {
                                    Map<String, Object> objMap = (Map<String, Object>)obj;
                                    List<Object> lstItems = (List<Object>) objMap.get('RatioItems');
                                    Integer Countrat = 0;
                                    for (Object lst : lstItems) {
                                        Map<String, Object> auxMap = (Map<String, Object>)lst;
                                        String code = String.valueOf(auxMap.get('code'));
                                        if (code.contains('RAT EDF')) {                                    
                                            NetFinDebtEbitdaValue = Integer.valueOf(auxMap.get('amount'));
                                            fieldsToUpdate.put('CIBE_NetFinancialDebt_Ebitda__c', NetFinDebtEbitdaValue);
                                            Countrat ++;
                                            
                                        } else if (code.contains('RAT SCH')) {
                                            Integer cashFlowValue = Integer.valueOf(auxMap.get('amount'));
                                            fieldsToUpdate.put('CIBE_CashFlow__c', cashFlowValue);
                                            Countrat ++;
                                        }
                                        if (Countrat == 2){
                                            break;
                                        }
                                    }
                                }
                                List<Object> lstBSItems = (List<Object>) JSON.deserializeUntyped(jsonBSItems);
                                for (Object obj : lstBSItems) {
                                    Map<String, Object> objMap = (Map<String, Object>)obj;
                                    List<Object> lstItems = (List<Object>) objMap.get('BalanceSheetItems');
                                    //Declaramos variables Aux
                                    //Resultado Explotación (C0491000)
                                    Integer resExplotValue = 0;
                                    //Resultado Post Impuesto (C0495000)
                                    Integer resPostTaxValue= 0;
                                    //Importe neto de la cifra de negocios (C0401000)
                                    Integer imporNetNegoVlue = 0;
                                    // Otros ingresos Explotación (C0405000)
                                    Integer otrosIngExplotValue = 0;
                                    //Ingresos Explotación (imporNetNegoVlue+otrosIngExplotValue)
                                    Integer totalIngExplot = 0;
                                    //Deudas a Corto Plazo (C0323000)
                                    Integer deudaCortoPlazo = 0;
                                    //Deuda Largo Plazo (C0312000)
                                    Integer deudaLargoPlazo = 0;
                                    //Efectivo y otros activos líquidos (C0127000)
                                    Integer activosLiquidos = 0;
                                    //Deuda financiera neta (deudaCortoPlazo + deudaLargoPlazo) - activosLiquidos
                                    Integer deudaFinanceNeta = 0;
                                    //EBITDA
                                    Decimal EBITDA = 0;
                                    for (Object lst : lstItems) {
                                        Map<String, Object> auxMap = (Map<String, Object>)lst;
                                        String code = String.valueOf(auxMap.get('code'));
                                        // Resultado Explotación
                                        if (code.contains('C0491000') && resExplotValue == 0) {
                                            resExplotValue = Integer.valueOf(auxMap.get('amount'));
                                            if(resExplotValue != 0) {
                                                fieldsToUpdate.put('CIBE_ResultadoExplotacion__c', resExplotValue);
                                            }
                                            // Resultado Post Impuesto
                                        } else if (code.contains('C0495000') && resPostTaxValue == 0) {
                                            resPostTaxValue = Integer.valueOf(auxMap.get('amount'));
                                            if(resPostTaxValue != 0) {
                                                fieldsToUpdate.put('CIBE_ResultadoPostImpuestos__c', resPostTaxValue);
                                            }
                                            //Ingresos Explotación --> Importe neto de la cifra de negocios(C0401000) + Otros ingresos de explotación (C0405000)
                                        } else if (code.contains('C0401000') && imporNetNegoVlue == 0) {
                                            imporNetNegoVlue = Integer.valueOf(auxMap.get('amount'));
                                        } else if (code.contains('C0405000') && otrosIngExplotValue == 0) {
                                            otrosIngExplotValue = Integer.valueOf(auxMap.get('amount'));
                                        }                                       
                                        /*EBITDA = A/B 
                                        A = (Deuda financiera neta/Ebitda= NetFinDebtEbitdaValue) / Deuda financiera neta.
                                        B = Deuda financiera neta = (Deudas a corto plazo + deudas a largo plazo) - Efectivo y otros activos líquidos equivalentes. */                              
                                        else if (code.contains('C0323000')) {
                                            deudaCortoPlazo = Integer.valueOf(auxMap.get('amount'));
                                        } else if (code.contains('C0312000')) {
                                            deudaLargoPlazo = Integer.valueOf(auxMap.get('amount'));
                                        } else if (code.contains('C0127000')) {
                                            activosLiquidos = Integer.valueOf(auxMap.get('amount'));
                                        }
                                    }
                                    if (totalIngExplot == 0) {                                        
                                            totalIngExplot = imporNetNegoVlue+otrosIngExplotValue;
                                            fieldsToUpdate.put('CIBE_Facturacion__c', totalIngExplot);
                                        }
                                    if (deudaFinanceNeta == 0) {
                                        deudaFinanceNeta = (deudaCortoPlazo+deudaLargoPlazo)-activosLiquidos;
                                    }
                                    if(NetFinDebtEbitdaValue != 0 && deudaFinanceNeta != 0) {
                                        EBITDA = NetFinDebtEbitdaValue/deudaFinanceNeta;
                                        Decimal ebitdaRound = EBITDA.setscale(2);
                                        fieldsToUpdate.put('CIBE_EBITDA__c', ebitdaRound);
                                    }   
                                }
                            }
                            sError = CIBE_IntegrationUtilities.updateObject(fieldsToUpdate, 'Account');
                            if(!string.isBlank(sError)){
                                cbk_log.error(sError);
                            }
                        }
                        else {
                            sError = 'Response Error EEFF Details: ' + res2.getStatusCode() + ' ' + res2.getBody();
                            //quitar el cbk log cuando el tratamiento de errores por status code funcione correctamente a nivel de fwk
                            cbk_log.error(sError);
                            sError = 'Fallo conexión al obtener información sobre Estados Financieros Detalles';
                        }
                    }   
                    catch(Exception e) {
                        sError = 'Error al procesar los datos de la integración. Contacte con el administrador';
                        cbk_log.error(e);
                    }
                    if(!string.isBlank(sError)){
                        throw new AuraHandledException(sError);
                    }
                } else {
                    sError = 'Han pasado menos de 24H desde el último refresco ' + acc.CIBE_FechaRefrescoEEFF__c.format('d/M/y H:m');
                    cbk_log.error(sError);
                    throw new AuraHandledException(sError);  
                }
            }
            else {
                sError = '¡Error!, Falta información a nivel de cliente para procesar la petición. NumPerso:'+personNumberId+'Nº Documento:'+documentNumber+'Tipo de Documento:'+documentType+'.';
                cbk_log.error(sError);
                throw new AuraHandledException(sError);                
            }
        }
        return respData;
    }
}