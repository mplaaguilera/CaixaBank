public with sharing class CC_MonitorOnline_Carga
{
    @AuraEnabled
    public static void saveFile(String base64Data)
    {
        String data = JSON.deserializeUntyped(base64Data).toString();
        list<CC_Prevision__c> lstCCToInsert = new list<CC_Prevision__c>();
        list<String> lstCSVLines = data.split('\n');
        Id recordTypeIdAgentes = [SELECT Id FROM RecordType WHERE SobjectType = 'CC_Prevision__c' AND DeveloperName = 'CC_Agentes'].Id;
        Id recordTypeIdChat = [SELECT Id FROM RecordType WHERE SobjectType = 'CC_Prevision__c' AND DeveloperName = 'CC_Chats'].Id;

        for(Integer i = 1; i < lstCSVLines.size(); i++)
        {
            if(!lstCSVLines[i].contains(';;;;;'))
                {
                CC_Prevision__c prevision = new CC_Prevision__c();
                String csvLine = lstCSVLines[i];
                String prevLine = csvLine;
                Integer startIndex;
                Integer endIndex;
                
                List<String> csvRowData = new List<String>();
                for(String column : csvLine.split(';'))
                {
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    csvRowData.add(column);
                }
                String developerNameRT = 'CC_' + csvRowData.get(26).trim();
                prevision.CC_Fecha__c = Date.valueOf(csvRowData[0]);
                prevision.CC_Proveedor__c = csvRowData[1];
                if(developerNameRT == 'CC_Agentes'){
                    prevision.RecordTypeId = recordTypeIdAgentes;
                }else{
                    prevision.RecordTypeId = recordTypeIdChat;
                }
                prevision.CC_00__c = Decimal.valueOf(csvRowData[2]);
                prevision.CC_01__c = Decimal.valueOf(csvRowData[3]);
                prevision.CC_02__c = Decimal.valueOf(csvRowData[4]);
                prevision.CC_03__c = Decimal.valueOf(csvRowData[5]);
                prevision.CC_04__c = Decimal.valueOf(csvRowData[6]);
                prevision.CC_05__c = Decimal.valueOf(csvRowData[7]);
                prevision.CC_06__c = Decimal.valueOf(csvRowData[8]);
                prevision.CC_07__c = Decimal.valueOf(csvRowData[9]);
                prevision.CC_08__c = Decimal.valueOf(csvRowData[10]);
                prevision.CC_09__c = Decimal.valueOf(csvRowData[11]);
                prevision.CC_10__c = Decimal.valueOf(csvRowData[12]);
                prevision.CC_11__c = Decimal.valueOf(csvRowData[13]);
                prevision.CC_12__c = Decimal.valueOf(csvRowData[14]);
                prevision.CC_13__c = Decimal.valueOf(csvRowData[15]);
                prevision.CC_14__c = Decimal.valueOf(csvRowData[16]);
                prevision.CC_15__c = Decimal.valueOf(csvRowData[17]);
                prevision.CC_16__c = Decimal.valueOf(csvRowData[18]);
                prevision.CC_17__c = Decimal.valueOf(csvRowData[19]);
                prevision.CC_18__c = Decimal.valueOf(csvRowData[20]);
                prevision.CC_19__c = Decimal.valueOf(csvRowData[21]);
                prevision.CC_20__c = Decimal.valueOf(csvRowData[22]);
                prevision.CC_21__c = Decimal.valueOf(csvRowData[23]);
                prevision.CC_22__c = Decimal.valueOf(csvRowData[24]);
                prevision.CC_23__c = Decimal.valueOf(csvRowData[25]);
                prevision.CC_Servicio__c = csvRowData[27];
                lstCCToInsert.add(prevision);
            }
        }

        if(!lstCCToInsert.isEmpty())
        {
            insert lstCCToInsert;
        }
    }
}