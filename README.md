# Serverside Usage:

```lua
  local Identifier = 'char1:12345678910'
  local PlayerName = 'John Doe'
  local Amount = 1000

  exports['mani-checks']:RegisterCheck({
    Identifier = Identifier,
    Name = PlayerName,
    Amount = Amount,
    InvId = Source
  })
```
