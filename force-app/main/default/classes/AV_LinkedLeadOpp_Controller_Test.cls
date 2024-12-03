/**********************************************************************************************************************
 Name:      AV_LinkedLeadOpp_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test class for AV_LinkedLeadOpp_Controller_Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				DATE        Description
   	1.0      US473478			Vladislav Lityagin		15/11/2022  Init version
***********************************************************************************************************************/ 
@isTest
public class AV_LinkedLeadOpp_Controller_Test  {
    @Testsetup
    public static void setup(){
        
        Account a1=new Account();
        a1.Name='Test';
        insert a1;
        Task t1=new Task();
        t1.WhatId=a1.id;
        t1.Priority='A';
        insert t1;
        
         
    }
    
    @isTest
    public static void getLeadOppTest(){
        String idsTask =[Select id from Task where Priority='A' limit 1].id;
        String objectName='Task';
        String valid =null;
        
        Test.startTest();
        AV_LinkedLeadOpp_Controller.getLeadOpp(idsTask, objectName,valid);
        Test.stopTest();
        System.assertNotEquals(null, idsTask);
        
    }
    
   

}