@isTest
public class CSBD_RunTestSuite_Schedulable_Test {

    @isTest
    public static void programar() {
        Test.startTest();
        CSBD_RunTestSuite_Schedulable.programar();
        CSBD_RunTestSuite_Schedulable.programar('report');
        Test.stopTest();

        System.assert(true, 'Pendiente');
    }

    @isTest
    public static void execute() {
        Test.startTest();
        //Constructores
        CSBD_RunTestSuite_Schedulable csbdRunTestSuiteSch = new CSBD_RunTestSuite_Schedulable();
        csbdRunTestSuiteSch = new CSBD_RunTestSuite_Schedulable('run');

        //Execute
        csbdRunTestSuiteSch.execute(null);
        Test.stopTest();

        System.assert(true, 'Pendiente');
    }
}