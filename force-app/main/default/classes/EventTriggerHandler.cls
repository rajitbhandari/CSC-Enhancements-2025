/**
*————————————————————————————————————————————————————
* @Name            EventTriggerHandler
* @Author          from Vploavarapu
*@group           TriggerHandler
*————————————————————————————————————————————————————
* @Description
* A trigger handler for Event Object
*
*————————————————————————————————————————————————————
* @Changes
*
**/

public class EventTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
       
      EventModel.processEvents(null, trigger.new);
    }
    
    public override void beforeUpdate() {
       EventModel.processEvents(Trigger.oldMap, Trigger.new);
    }
    
    public override void afterInsert() {
    
    }
    
    public override void afterUpdate() {
    
    }
    
}