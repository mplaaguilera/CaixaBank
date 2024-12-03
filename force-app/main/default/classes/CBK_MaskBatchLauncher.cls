public with sharing class CBK_MaskBatchLauncher {



    public static void launchSerialMaskLeadBatch(){
        CBK_Mask_Batch objTest = new CBK_Mask_Batch('Lead',0,false,null,true);
        Database.executebatch(objTest);
    }
    public static void launchSerialMaskCaseBatch(string strLimit){
        CBK_Mask_Case_Batch objTest;
        if(String.isBlank(strLimit)){
            objTest = new CBK_Mask_Case_Batch();
        }
        else{
            objTest = new CBK_Mask_Case_Batch(strLimit);
        }       
        Database.executebatch(objTest,2000);
    }
    public static void launchParallelMaskCaseBatch(integer bloques,integer batchSize){
        for (integer i=0; i< bloques;i++){
            //Lanzar el batch del segmento
            CBK_Mask_Case_Batch objTest = new CBK_Mask_Case_Batch(i,bloques);
            Database.executebatch(objTest,batchSize);
        }
    }

    public static void launchSerialMaskAccountBatch(string strLimit){
        CBK_Mask_Account_Batch objTest;
        if(String.isBlank(strLimit)){
            objTest = new CBK_Mask_Account_Batch();
        }
        else{
            objTest = new CBK_Mask_Account_Batch(strLimit);
        }       
        Database.executebatch(objTest,2000);
    }


    public static void launchParallelMaskAccountBatch(integer bloques,integer batchSize){
        for (integer i=0; i< bloques;i++){
            //Lanzar el batch del segmento
            CBK_Mask_Account_Batch objTest = new CBK_Mask_Account_Batch(i,bloques);
            Database.executebatch(objTest,batchSize);
        }
    }
    public static void launchSerialMaskContactBatch(string strLimit){
        CBK_Mask_Contact_Batch objTest;
        if(String.isBlank(strLimit)){
            objTest = new CBK_Mask_Contact_Batch();
        }
        else{
            objTest = new CBK_Mask_Contact_Batch(strLimit);
        }       
        Database.executebatch(objTest,2000);
    }
    public static void launchMaskContactBatch(Boolean parrallelExecution,Decimal BatchSize,Boolean lanzarEjecucionBatchs){
        Boolean lanzarBatchs = false;
        Decimal tamanyo = 5000000;
        if (BatchSize != null){
            tamanyo = BatchSize;
        }
        if (lanzarEjecucionBatchs != null){
            lanzarBatchs = lanzarEjecucionBatchs;
        }
        String strObject;
        CBK_MaskObject__mdt currentMaskObject;
        List<Map<String, String>> rangeListChunked;
        Id firstId, lastId;
        Id minPod,maxPod,min2Pod,max2Pod;
        String strQuery;
        List<Sobject> loList;
        currentMaskObject = CBK_MaskUtilities.getMaskObjectConfig('Contact');
        strObject = currentMaskObject.CBK_Objeto__c;

        if (parrallelExecution){
            firstId = CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c);
            lastId = CBK_MaskUtilities.getLastId(currentMaskObject.CBK_Objeto__c);
            system.debug(String.valueOf(firstId).left(5));
            if (String.valueOf(firstId).left(5)==String.valueOf(lastId).left(5)){
                rangeListChunked = CBK_MaskUtilities.chunkIdRange (CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c),CBK_MaskUtilities.getLastId(currentMaskObject.CBK_Objeto__c),tamanyo);
                system.debug('size: '+rangeListChunked.size());
                for (Map<String, String> range :rangeListChunked){
                    system.debug('elem: '+range);
                    If (rangeListChunked.size()<90){
                        strQuery = 'select count() from '+ currentMaskObject.CBK_Objeto__c+' where id>= \''+range.get('first') +'\' and id<= \''+range.get('last')+'\'';
                        integer num = Database.countQuery(strQuery);
                        system.debug('registros en rango: '+ num);
                        if (num>0 && lanzarBatchs){
                            //Lanzar el batch del segmento
                            CBK_Mask_Contact_Batch objTest = new CBK_Mask_Contact_Batch(range);
                            Database.executebatch(objTest,2000);
                        }
                    }
                }
            }
            else{
                //recuperamos min, max
                loList = Database.Query('select id from '+ currentMaskObject.CBK_Objeto__c+' where Id >=\''+ String.valueOf(firstId).left(5)+'0000000000\' AND Id <=\''+ String.valueOf(firstId).left(5)+'00zzzzzzzz\' ORDER BY ID ASC LIMIT 1');
                minPod = loList[0].Id;
                loList = Database.Query('select id from '+ currentMaskObject.CBK_Objeto__c+' where Id >=\''+ String.valueOf(firstId).left(5)+'0000000000\' AND Id <=\''+ String.valueOf(firstId).left(5)+'00zzzzzzzz\' ORDER BY ID DESC LIMIT 1');	
                maxPod = loList[0].Id;
                loList = Database.Query('select id from '+ currentMaskObject.CBK_Objeto__c+' where Id >=\''+ String.valueOf(lastId).left(5)+'0000000000\' AND Id <=\''+ String.valueOf(lastId).left(5)+'00zzzzzzzz\' ORDER BY ID ASC LIMIT 1');
                min2Pod = loList[0].Id;
                loList = Database.Query('select id from '+ currentMaskObject.CBK_Objeto__c+' where Id >=\''+ String.valueOf(lastId).left(5)+'0000000000\' AND Id <=\''+ String.valueOf(lastId).left(5)+'00zzzzzzzz\' ORDER BY ID DESC LIMIT 1');
                max2Pod = loList[0].Id;
                rangeListChunked = CBK_MaskUtilities.chunkIdRange (minPod,maxPod,tamanyo);
                system.debug('size: '+rangeListChunked.size());
                for (Map<String, String> range :rangeListChunked){
                    system.debug('elem: '+range);
                    If (rangeListChunked.size()<60){
                        strQuery = 'select count() from '+ currentMaskObject.CBK_Objeto__c+' where id>= \''+range.get('first') +'\' and id<= \''+range.get('last')+'\'';
                        integer num = Database.countQuery(strQuery);
                        system.debug('registros en rango: '+ num);
                        if (num>0 && lanzarBatchs){
                            //Lanzar el batch del segmento
                            CBK_Mask_Contact_Batch objTest = new CBK_Mask_Contact_Batch(range);
                            Database.executebatch(objTest,2000);
                        }
                    }
                }
                rangeListChunked = CBK_MaskUtilities.chunkIdRange (min2Pod,max2Pod,tamanyo);
                system.debug('size: '+rangeListChunked.size());
                for (Map<String, String> range :rangeListChunked){
                    system.debug('elem: '+range);
                    If (rangeListChunked.size()<60){
                        strQuery = 'select count() from '+ currentMaskObject.CBK_Objeto__c+' where id>= \''+range.get('first') +'\' and id<= \''+range.get('last')+'\'';
                        integer num = Database.countQuery(strQuery);
                        system.debug('registros en rango: '+ num);
                        if (num>0 && lanzarBatchs){
                            //Lanzar el batch del segmento
                            CBK_Mask_Contact_Batch objTest = new CBK_Mask_Contact_Batch(range);
                            Database.executebatch(objTest,2000);
                        }
                    }
                }
            }
        }
        else{
            CBK_Mask_Contact_Batch objTest = new CBK_Mask_Contact_Batch();
            objTest = new CBK_Mask_Contact_Batch();    
            Database.executebatch(objTest,2000);
        }
    }
    @TestVisible private static void coberturaDa(){
        Account acc = [SELECT Id FROM Account Limit 1];
        Id colaboradorContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        List <Contact> lstCtcs = new List <Contact> ();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = colaboradorContactRT;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = acc.ID;
        lstCtcs.add(cnt1);
        Contact cnt2 = new Contact();
        cnt2.recordtypeId = colaboradorContactRT;
        cnt2.lastname = 'cnt2';
        cnt2.email = 'Atest@test.com';
        cnt2.AccountId = acc.ID;
        lstCtcs.add(cnt2);
        Contact cnt3 = new Contact();
        cnt3.recordtypeId = colaboradorContactRT;
        cnt3.lastname = 'cnt3';
        cnt3.email = 'Btest@test.com';
        cnt3.AccountId = acc.ID;
        lstCtcs.add(cnt3);
        Contact cnt4 = new Contact ();
        cnt4.recordtypeId = colaboradorContactRT;
        cnt4.lastname = 'cnt1';
        cnt4.email = 'test@test.com';
        cnt4.AccountId = acc.ID;
        lstCtcs.add(cnt4);
        Contact cnt5 = new Contact();
        cnt5.recordtypeId = colaboradorContactRT;
        cnt5.lastname = 'cnt2';
        cnt5.email = 'Atest@test.com';
        cnt5.AccountId = acc.ID;
        lstCtcs.add(cnt5);
        Contact cnt6 = new Contact();
        cnt6.recordtypeId = colaboradorContactRT;
        cnt6.lastname = 'cnt3';
        cnt6.email = 'Btest@test.com';
        cnt6.AccountId = acc.ID;
        lstCtcs.add(cnt6);
        Contact cnt7 = new Contact();
        cnt7.recordtypeId = colaboradorContactRT;
        cnt7.lastname = 'cnt2';
        cnt7.email = 'Atest@test.com';
        cnt7.AccountId = acc.ID;
        lstCtcs.add(cnt7);
        Contact cnt8 = new Contact();
        cnt8.recordtypeId = colaboradorContactRT;
        cnt8.lastname = 'cnt3';
        cnt8.email = 'Btest@test.com';
        cnt8.AccountId = acc.ID;
        lstCtcs.add(cnt8);
    }
}