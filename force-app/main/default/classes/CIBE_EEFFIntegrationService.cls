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
        public List<BalanceSheetItems> BalanceSheetItems;
        public List<Inconsistencies> SettlementSheets;
        public List<IncomeStatements> IncomeStatements;
        public List<IncomeStatementItems> IncomeStatementItems;
        public List<Inconsistencies> Remnants;
        public List<Ratios> Ratios;
        public List<RatioItems> RatioItems;
        public List<RatiosSE> RatiosSE;
        @AuraEnabled
        public String responseFromService;
        @AuraEnabled
        public Integer responseEEFFStatus;
        
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
    public class IncomeStatementItems {
        public String code;
        public Integer amount; 
        public String percentageFlag; 
        public Integer percentage;
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
        map<string, object> fieldsToUpdate = new map<string, object>();
        Integer yearMonth = null;
        Integer year = null;
        
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
                        //si detecta que usamos la name credential del camaleon le metemos su cabecera
                        if(wsc?.NamedCredential__c.contains('CAMALEON')){
                            mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
                        }
                        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
                        //Rellenamos el cuerpo de la petición para EEFF
                        //class = "LI" Son Liquidaciones, "I7" Son EEFF individuales, "C7" Son EEFF consolidados.
                        
                        string body = '{"action":"IN","numberRows":1,"customerId":"[CUSTOMERID]","customerIdType":"[DOCUMENTTYPE]","class":"I7","microBalance":"N"}';
                        body = body.replace('[CUSTOMERID]', documentNumber);
                        body = body.replace('[DOCUMENTTYPE]', documentType);
                        
                        CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                        reqWrapper.body = body;
                        reqWrapper.intSetting = 'CIBE_getEeFF';
                        reqWrapper.method = 'POST';
                        reqWrapper.mHeaders =  mHeaders;
                        reqWrapper.mUriParams = new  Map<String,string>();
                        reqWrapper.mQueryParams = new  Map<String,string>();
                                
       					HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);                        
                        HttpResponse res = CBK_HttpServiceIntegration.multiCallHttpService(req, recordId, 'CIBE_getEeFF');
                        //Log Response And Body
                        CBK_Log.debug('Respuesta' + res, logginglevel.DEBUG);
                        //Si nos da un 200 obtenemos los datos necesarios para solicitar la request "Details"
                        if (res.getStatusCode() == 200) {
                            wrapper.responseEEFFStatus = res.getStatusCode();
                            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                            for(Object obj: (List<Object>)resBody.get('FinancialStatements')) {
                                // the result of obj is JSON, so convert it to map
                                Map<String, Object> objMap = (Map<String, Object>) obj;
                                statementId = (Integer)objMap.get('stateId');
                                tipoEeff = (String)objMap.get('type');
                                company = (Integer)objMap.get('company');
                                sourceResp = (String)objMap.get('source');
                                state = (String)objMap.get('state');
                                classResp = (String)objMap.get('class');
                                yearMonth = (Integer)objMap.get('yearMonth');
                                year = (Integer)objMap.get('financialYear');
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
                        //si detecta que usamos la name credential del camaleon le metemos su cabecera
                        if(wsc2?.NamedCredential__c.contains('CAMALEON')) {
                            mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
                        }
                        string body2 = '{"class":"[CLASSRESP]","company":'+company+',"customerId":"[CUSTOMERID]","customerIdType":"[DOCUMENTTYPE]","personNumber":'+personNumberId+',"queryType":"todos","source":"[SOURCERESP]","state":"[STATE]","stateId":'+statementId+',"type":"[TIPOEEFF]","yearMonth":'+yearMonth+',"financialYear":'+year+'}';
                        body2 = body2.replace('[CUSTOMERID]', documentNumber);
                        body2 = body2.replace('[DOCUMENTTYPE]', documentType);
                        body2 = body2.replace('[CLASSRESP]', classResp);
                        body2 = body2.replace('[SOURCERESP]', sourceResp);
                        body2 = body2.replace('[STATE]', state);
                        body2 = body2.replace('[TIPOEEFF]', tipoEeff);
                        HttpRequest req2 = CBK_HttpServiceIntegration.getRequest(body2, 'CIBE_getEeFF_Details', 'POST', mHeaders);
                        HttpResponse res2 = CBK_HttpServiceIntegration.multiCallHttpService(req2, recordId, 'CIBE_getEeFF_Details');
                        //Log Response And Body
                        CBK_Log.debug('Request Detail' + req2, logginglevel.DEBUG);
                        CBK_Log.debug('Respuesta Detail' + res2, logginglevel.DEBUG);
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
                                List<Object> CuentaResultados = (List<Object>)root.get('IncomeStatements');
                                String jsonBSItems = JSON.serialize(BalanceSheets);
                                String jsonRatios = JSON.serialize(Ratios);
                                String jsonCuentaResult = JSON.serialize(CuentaResultados);
                                //Target FinancialYear
                                Integer targetFinancialYear = Integer.valueOf(financialStatement.get('financialYear'));                            
                                //Nº Empleados
                                String numeroEmpleados = String.valueOf(financialStatement.get('numberEmployees'));
                                //cnae
                                String cnae = String.valueOf(financialStatement.get('cnae'));
                                //cnae Description
                                String cnaeDesc = String.valueOf(financialStatement.get('descriptionCnae'));
                                //YearMonth
                                Integer yearMonthJson = Integer.valueOf(financialStatement.get('yearMonth'));
                                string yearMonthString = string.ValueOf(yearMonthJson);
                                //Unidad de Medida 0-unidades , 1–miles de euro o 2-millones de euro
                                String UnitMeasure = String.valueOf(financialStatement.get('units'));
                                //netWorh
                                Integer networh = Integer.valueOf(summary.get('netWorth'));
                                Decimal netWorthMult = networh*calculateunit(UnitMeasure);
                                if (yearMonthJson != null && yearMonthString.length() == 6 ) {
                                    String yearJson = yearMonthString.substring(0, 4);
                                    String monthJson = yearMonthString.substring(4, 6);
                                    yearMonthString = monthJson+'/'+ yearJson;
                                }
                                //Concatenate cnae + Description
                                String fullCnae = cnae+' '+cnaeDesc;
                                //Source
                                String source = tipoEeffDesc+' a '+yearMonthString;

                                fieldsToUpdate.put('Id',recordId);
                                fieldsToUpdate.put('CIBE_TipoEEFF__c', tipoEeffDesc);
                                fieldsToUpdate.put('CIBE_Source__c', source);
                                fieldsToUpdate.put('CIBE_Fecha_EEFF__c',yearMonthString);
                                fieldsToUpdate.put('CIBE_FechaRefrescoEEFF__c',dateTime.now());
                                fieldsToUpdate.put('CIBE_NumeroEmpleados__c',numeroEmpleados);
                                fieldsToUpdate.put('CIBE_cnae__c', fullCnae);
                                fieldsToUpdate.put('CIBE_NetWorth__c', netWorthMult);
                                
                                //Recorremos array RatioItems
                                List<Object> lstRatios = (List<Object>) JSON.deserializeUntyped(jsonRatios);
                                Integer netFinDebtEbitdaValue = 0;
                                Decimal netFinDebtEbitdaMiles = 0;
                                for (Object obj : lstRatios) {
                                    Map<String, Object> objMap = (Map<String, Object>)obj;
                                    if (objMap.containsKey('financialYear') && objMap.get('financialYear') instanceof Integer &&
                                    (Integer)objMap.get('financialYear') == targetFinancialYear) {
                                        if (objMap.containsKey('units') && objMap.get('units') != '') {
                                            UnitMeasure = String.valueOf(objMap.get('units'));
                                        }
                                        List<Object> lstItems = (List<Object>) objMap.get('RatioItems');
                                        Integer countrat = 0;
                                        for (Object lst : lstItems) {
                                            Map<String, Object> auxMap = (Map<String, Object>)lst;
                                            String code = String.valueOf(auxMap.get('code'));
                                            if (code.contains('RAT EDF')) {                                    
                                                netFinDebtEbitdaValue = Integer.valueOf(auxMap.get('amount'));
                                                netFinDebtEbitdaMiles = netFinDebtEbitdaValue*calculateunit(UnitMeasure);
                                                fieldsToUpdate.put('CIBE_NetFinancialDebt_Ebitda__c', netFinDebtEbitdaValue);
                                                countrat ++;
                                                
                                            }
                                            if (countrat == 2){
                                                break;
                                            }
                                        }
                                    }
                                }
                                //Recorremos array BalanceSheetItems
                                List<Object> lstBSItems = (List<Object>) JSON.deserializeUntyped(jsonBSItems);
                                for (Object obj : lstBSItems) {
                                    Map<String, Object> objMap = (Map<String, Object>)obj;
                                    if (objMap.containsKey('financialYear') && objMap.get('financialYear') instanceof Integer &&
                                    (Integer)objMap.get('financialYear') == targetFinancialYear) {
                                        if (objMap.containsKey('units') && objMap.get('units') != '') {
                                            UnitMeasure = String.valueOf(objMap.get('units'));
                                        }
                                        List<Object> lstItems = (List<Object>) objMap.get('BalanceSheetItems');
                                        //Deudas a Corto Plazo (C0323000)
                                        Integer deudaCortoPlazo = 0;
                                        //Deuda Largo Plazo (C0312000)
                                        Integer deudaLargoPlazo = 0;
                                        //Efectivo y otros activos líquidos (C0127000)
                                        Integer activosLiquidos = 0;
                                        //Deuda financiera neta (deudaCortoPlazo + deudaLargoPlazo) - activosLiquidos
                                        Integer deudaFinanceNeta = 0;
                                        //Ebitda
                                        Decimal Ebitda = 0;
                                        //DedudaFinanciera Multiplicada por units
                                        Decimal deudaFinanceNetaMul;
                                        for (Object lst : lstItems) {
                                            Map<String, Object> auxMap = (Map<String, Object>)lst;
                                            String code = String.valueOf(auxMap.get('code'));                                   
                                            /*Ebitda = A/B 
                                            A = (Deuda financiera neta/Ebitda= netFinDebtEbitdaValue) / Deuda financiera neta.
                                            B = Deuda financiera neta = (Deudas a corto plazo + deudas a largo plazo) - Efectivo y otros activos líquidos equivalentes. */                              
                                            if (code.contains('C0323000')) {
                                                deudaCortoPlazo = Integer.valueOf(auxMap.get('amount'));
                                            } else if (code.contains('C0312000')) {
                                                deudaLargoPlazo = Integer.valueOf(auxMap.get('amount'));
                                            } else if (code.contains('C0127000')) {
                                                activosLiquidos = Integer.valueOf(auxMap.get('amount'));
                                            } 
                                        }
                                        if (deudaFinanceNeta == 0) {
                                            deudaFinanceNeta = (deudaCortoPlazo+deudaLargoPlazo)-activosLiquidos;
                                            deudaFinanceNetaMul = deudaFinanceNeta*calculateunit(UnitMeasure);
                                        }
                                        if(netFinDebtEbitdaMiles != 0 && deudaFinanceNeta != 0) {
                                            Ebitda = netFinDebtEbitdaMiles/deudaFinanceNetaMul;
                                            Decimal ebitdaRound = Ebitda.setScale(2, RoundingMode.HALF_UP);
                                            fieldsToUpdate.put('CIBE_EBITDA__c', ebitdaRound);
                                        }
                                                            
                                    }  
                                }
                                //Recorremos array IncomeStatements
                                List<Object> lstCRItems = (List<Object>) JSON.deserializeUntyped(jsonCuentaResult);
                                for (Object obj : lstCRItems) {
                                    Map<String, Object> objMap = (Map<String, Object>)obj;
                                    if (objMap.containsKey('financialYear') && objMap.get('financialYear') instanceof Integer &&
                                    (Integer)objMap.get('financialYear') == targetFinancialYear) {
                                        if (objMap.containsKey('units') && objMap.get('units') != '') {
                                            UnitMeasure = String.valueOf(objMap.get('units'));
                                        }
                                        List<Object> lstItems = (List<Object>) objMap.get('IncomeStatementItems');
                                        //Resultado Explotación (C0491000)
                                        Decimal resExplotValue = 0;
                                        //Resultado Post Impuesto (C0495000)
                                        Integer resPostTaxValue= 0;
                                        //Importe neto de la cifra de negocios (C0401000)
                                        Integer imporNetNegoVlue = 0;
                                        Decimal imporNetNegoVlueDec;
                                        // Otros ingresos Explotación (C0405000)
                                        Integer otrosIngExplotValue = 0;
                                        Decimal otrosIngExplotValueDec;
                                        //Ingresos Explotación (imporNetNegoVlue+otrosIngExplotValue)
                                        Integer totalIngExplot = 0;
                                        //Calculo Cashflow (C0495000 - C0408000 - C0999401) && if C0419000 > 0 se resta tb.
                                        //Amortización inmovilizado (C0408000)
                                        Integer amortInmov = 0;
                                        //Dividendos (C0999401 )
                                        Integer dividendos = 0;
                                        //Impuesto Sobre beneficios (C0419000)
                                        Integer taxOverBen = 0;
                                        //CashFlow neto de dividendos
                                        Decimal cashFlowNeto = 0;
                                        //Resultado Explotación (C0495000)
                                        Decimal resulConso = 0;

                                        for (Object lst : lstItems) {
                                            Map<String, Object> auxMap = (Map<String, Object>)lst;
                                            String code = String.valueOf(auxMap.get('code'));
                                            if (code.contains('C0491000') && resExplotValue == 0) {
                                                resExplotValue = Integer.valueOf(auxMap.get('amount')) * calculateunit(UnitMeasure);
                                                if(resExplotValue != 0) {
                                                    fieldsToUpdate.put('CIBE_ResultadoExplotacion__c', resExplotValue);
                                                }
                                                // Resultado Post Impuesto
                                            } else if (code.contains('C0495000') && resPostTaxValue == 0) {
                                                resulConso = Integer.valueOf(auxMap.get('amount'));
                                                if(resPostTaxValue != 0) {
                                                    fieldsToUpdate.put('CIBE_ResultadoPostImpuestos__c', resPostTaxValue);
                                                }
                                                // Resultado Explotación
                                            } else if (code.contains('C0401000') && imporNetNegoVlue == 0) {
                                                imporNetNegoVlue = Integer.valueOf(auxMap.get('amount'));
                                                imporNetNegoVlueDec = imporNetNegoVlue*calculateunit(UnitMeasure);
                                            } else if (code.contains('C0405000') && otrosIngExplotValue == 0) {
                                                otrosIngExplotValue = Integer.valueOf(auxMap.get('amount'));
                                                otrosIngExplotValueDec = otrosIngExplotValue*calculateunit(UnitMeasure);
                                            } else if (code.contains('C0408000') && amortInmov == 0) {
                                                amortInmov = Integer.valueOf(auxMap.get('amount'));

                                            } else if (code.contains('C0999401') && dividendos == 0) {
                                                dividendos = Integer.valueOf(auxMap.get('amount'));
        
                                            } 
                                            else if (code.contains('C0419000') && taxOverBen == 0) {
                                                taxOverBen = Integer.valueOf(auxMap.get('amount'));
                                                
                                            }
                                        }
                                        if (totalIngExplot == 0) {                                        
                                            Decimal totalIngExplotDecimal = imporNetNegoVlue + otrosIngExplotValue;
                                            Decimal totalIngExplotMiles = totalIngExplotDecimal * calculateunit(UnitMeasure);
                                            fieldsToUpdate.put('CIBE_Facturacion__c', totalIngExplotMiles);
                                        }
                                        if(taxOverBen>=0) {
                                            cashFlowNeto = (resulConso - amortInmov - dividendos -taxOverBen)*calculateunit(UnitMeasure);
                                        } else {
                                            cashFlowNeto = (resulConso - amortInmov - dividendos)*calculateunit(UnitMeasure);
                                        }
                                        Decimal cashFlowNetoMiles = cashFlowNeto;
                                        fieldsToUpdate.put('CIBE_CashFlow__c', cashFlowNetoMiles);       
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
                    CBK_HttpServiceIntegration.registroTrazaIntegracion();
                } else {
                    sError = 'Han pasado menos de 24H desde el último refresco ' + acc.CIBE_FechaRefrescoEEFF__c.format('d/M/y H:m');
                    cbk_log.error(sError);
                }
            }
            else {
                sError = '¡Error!, Falta información a nivel de cliente para procesar la petición. NumPerso:'+personNumberId+'Nº Documento:'+documentNumber+'Tipo de Documento:'+documentType+'.';
                cbk_log.error(sError);             
            }
            if(!string.isBlank(sError)){
                system.debug('sError ' + sError);
                throw new AuraHandledException(sError);
            }
        }
        return respData;
    }
    public static Decimal calculateunit (String unitMeasure) {
        Decimal unitsToMultiply;
        if (unitMeasure != '') {
            if (unitMeasure.equals('0')) {
                unitsToMultiply = 0.001;
            } else if (unitMeasure.equals('1')) {
                unitsToMultiply = 1;
            } else if (unitMeasure.equals('2')) {
                unitsToMultiply = 1000;
            } else {
                 unitsToMultiply = 1;
            }
         } else {
             unitsToMultiply = 1;
         }
         return unitsToMultiply;
    }
}