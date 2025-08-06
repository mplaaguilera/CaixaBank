@isTest
public class CC_Aviso_Coordinador_FAX_Test {
	@isTest
	public static void test_publicarToast() {
        
        //Insertamos caso
        Case caso = new Case();
        caso.Subject = 'caso test';
        insert caso;
        
        Case casoQuery = [SELECT Id, CaseNumber FROM Case WHERE Id = :caso.Id];
        
        Test.startTest();
        
        //Generamos lista y llamamos al método que publica el aviso al coordinador
        List<Case> casos = new List<Case>();
        casos.add(casoQuery);
        CC_Aviso_Coordinador_FAX.publicarToast(casos);
        
        Test.stopTest();
    }  
}