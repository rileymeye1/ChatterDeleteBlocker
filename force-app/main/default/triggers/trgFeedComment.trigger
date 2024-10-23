trigger trgFeedComment on FeedComment (before delete)
{
  if (Trigger.isBefore)
  {
    if (Trigger.isDelete)
    {
      if (!DisableChatterDeleteHandler.allowDelete())
      {
        for (FeedComment f : Trigger.old)
        {
            f.addError('Your administrator has disabled feed post and comment deletions.'); 
        }
      }
    }
  }
}