@istest
public class CC_Consulta_RUC_Controller_Test {

    @istest
    public static void test() {   
    	List<Map<String,Object>> newMap = new List<Map<String,Object>>();
        
        newMap = CC_Consulta_RUC_Controller.ejecutarConsulta('12576341', '01/01/2018', '01/01/2019');
    }
    
    @istest
    public static void noData() {   
    	List<Map<String,Object>> newMap = new List<Map<String,Object>>();
        
        newMap = CC_Consulta_RUC_Controller.ejecutarConsulta('', '01/01/2018', '01/01/2019');
    }
    
}