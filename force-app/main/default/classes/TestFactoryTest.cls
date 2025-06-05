/**
*————————————————————————————————————————————————————
* @Name            TestFactoryTest
* @Author          from vpolavarpu
* @Description    using assertions to test Valid testdata
*
*————————————————————————————————————————————————————
* @Changes
*
**/

@IsTest
private  class TestFactoryTest {
    @IsTest
    public static void unitTest() {
        System.assert(TestFactory.returnEvents.size() >= 1);
        System.assert(TestFactory.returnUsers.size() >= 1);
        System.assert(TestFactory.returnAccounts.size() >= 1);
        System.assert(TestFactory.returnContentVersions.size() >= 1);
        System.assert(TestFactory.returnContact !=null);
    }
}