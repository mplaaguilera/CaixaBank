public class CIBE_AccountTeamMember_AD_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<AccountTeamMember>)tp.newList, (Map<Id, AccountTeamMember>)tp.newMap, (List<AccountTeamMember>) tp.oldList, (Map<Id, AccountTeamMember>) tp.oldMap);
	}
	
	private void process(List<AccountTeamMember> listNewObj, Map<Id, AccountTeamMember> mapNewObj, List<AccountTeamMember> listOldObj, Map<Id, AccountTeamMember> mapOldObj) {
		List<AccountTeamMember> listData = CIBE_AccountTeamMemberTriggerHelper.checkGeneralRT(listOldObj);

        if (listData != null && !listData.isEmpty()) {
			CIBE_AccountTeamMemberTriggerHelper.setAccountUsers(listData);
		}
	}
    
}