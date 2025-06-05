/**
*————————————————————————————————————————————————————
* @Name            CaseTriggerHandler
* @Author          from Vploavarapu
* @group TriggerHandler
*————————————————————————————————————————————————————
* @Description
* A class which  extends TriggerHandler
*————————————————————————————————————————————————————
* @Changes
*
**/
public class CaseTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        CaseModel.processCases(null, trigger.new);
    }
    
    public override void beforeUpdate() {
        CaseModel.processCases(trigger.oldMap, trigger.new);
    }
    
    public override void afterInsert() {
        CaseTriggerHelper.copyRecentEmailAddressFromParentToChild(null, trigger.new);  
    }
    
    public override void afterUpdate() {
      
       if(CaseModel.runOnce()){
           CaseModel.sendEmailToSME(trigger.oldmap, trigger.new);
           //CaseTriggerHelper.copyRecentEmailAddressFromParentToChild(trigger.oldmap, trigger.new);
       }  
    }  
}