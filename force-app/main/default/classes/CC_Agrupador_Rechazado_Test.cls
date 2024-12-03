@IsTest
public class CC_Agrupador_Rechazado_Test {
    @isTest
    static void test() {
		CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Titulo__c = 'Agrupador Test';
        insert agrupador;
        
        Case caso = new Case();
        caso.Subject = 'Caso Test';       
        caso.CC_Agrupador_Id__c = agrupador.Id;
        insert caso;	
        
        Task task = new Task();
		task.Type = 'Traslado Incidencia';
        task.status = 'Open';
        task.Subject = 'Email'; 
        task.WhatId = caso.Id;
        insert task; 
        
        List<Id> listId = new List<Id> ();
        listId.add(agrupador.Id);
        
        CC_Agrupador_Rechazado.agrupadorRechazado(listId);
    }
}