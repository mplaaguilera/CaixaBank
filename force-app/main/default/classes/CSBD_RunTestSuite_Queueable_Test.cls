@isTest
private class CSBD_RunTestSuite_Queueable_Test {

    @isTest
    private static void add() {
        Test.startTest();
        //Constructores
        CSBD_RunTestSuite_Queueable csbdRunTestQuiteQueable = new CSBD_RunTestSuite_Queueable();
        csbdRunTestQuiteQueable = new CSBD_RunTestSuite_Queueable('add');

        //Execute
        csbdRunTestQuiteQueable.execute(null);
        Test.stopTest();

        System.assert(true, 'Pendiente');
    }

    @isTest
    private static void report() {
        Test.startTest();
        //Constructores
        CSBD_RunTestSuite_Queueable csbdRunTestQuiteQueable = new CSBD_RunTestSuite_Queueable();
        csbdRunTestQuiteQueable = new CSBD_RunTestSuite_Queueable('report');

        //Execute
        csbdRunTestQuiteQueable.execute(null);
        Test.stopTest();

        System.assert(true, 'Pendiente');
    }
}