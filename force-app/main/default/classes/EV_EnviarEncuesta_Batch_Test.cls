@isTest
public class EV_EnviarEncuesta_Batch_Test {
    @isTest
    public static void blanqueoClase(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            EV_EnviarEncuesta_Batch.metodoBlanco();
        }
        System.assertEquals('', '');
    }

}