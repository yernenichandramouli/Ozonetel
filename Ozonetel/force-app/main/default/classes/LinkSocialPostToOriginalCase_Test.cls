@isTest

Public Class LinkSocialPostToOriginalCase_Test
{
    Static TestMethod void method()
    {
        Case A=new case(Status='New',Origin='Facebook');
        insert A;
        
        SocialPost SP1=new SocialPost(Name='Post From: xxxx',ParentID=A.id);
        insert SP1;
        
        Case B=new Case(Status='New',Origin='Facebook');
        insert B;
        
        SocialPost SP2=new SocialPost(Name='Comment From:TEST',ParentID=B.id,ReplyToId=SP1.id);
        insert SP2;
    }
}