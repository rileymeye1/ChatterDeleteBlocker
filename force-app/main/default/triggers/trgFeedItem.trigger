trigger trgFeedItem on FeedItem (before delete)
{
  if (Trigger.isBefore)
  {
    if (Trigger.isDelete)
    {
      if (!DisableChatterDeleteHandler.allowDelete())
      {
        for (FeedItem f : Trigger.old)
        {
          if (((String)f.ParentId).startsWith('00Q') && f.Type == 'TrackedChange')
          {
            // ok to ignore Lead Tracked Changes
          }
          else
          {
            f.addError('Your administrator has disabled feed post and comment deletions.');
          }
        }
      }
    }
  }
}