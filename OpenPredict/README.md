# OpenPredict
OpenPredict is an open-source library used to predict the best position to cast spells.

#####Core Functions:
  `GetPrediction(unit, { delay, speed, width, range, collision, source })`

All core functions used in OpenPredict return a predictInfo object:

```lua
  methods:
    predictInfo:setPredictPos()   -- Sets the mPredictPos member.
    predictInfo:setCastPos()      -- Sets the mCastPos member.

  members:
    predictInfo.x                 -- Self-explanatory.
    predictInfo.y                 -- Self-explanatory.
    predictInfo.z                 -- Self-explanatory.
    
    predictInfo.mCastPos          -- Best cast position.
    predictInfo.mPredictPos       -- Predicted position.
    predictInfo.mHitChance        -- Probability of skillshot hitting target (0.0f - 1.0f)
    predictInfo.mCollision        -- True if collision detected.
```

```lua
local pI = GetPrediction(unit, { delay = 0.25, speed = 2000, width = 50, range = 1000, collision = true, source = myHero })
```
