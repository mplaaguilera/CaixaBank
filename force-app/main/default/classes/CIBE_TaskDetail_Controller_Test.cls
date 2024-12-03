/**********************************************************************************************************************
 Name:      CIBE_TaskDetail_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_TaskDetail_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				DATE        Description
   	1.0      Initial				Mikel Lezama		27/10/2022  Init version

***********************************************************************************************************************/
@isTest
public class CIBE_TaskDetail_Controller_Test {
    @isTest
    public static void getValueLabelTest(){
        
        String value = 'Normal';
        Test.startTest();
        
		String result = CIBE_TaskDetail_Controller.getValueLabel(value);
        System.debug(result);
        
      	Test.stopTest();
        
       	System.assertNotEquals(null, result);
    }
}