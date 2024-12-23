trigger TriggerHandler on SocialPost(Before insert) 
{
    LinkSocialPostToOriginalCase.Link(Trigger.New);
}