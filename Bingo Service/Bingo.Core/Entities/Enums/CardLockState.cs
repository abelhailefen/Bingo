namespace Bingo.Core.Entities.Enums
{
    public enum CardLockState
    {
        Available = 0,
        Reserved = 1,   // Soft Lock (Preview)
        Purchased = 2   // Hard Lock (Owned)
    }
}
