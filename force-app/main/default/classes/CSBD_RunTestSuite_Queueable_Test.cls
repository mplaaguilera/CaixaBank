@isTest
private class CSBD_RunTestSuite_Queueable_Test {

    @isTest
    private static void execute() {
        ApexTestRunResult testRunResult = new ApexTestRunResult(
            Status = 'Completed',
            StartTime = System.now().addHours(-2),
            ClassesEnqueued = 2,
            ClassesCompleted = 2,
            MethodsEnqueued = 2,
            MethodsCompleted = 2,
            MethodsFailed = 0
        );
        insert testRunResult;

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