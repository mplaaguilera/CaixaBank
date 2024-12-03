@isTest
public  class CBK_LWC_Controller_ParseJson_Test {
    @isTest
    public static void getValuesOK(){
        Test.startTest();
        string tskId = createObjects('1');      
        
        Map<String,String> mValues = CBK_LWC_Controller_ParseJson.getStringbyRecordId(tskId, 'Description', '');
		Map<String,String> mValues2 = CBK_LWC_Controller_ParseJson.getStringbyRecordId(tskId, 'Description', 'Use');
		Map<String,String> mValues3 = CBK_LWC_Controller_ParseJson.getStringbyRecordId(tskId, 'Description', '607627203');
        Test.stopTest();
    }
    
    //@isTest
    //public static void beAvailableButton(){
        
        //Test.startTest();
        //string tskId = createObjects('1');
        //string tskId2 = createObjects('2');

        
        //list<Boolean> mValues = CBK_LWC_Controller_ParseJson.beAvailableButton(tskId,'Description');
        //list<Boolean> mValues2 = CBK_LWC_Controller_ParseJson.beAvailableButton(tskId2,'Description');
        //Test.stopTest();
    //}


    public static string createObjects(string num)
    {
        
        Task tskNew = new Task();
        tskNew.Subject = 'Email';
        tskNew.Priority = 'Normal';
        if (num == '1')
        {
            tskNew.Description = 'Text descripton.... {"valorVivienda" : "","user_Agent": "PostmanRuntime/7.26.8","tipoSolicitud": "prestamo","telOficina": "932480500","telefono2_2Tit": "","telefono2_1Tit": "607627203"}';
        }
        else{

            tskNew.Description = 'Text descripton.... [{"valorVivienda" : "","user_Agent": "PostmanRuntime/7.26.8","tipoSolicitud": "prestamo","telOficina": "932480500","telefono2_2Tit": "","telefono2_1Tit": "607627203"}';
        }
        insert tskNew;  
        
        return tskNew.Id;
    }
}