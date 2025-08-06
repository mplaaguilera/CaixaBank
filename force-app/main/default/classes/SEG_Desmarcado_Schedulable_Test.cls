@isTest
public class SEG_Desmarcado_Schedulable_Test {
	@isTest 
    static void test() {
        SchedulableContext sc = null;
        SEG_DesmarcadoCarterizacion_Schedulable lbs = new SEG_DesmarcadoCarterizacion_Schedulable();
        lbs.execute(sc);
    }
}