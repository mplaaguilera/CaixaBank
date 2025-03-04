public with sharing class DEMO_ValidateCode_AgentAction {

    @InvocableMethod(label='Validate OTP Code')
    public static List<Boolean> validateOtpCode(List<String> otpCodes) {
        List<Boolean> results = new List<Boolean>();
        for (String otpCode : otpCodes) {
            results.add(otpCode == '123456');
        }
        return results;
    }
}