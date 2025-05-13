@isTest
private class CC_CustomException_Test {
    @TestSetup
    static void makeData(){
        User adminUser = CC_TestDataFactory.insertUserAdmin();
    }
    @isTest
    static void testThrowAuraException() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
            try {
                CC_CustomException.throwAuraException('Test Aura Exception');       
            } catch (AuraHandledException e) {
                System.assertNotEquals('', e.getMessage(), 'Exception message should not be blank');
            }
            Test.stopTest();
        }
      
    }

    @isTest
    static void testThrowCustomException() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
                try {
                    CC_CustomException.throwCustomException('Test Custom Exception');         
                } catch (CC_CustomException e) {
                    System.assertEquals('Test Custom Exception', e.getMessage(), 'Exception message should match');
                }
            Test.stopTest();
        }
    
    }

    @isTest
    static void testThrowExceptionWithEmptyMessage() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
                try {
                    CC_CustomException.throwException('', false);     
                } catch (CC_CustomException e) {
                    System.assertEquals('Se ha producido un error inesperado.', e.getMessage(), 'Default exception message should be used');
                }
            Test.stopTest();
        }
       
    }
}