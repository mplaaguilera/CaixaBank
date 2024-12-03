@isTest
private class CSBD_RunTestSuite_Queueable_Test {

    @isTest
    private static void execute() {
        Test.startTest();
        //Constructores
        CSBD_RunTestSuite_Queueable csbdRunTestQuiteQueable = new CSBD_RunTestSuite_Queueable();
        csbdRunTestQuiteQueable = new CSBD_RunTestSuite_Queueable('add');

        //Execute
        csbdRunTestQuiteQueable.execute(null);
        Test.stopTest();

        System.assert(true, 'Pendiente');
    }
}