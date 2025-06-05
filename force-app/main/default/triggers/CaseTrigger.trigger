trigger CaseTrigger on Case (before insert,after update, after insert,before update ) {
    new CaseTriggerHandler().run();
}